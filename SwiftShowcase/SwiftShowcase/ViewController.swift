//
//  ViewController.swift
//  AmadeusCheckoutShowcase
//
//  Created by Yann Armelin on 04/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import UIKit
import AmadeusCheckout




class ViewController: UIViewController, AMCheckoutDelegate {
    
    var checkoutCtx: AMCheckoutContext!
    var paymentMethods: [AMPaymentMethod] = []
    var selectedMethod: AMPaymentMethod?
    
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var selectedMopText: UITextField!
    @IBOutlet weak var selectedMopPicker: UIPickerView!
    @IBOutlet weak var ppidTextField: UITextField!
    @IBOutlet weak var resultField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let picker: UIPickerView
        picker = UIPickerView(frame: CGRect(x:0, y:200, width:view.frame.width, height:300))
        selectedMopPicker = picker
        picker.delegate = self
        picker.dataSource = self
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y:0, width: 100, height: 20))
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(payWithSelectedMethod(_:)))
        doneButton.accessibilityIdentifier = "select_mop"
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        selectedMopText.inputView = picker
        selectedMopText.inputAccessoryView = toolBar
    }
    
    func paymentContext(_ checkoutContext: AMCheckoutContext, didFailToLoadWithError error: Error) {
        print("Host application: Payment didFailToLoadWithError")
        resultField.text = "Loading issue"
        
        checkoutCtx = nil
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
        }
        
        checkoutCtx = nil
    }
    
    @IBAction func pay(_ sender: Any) {
        let ppid = ppidTextField.text as NSString?
        checkoutCtx = AMCheckoutContext(ppid: ppid, environment:ppid == "" ? .mock : .pdt)
        checkoutCtx.delegate = self
        checkoutCtx.hostViewController = self
        checkoutCtx.presentChoosePaymentMethodViewController(options: OptionsViewController.options)
    }
    
    @IBAction func fetchPaymentMethods(_ sender: Any) {
        selectedMethod = nil
        selectedMopText.resignFirstResponder()

        
        let ppid = ppidTextField.text as NSString?
        checkoutCtx = AMCheckoutContext(ppid: ppid, environment:ppid == "" ? .mock : .pdt)
        checkoutCtx.delegate = self
        checkoutCtx.hostViewController = self
        checkoutCtx.fetchPaymentMethods(callback: {[weak self] methods in
            if let methods = methods, methods.count > 0 {
                self?.paymentMethods = methods
                self?.selectedMethod = methods.first
                
                self?.selectedMopPicker.reloadAllComponents()
                self?.selectedMopPicker.selectRow(0, inComponent: 0, animated: false)
                self?.selectedMopText.becomeFirstResponder()
            }
        })
    }

    @IBAction func payWithSelectedMethod(_ sender: Any) {
        selectedMopText.resignFirstResponder();
        checkoutCtx.presentPaymentViewController(selectedMethod!, options: OptionsViewController.options)
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK UIPickerViewDataSource, UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return paymentMethods.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if paymentMethods[row].paymentMethodType == .alternativeMethodOfPayment {
            return paymentMethods[row].name
        } else {
            return paymentMethods[row].paymentMethodType.description
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedMethod = paymentMethods[row]
    }
}
