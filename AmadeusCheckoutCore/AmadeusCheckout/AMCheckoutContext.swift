//
//  AMPaymentStatus.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 04/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import UIKit

@objc public protocol AMCheckoutDelegate : class {
    @objc optional func paymentContext(_ checkoutContext: AMCheckoutContext, didFinishWithStatus status: AMPaymentStatus, error: Error?)
}

extension NSNotification.Name {
    static let AMBackFromRedirection = NSNotification.Name("AMBackFromRedirection")
}

@objcMembers public class AMConstants: NSObject {
    public static let AmadeusCheckoutDomain = "com.amadeus.ios.AmadeusCheckout"
    public static let ErrorTypeKey = "com.amadeus.ios.AmadeusCheckout:ErrorType"
    public static let ErrorFeatureKey = "com.amadeus.ios.AmadeusCheckout:ErrorFeature"
}



public class AMCheckoutContext : NSObject {
    static weak var sharedContext: AMCheckoutContext? = nil

    @objc public weak var delegate: AMCheckoutDelegate?
    @objc public var hostViewController: UIViewController?
    @objc public let ppid: String
    
    var dataModel: PaymentPageDataModel?
    var options: AMCheckoutOptions!
    var viewController: UIViewController?
    var sessionObserver: NSKeyValueObservation?
    var hasBeenClosed = false
    
    @objc public init(ppid: NSString?, environment: AMEnvironment = .prd) {
        self.ppid = ppid as String? ?? ""
        
        var env: Environment!
        switch environment {
        case .pdt: env = .pdt
        case .uat: env = .uat
        case .prd: env = .prd
        case .mock: env = .mock
        default: fatalError("Unknown environment")
        }
        
        self.dataModel = PaymentPageDataModel(ppid: self.ppid, environement:env)
        
        super.init()
        
        
        initContext()
    }
    
    
    func checkSharedContext() {
        assert(AMCheckoutContext.sharedContext == self, "Cannot handle several AMCheckoutContext at the same time")
    }
    
    
    @objc public func presentChoosePaymentMethodViewController(options: AMCheckoutOptions = AMCheckoutOptions()) {
        checkSharedContext();
        
        guard let host = hostViewController else {
            return
        }

        LoadIndicator.sharedInstance.start(host) {[weak self] in
            self?.dataModel?.triggerLoad(responseHandler: {[weak self] in
                LoadIndicator.sharedInstance.stop() {
                    if self?.dataModel?.paymentMethods.count == 1 {
                        // If there is only 1 method of payment, we can select it immediately
                        let mop = (self?.dataModel?.paymentMethods.first)!
                        self?.presentPaymentViewController(AMPaymentMethod(paymentMethodType:AMPaymentMethodType.make(from: mop) ,name:mop.name, identifier:mop.id), options:options)
                    } else {
                        // Otherwise we let use chose
                        self?.start(viewControllerIdentifier:StoryboardConstants.SelectPaymentMethodController , options: options)
                    }
                }
            }, failureHandler: {[weak self] error in
                LoadIndicator.sharedInstance.stop() {[weak self] in
                    if error == .technicalNetworkFailure || error == .technicalUnreachableNetwork {
                        self?.closeWithStatus(.failure, error: NSError.checkoutError(type:.networkFailure, feature:.loadMethodOfPayments))
                    } else {
                        self?.closeWithStatus(.failure, error: NSError.checkoutError(type:.unexpectedError, feature:.loadMethodOfPayments))
                    }
                }
            })
        }
    }
    

    @objc public func fetchPaymentMethods(callback: @escaping ([AMPaymentMethod]?) -> Void) {
        checkSharedContext();
        
        dataModel?.triggerLoad(responseHandler: {[weak self] in
            if self != nil {
                var paymentMethods: [AMPaymentMethod] = []
                for mop in self?.dataModel?.paymentMethods ?? [] {
                    paymentMethods.append(AMPaymentMethod(paymentMethodType:AMPaymentMethodType.make(from: mop) ,name:mop.name, identifier:mop.id))
                }
                callback(paymentMethods)
            }
        }, failureHandler: {[weak self] error in
            if self != nil {
                callback(nil)
                if error == .technicalNetworkFailure || error == .technicalUnreachableNetwork {
                    self?.closeWithStatus(.failure, error: NSError.checkoutError(type:.networkFailure, feature:.loadMethodOfPayments))
                } else {
                    self?.closeWithStatus(.failure, error: NSError.checkoutError(type:.unexpectedError, feature:.loadMethodOfPayments))
                }
            }
        })
    }
    
    @objc public func presentPaymentViewController(_ methodOfPayment: AMPaymentMethod, options: AMCheckoutOptions = AMCheckoutOptions()) {
        checkSharedContext();
        
        guard let _ = hostViewController , let dataModel = dataModel else {
            return
        }
        
        let realMethodOfPayment = dataModel.paymentMethods.first(where: { $0.id == methodOfPayment.identifier })
        assert(realMethodOfPayment != nil, "Payment method not found")
        dataModel.selectedPaymentMethod = realMethodOfPayment
        
        switch realMethodOfPayment?.view {
        case "creditcard":
            start(viewControllerIdentifier: StoryboardConstants.CreditCardViewController, options: options)
        default:
            start(viewControllerIdentifier:StoryboardConstants.WebRedirectionViewController, options: options)
        }
    }
    
    private func start(viewControllerIdentifier: String, options: AMCheckoutOptions) {
        self.options = options
        Theme.sharedInstance.importOptions(options)
        dataModel!.dynamicVendor = options.dynamicVendor
        dataModel!.appCallbackScheme = options.appCallbackScheme
        
        sessionObserver = dataModel!.observe(\.sessionTimeout.expiresIn, changeHandler: { [weak self] expiresIn, change in
            if let expires_in = expiresIn.sessionTimeout.expiresIn {
                if expires_in.intValue <= 300 {
                    NotificationCenter.default.post(
                        name:NSNotification.Name.AMRequestSessionTimeoutAlert,
                        object: AMCheckoutContext.sharedContext,
                        userInfo: ["expires_in": expires_in]
                    )
                }
                if expires_in.intValue < 0 {
                    self?.closeWithStatus(.unknown, error: NSError.checkoutError(type:.sessionTimeout, feature:.none))
                }
            }
        })
        
        let storyBoard = UIStoryboard(name:StoryboardConstants.Filename, bundle: FileTools.mainBundle)
        viewController = storyBoard.instantiateViewController(withIdentifier:viewControllerIdentifier)
        viewController?.modalPresentationStyle = options.paymentControllerPresentationStyle
        
        if #available(iOS 13.0, *) { viewController?.isModalInPresentation = true }
        hostViewController!.present(viewController!, animated: true, completion: nil)
    }
    
    @objc static public func handleUrl(_ url: URL) -> Bool {
        // We are back from a redirection, the URL format is expected to be:
        //    "\(options.appCallbackScheme)://\(ppid)"
        // If the PPID matches the PPID of the current context, we post an event
        // that we trigger a verification of the opened redirection.

        let scheme = url.scheme ?? ""
        let receivedPpid = url.absoluteString[scheme.count+3, nil]
        let currentPpid = AMCheckoutContext.sharedContext?.ppid
        if currentPpid == receivedPpid {
            NotificationCenter.default.post(name:NSNotification.Name.AMBackFromRedirection, object: AMCheckoutContext.sharedContext)
            return true
        }
        return false
    }
    
    func closeWithStatus(_ status: AMPaymentStatus, error: Error?) {
        if AMCheckoutContext.sharedContext == self && !hasBeenClosed {
            AMCheckoutContext.sharedContext?.delegate?.paymentContext?(AMCheckoutContext.sharedContext!, didFinishWithStatus:status, error:error)
            cleanContext()
        }
    }
    
    private func initContext() {
        if let previousContext = AMCheckoutContext.sharedContext, !previousContext.hasBeenClosed {
            previousContext.cleanContext()
        }

        AMCheckoutPluginManager.sharedInstance.initializePlugins()
        AMCheckoutContext.sharedContext = self
        NetworkAlert.initialize()
        SessionTimeoutAlert.initialize()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleSessionTimeoutCancel),
            name: NSNotification.Name.AMRequestSessionTimeoutCancelPayment,
            object: nil
        )
    }
    
    @objc private func handleSessionTimeoutCancel() {
        closeWithStatus(.cancellation, error: nil)
    }
    
    private func cleanContext() {
        hasBeenClosed = true
        sessionObserver = nil
        
        NetworkTaskQueue.sharedInstance.cancelTasks()
        NetworkAlert.sharedInstance.shutdown()
        SessionTimeoutAlert.sharedInstance.shutdown()
        
        NotificationCenter.default.removeObserver(self)
        
        viewController?.presentingViewController?.dismiss(animated: true, completion: {
            AMCheckoutContext.sharedContext = nil
            
            /** **Workaround for iOS 10 Bug:**
             * On iOS 10, Observers has to be removed before the Observed.
             * The following line ensures the view controller is the first member of this class to be
             * deleted.
             * It also retains the `self` pointer, so that it's cannot be deleted before the end of
             * the closing animation.
             */
            DispatchQueue.main.async { self.viewController = nil }
        })
    }
}

