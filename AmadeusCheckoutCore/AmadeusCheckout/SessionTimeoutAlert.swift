//
//  LoadIndicator.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 28/06/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let AMRequestSessionTimeoutAlert = NSNotification.Name("AMRequestSessionTimeoutAlert")
    static let AMRequestSessionTimeoutCancelPayment = NSNotification.Name("AMRequestSessionTimeoutCancelPayment")
}


/*
 This class is reponsible of displaying an alert if the session is about to expire.
 To display the session timeout alert, a NSNotification.AMRequestSessionTimeoutAlert event has to be posted.
 Then if the user chooses to:
 - Continue: the alert is discarded, and won't be displayed again
 - Cancel: a NSNotification.AMRequestSessionTimeoutCancelPayment is posted
 
 For this mechanism to work, a call to SessionTimeoutAlert.initialize() is required.
*/
class SessionTimeoutAlert  {
    static var sharedInstance: SessionTimeoutAlert!
    
    var wasAlertDisplayed = false
    var isAlertDisplayed = false
    var alertController: CheckoutAlertController?
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.sessionTimeoutAlertRequested(_:)),
            name: NSNotification.Name.AMRequestSessionTimeoutAlert,
            object: nil
        )
    }
    
    deinit {
    }
    
    static func initialize() {
        sharedInstance = SessionTimeoutAlert()
    }
    
    func shutdown() {
        if isAlertDisplayed {
            alertController?.dismiss(animated: false, completion: nil)
            alertController = nil
        }
        SessionTimeoutAlert.sharedInstance = nil
    }
    
    fileprivate func formatRemainingSeconds(_ sec: Int) -> String {
        let minutes = sec / 60
        let seconds = String(format:"%02d" , sec % 60)
        return "\(minutes):\(seconds)"
    }
    
    fileprivate func presentSessionTimeoutAlert(remainingSeconds : Int) {
        let message = "session_will_expire".localize(type: .error).replacingOccurrences(of: "{0}", with: formatRemainingSeconds(remainingSeconds))
        alertController = CheckoutAlertController(title: "warning".localize(type: .label), message: message, preferredStyle: .alert)
        alertController!.addAction(title: "continue".localize(type: .button), style: .default) {[weak self] _ in self?.completionHandler(cancelRequested: false) }
        alertController!.addAction(title: "cancel_payment".localize(type: .button), style: .cancel) {[weak self]  _ in self?.completionHandler(cancelRequested: true)}
        alertController!.show()
    }
    
    fileprivate func updateSessionTimeoutAlert(remainingSeconds : Int) {
        alertController?.message = "session_will_expire".localize(type: .error).replacingOccurrences(of: "{0}", with: formatRemainingSeconds(remainingSeconds))
    }
    
    fileprivate func completionHandler(cancelRequested: Bool) {
        isAlertDisplayed = false
        alertController = nil
        if cancelRequested {
            NotificationCenter.default.post(name:NSNotification.Name.AMRequestSessionTimeoutCancelPayment, object: AMCheckoutContext.sharedContext)
        }
    }
    
    @objc fileprivate func sessionTimeoutAlertRequested(_ notif: Notification) {
        var remainingSeconds = 0
        if let expires_in = notif.userInfo?["expires_in"] as? NSNumber {
            remainingSeconds = expires_in.intValue
        }
        if remainingSeconds<=0 {
            return
        }
        
        if !wasAlertDisplayed {
            wasAlertDisplayed = true
            isAlertDisplayed = true
            presentSessionTimeoutAlert(remainingSeconds: remainingSeconds)
        } else if isAlertDisplayed {
            updateSessionTimeoutAlert(remainingSeconds: remainingSeconds)
        }
    }
}
