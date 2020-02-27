//
//  BindedTextField.swift
//  Test
//
//  Created by Yann Armelin on 16/04/2019.
//  Copyright © 2019 Yann Armelin. All rights reserved.
//

import UIKit


class BoundTextField: TextFieldWithMessage, BindableView {
    var binding: DataModelBinding? {
        didSet {
            binding?.view = self
            setIsLoading(binding?.isPending ?? false)
        }
    }
    var infoBinding: DataModelBinding? {
        didSet {
            infoBinding?.didSetViewValue = { [weak self] value in
                if let field = self {
                    field.infoText = value.isEmpty ? nil : value
                }
            }
        }
    }
    var placeholderBinding: DataModelBinding? {
        didSet {
            placeholderBinding?.didSetViewValue = { [weak self] value in
                if let field = self {
                    field.placeholder = value.isEmpty ? nil : value
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(self.editingChanged), for: .editingChanged)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(self.editingChanged), for: .editingChanged)
    }
    
    @objc func editingChanged() {
        binding?.value = self.text ?? ""
    }
    
    func setErrorCode(_ errorCode: String?) {
        errorText = errorCode
    }
    
    func setIsLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    var viewValue : String {
        set(newValue) {
            self.text = newValue
        }
        get {
            return self.text ?? ""
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            if binding?.touched != true {
                binding?.touched = true
            }
            return true
        }
        return false
    }
}
