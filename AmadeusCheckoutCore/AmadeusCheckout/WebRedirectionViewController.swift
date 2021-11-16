//
//  WebRedirectionViewController.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 10/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation
import WebKit


class WebRedirectionViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    var webview: WKWebView!
    var amopFlow = false
    var isRedirectionFinished = false
    
    var theme = Theme.sharedInstance
    weak var ctx: AMCheckoutContext? = AMCheckoutContext.sharedContext
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.checkRedirectionStatus),
            name: NSNotification.Name.AMBackFromRedirection,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        if webview == nil {
            initWebView()
        }
        webview.uiDelegate = self
        webview.navigationDelegate = self

        if let pendingRedirection = ctx?.dataModel?.pendingRedirection {
            amopFlow = false
            initRedirection(pendingRedirection)
        } else {
            amopFlow = true
            ctx?.dataModel?.triggerAdd(successHandler: {[weak self] in
                if let pendingRedirection = self?.ctx?.dataModel?.pendingRedirection {
                    self?.initRedirection(pendingRedirection)
                } else {
                    // No redirection from AMOP - close MOP
                    self?.closeWebViewWithStatus(.failure, error: NSError.checkoutError(type:.unexpectedError, feature:.addAlternativeMethodOfPayment))
                }
            }, failureHandler: {[weak self] error in
                // Error when adding the AMOP - close MOP
                if error == .technicalNetworkFailure || error == .technicalUnreachableNetwork {
                    self?.closeWebViewWithStatus(.failure, error: NSError.checkoutError(type:.networkFailure, feature:.addAlternativeMethodOfPayment))
                } else {
                    self?.closeWebViewWithStatus(.failure, error: NSError.checkoutError(type:.unexpectedError, feature:.addAlternativeMethodOfPayment))
                }
            })
        }
        
        updateAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         if #available(iOS 13.0, *) {
              navigationController?.navigationBar.setNeedsLayout()
         }
    }
    
    private func initWebView() {
        webview = WKWebView(frame: view.frame)
        view = webview
    }
    
    func updateAppearance() {
        if let bar = navigationController?.navigationBar {
            theme.apply(navigationBar: bar)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        closeWebViewWithStatus(.cancellation, error: nil)
    }
    
    fileprivate func closeWebViewWithStatus(_ status: AMPaymentStatus, error: Error?) {
        if amopFlow {
            ctx?.closeWithStatus(status, error: error)
        } else {
            switch(status) {
            case .cancellation:
                self.performSegue(withIdentifier: StoryboardConstants.TdsRedirectionCancelledByUserSegue, sender: self)
            case .failure:
                self.performSegue(withIdentifier: StoryboardConstants.TdsRedirectionFailedSegue, sender: self)
            case .unknown:
                ctx?.closeWithStatus(.unknown, error: error)
            case .success:
                ctx?.closeWithStatus(.success, error: nil)
            }
        }
    }
    
    func initRedirection(_ redirection: Redirection) {
        let url = URL(string: redirection.url)!
        var request = URLRequest(url: url)
        if redirection.method == "GET" {
            request.httpMethod = "GET"
        } else {
            guard #available(iOS 11.0, *) else {
                /** **Workaround for iOS 10 Bug:**
                 * On iOS 10, `WKWebView` is not able to load a POST request that contains
                 * a http body.
                 * Instead we have to load a generated dummy html page, that will do the POST.
                 */
                initPostRedirectionIOS10Workaround(redirection)
                return
            }
            
            request.httpMethod = "POST"
            var components = URLComponents()
            var allowedCharacters = CharacterSet()
            allowedCharacters.insert(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.!~*'()")
            components.queryItems = redirection.params?.map {
                URLQueryItem(name: $0.key.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!, value: $0.value.addingPercentEncoding(withAllowedCharacters: allowedCharacters))
            }
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = components.query?.data(using: .utf8)
        }
        
        LoadIndicator.sharedInstance.start(self) {
            self.webview.load(request)
        }
    }
    
    func htmlEscape(_ str: String) -> String {
        var result = ""
        for character in str {
            result += character.unicodeScalars.reduce(into: "") { $0 += "&#\($1.value);" }
        }
        return result
    }
    
    func initPostRedirectionIOS10Workaround(_ redirection: Redirection) {
        var htmlForm = "<form method='POST' action='\(htmlEscape(redirection.url))\'>"
        for param  in redirection.params ?? [] {
            htmlForm += "<input type='hidden' name='\(htmlEscape(param.key))' value='\(htmlEscape(param.value))'/>"
        }
        htmlForm += "</form><script type='text/javascript'>document.forms[0].submit()</script>"
        
        LoadIndicator.sharedInstance.start(self) {
            self.webview.loadHTMLString(htmlForm, baseURL: nil)
        }
    }
        
    @objc func checkRedirectionStatus () {        
        LoadIndicator.sharedInstance.start(self) {
            self.ctx?.dataModel?.triggerVerify(successHandler: {[weak self] in
                LoadIndicator.sharedInstance.stop() {
                    self?.closeWebViewWithStatus(.success, error: nil)
                }
            }, failureHandler: {[weak self] error in
                LoadIndicator.sharedInstance.stop() {[weak self]  in
                    print("WebRedirectionViewController: Redirection status is KO")
                    if error == .functionalAborted {
                        self?.closeWebViewWithStatus(.cancellation, error: nil)
                    } else if error.isFunctional() {
                        self?.closeWebViewWithStatus(.failure, error: NSError.checkoutError(type:.paymentError, feature:.verifyAfterRedirection))
                    } else if error == .technicalNetworkFailure || error == .technicalUnreachableNetwork {
                        self?.closeWebViewWithStatus(.unknown, error: NSError.checkoutError(type:.networkFailure, feature:.verifyAfterRedirection))
                    } else {
                        self?.closeWebViewWithStatus(.unknown, error: NSError.checkoutError(type:.unexpectedError, feature:.verifyAfterRedirection))
                    }
                }
            })
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void))
    {
        if let url = navigationAction.request.url, let ctx = ctx, let env = ctx.dataModel?.environement {
            let loadedPage = url.description
            print("WebRedirectionViewController: webView shouldStartLoadWith \(loadedPage)")
            let callbackScheme = "\(ctx.options.appCallbackScheme)://"
            if loadedPage.starts(with: env.landUrl) || loadedPage.starts(with: callbackScheme) {
                isRedirectionFinished = true
                checkRedirectionStatus()
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        LoadIndicator.sharedInstance.stop() {
            print("WebRedirectionViewController: webView webViewDidFinishLoad")
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if !isRedirectionFinished {
            self.closeWebViewWithStatus(.failure, error: NSError.checkoutError(type:.networkFailure, feature:.webViewRedirection))
        }
    }

    /// Handle javascript:alert(...)
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok".localize(type: .button), style: .default) { _ in
            completionHandler()
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Handle javascript:confirm(...)
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok".localize(type: .button), style: .default) { _ in completionHandler(true) })
        alertController.addAction(UIAlertAction(title: "back".localize(type: .button), style: .cancel) { _ in completionHandler(false)})
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Handle javascript:prompt(...)
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in  textField.text = defaultText }
        alertController.addAction( UIAlertAction(title: "ok".localize(type: .button), style: .default) { action in
            let textField = alertController.textFields![0] as UITextField
            completionHandler(textField.text)
        })
        alertController.addAction(UIAlertAction(title: "back".localize(type: .button), style: .cancel) { _ in completionHandler(nil) })
        self.present(alertController, animated: true, completion: nil)
    }

}
