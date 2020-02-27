//
//  KeyboardToolbar.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 09/07/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import UIKit



enum KeyboardToolbarButton: Int {
    case done = 0
    case back
    case forward
    case scan
}

protocol KeyboardToolbarDelegate: class {
    func keyboardToolbar(button: UIBarButtonItem, type: KeyboardToolbarButton, tappedIn toolbar: KeyboardToolbar)
}

class KeyboardToolbar: UIToolbar {
    weak var toolBarDelegate: KeyboardToolbarDelegate?
    
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    var scanButton: UIBarButtonItem!
    
    var barButtonItemGroup: UIBarButtonItemGroup!
    
    var height: CGFloat {
        // On iPad it's not possible to know the height of the inputAssistantItem
        // so we return an hardcoded value.
        return UIDevice.current.userInterfaceIdiom == .pad ? 55 : frame.size.height
    }
    
    init() {
        super.init(frame: CGRect(x:0, y:0, width:100, height:20))
        barStyle = UIBarStyle.default
        isTranslucent = true
        sizeToFit()
        
        isUserInteractionEnabled = true
        backButton = makeButton(.back, icon:UIBarButtonItem.SystemItem(rawValue: 103), fallbackTitle:"▲", accessibilityIdentifier:"keyboard_previous")
        forwardButton = makeButton(.forward, icon:UIBarButtonItem.SystemItem(rawValue: 104), fallbackTitle:"▼", accessibilityIdentifier:"keyboard_next")
        doneButton = makeButton(.done, icon:.done, fallbackTitle:nil, accessibilityIdentifier:"keyboard_done")
        scanButton = makeButton(.scan, icon:nil, fallbackTitle:"scan_card".localize(type: .label), accessibilityIdentifier:"keyboard_scan")
    }
    
    private func makeButton(_ type: KeyboardToolbarButton, icon:UIBarButtonItem.SystemItem?, fallbackTitle: String?, accessibilityIdentifier: String?) -> UIBarButtonItem {
        let action = #selector(buttonTapped(sender:))
        var button: UIBarButtonItem!
        if icon == nil {
            button = UIBarButtonItem(title: fallbackTitle, style: .plain, target: self, action: action)
        } else {
            button = UIBarButtonItem(barButtonSystemItem: icon!, target: self, action: action)
        }
        button.tag = type.rawValue
        button.accessibilityIdentifier = accessibilityIdentifier
        return button
    }
    
    private func setupBarButtonItemGroup() {
        if barButtonItemGroup == nil {
            var buttons = [
                backButton!,
                forwardButton!
            ]
            if AMCheckoutPluginManager.sharedInstance.scanCardPlugin != nil {
                buttons.insert(scanButton!, at: 0)
            }
            barButtonItemGroup = UIBarButtonItemGroup(barButtonItems: buttons, representativeItem: nil)
        }
    }
    
    private func setupAsToolbar() {
        if items == nil {
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let marginButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            marginButton.width = 6.0

            if AMCheckoutPluginManager.sharedInstance.scanCardPlugin != nil {
                setItems([backButton, marginButton, forwardButton, spaceButton, scanButton, spaceButton, doneButton], animated: false)
            } else {
                setItems([backButton, marginButton, forwardButton, spaceButton, doneButton], animated: false)
            }
        }
    }
    
    func associate(toField field:UITextField) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            setupBarButtonItemGroup()
            field.inputAssistantItem.trailingBarButtonGroups = [barButtonItemGroup];
        } else {
            setupAsToolbar()
            field.inputAccessoryView = self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func buttonTapped(sender: UIBarButtonItem) {
        toolBarDelegate?.keyboardToolbar(button: sender, type: KeyboardToolbarButton(rawValue: sender.tag)!, tappedIn: self)
    }
    
}
