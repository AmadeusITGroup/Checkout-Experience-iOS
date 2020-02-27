//
//  Bindings.swift
//  Test
//
//  Created by Yann Armelin on 16/04/2019.
//  Copyright © 2019 Yann Armelin. All rights reserved.
//

import UIKit


@objc protocol BindableView where Self:UIView {
    var viewValue : String { get set }
    @objc optional func setErrorCode(_: String?)
    @objc optional func setIsLoading(_: Bool)
}


class DataModelBindingAggregator: NSObject {
    private var bindingList: [(DataModelBinding,[NSKeyValueObservation])] = []
    @objc dynamic var isValid = true
    @objc dynamic var isPending = false
    
    private func refreshStatus() {
        var newIsValid = true
        var newIsPending = false
        for (binding,_) in bindingList {
            newIsValid = newIsValid && binding.isValid
            newIsPending = newIsPending || binding.isPending
        }
        if newIsValid != isValid {
            isValid = newIsValid
        }
        if newIsPending != isPending {
            isPending = newIsPending
        }
    }
    
    func touchAll() {
        for (binding,_) in bindingList {
            if !binding.touched {
                binding.touched = true
            }
        }
    }
    
    func add(_ newBinding: DataModelBinding) {
        if bindingList.firstIndex(where: { $0.0 === newBinding } ) == nil {
            let observations = [
                newBinding.observe(\.isPending, changeHandler: {[weak self] binding, change in self?.refreshStatus() }),
                newBinding.observe(\.isValid, changeHandler: {[weak self] binding, change in self?.refreshStatus() })
            ]
            
            bindingList.append((newBinding, observations))
            refreshStatus()
        }
    }

    func remove(_ binding: DataModelBinding) {
        bindingList.removeAll(where: { $0.0 === binding })
        refreshStatus()
    }
}

class DataModelBinding : NSObject {
    weak var view : BindableView? {
        didSet { pushToView() }
    }
    var didSetViewValue: ((String)->Void)? {
        didSet { pushToView() }
    }
    
    var formatter : ((String)->String)? {
        didSet { pushToView() }
    }
    var parser : ((String)->String)?
    
    var genericFormatter : ((Any)->String)? {
        didSet { pushToView() }
    }
    var genericParser : ((String)->Any)?
    
    var validator: Validator? {
        didSet { validate() }
    }
    var errorCode : String? = nil {
        didSet {
            isValid = (errorCode == nil)
            if touched || self.value != "" {
                view?.setErrorCode?(errorCode)
            }
        }
    }
    var touched = false {
        didSet {
            validate()
        }
    }
    
    @objc dynamic var isValid = true
    @objc dynamic var isPending = false {
        didSet {
            view?.setIsLoading?(isPending)
        }
    }
    
    private var disableObservation = false
    private weak var target: NSObject?
    private let keyPath : String
    private var asyncValidatorId: Int?
    
    private static var NextAsyncValidatorId: Int = 0
    
    init<ModelType:NSObject, ValueType>(_ target:ModelType, keyPath: KeyPath<ModelType, ValueType>) {
        self.target = target
        self.keyPath = NSExpression(forKeyPath:keyPath).keyPath
        super.init()
        target.addObserver(self, forKeyPath: self.keyPath, options: [.new, .old], context: nil)
    }
    
    var value : String {
        set(newValue) { // Set model value from view
            let parsedNewValue = parse(newValue)
            setModelValue(parsedNewValue)
            touched = true
        }
        get { // Get model value as string
            return (target?.value(forKeyPath: keyPath) as? String) ?? ""
        }
    }
    
    deinit {
        target?.removeObserver(self, forKeyPath: keyPath)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !disableObservation {
            let valueToPush = format(change?[.newKey] ?? "")
            view?.viewValue = valueToPush
            didSetViewValue?(valueToPush)
        }
    }
    
    func pushToView() {
        let valueToPush = format(target?.value(forKeyPath: keyPath))
        view?.viewValue = valueToPush
        didSetViewValue?(valueToPush)
        if touched {
            view?.setErrorCode?(errorCode)
        }
    }
    
    /*
     This method performs a validation of the current value of the field.
     It guarantes a proper validation of the field, even if it's called
     again before the previous validation is finished.
     In that case, the on-going validation is dismissed, and only the last one
     is taken into account.
     */
    func validate() {
        if let validator = validator {
            var didValidatorAnswered = false

            asyncValidatorId = DataModelBinding.GenerateAsyncValidatorId()
            let currentAsyncValidatorId = asyncValidatorId
            
            validator.isValid(value, successHandler: {[weak self] in
                // accept callback
                if currentAsyncValidatorId == self?.asyncValidatorId {
                    self?.isPending = false
                    self?.errorCode = nil
                    didValidatorAnswered = true
                }
            }, failureHandler: {[weak self] newErrorCode in
                // reject callback
                if currentAsyncValidatorId == self?.asyncValidatorId {
                    self?.isPending = false
                    self?.errorCode = newErrorCode
                    didValidatorAnswered = true
                }
            })
            if !didValidatorAnswered {
                // Validator is asynchronous
                errorCode = nil
                isPending = true
                isValid = false
            }
        }
    }
    
    static func GenerateAsyncValidatorId() -> Int {
        DataModelBinding.NextAsyncValidatorId += 1
        return DataModelBinding.NextAsyncValidatorId
    }
    
    private func setModelValue(_ string: Any?) {
        disableObservation = true
        target?.setValue(string, forKeyPath: keyPath)
        disableObservation = false
    }
    
    private func parse(_ string: String) -> Any  {
        if let parser = genericParser {
            return parser(string)
        }
        if let parser = parser {
            return parser(string)
        }
        return string
    }
    
    private func format(_ value: Any?) -> String {
        if let formatter = genericFormatter, let value = value {
            return formatter(value)
        }
        if let string = value as? String {
            if let formatter = formatter {
                return formatter(string)
            }
            return string
        }
        return ""
    }
}
