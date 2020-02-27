//
//  CheckoutStoryBoardConstants.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 06/06/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


class StoryboardConstants  {
    static let Filename  = "CheckoutStoryboard"
    
    static let SelectPaymentMethodController = "selectPaymentMethod"
    static let CreditCardViewController = "payWithCreditCard"
    static let CreditCardContentViewController = "payWithCreditCardContent"
    static let WebRedirectionViewController = "webRedirection"
    static let WebRedirectionContentViewController = "webRedirectionContent"
    static let CreditCardCvvHelpViewController = "cvvHelpViewController"
    
    static let SelectVendorSegue = "selectVendor"
    static let SelectCountrySegue = "selectCountry"
    static let ExternalRedirectionSegue = "externalRedirection"
    static let TdsRedirectionCancelledByUserSegue = "tdsRedirectionCancelledByUser"
    static let TdsRedirectionFailedSegue = "tdsRedirectionFailed"
    
    static let CreditCardBasicInputCell = "BasicInputCell"
    static let CreditCardDetailCell = "DetailCell"
    static let CreditCardVendorCell = "CardVendorCell"
    static let CreditCardNumberCell = "CardNumberCell"
    static let CreditCardExpiryCell = "ExpiryCell"
    static let CreditCardCvvCell = "CvvCell"
    static let CreditCardPayButtonCell = "PayButtonCell"
    
    static let PaymentMethodCCCell = "PaymentMethodCCCell"
    static let PaymentMethodAmopCell = "PaymentMethodAmopCell"
}


