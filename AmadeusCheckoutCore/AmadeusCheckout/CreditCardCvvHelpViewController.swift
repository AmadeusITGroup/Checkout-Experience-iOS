//
//  CreditCardCvvHelpViewController.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 19/11/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation




class CreditCardCvvHelperOkButton: UIButton {
    override open var isHighlighted: Bool {
        didSet {
            if #available(iOS 13.0, *) {
                backgroundColor = isHighlighted ? UIColor.systemFill : nil
            } else {
                backgroundColor = isHighlighted ? UIColor(white: 0.47, alpha: 0.2) : nil
            }
        }
    }
}

class CreditCardCvvHelpViewController: UIViewController {
    enum CvvType {
        case generic
        case amex
    }
    
    @IBOutlet private var alertView: UIVisualEffectView!
    @IBOutlet private var okButton: UIButton!
    @IBOutlet private var helpImage: UIImageView!
    
    var type: CvvType?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        providesPresentationContextTransitionStyle = true
        definesPresentationContext = true
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
        alertView.clipsToBounds = true
        
        alertView.backgroundColor = UIColor.white
        if #available(iOS 11.0, *) {
            alertView.backgroundColor = UIColor.clear
        }
        if #available(iOS 13.0, *) {
            alertView.effect = UIBlurEffect(style: .systemThickMaterial)
        }
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.20)
        
        switch type {
        case .amex: helpImage.image = UIImage(named: "cvv_amex", in: FileTools.mainBundle, compatibleWith: nil)
        default: helpImage.image = UIImage(named: "cvv", in: FileTools.mainBundle, compatibleWith: nil)
        }
    }
    
    func animateView() {
        self.alertView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.alertView.transform = CGAffineTransform.identity
        })
    }
    
    @IBAction func onTapOkButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
