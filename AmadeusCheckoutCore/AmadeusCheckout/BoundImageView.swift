//
//  BindedImageView.swift
//  Test
//
//  Created by Yann Armelin on 16/04/2019.
//  Copyright © 2019 Yann Armelin. All rights reserved.
//

import UIKit


class BoundImageView: UIImageView, BindableView {
    var bundle: Bundle = Bundle.main
    var defaultImageName: String?
    var binding: DataModelBinding? {
        didSet { binding?.view = self }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override convenience init(image: UIImage?) {
        self.init(image:image, highlightedImage:nil)
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image:image, highlightedImage:highlightedImage)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var viewValue : String {
        get {
            return ""
        }
        set(newValue) {
            if newValue.isEmpty {
                self.image = nil
            } else if let im = UIImage(named: newValue, in: bundle, compatibleWith: nil) {
                self.image = im
            } else if let defaultImageName = defaultImageName{
                self.image = UIImage(named: defaultImageName, in: bundle, compatibleWith: nil)
            } else {
                self.image = nil
            }
        }
    }
}
