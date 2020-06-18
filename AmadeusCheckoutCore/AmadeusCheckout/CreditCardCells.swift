//
//  CreditCardCells.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 08/08/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


extension TableModel.Cell{
    static let cardholderName = TableModel.Cell(StoryboardConstants.CreditCardBasicInputCell, labelKey: "cardHolderName", placeholderKey: "cardHolderNamePlaceholder")
    static let cardVendor = TableModel.Cell(StoryboardConstants.CreditCardVendorCell, labelKey: "", segueIdentifier: StoryboardConstants.SelectVendorSegue)
    static let cardNumber = TableModel.Cell(StoryboardConstants.CreditCardNumberCell, labelKey: "", placeholderKey: "", height: 66)
    static let cardExpiry = TableModel.Cell(StoryboardConstants.CreditCardExpiryCell, labelKey: "expiry", placeholderKey: "")
    static let cardCvv = TableModel.Cell(StoryboardConstants.CreditCardCvvCell, labelKey: "cvv", placeholderKey: "")
    static let billingAddressLine1 = TableModel.Cell(StoryboardConstants.CreditCardBasicInputCell, labelKey: "addressLine1", placeholderKey: "addressLine1Placeholder")
    static let billingAddressLine2 = TableModel.Cell(StoryboardConstants.CreditCardBasicInputCell, labelKey: "addressLine2", placeholderKey: "addressLine2Placeholder")
    static let billingAddressZipCode = TableModel.Cell(StoryboardConstants.CreditCardBasicInputCell, labelKey: "zipCode", placeholderKey: "zipCodePlaceholder")
    static let billingAddressCity = TableModel.Cell(StoryboardConstants.CreditCardBasicInputCell, labelKey: "city", placeholderKey: "cityPlaceholder")
    static let billingAddressCountry = TableModel.Cell(StoryboardConstants.CreditCardDetailCell, labelKey: "country", segueIdentifier: StoryboardConstants.SelectCountrySegue)
}


protocol BoundTableViewCell: class  {
    func setupBinding(bindingsAggregator: DataModelBindingAggregator, cellBindings: [DataModelBinding])
    func setupLabels(cell: TableModel.Cell, isOptional: Bool)
}

class DetailTableViewCell: StyledTableViewCell, BoundTableViewCell {
    var validityObserver: NSKeyValueObservation?
    
    @IBOutlet var leftLabel: UILabel!
    @IBOutlet var icon: IconViewFactoryView! {
        didSet {
            icon.color = theme.errorColor
            icon.type = .warning
        }
    }
    @IBOutlet var detailLabel: BoundLabel! {
        didSet {
            detailLabel.textColor = tintColor
        }
    }
    
    override func updateAppearance() {
        super.updateAppearance()
        accessoryView = IconViewFactory.disclosureIndicator.createView(color: theme.secondaryForegroundColor)
    }
    func setupBinding(bindingsAggregator: DataModelBindingAggregator, cellBindings: [DataModelBinding]) {
        detailLabel.binding = cellBindings[0]
        validityObserver = cellBindings[0].observe(\.isValid) {[weak self] (binding, _) in
            if self != nil {
                self!.icon.isHidden = binding.isValid || !binding.touched
            }
        }
    }
    func setupLabels(cell: TableModel.Cell, isOptional: Bool) {
        leftLabel.keyPath = cell.labelKey
    }
}

class InputTextViewCell: StyledTableViewCell, BoundTableViewCell, UITextFieldDelegate {
    @IBOutlet var inputTextField: BoundTextField!
    @IBOutlet var leftLabel: UILabel!
    
    weak var delegate: UITextFieldDelegate? // To forward delegate events from inputTextField
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputTextField.delegate = self
        inputTextField.returnKeyType = .continue
    }
    func setupBinding(bindingsAggregator: DataModelBindingAggregator, cellBindings: [DataModelBinding]) {
        inputTextField.binding = cellBindings[0]
    }
    func setupLabels(cell: TableModel.Cell, isOptional: Bool) {
        leftLabel.keyPath = cell.labelKey
        if isOptional {
            inputTextField.smartPlaceholder = "\(cell.placeholderKey?.localize(type: .label) ?? "")\("optional".localize(type: .label))"
        } else {
            inputTextField.keyPath = cell.placeholderKey
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing?(textField)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing?(textField)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let textFieldShouldReturn = delegate?.textFieldShouldReturn?(textField) {
            return textFieldShouldReturn
        }
        return false
    }
}

class AmountTableViewCell: StyledTableViewCell, BoundTableViewCell {
    @IBOutlet var label: BoundLabel!
    @IBOutlet var leftLabel: UILabel!
    
    func setupBinding(bindingsAggregator: DataModelBindingAggregator, cellBindings: [DataModelBinding]) {
        label.binding = cellBindings[0]
    }
    
    func setupLabels(cell: TableModel.Cell, isOptional: Bool) {
        leftLabel.keyPath = cell.labelKey
    }
}

class CardNumberTableViewCell: InputTextViewCell {
    @IBOutlet var vendorImage: BoundImageView?
    
    // MARK: Instance properties
    var creditCardModel: CreditCardPaymentMethod?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vendorImage?.bundle = FileTools.mainBundle
    }
    // MARK: Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.creditCardModel = AMCheckoutContext.sharedContext?.dataModel?.selectedPaymentMethod as? CreditCardPaymentMethod
    }
    
    override func setupBinding(bindingsAggregator: DataModelBindingAggregator, cellBindings: [DataModelBinding]) {
        super.setupBinding(bindingsAggregator: bindingsAggregator, cellBindings: cellBindings)
        
        inputTextField.infoBinding = cellBindings[1]
        inputTextField.placeholderBinding = cellBindings[2]
        if cellBindings.count >= 4 {
            vendorImage?.binding = cellBindings[3]
        }
    }
    
    override func setupLabels(cell: TableModel.Cell, isOptional: Bool) {}
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentValue: String = textField.text!
        let newValue = currentValue.replacingCharacters(in: currentValue.range(range.lowerBound, range.upperBound) , with: string.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))
        let rawValue = CardFormatter.unformat(newValue)
        let formattedValue = inputTextField.binding?.formatter?(rawValue) ?? rawValue
        
        let rawCursorPosition = range.location + string.count;
        let cursorPosition = CardFormatter.unformat(newValue[0, rawCursorPosition]).count
        var formattedCursorPosition = 0
        var i = 0
        while i<cursorPosition {
            if formattedValue[formattedCursorPosition] != " " {
                i += 1
            }
            formattedCursorPosition += 1
        }
        formattedCursorPosition = min(formattedCursorPosition , formattedValue.count)
        
        textField.text = formattedValue
        let caretPosition = textField.position(from: textField.beginningOfDocument, offset: formattedCursorPosition)
        textField.selectedTextRange = textField.textRange(from: caretPosition!, to: caretPosition!)
        
        textField.sendActions(for: .editingChanged)
        
        return false
    }
}

class ExpiryTableViewCell: InputTextViewCell {
    @IBOutlet var expiryPicker: ExpiryPickerView!
    var observation: NSKeyValueObservation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputTextField.inputView = expiryPicker
    }
    
    override func setupBinding(bindingsAggregator: DataModelBindingAggregator, cellBindings: [DataModelBinding]) {
        super.setupBinding(bindingsAggregator: bindingsAggregator, cellBindings: cellBindings)
        expiryPicker.binding = cellBindings[1]
        
        observation = expiryPicker.binding?.observe(\.isValid, changeHandler: {[weak self] binding, change in
            if binding.isValid {
                self?.inputTextField.binding?.errorCode = nil
            } else {
                self?.inputTextField.binding?.errorCode = binding.errorCode
            }
        })
        
    }
    override func setupLabels(cell: TableModel.Cell, isOptional: Bool) {}
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

class CvvTableViewCell: InputTextViewCell {
    @IBOutlet var cvvHelpButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if(AMCheckoutContext.sharedContext?.options.displayCvvHelp != true)  {
            self.cvvHelpButton.isHidden = true
        }
    }
    
    override func setupLabels(cell: TableModel.Cell, isOptional: Bool) {}
    
    override func setupBinding(bindingsAggregator: DataModelBindingAggregator, cellBindings: [DataModelBinding]) {
        super.setupBinding(bindingsAggregator: bindingsAggregator, cellBindings: cellBindings)
        inputTextField.placeholderBinding = cellBindings[1]
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLen = 4
        let currentValue: String = textField.text!
        var stringNumbersOnly = string.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if (currentValue.count - range.length) + stringNumbersOnly.count  > maxLen {
            stringNumbersOnly = stringNumbersOnly[0, maxLen - (currentValue.count - range.length)]
        }
        
        let newValue = currentValue.replacingCharacters(in: currentValue.range(range.lowerBound, range.upperBound) , with: stringNumbersOnly)
        textField.text = newValue
        
        let cursorPosition = range.location + stringNumbersOnly.count
        let caretPosition = textField.position(from: textField.beginningOfDocument, offset: cursorPosition)
        textField.selectedTextRange = textField.textRange(from: caretPosition!, to: caretPosition!)
        
        textField.sendActions(for: .editingChanged)
        
        return false
    }
}

class VendorTableViewCell: DetailTableViewCell {
    @IBOutlet var vendorImage: BoundImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vendorImage.bundle = FileTools.mainBundle
    }
    
    override func setupBinding(bindingsAggregator: DataModelBindingAggregator, cellBindings: [DataModelBinding]) {
        vendorImage.binding = cellBindings[0]
    }
    override func setupLabels(cell: TableModel.Cell, isOptional: Bool) {}
}

