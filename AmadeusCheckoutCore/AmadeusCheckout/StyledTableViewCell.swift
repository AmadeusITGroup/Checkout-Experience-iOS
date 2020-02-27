//
//  StyledTableViewCell.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 16/07/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation

class StyledTableViewCell: UITableViewCell  {
    var theme = Theme.sharedInstance
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        updateAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateAppearance()
    }
    
    private func updateSubviewsAppearance(view: UIView) {
        for subview in view.subviews {
            switch subview {
            case let label as UILabel:
                label.textColor = label === detailTextLabel ? theme.accentColor : theme.primaryForegroundColor
                label.font = theme.font
            case let field as TextFieldWithMessage:
                field.textColor = theme.accentColor
                field.errorColor = theme.errorColor
                field.messageFont = theme.smallFont
                field.infoColor = theme.primaryForegroundColor
                field.font = theme.font
                field.loaderColor = theme.secondaryForegroundColor
                field.attributedPlaceholder = NSAttributedString(
                    string: field.placeholder ?? "",
                    attributes: [
                        NSAttributedString.Key.foregroundColor:theme.secondaryForegroundColor as Any,
                        NSAttributedString.Key.font:theme.font as Any
                    ]
                )
            default:
                updateSubviewsAppearance(view:subview)
            }
        }
    }
    
    func updateAppearance() {
        backgroundColor = theme.primaryBackgroundColor
        selectionStyle = .default
        tintColor = theme.accentColor
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = theme.secondaryForegroundColor
        
        if let label = detailTextLabel {
            label.font = theme.font
            label.textColor = theme.primaryForegroundColor
        }
        if let label = textLabel {
            label.font = theme.font
            label.textColor = theme.primaryForegroundColor
        }
        
        updateSubviewsAppearance(view:self)
    }
    
}
