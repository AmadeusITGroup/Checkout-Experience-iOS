//
//  Localization.swift
//  AmadeusCheckout
//
//  Created by Hela OTHMANI on 12/06/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation

enum LocalizableType {
    case label
    case button
    case error
    case errorField
    case hint
    case `default`
}

extension String {
    func localize(type: LocalizableType = .default) -> String{
        var key = ""
        switch type {
        case .label: key = "label_"+self
        case .button: key = "button_"+self
        case .errorField: key = "error_field_"+self
        case .error: key =  "label_error_"+self
        case .hint: key = "p"+self
        default: key =  self
        }
        if let overridenLabel = AMCheckoutLabels.getOverridenLocalizableString(forKey: key) {
            return overridenLabel
        }
        return FileTools.mainBundle.localizedString(forKey: key, value: nil, table: nil)
    }
}

protocol XIBLocalizable {
    var keyPath: String? { get set }
}

extension UILabel: XIBLocalizable {
    @IBInspectable var keyPath: String? {
        get { return nil }
        set(key) {
            text = key?.localize(type: .label)
        }
    }
}

extension UITextField: XIBLocalizable {
    /**
    Dynamically chose to set the `placeholder`  or the `attributedPlaceholder`, depending on the
    styles that are currently applied.
     */
    var smartPlaceholder: String? {
        get { return nil }
        set(value) {
            if attributedPlaceholder != nil {
                // If the placeholder has style attribute, we try to keep them
                attributedPlaceholder = NSAttributedString(string: value ?? "", attributes: attributedPlaceholder?.attributes(at: 0, effectiveRange: nil))
            } else {
                placeholder = value
            }
        }
    }
    
    @IBInspectable var keyPath: String? {
        get { return nil }
        set(key) {
            smartPlaceholder = key?.localize(type: .label)
        }
    }
}

extension UIButton: XIBLocalizable {
    @IBInspectable var keyPath: String? {
        get { return nil }
        set(key) {
            setTitle(key?.localize(type: .button), for: .normal)
        }
    }
}

extension UINavigationItem: XIBLocalizable {
    @IBInspectable var keyPath: String? {
        get { return nil }
        set(key) {
            self.title = key?.localize(type: .label)
        }
    }
}


extension UIBarButtonItem: XIBLocalizable {
    @IBInspectable var keyPath: String? {
        get { return nil }
        set(key) {
            self.title = key?.localize(type: .button)
        }
    }
}

