//
//  Datamodel.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 11/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


class PaymentPageDataModel: NSObject {
    var ppid: String
    var environement: Environment
    var service: BackendServices
    

    var appCallbackScheme: String = ""
    
    var pendingRedirection: Redirection?
    var paymentCompleted = false
    
    
    @objc dynamic var amount: Amount =  Amount()
    @objc dynamic var obFeeAmount: Amount =  Amount()
    @objc dynamic var totalAmount: Amount =  Amount()
    var calculateObFee = false
    var dynamicVendor = false
    
    @objc dynamic var sessionTimeout = SessionTimeout()
    
    
    var paymentMethods: [PaymentMethod] = []
    var selectedPaymentMethod: PaymentMethod?
    var additionalFields: [DataField] = []
    var countries: [(code:String, label:String)] = []
    
    private var lastVendorFromBinTable: CreditCardVendor?
    private var lastPayload : JSON?
    private var binTableCache = BinTableCache()
    
    
    init(ppid: String, environement: Environment) {
        self.ppid = ppid
        self.environement = environement
        service = BackendServices.create(environement: environement, ppid: ppid)
    }
    
    private func payResponse(_ response: JSON ,successHandler: @escaping ()->Void, failureHandler: @escaping (BackendError)->Void) {
        let action = response["action"].stringValue

        pendingRedirection = nil
        
        switch action {
            case "mop_selection":
                if paymentMethods.count == 0 {
                    // We import the MOP only the first time

                    for (_,field) in response["data","input_data_fields"].dictionaryValue {
                        additionalFields.append(DataField(field))
                    }
                    
                    for country in response["data","address_config","DEFAULT_CONFIG",0,"selectContent"].arrayValue {
                        let code = country["value"].stringValue
                        let label = Translator.countryLocalName(code: code) ?? country["label_code"].stringValue
                        countries.append((code:country["value"].stringValue, label:label))
                    }
                    countries.sort { $0.label < $1.label }
                    
                    if let amountValue = Double(response["data","init_data","amount"].stringValue) {
                        let amountCurrency = response["data","init_data","currency"].stringValue
                        self.amount = Amount(amountValue, amountCurrency)
                        self.totalAmount = Amount(amountValue, amountCurrency)
                    }
                    
                    for rawMop in response["data","init_data","available_mops"].arrayValue {
                        self.paymentMethods.append(PaymentMethod.create(rawMop, fields: additionalFields))
                    }
                    
                    self.calculateObFee = (response["data","init_data","calculate_ob_fee"].boolValue == true)
                    
                    if(response["data","init_data","frontend_type"].stringValue != "CHECKOUT_SDK") {
                        failureHandler(.technicalUnexpected)
                        return
                    }
                }
                
                
                if let creditcard = selectedPaymentMethod as? CreditCardPaymentMethod {
                    let vendor = response["vendor_bin"].stringValue
                    if vendor != "" {
                        lastVendorFromBinTable = creditcard.allowedVendors.first(where: { $0.id == vendor })
                    }
                    
                    if creditcard.vendor.id == lastPayload?["mopdata","vendor"].stringValue && creditcard.creditCardNumber == lastPayload?["mopdata","pan"].stringValue {
                        
                        // We import ob fees value only if CC+Vendor didn't change since last query.
                        // If value is not the same, it means the ObFee query isn't valid anymore.

                        let obeFees = response["obfees_amount"].stringValue
                        if let value = Double(obeFees) {
                            obFeeAmount = Amount(value, self.amount.currency)
                            totalAmount = Amount(obFeeAmount.value + self.amount.value, self.amount.currency)
                        }
                    }
                }
                
                if let expires_in = response["data","init_data","expires_in"].string {
                    sessionTimeout.setExpiresIn(Int(expires_in))
                }
                
                successHandler()
            case "confirm":
                // UI is waiting for a confirmation
                break
            case "cancel":
                triggerAction("cancel", successHandler:successHandler, failureHandler:failureHandler)
            case "authorize":
                triggerAction("confirm", successHandler:successHandler, failureHandler:failureHandler)
            case "auto_verify":
                triggerAction("verify", successHandler:successHandler, failureHandler:failureHandler)
            case "redirect":
                if response["data","type"] == "success_backtomerchant" {
                    paymentCompleted = true
                } else {
                    // 3DS or Amop redirection
                    pendingRedirection = Redirection(url:response["data","url"].stringValue, method:response["data","method"].stringValue)
                    let tdsParams = response["data","params"].dictionaryValue.map { (key:$0,value:$1.stringValue) }
                    let amopParams = response["data","amopParams"].arrayValue.map { (key:$0["key"].stringValue, value:$0["value"].stringValue) }
                    pendingRedirection?.params = tdsParams + amopParams
                }
                successHandler()
            case "wait_verify":
                break
            case "pay_failure", "error":
                failureHandler(.technicalUnexpected)
            default:
                break
        }
    }
    
    func getFieldConfig(id: String) -> DataField? {
        return additionalFields.first(where: { $0.id == id })
    }
    
    func getCountryLabel(countryCode: String) -> String {
        return countries.first(where: { $0.code == countryCode })?.label ?? countryCode
    }
    
    func resetObFees() {
        if obFeeAmount.value > 0 {
            obFeeAmount = Amount(0, self.amount.currency)
            totalAmount = Amount(self.amount.value, self.amount.currency)
        }
    }
    
    func resetVendor() {
        if let creditcard = selectedPaymentMethod as? CreditCardPaymentMethod, !creditcard.vendor.id.isEmpty {
            creditcard.vendor = CreditCardVendor()
        }
    }
    
    fileprivate func triggerAction(_ action: String , successHandler: @escaping ()->Void, failureHandler: @escaping (BackendError)->Void) {
        /*
         Supported actions: Add, Bin, Obfees, Load, Verify, Confirm
         */
        
        var data: JSON? = nil
        
        switch action {
            case "add":
                data = selectedPaymentMethod?.export()
                data!["sdk"] = [:]
                data!["sdk","app_callback_scheme"].string = appCallbackScheme
            case "bin", "obfees":
                let creditcard = selectedPaymentMethod! as! CreditCardPaymentMethod
                data = JSON(["mopid": selectedPaymentMethod!.id])
                data!["mopdata"] = [
                    "pan": creditcard.creditCardNumber
                ]
            
                if !dynamicVendor || action != "bin" {
                    data!["mopdata","vendor"].string = creditcard.vendor.id
                }
            default:
                break
        }
        
        service.call(action: action, data: data, responseHandler: {[weak self] (response: JSON?, error: BackendError?) in
            if error != nil {
                failureHandler(error!)
            } else {
                self?.payResponse(response!, successHandler:successHandler, failureHandler:failureHandler)
            }
        })
        
        lastPayload = data
    }
    
    func triggerLoad(responseHandler: @escaping ()->Void, failureHandler: @escaping (BackendError)->Void) {
        triggerAction("load", successHandler:responseHandler, failureHandler:failureHandler)
    }
    
    
    /**
     Trigger a bin validation of selected payment method, if it's credit card.
     
     A call to the bin table is done only the first time, then a cache is populated
     with the results.
     In dynamic mode, this method will also set the vendor in the data model. Note
     also that this behavior is disabled if the credit card bin changes between
     this method call , and the bin table response.
    */
    func triggerBinValidation(responseHandler: @escaping (CreditCardVendor?)->Void, failureHandler: @escaping (BackendError)->Void) {
        guard let creditcard = selectedPaymentMethod as? CreditCardPaymentMethod else {
            // Bin validation is possible only if selected method is credit card
            return
        }
        
        let vendor = dynamicVendor ? "" : creditcard.vendor.id
        let bin = creditcard.creditCardNumber[0,6]

        let binCallNeeded = !binTableCache.checkCache(bin, vendor,
            validHandler: {[weak self] realVendor in
                responseHandler(realVendor)
                if self?.dynamicVendor==true {
                    let binAfterCheck = creditcard.creditCardNumber[0,6]
                    if bin==binAfterCheck && creditcard.vendor.id != realVendor.id {
                        creditcard.vendor = realVendor
                    }
                }
            },
            invalidHandler: {[weak self] _ in
                responseHandler(nil)
                if self?.dynamicVendor==true {
                    let binAfterCheck = creditcard.creditCardNumber[0,6]
                    if bin==binAfterCheck && !creditcard.vendor.id.isEmpty {
                        creditcard.vendor = CreditCardVendor(JSON({}))
                    }
                }
            },
            unknownHandler: failureHandler
        )

        if binCallNeeded {
            triggerAction("bin"
            , successHandler: {[weak self] in
                if self?.dynamicVendor==true {
                    if self?.lastVendorFromBinTable==nil {
                        //We arrive here if bin has a vendor that is not allowed
                        self?.binTableCache.setInvalid(bin, vendor)
                    } else {
                        self?.binTableCache.setValid(bin, vendor, vendor: (self?.lastVendorFromBinTable)!)
                    }
                } else {
                    let vendorObj = creditcard.allowedVendors.first(where: { $0.id == vendor })
                    self?.binTableCache.setValid(bin, vendor, vendor: vendorObj!)
                }
            }, failureHandler: {[weak self] (error) in
                if error == BackendError.functionalValidationError {
                    // The (vendor/bin) couple is invalid
                    self?.binTableCache.setInvalid(bin, vendor)
                } else {
                    // The (vendor/bin) couple was not validated
                    self?.binTableCache.setUnknown(bin, vendor, error: error)
                }
            })
        }
    }
    
    func triggerObFees(successHandler: @escaping ()->Void, failureHandler: @escaping (BackendError)->Void) {
        triggerAction("obfees", successHandler:successHandler, failureHandler:failureHandler)
    }
    
    func triggerAdd(successHandler: @escaping ()->Void, failureHandler: @escaping (BackendError)->Void) {
        triggerAction("add", successHandler:successHandler, failureHandler:failureHandler)

    }
    
    func triggerVerify(successHandler: @escaping ()->Void, failureHandler: @escaping (BackendError)->Void) {
        sessionTimeout.preventExpiration = true
    
        triggerAction("load", successHandler:{
            if self.paymentCompleted == true {
                // Payment is verified, we can call the success handler
                successHandler()
            } else {
                failureHandler(.technicalUnexpected)
                self.sessionTimeout.preventExpiration = false
            }
        }, failureHandler:{e in
            failureHandler(e)
            self.sessionTimeout.preventExpiration = false
        })
    }
}

class Amount: NSObject {
    var value: Double = 0
    @objc dynamic var currency: String = ""

    override init() {}
    
    init(_ value: Double, _ currency: String) {
        self.value = value
        self.currency = currency
    }
}

class Redirection {
    var url: String
    var method: String
    var params: [(key:String, value:String)]?
    var completed = false
    
    init(url: String, method: String) {
        self.url = url
        self.method = method
    }
}


class PaymentMethod: NSObject {
    @objc dynamic var id: String
    @objc dynamic var name: String
    @objc dynamic var view: String
    
    init(_ jsonData : JSON) {
        self.id = jsonData["id"].stringValue
        self.name = jsonData["name"].stringValue
        self.view = jsonData["view"].stringValue
    }
    
    func export() -> JSON {
        return JSON(["mopid" : id])
    }
    
    static func create(_ jsonData : JSON, fields: [DataField]) -> PaymentMethod {
        switch(jsonData["view"]) {
        case "creditcard" , "creditcardTok":
            return CreditCardPaymentMethod(jsonData, fields: fields)
        default:
            return PaymentMethod(jsonData)
        }
    }
}



class CreditCardPaymentMethod : PaymentMethod {
    var allowedVendors: [CreditCardVendor] = []

    @objc dynamic var creditCardNumber = ""
    @objc dynamic var cvv = ""
    @objc dynamic var expiryDate = ""
    @objc dynamic var cardHolderName = ""
    @objc dynamic var vendor = CreditCardVendor()
    
    @objc dynamic var billingAddress: BillingAddress?
    
    init(_ jsonData : JSON, fields: [DataField]) {
        super.init(jsonData)
        
        for mop in jsonData["config","cardVendors"].arrayValue {
            allowedVendors.append(CreditCardVendor(mop))
        }
        
        if jsonData["config", "billingAddress"] == "true" {
            billingAddress = BillingAddress(fields: fields)
        }
    }

    override func export() -> JSON {
        var baseJson = super.export()
        baseJson["mopdata"] = [
            "CVV":cvv,
            "expmonth":expiryDate[nil,2],
            "expyear":expiryDate[-2,nil],
            "holdername":cardHolderName,
            "pan":creditCardNumber,
            "vendor":vendor.id
        ]
        if let billingAddress = billingAddress {
            baseJson["mopdata","address"] = billingAddress.export()
        }
        return baseJson
    }
    
    var expectedCvvLength: Int {
        return CardFormatter.cvvLength(for: vendor.id)
    }
}

class CreditCardVendor: NSObject {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    var hasLuhn: Bool = false
    var has3ds: Bool = false
    
    override init() {
    }
    
    init(_ jsonData : JSON) {
        self.id = jsonData["id"].stringValue
        self.name = jsonData["name"].stringValue
        self.hasLuhn = jsonData["luhn"].stringValue == "true"
        self.has3ds = jsonData["3dsecure"].stringValue == "true"
    }
}


class BillingAddress: NSObject {
    @objc dynamic var billAddressLine1: String?
    @objc dynamic var billAddressLine2: String?
    @objc dynamic var city: String?
    @objc dynamic var country: String?
    @objc dynamic var zipCode: String?
    
    init(fields: [DataField]) {
        for field in fields {
            switch field.id {
            case "billAddressLine1": billAddressLine1 = field.defaultValue
            case "billAddressLine2": billAddressLine2 = field.defaultValue
            case "city": city = field.defaultValue
            case "country": country = field.defaultValue
            case "zipCode": zipCode = field.defaultValue
            default:break
            }
        }
    }
    
    func export() -> JSON {
        var baseJson = JSON([:])
        if let billAddressLine1 = billAddressLine1 {
            baseJson["address_line1"].string = billAddressLine1
        }
        if let billAddressLine2 = billAddressLine2 {
            baseJson["address_line2"].string = billAddressLine2
        }
        if let city = city {
            baseJson["city"].string = city
        }
        if let country = country {
            baseJson["country"].string = country
        }
        if let zipCode = zipCode {
            baseJson["zipcode"].string = zipCode
        }
        return baseJson
    }
}

class DataField: NSObject {
    var id: String
    var order: Int
    var hidden: Bool
    var required: Bool
    var defaultValue: String
    
    init(_ jsonData : JSON) {
        id = jsonData["id"].stringValue
        order = jsonData["order"].intValue
        hidden = jsonData["hidden"].stringValue == "true"
        required = jsonData["required"].stringValue == "true"
        defaultValue = jsonData["value"].stringValue
    }
}


class SessionTimeout: NSObject {
    private var sessionTimer: Timer?
    private var expirationTime: Date?
    
    var preventExpiration = false
    
    @objc dynamic var expiresIn: NSNumber?
    
    override init() {
        super.init()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) {  [weak self] _ in
            self?.updateSessionTimeout()
        }
    }
    
    deinit {
        sessionTimer?.invalidate()
    }
    
    private func updateSessionTimeout() {
        if let expirationTime = expirationTime {
            if !preventExpiration {
                expiresIn = NSNumber(value: expirationTime.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate )
            }
        } else {
            expiresIn = nil
        }
    }
    
    func setExpiresIn(_ value: Int?) {
        if let value = value {
            expirationTime = Date().addingTimeInterval(TimeInterval(value))
        } else {
            expirationTime = nil
        }
    }
}
