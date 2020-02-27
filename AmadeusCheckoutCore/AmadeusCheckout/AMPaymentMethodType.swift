//
//  AMPaymentMethodType.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 24/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


@objc public enum AMPaymentMethodType : Int {
    case paymentCard
    case alternativeMethodOfPaymentKnet
    case alternativeMethodOfPaymentPaypal
    case alternativeMethodOfPaymentKlarna
    case alternativeMethodOfPaymentSofort
    case alternativeMethodOfPaymentBancontact
    case alternativeMethodOfPaymentNordea
    case alternativeMethodOfPaymentSeb
    case alternativeMethodOfPaymentSwish
    case alternativeMethodOfPaymentAlipay
    case alternativeMethodOfPaymentCup
    case alternativeMethodOfPaymentWechat
    case alternativeMethodOfPaymentIdeal
    case alternativeMethodOfPayment
    
    static func make(from mop: PaymentMethod) -> AMPaymentMethodType {
        if mop.view == "creditcardTok" || mop.view == "creditcard" {
            return .paymentCard
        } else {
            switch mop.name {
            case "label_amop_knet": return .alternativeMethodOfPaymentKnet
            case "label_amop_paypal": return .alternativeMethodOfPaymentPaypal
            case "label_amop_klarna": return .alternativeMethodOfPaymentKlarna
            case "label_amop_sofort": return .alternativeMethodOfPaymentSofort
            case "label_amop_bancontact": return .alternativeMethodOfPaymentBancontact
            case "label_amop_nordea": return .alternativeMethodOfPaymentNordea
            case "label_amop_seb": return .alternativeMethodOfPaymentSeb
            case "label_amop_swish": return .alternativeMethodOfPaymentSwish
            case "label_amop_alipay": return .alternativeMethodOfPaymentAlipay
            case "label_amop_cup": return .alternativeMethodOfPaymentCup
            case "label_amop_wechat": return .alternativeMethodOfPaymentWechat
            case "label_amop_ideal": return .alternativeMethodOfPaymentIdeal
            default: return .alternativeMethodOfPayment
            }
        }
    }
    
    public var description: String {
        switch self {
        case .paymentCard: return "Payment card"
        case .alternativeMethodOfPaymentKnet: return "KNET"
        case .alternativeMethodOfPaymentPaypal: return "PayPal"
        case .alternativeMethodOfPaymentKlarna: return "Klarna"
        case .alternativeMethodOfPaymentSofort: return "Sofort"
        case .alternativeMethodOfPaymentBancontact: return "Bancontact"
        case .alternativeMethodOfPaymentNordea: return "Nordea"
        case .alternativeMethodOfPaymentSeb: return "SEB"
        case .alternativeMethodOfPaymentSwish: return "Swish"
        case .alternativeMethodOfPaymentAlipay: return "Aliapy"
        case .alternativeMethodOfPaymentCup: return "China UnionPay"
        case .alternativeMethodOfPaymentWechat: return "WeChat"
        case .alternativeMethodOfPaymentIdeal: return "iDEAL"
        case .alternativeMethodOfPayment: return "External Payment"
        }
    }
}
