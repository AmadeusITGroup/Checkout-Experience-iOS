//
//  ColorUtils.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 15/07/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


extension UIColor {
    var isBright: Bool {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var perceivedBrightness: CGFloat = 0.4
        if self.getRed(&red, green: &green, blue: &blue, alpha: nil) {
            perceivedBrightness = 0.299*red + 0.587*green + 0.114*blue
        }
        return perceivedBrightness>0.3
    }
}
