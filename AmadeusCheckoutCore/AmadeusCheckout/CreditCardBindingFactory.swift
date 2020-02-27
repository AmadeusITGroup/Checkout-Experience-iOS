//
//  CreditCardBindingFactory.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 08/08/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


class CreditCardBindingFactory {
    // MARK: Internal helpers
    private func createAmountBinding<ModelType:NSObject, ValueType>(_ target:ModelType, keyPath: KeyPath<ModelType, ValueType>) -> [DataModelBinding] {
        let binding = DataModelBinding(target, keyPath: keyPath)
        binding.genericFormatter = {(amount) in
            if let amount = amount as? Amount {
                return Translator.formatAmount(amount.value, currency: amount.currency)
            }
            return ""
        }
        return [binding]
    }
    private func createFieldBinding<ModelType:NSObject, ValueType>(_ target:ModelType, keyPath: KeyPath<ModelType, ValueType>, required: Bool, minLen: Int?, maxLen: Int?) -> [DataModelBinding] {
        let binding = DataModelBinding(target, keyPath: keyPath)
        binding.validator = ValidatorFactory.requiredMinMaxLength(required, minLen, maxLen).create()
        return [binding]
    }
    
    // MARK: Public binding initializers
    func createAmountBindings(rootModel: PaymentPageDataModel) -> [DataModelBinding] {
        return createAmountBinding(rootModel, keyPath: \.totalAmount)
    }
    func createObfeesBindings(rootModel: PaymentPageDataModel) -> [DataModelBinding] {
        return createAmountBinding(rootModel, keyPath: \.obFeeAmount)
    }
    func createVendorBindings(model: CreditCardPaymentMethod) -> [DataModelBinding] {
        let binding = DataModelBinding(model, keyPath: \.vendor.id)
        binding.formatter = {(vendorCode) in
            return !vendorCode.isEmpty ? "vendor_"+vendorCode : ""
        }
        return [binding]
    }
    func createExpiryBindings(model: CreditCardPaymentMethod) -> [DataModelBinding] {
        let fieldBinding = DataModelBinding(model, keyPath: \.expiryDate)
        let pickerBinding = DataModelBinding(model, keyPath: \.expiryDate)
        pickerBinding.validator = ValidatorFactory.expiryDate.create()
        return [fieldBinding, pickerBinding]
    }
    func createCardHoldernameBindings(model: CreditCardPaymentMethod) -> [DataModelBinding] {
        return createFieldBinding(model, keyPath: \.cardHolderName, required: true, minLen: nil, maxLen: 50)
    }
    func createCardNumberBindings(rootModel: PaymentPageDataModel, model: CreditCardPaymentMethod, dynamic: Bool) -> [DataModelBinding] {
        let ccnBinding = DataModelBinding(model, keyPath: \.creditCardNumber)
        ccnBinding.validator = ValidatorFactory.ccNum.create()
        ccnBinding.formatter = { CardFormatter.format($0) }
        ccnBinding.parser = { CardFormatter.unformat($0) }
        
        let obFeesBinding = DataModelBinding(rootModel, keyPath: \.obFeeAmount)
        obFeesBinding.genericFormatter = {(amount) in
            if let amount = amount as? Amount, amount.value>0 {
                let fees = Translator.formatAmount(amount.value, currency: amount.currency)
                return "obFees".localize(type: .label).replacingOccurrences(of: "{0}", with: fees)
            }
            return ""
        }
        
        let placeHolderBinding = DataModelBinding(model, keyPath: \.vendor.id)
        placeHolderBinding.formatter = {(vendorCode) in
            return CardFormatter.placehodlerCardSplit(for: vendorCode)
                    .map { String(repeating: "0", count:$0) }
                    .joined(separator: " ")
        }
        
        if dynamic {
            // We add the binding between Card number cell and vendor ID only in case of dynamic BIN.
            // In non dynamic mode, vendor is displayed in another cell.
            return [ccnBinding, obFeesBinding, placeHolderBinding] + createVendorBindings(model: model)
        } else {
            return [ccnBinding, obFeesBinding, placeHolderBinding]
        }
    }
    func createCvvBindings(model: CreditCardPaymentMethod) -> [DataModelBinding] {
        let valueBinding = DataModelBinding(model, keyPath: \.cvv)
        valueBinding.validator = ValidatorFactory.cvv.create()
        
        let placeHolderBinding = DataModelBinding(model, keyPath: \.vendor.id)
        placeHolderBinding.formatter = {(vendorCode) in
            return String(repeating: "0", count: CardFormatter.cvvLength(for: vendorCode))
        }
        
        return [valueBinding, placeHolderBinding]
    }
    func createAddressLine1Bindings(model: CreditCardPaymentMethod, required: Bool) -> [DataModelBinding] {
        return createFieldBinding(model, keyPath: \.billingAddress?.billAddressLine1, required: required, minLen: nil, maxLen: 100)
    }
    func createAddressLine2Bindings(model: CreditCardPaymentMethod, required: Bool) -> [DataModelBinding] {
        return createFieldBinding(model, keyPath: \.billingAddress?.billAddressLine2, required: required, minLen: nil, maxLen: 100)

    }
    func createAddressZipCodeBindings(model: CreditCardPaymentMethod, required: Bool) -> [DataModelBinding] {
        return createFieldBinding(model, keyPath: \.billingAddress?.zipCode, required: required, minLen: nil, maxLen: nil)
    }
    func createAddressCountryBindings(rootModel: PaymentPageDataModel, model: CreditCardPaymentMethod, required: Bool) -> [DataModelBinding] {
        let binding = DataModelBinding(model, keyPath: \.billingAddress?.country)
        binding.validator = ValidatorFactory.requiredMinMaxLength(required, nil, nil).create()
        binding.formatter = {(countryCode) in
            return !countryCode.isEmpty ? rootModel.getCountryLabel(countryCode:countryCode)  : ""
        }
        return [binding]
    }
    func createAddressCityBindings(model: CreditCardPaymentMethod, required: Bool) -> [DataModelBinding] {
        return createFieldBinding(model, keyPath: \.billingAddress?.city, required: required, minLen: nil, maxLen: 30)
    }
}
