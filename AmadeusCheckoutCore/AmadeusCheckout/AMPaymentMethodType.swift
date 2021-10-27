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
    case alternativeMethodOfPaymentBoost
    case alternativeMethodOfPaymentCimbclicks
    case alternativeMethodOfPaymentFpx
    case alternativeMethodOfPaymentGrabpay
    case alternativeMethodOfPaymentInstallment
    case alternativeMethodOfPaymentMaybank
    case alternativeMethodOfPaymentTouchngo
    case alternativeMethodOfPaymentHumm
    case alternativeMethodOfPaymentPoli
    case alternativeMethodOfPaymentFnpl
    
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
            case "label_amop_boost": return .alternativeMethodOfPaymentBoost
            case "label_amop_cimbclicks": return .alternativeMethodOfPaymentCimbclicks
            case "label_amop_fpx": return .alternativeMethodOfPaymentFpx
            case "label_amop_grabpay": return .alternativeMethodOfPaymentGrabpay
            case "label_amop_installmentpayment": return .alternativeMethodOfPaymentInstallment
            case "label_amop_maybank": return .alternativeMethodOfPaymentMaybank
            case "label_amop_touchngo": return .alternativeMethodOfPaymentTouchngo
            case "label_amop_humm": return .alternativeMethodOfPaymentHumm
            case "label_amop_poli": return .alternativeMethodOfPaymentPoli
            case "label_amop_fnpl": return .alternativeMethodOfPaymentFnpl
                
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
        case .alternativeMethodOfPaymentBoost: return "Boost"
        case .alternativeMethodOfPaymentCimbclicks: return "CIMB Clicks"
        case .alternativeMethodOfPaymentFpx: return "FPX"
        case .alternativeMethodOfPaymentGrabpay: return "GrabPay"
        case .alternativeMethodOfPaymentInstallment: return "Instalment payment"
        case .alternativeMethodOfPaymentMaybank: return "Maybank2u"
        case .alternativeMethodOfPaymentTouchngo: return "TouchnGO"
        case .alternativeMethodOfPaymentHumm: return "Humm"
        case .alternativeMethodOfPaymentPoli: return "Poli"
        case .alternativeMethodOfPaymentFnpl: return "FlyNow PayLater"
            
        case .alternativeMethodOfPayment: return "External Payment"
        }
    }
}
