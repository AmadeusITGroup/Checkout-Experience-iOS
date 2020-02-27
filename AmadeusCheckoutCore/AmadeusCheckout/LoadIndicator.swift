//
//  LoadIndicator.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 28/06/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation

class LoadIndicator  {
    static var sharedInstance :LoadIndicator = {
        return LoadIndicator()
    }()
    
    let loadIndicatorViewController: UIViewController
    weak var hostViewController: UIViewController?
    
    
    init() {
        loadIndicatorViewController = UIAlertController(title: nil, message: "loading".localize(type:.label), preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loadingIndicator.style = UIActivityIndicatorView.Style.medium
        } else {
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
        }
        loadingIndicator.startAnimating()
        
        // In theory, the view hierarchy of UIAlertController is private,
        // but the following line seems to work well (tested until iOS 13).
        loadIndicatorViewController.view.addSubview(loadingIndicator)
    }
    
    func start(_ hostViewController: UIViewController, callback:@escaping () -> Void) {
        if self.hostViewController == nil {
            hostViewController.present(loadIndicatorViewController, animated: true, completion: callback)
            self.hostViewController = hostViewController
        }
    }
    
    func stop(callback:@escaping () -> Void) {
        if self.hostViewController != nil {
            hostViewController?.dismiss(animated: true, completion: callback)
            hostViewController = nil
        }
    }

}
