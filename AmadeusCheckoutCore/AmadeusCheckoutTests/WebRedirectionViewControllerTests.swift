//
//  CreditCardViewControllerTests.swift
//  AmadeusCheckoutTests
//
//  Created by Yann Armelin on 12/08/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import XCTest
import WebKit
@testable import AmadeusCheckout

// Fake WKNavigationAction, that wraps a URLRequest
class TestableNavigationAction: WKNavigationAction {
    let testRequest: URLRequest
    override var request: URLRequest {
        return testRequest
    }
    init(_ testRequest: URLRequest) {
        self.testRequest = testRequest
    }
}

// Fake webview, that doesn't load any request, but exposes the last loaded request
fileprivate class TestableWebView: WKWebView {
    var loadedRequest: URLRequest?
    var loadedRequestCallback: (()->Void)?

    override func load(_ request: URLRequest) -> WKNavigation? {
        var policy = WKNavigationActionPolicy.allow
        self.navigationDelegate?.webView?(self, decidePolicyFor: TestableNavigationAction(request), decisionHandler: { policy = $0 })
        if policy == .allow {
            self.loadedRequest = request
            self.loadedRequestCallback?()
            self.navigationDelegate?.webView?(self, didFinish: nil)
        }
        return nil
    }
}

// Fake load indicator, that returns immediately
fileprivate class TestableLoadIndicator: LoadIndicator {
    override init() {
        super.init()
    }
    override func start(_ hostViewController: UIViewController, callback:@escaping () -> Void) {
        callback()
    }
    override func stop(callback:@escaping () -> Void) {
        callback()
    }
}


class WebRedirectionViewControllerTests: XCTestCase, AMCheckoutDelegate {
    var vc: WebRedirectionViewController!
    var ctx: AMCheckoutContext!
    fileprivate var wv: TestableWebView!
    
    // This function is called, then nullified when the CheckoutContext is terminated
    var finishCallback: ((AMPaymentStatus)->Void)?
    
    
    override func setUp() {
        super.setUp()

        // Context intialization
        ctx = AMCheckoutContext(ppid: "1234", environment: .mock)
        ctx.delegate = self
        let options = AMCheckoutOptions()
        options.appCallbackScheme = "test-scheme"
        ctx.options = options
        
        // View Controller creation
        let storyboard = UIStoryboard(name: StoryboardConstants.Filename, bundle: FileTools.mainBundle)
        vc = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.WebRedirectionContentViewController) as? WebRedirectionViewController
        
        // We override the LoadIndicator with the fake one
        LoadIndicator.sharedInstance = TestableLoadIndicator()
        
        // We override the WebView with the fake one
        wv = TestableWebView()
        vc.webview = wv
        
        // Mock response time
        BackendServicesMock.delay = 0.01
    }
    
    override func tearDown() {
        ctx = nil
        wv = nil
        vc = nil
        finishCallback = nil
    }
    
    func paymentContext(_ checkoutContext: AMCheckoutContext, didFinishWithStatus status: AMPaymentStatus, error: Error?) {
        finishCallback?(status)
        finishCallback = nil
    }

    
    func testInit() {
        // Check the view controller is not nil
        XCTAssertNotNil(vc)
    }
    
    func testImmediateRedirection() {
        // Add a pending redirection in the context
        let redir = Redirection(url: "https://test", method: "POST")
        redir.params = [(key:"AKEY",value:"AVALUE")]
        vc.ctx!.dataModel?.pendingRedirection = redir
        
        // viewDidLoad should do the redirection to the pending URL
        let expectation = self.expectation(description: "LOADED")
        wv.loadedRequestCallback = {
            expectation.fulfill()
        }
        vc.viewDidLoad()
        waitForExpectations(timeout: 0.5, handler: nil)
        
        // Check if the redirection was properly done
        XCTAssertEqual(wv.loadedRequest?.url, URL(string: redir.url))

        // Simulate a load request of `test-scheme://1234` , that means the external redirection is over
        let expectation2 = self.expectation(description: "FINISHED")
        var status: AMPaymentStatus? = nil
        finishCallback = {finalStatus in
            status = finalStatus
            expectation2.fulfill()
        }
        BackendServicesMock.auto_verify_once = true
        let _ = wv.load(URLRequest(url: URL(string: "test-scheme://1234")!))
        waitForExpectations(timeout: 0.5, handler: nil)
        
        // Check the overall status is correct
        XCTAssertEqual(status, AMPaymentStatus.success)
    }
    
    func testAddThenRedirection() {
        // Set an AMOP as the selected payment method
        let amop = PaymentMethod(["id":"amop0","name":"Bancontact","view":"amop0"])
        vc.ctx!.dataModel?.selectedPaymentMethod = amop
        
        // viewDidLoad should trigger an 'add' action on the AMOP, then do the redirection
        // (redirection is not done immediately, because there is no pending redirection)
        let expectation = self.expectation(description: "LOADED")
        wv.loadedRequestCallback = {
            expectation.fulfill()
        }
        vc.viewDidLoad()
        waitForExpectations(timeout: 0.5, handler: nil)
        
        
        // Check if the redirection was properly done
        XCTAssertEqual(wv.loadedRequest?.url, URL(string: "https://paypages.test.payment.amadeus.com/1ASIATP/ACSWPP/acs"))

        // Simulate a load request of `test-scheme://1234` coming from an external application,
        // that means the external redirection is over
        let expectation2 = self.expectation(description: "FINISHED")
        finishCallback = {_ in
            expectation2.fulfill()
        }
        BackendServicesMock.auto_verify_once = true
        XCTAssertTrue( AMCheckoutContext.handleUrl(URL(string: "test-scheme://1234")!) )
        waitForExpectations(timeout: 0.5, handler: nil)

        
    }
}

