//
//  UIAlertControllerUtils.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 30/08/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation

/*
 The purpose of CheckoutAlertController is to be be able to display a UIAlertController
 without the need of parent view controller.
 Warning: it's not a subclass of UIAlertController, because subclassing UIAlertController
   is not supported, and causes memory leaks.
 */
class CheckoutAlertController {
    var alertWindow: UIWindow? = nil
    var alertController: UIAlertController
    
    var dismissRequested = false
    
    public init(title: String?, message: String?, preferredStyle: UIAlertController.Style)
    {
        alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    func show() {
        show(animated: true)
    }
    
    func show(animated: Bool) {
        dismissRequested = false
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow?.rootViewController = UIViewController()
        
        let delegate = UIApplication.shared.delegate

        if let window = delegate?.window {
            // we inherit the main window's tintColor
            alertWindow?.tintColor = window?.tintColor
        }
        
        // window level is above the top window (this makes the alert, if it's a sheet, show over the keyboard)
        let topWindow = UIApplication.shared.windows.last
        alertWindow?.windowLevel = (topWindow?.windowLevel ?? UIWindow.Level(0)) + 1
        
        alertWindow?.makeKeyAndVisible()
        alertWindow?.rootViewController?.present(alertController, animated:animated, completion:{
            if self.dismissRequested {
                self.dismiss(animated: false, completion: nil)
            }
        })
    }
    
    func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if alertController.isBeingPresented {
            dismissRequested = true
        } else {
            alertController.dismiss(animated: flag, completion: completion)
            releaseWindow()
        }
    }
        
    func addAction(title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil)
    {
        alertController.addAction(UIAlertAction(title: title, style: style, handler: {[weak self] action in
            if let handler = handler {
                handler(action)
                self?.releaseWindow()
            }
        }))
    }
    
    var message: String? {
        set(value) {
            alertController.message = value
        }
        get {
            return alertController.message
        }
    }
    
    private func releaseWindow() {
        alertWindow?.isHidden = true
        alertWindow = nil
    }
}
