//
//  ViewController.swift
//  HostApp
//
//  Created by Yann Armelin on 09/01/2020.
//  Copyright © 2020 Amadeus. All rights reserved.
//

import UIKit
import AmadeusCheckout

class HostAppViewController: UIViewController, AMCheckoutDelegate {

    var checkoutCtx: AMCheckoutContext!
    @IBOutlet weak var resultField: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func pay(_ sender: Any) {
        checkoutCtx = AMCheckoutContext(ppid: "", environment:.mock)
        checkoutCtx.delegate = self
        checkoutCtx.hostViewController = self
        checkoutCtx.presentChoosePaymentMethodViewController()
    }
    
    func paymentContext(_ checkoutContext: AMCheckoutContext, didFinishWithStatus status: AMPaymentStatus, error: Error?) {
        switch status {
        case .success:
            print("Host application: Payment didFinishWithStatus 'success'")
            resultField.text = "Success"
        case .failure, .unknown:
            print("Host application: Payment didFinishWithStatus 'failure'")
            let statusStr = (status == .failure ? "Failure" : "Unknown")
            var errorType = ""
            var errorFeature = ""
            var code = -1
            if let error = error as NSError? {
                errorType = error.amErrorType.description
                errorFeature = error.amErrorFeature.description
                code = error.code
            }
            resultField.text = "\(statusStr)(\(code))\nType: \(errorType)\nFeature: \(errorFeature)"
        case .cancellation:
            print("Host application: Payment didFinishWithStatus 'cancellation'")
            resultField.text = "Cancellation"
        default: break
        }
        
        checkoutCtx = nil
    }
}

