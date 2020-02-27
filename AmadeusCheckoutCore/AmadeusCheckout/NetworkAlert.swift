//
//  LoadIndicator.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 28/06/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let AMRequestNetworkAlert = NSNotification.Name("AMRequestNetworkAlert")
    static let AMRequestNetworkRetry = NSNotification.Name("AMRequestNetworkRetry")
    static let AMRequestNetworkCancel = NSNotification.Name("AMRequestNetworkCancel")
}

/*
 This class is reponsible of displaying an Alert if network is unreachable.
 To display the network alert, a NSNotification.AMRequestNetworkAlert event has to be posted.
 Then if the user chooses to:
 - Retry: a NSNotification.AMRequestNetworkRetry is posted
 - Cancel: a NSNotification.AMRequestNetworkCancel is posted
 
 For this mechanism to work, a call to NetworkAlert.initialize() is required.
*/
class NetworkAlert  {
    static var sharedInstance: NetworkAlert!
    
    var isAlertDisplayed = false
    var alertController: CheckoutAlertController?
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.networkAlertRequested),
            name: NSNotification.Name.AMRequestNetworkAlert,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    static func initialize() {
        sharedInstance = NetworkAlert()
    }
    
    func shutdown() {
        if isAlertDisplayed {
            alertController?.dismiss(animated: false, completion: nil)
            alertController = nil
        }
        NetworkAlert.sharedInstance = nil
    }
    
    fileprivate func presentNetworkAlert() {
        alertController = CheckoutAlertController(title: "error".localize(type: .label), message: "unreachable_network".localize(type: .error), preferredStyle: .alert)
        alertController!.addAction(title: "retry".localize(type: .button), style: .default) {[weak self] _ in self?.completionHandler(retryRequested: true) }
        alertController!.addAction(title: "cancel_payment".localize(type: .button), style: .cancel) {[weak self]  _ in self?.completionHandler(retryRequested: false)}
        alertController!.show()
    }
    
    fileprivate func completionHandler(retryRequested: Bool) {
        isAlertDisplayed = false
        alertController = nil
        if retryRequested {
            NotificationCenter.default.post(name:NSNotification.Name.AMRequestNetworkRetry, object: AMCheckoutContext.sharedContext)
        } else {
            NotificationCenter.default.post(name:NSNotification.Name.AMRequestNetworkCancel, object: AMCheckoutContext.sharedContext)
        }
    }
    
    @objc fileprivate func networkAlertRequested() {
        if !isAlertDisplayed {
            isAlertDisplayed = true
            presentNetworkAlert()
        }
    }
}
