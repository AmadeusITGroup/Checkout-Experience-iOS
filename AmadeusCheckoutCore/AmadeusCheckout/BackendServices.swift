//
//  BackendServices.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 10/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation



enum Environment: String {
    case mock, pdt, mig, uat, frt, prd
    
    var isMock: Bool {
        get {
            return self == .mock
        }
    }
    
    var payUrl: String {
        get {
            return (Environment.urlDictionnary[self] ?? "")+"pay"
        }
    }
    
    var landUrl: String {
        get {
            return (Environment.urlDictionnary[self] ?? "")+"land"
        }
    }
    
    static let urlDictionnary : [Environment: String] = [
        .pdt : "https://paypages.test.payment.amadeus.com/1ASIATP/ARIAPP/",
        .mig : "https://paypages.test.payment.amadeus.com/1ASIATPM/ARIAPP/",
        .uat : "https://paypages.test.payment.amadeus.com/1ASIATPU/ARIAPP/",
        .frt : "https://paypages.test.payment.amadeus.com/1ASIATPF/ARIAPP/",
        .prd : "https://paypages.payment.amadeus.com/1ASIATP/ARIAPP/",
        .mock : "https://mock.com/"
    ]
}

enum BackendError: Error {
    /* This error occurs when we didn't receive any response from the backend after a certain duration. */
    case technicalNetworkFailure
    
    /* This error occurs when the network is unreachable, and user decided not to retry. */
    case technicalUnreachableNetwork
    
    /* The error refers to the following cases:
      - Unable to parse JSON response
      - Invalid JSON response
      - PPID is expired
      - KO case, with label_error_payment_rto
      - KO case, with label_error_fop_solution
      - KO case, with label_error_internal,
    */
    case technicalUnexpected
    
    /* This error refers to the following KO cases:
      - label_error_bin_vendor
      - label_error_bin
      - label_error_bin_type
    */
    case functionalValidationError
    
    /* This error refers to the following KO cases:
     - label_error_payment
     */
    case functionalPaymentError
    
    /* This error refers to the following KO cases:
     - label_error_abort
     */
    case functionalAborted
    
    func isFunctional() -> Bool {
        switch self {
        case .technicalUnreachableNetwork, .technicalNetworkFailure, .technicalUnexpected: return false
        case .functionalValidationError, .functionalPaymentError, .functionalAborted: return true
        }
    }
    
    func isTechnical() -> Bool {
        return !isFunctional()
    }
}

class BackendServices {
    typealias Callback = (JSON?, BackendError?)->Void
    
    static let queryTimeout = 10.0

    var environement: Environment
    var ppid: String
    
    init(environement: Environment, ppid: String) {
        self.environement = environement
        self.ppid = ppid
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleNetworkAlertRetryResponse),
            name: NSNotification.Name.AMRequestNetworkRetry,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleNetworkAlertCancelResponse),
            name: NSNotification.Name.AMRequestNetworkCancel,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    static func create(environement: Environment, ppid: String) -> BackendServices {
        if environement.isMock {
            return BackendServicesMock(environement:environement, ppid:ppid)
        } else {
            return BackendServices(environement: environement, ppid: ppid)
        }
    }
    
    static func mapError(response json: JSON) -> BackendError? {
        if json["status"].stringValue != "OK" {
            for error in json["messages"].arrayValue  {
                switch error["text"].stringValue {
                case "label_error_payment_rto", "label_error_fop_solution", "label_error_internal":
                    return .technicalUnexpected
                case "label_error_bin_vendor", "label_error_bin", "label_error_bin_type":
                    return .functionalValidationError
                case "label_error_payment":
                    return .functionalPaymentError
                case "label_error_abort":
                    return .functionalAborted
                default:
                    break
                }
            }
            return .technicalUnexpected
        }
        return nil
    }
    
    @objc fileprivate func handleNetworkAlertCancelResponse() {
        NetworkTaskQueue.sharedInstance.cancelTasks()
    }
    
    @objc fileprivate func handleNetworkAlertRetryResponse() {
        NetworkTaskQueue.sharedInstance.retryStuckTasks()
    }
    
    func call(action: String, data: JSON? = nil, responseHandler: @escaping Callback) {
        var params: JSON = ["action":action, "PPID":self.ppid]

        if data != nil {
            params["data"] = data!
        }
        
        var request = URLRequest(url: URL(string: environement.payUrl)!)

        request.httpMethod = "POST"
        request.timeoutInterval = BackendServices.queryTimeout

        do {
            request.httpBody = try params.rawData()
        } catch {
            print("BackendServices: unable to encode JSON Data")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            DispatchQueue.main.async {
                if (error as NSError?)?.code == NSURLErrorCancelled {
                    // We end up here, if user cancels the payment after a network alert.
                    responseHandler(nil, .technicalUnreachableNetwork)
                } else if data == nil || error != nil {
                    responseHandler(nil, .technicalNetworkFailure)
                } else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    print("BackendServices: \(statusCode) for \(response!.url!)")
                    do {
                        let json = try JSON.init(data: data!)
                        responseHandler(json, BackendServices.mapError(response: json))
                    } catch {
                        print("BackendServices: unable to decode JSON Response")
                        responseHandler(nil, .technicalUnexpected)
                    }
                }
            }
        })
        
        
        NetworkTaskQueue.sharedInstance.handleTask(task)
    }
}
