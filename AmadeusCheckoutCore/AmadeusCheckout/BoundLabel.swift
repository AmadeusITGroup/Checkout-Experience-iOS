//
//  BoundLabel.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 16/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


class BoundLabel: UILabel, BindableView {
    var binding: DataModelBinding? {
        didSet { binding?.view = self }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var viewValue : String {
        set(newValue) {
            self.text = newValue
        }
        get {
            return self.text ?? ""
        }
    }
}
