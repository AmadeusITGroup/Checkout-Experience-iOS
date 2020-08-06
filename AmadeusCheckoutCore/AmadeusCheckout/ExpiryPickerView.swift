//
//  ExpiryPickerView.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 09/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation



class ExpiryPickerView: UIPickerView, BindableView {
    // MARK: Instance properties
    var binding: DataModelBinding? {
        didSet { binding?.view = self }
    }
    var selectedMonth = 0
    var selectedYear = 0
    var expiryPickerPresentationStyle = AMExpiryPickerMonthStyle.numberAndText

    // This field contains the expected height of the expiry picker,
    // so that it can be aligned with other types of keyboards.
    var intrinsicHeight: CGFloat = 162.0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: UIView.noIntrinsicMetric, height: max(162.0, intrinsicHeight))
        }
    }
    

    var viewValue: String {
        set(value) {
            if value.count>=4 {
                let month = value.prefix(2)
                let year = value.suffix(2)
                
                if let monthIndex = Int(month) {
                    selectedMonth = monthIndex
                }
                if let yearIndex = ExpiryPickerView.years.firstIndex(where: { $0.suffix(2) == year }) {
                    selectedYear = yearIndex
                }
            } else {
                selectedMonth = 0
                selectedYear = 0
            }
            updateSelectedRows()
        }
        get {
            if selectedMonth==0 || selectedYear==0 {
                return ""
            }
            let month = String(format: "%02d", selectedMonth)
            let year = String( Int(ExpiryPickerView.years[1])! + selectedYear - 1)
            return month+"/"+year.suffix(2)
        }
    }
    
    override func didMoveToSuperview() {
        if let value = binding?.value {
            viewValue = value
            binding?.touched = true
        }
    }
    
    // MARK: Class properties
    static let headerAttributes: [NSAttributedString.Key: Any] = {
        var attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
        if #available(iOS 13.0, *) {
            attributes[.foregroundColor] = UIColor.tertiaryLabel
        } else {
            attributes[.foregroundColor] = UIColor.lightGray
        }
        return attributes
    }()
    static let rowAttributes: [NSAttributedString.Key: Any] = {
        var attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
        if #available(iOS 13.0, *) {
            attributes[.foregroundColor] = UIColor.label
        } else {
            attributes[.foregroundColor] = UIColor.black
        }
        return attributes
    }()
    
    
    static var months: [AMExpiryPickerMonthStyle:[String]] = {
        let monthLabel = "Month".localize(type: .hint)
        var months = [
            AMExpiryPickerMonthStyle.numberAndText:[monthLabel],
            AMExpiryPickerMonthStyle.numberOnly:[monthLabel],
            AMExpiryPickerMonthStyle.textOnly:[monthLabel]
        ]
        for i in 1...12 {
            let monthNumber = "\(i<10 ?"0":"")\(i)"
            let monthLabel = Translator.instance.monthLocalName(month: i)
            months[AMExpiryPickerMonthStyle.numberAndText]!.append("\(monthNumber) - \(Translator.instance.monthLocalName(month: i))")
            months[AMExpiryPickerMonthStyle.numberOnly]!.append(monthNumber)
            months[AMExpiryPickerMonthStyle.textOnly]!.append(Translator.instance.monthLocalName(month: i))
        }
        return months
    }()
    
    static var years: [String] = {
        let year = Calendar.current.component(.year, from: Date())
        var years = ["Year".localize(type: .hint)]
        for i in 0...49 {
            years.append(String(year + i))
        }
        return years
    }()
    
    // MARK: Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.delegate = self
        self.dataSource = self
        self.updateSelectedRows()
    }
    
    // MARK: Instance methods
    func updateSelectedRows() {
        selectRow(selectedMonth, inComponent: 0, animated: false)
        selectRow(selectedYear, inComponent: 1, animated: false)
    }
    

}



extension ExpiryPickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return ExpiryPickerView.months[self.expiryPickerPresentationStyle]!.count
        } else {
            return ExpiryPickerView.years.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?
    {
        return NSAttributedString(
            string: component == 0 ? ExpiryPickerView.months[self.expiryPickerPresentationStyle]![row] : ExpiryPickerView.years[row] ,
            attributes: row == 0 ? ExpiryPickerView.headerAttributes : ExpiryPickerView.rowAttributes
        )
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedMonth = row
        } else {
            selectedYear = row
        }
        binding?.value =  viewValue
    }
}
