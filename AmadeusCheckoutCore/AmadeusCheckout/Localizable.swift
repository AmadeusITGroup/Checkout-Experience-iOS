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
        switch type {
        case .label:
            return FileTools.mainBundle.localizedString(forKey: "label_"+self, value: nil, table: nil)
        case .button:
            return FileTools.mainBundle.localizedString(forKey: "button_"+self, value: nil, table: nil)
        case .errorField:
            return FileTools.mainBundle.localizedString(forKey: "error_field_"+self, value: nil, table: nil)
        case .error:
            return FileTools.mainBundle.localizedString(forKey: "label_error_"+self, value: nil, table: nil)
        case .hint:
            return FileTools.mainBundle.localizedString(forKey: "p"+self, value: nil, table: nil)
        default:
            return FileTools.mainBundle.localizedString(forKey: self, value: nil, table: nil)
        }
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

