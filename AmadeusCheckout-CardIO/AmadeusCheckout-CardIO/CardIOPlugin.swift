//
//  CardIOPlugin.swift
//  AmadeusCheckout-CardIO
//
//  Created by Yann Armelin on 10/01/2020.
//  Copyright © 2020 Amadeus. All rights reserved.
//

import Foundation
import CardIO

#if !COCOAPODS
import AmadeusCheckout
#endif



@objc fileprivate class CardIOPluginDelegate: NSObject, CardIOPaymentViewControllerDelegate {
    weak var hostViewController: UIViewController?
    let callback: (AMScannedCard?) -> ()

    init(_ callback: @escaping (AMScannedCard?) -> ()) {
        self.callback = callback
        super.init()
    }
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        callback(nil)
        hostViewController?.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        let expiry = "\(String(format: "%02d", cardInfo.expiryMonth))/\(String(format: "%02d", cardInfo.expiryYear % 100))"
        callback(AMScannedCard(number:cardInfo.cardNumber, cvv:cardInfo.cvv, expiry: expiry))
        hostViewController?.dismiss(animated: true, completion: nil)
    }
}

fileprivate class CardIOPaymentWithCallbackViewController: CardIOPaymentViewController {
    var helper: CardIOPluginDelegate!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(_ callback: @escaping (AMScannedCard?) -> ()) {
        let callbackWrapper = CardIOPluginDelegate(callback)
        super.init(paymentDelegate: callbackWrapper, scanningEnabled: true)
        helper = callbackWrapper
        helper.hostViewController = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CardIOPlugin: AMScanCardPlugin {
    static func staticInit() {
        AMCheckoutPluginManager.sharedInstance.registerScanCardPlugin(CardIOPlugin())
    }
    
    func scanCard(host: UIViewController, callback: @escaping (AMScannedCard?) -> ()) {
        let cardIOViewController = CardIOPaymentWithCallbackViewController(callback)
        host.present(cardIOViewController, animated: true, completion: nil)
    }
}

