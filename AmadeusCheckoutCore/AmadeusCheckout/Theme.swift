//
//  Theme.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 15/07/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


class Theme {
    static var sharedInstance = Theme()
    
    static let defaultPrimaryBackgroundColor: UIColor = {
         if #available(iOS 11.0, *) { return UIColor(named: "defaultPrimaryBackgroundColor", in: FileTools.mainBundle, compatibleWith: nil)! }
         else { return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    }()
    static let defaultSecondaryBackgroundColor: UIColor = {
         if #available(iOS 11.0, *) { return UIColor(named: "defaultSecondaryBackgroundColor", in: FileTools.mainBundle, compatibleWith: nil)! }
         else { return #colorLiteral(red: 0.937, green: 0.937, blue: 0.957, alpha: 1.0) }
    }()
    static let defaultPrimaryForegroundColor: UIColor = {
         if #available(iOS 11.0, *) { return UIColor(named: "defaultPrimaryForegroundColor", in: FileTools.mainBundle, compatibleWith: nil)! }
         else { return #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) }
    }()
    static let defaultSecondaryForegroundColor: UIColor = {
         if #available(iOS 11.0, *) { return UIColor(named: "defaultSecondaryForegroundColor", in: FileTools.mainBundle, compatibleWith: nil)! }
         else { return #colorLiteral(red: 0.78, green: 0.78, blue: 0.8, alpha: 1) }
    }()
    static let defaultAccentColor: UIColor = {
         if #available(iOS 11.0, *) { return UIColor(named: "defaultAccentColor", in: FileTools.mainBundle, compatibleWith: nil)! }
         else { return #colorLiteral(red: 0.039, green: 0.447, blue: 0.996, alpha: 1) }
    }()
    static let defaultErrorColor: UIColor = {
         if #available(iOS 11.0, *) { return UIColor(named: "defaultErrorColor", in: FileTools.mainBundle, compatibleWith: nil)! }
         else { return #colorLiteral(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0) }
    }()
    static let defaultFont = UIFont.systemFont(ofSize: 17.0)
    static let defaultEmphasisFont = UIFont.systemFont(ofSize: 17.0)
    
    var primaryBackgroundColor = Theme.defaultPrimaryBackgroundColor
    var secondaryBackgroundColor = Theme.defaultSecondaryBackgroundColor
    var primaryForegroundColor = Theme.defaultPrimaryForegroundColor
    var secondaryForegroundColor = Theme.defaultSecondaryForegroundColor
    var accentColor = Theme.defaultAccentColor
    var errorColor = Theme.defaultErrorColor
    var font = Theme.defaultFont
    var emphasisFont = Theme.defaultEmphasisFont
    
    init() {}
    
    func importOptions(_ options: AMCheckoutOptions) {
        primaryBackgroundColor = options.primaryBackgroundColor ?? Theme.defaultPrimaryBackgroundColor
        secondaryBackgroundColor = options.secondaryBackgroundColor ?? Theme.defaultSecondaryBackgroundColor
        primaryForegroundColor = options.primaryForegroundColor ?? Theme.defaultPrimaryForegroundColor
        secondaryForegroundColor = options.secondaryForegroundColor ?? Theme.defaultSecondaryForegroundColor
        accentColor = options.accentColor ?? Theme.defaultAccentColor
        errorColor = options.errorColor ?? Theme.defaultErrorColor
        font = options.font ?? Theme.defaultFont
        emphasisFont = options.emphasisFont ?? Theme.defaultEmphasisFont
    }
    
    var primaryLighterForegroundColor: UIColor? {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        primaryForegroundColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor.init(red: red, green: green, blue: blue, alpha: 0.7*alpha)
    }
    
    var primaryDarkerBackgroundColor: UIColor? {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        primaryBackgroundColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor.init(hue: hue, saturation: saturation, brightness: (brightness - 0.15), alpha: alpha)
    }
    
    var separatorColor: UIColor? {
        return primaryBackgroundColor.isBright ? #colorLiteral(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.29) : #colorLiteral(red: 0.329, green: 0.329, blue: 0.345, alpha: 0.6)
    }
    
    var barStyle: UIBarStyle {
        return primaryBackgroundColor.isBright ? .default : .black
    }
    
    var smallFont: UIFont? {
        return font.withSize(font.pointSize - 3)
    }
    
    func apply(navigationBar: UINavigationBar) {
        navigationBar.isTranslucent = true
        navigationBar.barStyle = barStyle
        navigationBar.barTintColor = primaryBackgroundColor
        navigationBar.tintColor = accentColor
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor:primaryForegroundColor as Any,
            NSAttributedString.Key.font:emphasisFont as Any,
        ]
    }
    
    func apply(tableView: UITableView) {
        tableView.separatorColor = separatorColor
        
        // If the table view style is grouped, the background color is the secondary one
        let tableBackgroundColor = tableView.style == .grouped ? secondaryBackgroundColor : primaryBackgroundColor
        
        tableView.backgroundColor = tableBackgroundColor
        if tableView.responds(to: Selector(("tableHeaderBackgroundColor"))) {
            tableView.setValue(tableBackgroundColor, forKey: "tableHeaderBackgroundColor")
        }
    }
    
    func apply(searchBar: UISearchBar) {
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = accentColor
        searchBar.barStyle = barStyle
    }
}
