//
//  OptionViewController.swift
//  SwiftShowcase
//
//  Created by Yann Armelin on 11/09/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation
import UIKit
import AmadeusCheckout

class OptionsViewController: UIViewController {
    static var options = AMCheckoutOptions()
    
    @IBOutlet var payOnTopSwitch: UISwitch!
    @IBOutlet var dynamicVendorSwitch: UISwitch!
    @IBOutlet var appCallbackSchemeField: UITextField!
    
    @IBOutlet var primaryBackgroundColorSwitch: UISwitch!
    @IBOutlet var secondaryBackgroundColorSwitch: UISwitch!
    @IBOutlet var primaryForegroundColorSwitch: UISwitch!
    @IBOutlet var secondaryForegroundColorSwitch: UISwitch!
    @IBOutlet var accentColorSwitch: UISwitch!
    @IBOutlet var errorColorSwitch: UISwitch!
    @IBOutlet var fontSwitch: UISwitch!
    @IBOutlet var emphasisFontSwitch: UISwitch!
    @IBOutlet var termsAndConditionsSwitch: UISwitch!
    @IBOutlet var bookingDetailsSwitch: UISwitch!
    @IBOutlet var amountBreakdownSwitch: UISwitch!
    
    @IBOutlet var primaryBackgroundColorPicker: ColorPicker!
    @IBOutlet var secondaryBackgroundColorPicker: ColorPicker!
    @IBOutlet var primaryForegroundColorPicker: ColorPicker!
    @IBOutlet var secondaryForegroundColorPicker: ColorPicker!
    @IBOutlet var accentColorPicker: ColorPicker!
    @IBOutlet var errorColorPicker: ColorPicker!
    
    @IBOutlet var fontTypeControl: UISegmentedControl!
    @IBOutlet var fontSizeSlider: UISlider!
    @IBOutlet var fontSizeLabel: UILabel!
    @IBOutlet var emphasisFontTypeControl: UISegmentedControl!
    @IBOutlet var emphasisFontSizeSlider: UISlider!
    @IBOutlet var emphasisFontSizeLabel: UILabel!
    
    @IBOutlet var termsAndConditionsNumberControl: UISegmentedControl!
    @IBOutlet var termsAndConditionsSizeControl: UISegmentedControl!
    
    @IBOutlet var bookingDetailsPassengerNumberControl: UISegmentedControl!
    @IBOutlet var bookingDetailsFlightNumberControl: UISegmentedControl!
    
    @IBOutlet var amountBreakdownNumberControl: UISegmentedControl!
    
    fileprivate func makeTestFont(type: Int, size: CGFloat) -> UIFont {
        switch type {
        case 0: return .systemFont(ofSize:size)
        case 1: return .italicSystemFont(ofSize:size)
        case 2: return .boldSystemFont(ofSize:size)
        case 3: return UIFont(name:"Zapfino", size: size)!
        default: return UIFont(name: "Papyrus", size: size)!
        }
    }
    
    func refresh() {
        fontSizeLabel.text = String(Int(fontSizeSlider.value))
        emphasisFontSizeLabel.text = String(Int(emphasisFontSizeSlider.value))
    }
    
    @IBAction func onChange(_ sender: Any) {
        if sender as? ColorPicker === primaryBackgroundColorPicker { primaryBackgroundColorSwitch.isOn = true }
        if sender as? ColorPicker === secondaryBackgroundColorPicker { secondaryBackgroundColorSwitch.isOn = true }
        if sender as? ColorPicker === primaryForegroundColorPicker { primaryForegroundColorSwitch.isOn = true }
        if sender as? ColorPicker === secondaryForegroundColorPicker { secondaryForegroundColorSwitch.isOn = true }
        if sender as? ColorPicker === accentColorPicker { accentColorSwitch.isOn = true }
        if sender as? ColorPicker === errorColorPicker { errorColorSwitch.isOn = true }
        if sender as? UISegmentedControl === fontTypeControl || sender as? UISlider === fontSizeSlider { fontSwitch.isOn = true }
        if sender as? UISegmentedControl === emphasisFontTypeControl || sender as? UISlider === emphasisFontSizeSlider { emphasisFontSwitch.isOn = true }
        if sender as? UISegmentedControl === termsAndConditionsNumberControl || sender as? UISegmentedControl === termsAndConditionsSizeControl { termsAndConditionsSwitch.isOn = true }
        if sender as? UISegmentedControl === bookingDetailsPassengerNumberControl || sender as? UISegmentedControl === bookingDetailsFlightNumberControl { bookingDetailsSwitch.isOn = true }
        if sender as? UISegmentedControl === amountBreakdownNumberControl { amountBreakdownSwitch.isOn = true }
        
        let opt = OptionsViewController.options
        
        opt.displayPayButtonOnTop = payOnTopSwitch.isOn
        opt.dynamicVendor = dynamicVendorSwitch.isOn
        
        opt.appCallbackScheme = appCallbackSchemeField.text ?? ""
        
        opt.primaryBackgroundColor = primaryBackgroundColorSwitch.isOn ? primaryBackgroundColorPicker.color : nil
        opt.secondaryBackgroundColor = secondaryBackgroundColorSwitch.isOn ? secondaryBackgroundColorPicker.color : nil
        opt.primaryForegroundColor = primaryForegroundColorSwitch.isOn ? primaryForegroundColorPicker.color : nil
        opt.secondaryForegroundColor = secondaryForegroundColorSwitch.isOn ? secondaryForegroundColorPicker.color : nil
        opt.accentColor = accentColorSwitch.isOn ? accentColorPicker.color : nil
        opt.errorColor = errorColorSwitch.isOn ? errorColorPicker.color : nil
        opt.primaryBackgroundColor = primaryBackgroundColorSwitch.isOn ? primaryBackgroundColorPicker.color : nil
        opt.primaryBackgroundColor = primaryBackgroundColorSwitch.isOn ? primaryBackgroundColorPicker.color : nil
        
        opt.font = fontSwitch.isOn ? makeTestFont(type: fontTypeControl.selectedSegmentIndex, size: CGFloat(fontSizeSlider.value).rounded()) : nil
        opt.emphasisFont = emphasisFontSwitch.isOn ? makeTestFont(type: emphasisFontTypeControl.selectedSegmentIndex, size: CGFloat(emphasisFontSizeSlider.value).rounded()) : nil

        opt.termsAndConditions = []
        let names = termsAndConditionsSizeControl.selectedSegmentIndex==0 ?
            ["Terms and Conditions", "Terms and Conditions appendix 1", "Terms and Conditions appendix 2", "Terms and Conditions appendix 3", "Terms and Conditions appendix 4"]:
            ["Lorem ipsum dolor sit amet, consectetur adipiscing elit", "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua", "Ut enim ad minim veniam, quis nostrud exercitation ullamco",
             "Laboris nisi ut aliquip ex ea commodo consequat", "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."]
        if termsAndConditionsSwitch.isOn {
            opt.termsAndConditions = []
            for i in 0...termsAndConditionsNumberControl.selectedSegmentIndex {
                opt.termsAndConditions.append(AMTermsAndConditions(link: URL(string: "https://www.google.com/search?q=\(i)")!, localizedLabel: names[i % names.count]))
            }
        }
        
        opt.bookingDetails = nil
        if bookingDetailsSwitch.isOn {
            var passengerList: [String]? = nil
            var flightList: [AMFlight]? = nil
            
            let passengers = ["Andy Davis", "Carl Fredricksen", "Alfredo Linguini", "Miguel Rivera", "Michael Wazowski"]
            if bookingDetailsPassengerNumberControl.selectedSegmentIndex > 0 {
                passengerList = []
                for i in 1...bookingDetailsPassengerNumberControl.selectedSegmentIndex {
                    passengerList?.append(passengers[i-1])
                }
            }
            
            let airports = [
                ("Nice NCE", 0, "Europe/Paris"),
                ("Paris CDG", 70, "Europe/Paris"),
                ("New York JFK", 500, "America/New_York"),
                ("San Francisco SFO", 385, "America/Los_Angeles"),
                ("Honolulu HNL", 330, "Pacific/Honolulu")
            ]
            if bookingDetailsFlightNumberControl.selectedSegmentIndex > 0 {
                flightList = []
                var date = Calendar.current.date(byAdding: .minute, value: 1500, to: Date())!
                for i in 1...bookingDetailsFlightNumberControl.selectedSegmentIndex {
                    flightList?.append(
                        AMFlight(
                            departureAirport: airports[i-1].0, departureDate: date, departureTimezone: TimeZone(identifier: airports[i-1].2)!,
                            arrivalAirport: airports[i].0, arrivalDate: Calendar.current.date(byAdding: .minute, value: airports[i].1, to: date)!, arrivalTimezone: TimeZone(identifier: airports[i].2)!
                        )
                    )
                    date = Calendar.current.date(byAdding: .minute, value: airports[i].1 + 90, to: date)!
                }
            }
            
            opt.bookingDetails = AMBookingDetails(passengerList: passengerList, flightList: flightList)
        }

        opt.amountBreakdown = []
        if amountBreakdownSwitch.isOn{
            let amounts = [
                AMAmountDetails(label:"Flight ticket", amount: 123.45),
                AMAmountDetails(label:"Seat", amount:10.00),
                AMAmountDetails(label:"Excess luggage", amount: 9.50),
                AMAmountDetails(label:"VAT", amount: 24.69)
            ]
            for i in 0...amountBreakdownNumberControl.selectedSegmentIndex {
                opt.amountBreakdown.append(amounts[i])
                if i>0 {
                    amounts[0].amount -= amounts[i].amount
                }
            }
        }
        
        refresh()
    }
}
