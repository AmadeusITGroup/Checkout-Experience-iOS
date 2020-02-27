//
//  CreditCardToolbar.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 05/09/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation
import SafariServices


class CreditCardToolbar: UIView, SFSafariViewControllerDelegate {
    let toolbarLineHeight: CGFloat = 50.0
    var toolbarHeight: CGFloat
    let checkboxMargin: CGFloat = 16.0
    let checkboxSize: CGFloat = 21.0
    
    var termAndConditionsAccepted: Bool {
        checkbox?.isChecked ?? false
    }
    var termsAndConditionsList: [AMTermsAndConditions] = []
    
    var theme: Theme
    
    var checkbox: Checkbox!
    var payButton: UIButton!
    var amountButton: UIButton!
    var amountBreakDownIcon: UIView!
    var contentWrapper: UIView!
    var amountBreakdownPopover: AmountBreakdownPopoverController
    
    weak var hostViewController: UIViewController!
    var displayedInsideTableView = false

    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented.")
    }

    init(termsAndConditions:[AMTermsAndConditions] , theme: Theme) {
        self.theme = theme
        self.termsAndConditionsList = termsAndConditions
        self.toolbarHeight = termsAndConditions.isEmpty ? toolbarLineHeight : 2*toolbarLineHeight
        self.amountBreakdownPopover = AmountBreakdownPopoverController(theme: theme)
        super.init(frame: CGRect(x:0,y:0,width:400, height:toolbarHeight))
        configureView()
    }

    private func configureView() {
        // Root view configuration
        backgroundColor = .clear
        autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        

        initContentWrapper()
        if !termsAndConditionsList.isEmpty {
            initTermsAndConditionViews()
        }
        initAmountViews()
    }
    
    /**
     Initialize the container of the toolbar, with a regular blur effect as background.
     */
    private func initContentWrapper() {
        // Content wrapper
        contentWrapper = UIView(frame: CGRect(x:0,y:0,width:400, height:toolbarHeight))
        var style: UIBlurEffect.Style = .light
        if #available(iOS 11.0, *) {
            style = .regular
        }
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
          blurView.heightAnchor.constraint(equalTo: heightAnchor),
          blurView.widthAnchor.constraint(equalTo: widthAnchor),
          blurView.centerXAnchor.constraint(equalTo: centerXAnchor),
          blurView.centerYAnchor.constraint(equalTo: centerYAnchor)
          ])

        blurView.contentView.addSubview(contentWrapper)
    }
    
    private func colorizeLabel(_ label: String) -> NSMutableAttributedString {
        var labelCopy = label
        let startIndex = labelCopy.firstIndex(of: "[")
        if startIndex != nil {
            labelCopy.remove(at: startIndex!)
        }
        
        let endIndex = labelCopy.firstIndex(of: "]")
        if endIndex != nil {
            labelCopy.remove(at: endIndex!)
        }
        let colorizedLabel = NSMutableAttributedString(
            string: labelCopy,
            attributes: [
                NSAttributedString.Key.foregroundColor:theme.primaryForegroundColor as Any,
                NSAttributedString.Key.font:theme.font as Any
            ]
        )
        if let start = startIndex?.utf16Offset(in: labelCopy), let end = endIndex?.utf16Offset(in: labelCopy) {
            colorizedLabel.setAttributes([ NSAttributedString.Key.foregroundColor:theme.accentColor as Any], range: NSRange(location:start, length: end - start))
        }
        return colorizedLabel
    }
    
    private func initTermsAndConditionViews() {
        // Checkbox configuration
        checkbox = Checkbox()
        checkbox.isOpaque = false
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.color = theme.accentColor
        contentWrapper.addSubview(checkbox)
        
        // Label configuration
        let label = UILabel()
        label.attributedText = colorizeLabel("valid_termcondition".localize(type: .label))
        label.allowsDefaultTighteningForTruncation = true
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        contentWrapper.addSubview(label)
        
        
        var checkboxLeadingAnchor = contentWrapper.leadingAnchor
        if #available(iOS 11.0, *) {
            checkboxLeadingAnchor = contentWrapper.safeAreaLayoutGuide.leadingAnchor
        }
        
        NSLayoutConstraint.activate([
            checkbox.centerYAnchor.constraint(equalTo: contentWrapper.topAnchor, constant: 0.5*toolbarLineHeight),
            checkbox.leadingAnchor.constraint(equalTo: checkboxLeadingAnchor, constant: checkboxMargin),
            checkbox.widthAnchor.constraint(equalToConstant: checkboxSize),
            checkbox.heightAnchor.constraint(equalToConstant: checkboxSize),
            
            label.topAnchor.constraint(equalTo: contentWrapper.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: contentWrapper.bottomAnchor, constant: -toolbarLineHeight-4),
            label.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentWrapper.trailingAnchor, constant: -checkboxMargin)
        ])
        
        // Tap handler configuration
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(self.didClickOnTerms))
        tap.minimumPressDuration = 0
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
    }
    
    
    private func initAmountViews() {
        payButton = UIButton(type: .system)
        payButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.setTitle("next".localize(type: .button), for: .normal)
        payButton.titleLabel?.font = theme.font
        payButton.tintColor = theme.primaryBackgroundColor
        payButton.accessibilityIdentifier = "pay_button"
        payButton.backgroundColor = theme.accentColor
        payButton.layer.cornerRadius = 8.0
        
        amountButton = UIButton(type: .system)
        amountButton.translatesAutoresizingMaskIntoConstraints = false
        amountButton.addTarget(self, action: #selector(self.didClickOnAmount), for: .touchUpInside)
        amountButton.backgroundColor = .clear
        amountButton.tintColor = theme.accentColor
        amountButton.titleLabel!.adjustsFontSizeToFitWidth = true
        amountButton.titleLabel!.minimumScaleFactor = 0.5
        amountButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 28.0)
        amountButton.titleLabel?.font = theme.font
        
        refreshAmountBreakdownButton()
        
        contentWrapper.addSubview(payButton)
        contentWrapper.addSubview(amountButton)
        
        NSLayoutConstraint.activate([
            payButton.heightAnchor.constraint(equalToConstant: toolbarLineHeight - 16.0),
            payButton.trailingAnchor.constraint(equalTo: contentWrapper.trailingAnchor, constant: -8.0),
            payButton.leadingAnchor.constraint(equalTo: contentWrapper.centerXAnchor, constant: 8.0),
            payButton.bottomAnchor.constraint(equalTo: contentWrapper.bottomAnchor, constant: -8.0),
            
            amountButton.heightAnchor.constraint(equalToConstant: toolbarLineHeight),
            amountButton.leadingAnchor.constraint(equalTo: contentWrapper.leadingAnchor, constant: 8.0),
            amountButton.trailingAnchor.constraint(equalTo: contentWrapper.centerXAnchor),
            amountButton.bottomAnchor.constraint(equalTo: contentWrapper.bottomAnchor)
        ])
    }
    
    /**
     Refresh the open/close icon next to the amount button.
     */
    private func refreshAmountBreakdownButton() {
        if amountBreakDownIcon != nil {
            amountBreakDownIcon!.removeFromSuperview()
        }
        let icon = amountBreakdownPopover.isBeingPresented ? IconViewFactory.chevronDown : IconViewFactory.chevronUp
        amountBreakDownIcon = icon.createView(color: theme.accentColor, scaleToFit: true)
        amountBreakDownIcon.translatesAutoresizingMaskIntoConstraints = false
        amountBreakDownIcon.isUserInteractionEnabled = false
        amountButton.addSubview(amountBreakDownIcon)
        
        NSLayoutConstraint.activate([
            amountBreakDownIcon.topAnchor.constraint(equalTo: amountButton.topAnchor),
            amountBreakDownIcon.bottomAnchor.constraint(equalTo: amountButton.bottomAnchor),
            amountBreakDownIcon.trailingAnchor.constraint(equalTo: amountButton.trailingAnchor, constant: -8),
            amountBreakDownIcon.widthAnchor.constraint(equalToConstant: 20.0)
        ])
    }
    
    // MARK: view lifecycle
    override func layoutSubviews() {
        if let parent = superview {
            adaptFrame(to: parent)
        }
    }
    
    // MARK: public instance methods
    var height: CGFloat {
        return isHidden ? 0 : toolbarHeight
    }
    
    func display(insideTableView tableViewController: UITableViewController) {
        displayedInsideTableView = true
        self.removeFromSuperview()
        adaptFrame(to: tableViewController.view)
        let tableFooterWrapperView = UIView(frame: CGRect(x:0,y:0,width:400, height:toolbarHeight))
        tableViewController.tableView.tableFooterView = tableFooterWrapperView
        tableFooterWrapperView.addSubview(self)
    }
    
    func display(inside viewController: UIViewController) {
        displayedInsideTableView = false
        self.removeFromSuperview()
        adaptFrame(to: viewController.view)
        viewController.view.addSubview(self)
    }

    func setAmounts(total amount : Double, currency: String, breakdown: [AMAmountDetails]) {
        let totalStr = Translator.formatAmount(amount, currency: currency)
        amountButton.setTitle("total".localize(type: .button).replacingOccurrences(of: "{0}", with: totalStr), for: .normal)
        amountBreakdownPopover.amountBreakdown = breakdown
        amountBreakdownPopover.currency = currency
    }
    
    // MARK: private utils

    private func adaptFrame(to view: UIView) {
        var myViewFrame = view.frame

        if !displayedInsideTableView {
            var safeAreaMargin: CGFloat = 0.0
            if #available(iOS 11.0, *) {
                safeAreaMargin = view.safeAreaInsets.bottom
            }
            myViewFrame.origin.y = myViewFrame.minY + myViewFrame.height - height - safeAreaMargin
            myViewFrame.size.height = height + safeAreaMargin
        } else {
            myViewFrame.origin.y = 0
            myViewFrame.size.height = height
        }
        
        
        var wrapperFrame = contentWrapper.frame
        wrapperFrame.size.width = myViewFrame.size.width
        contentWrapper.frame = wrapperFrame
        
        frame = myViewFrame
    }
    
    private func displayTermsAndCondtionSheet(animated: Bool) {
        if termsAndConditionsList.count > 1 {
            // If there are several links, we let the user chose the one he wants to see
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            for item in termsAndConditionsList {
                alertController.addAction(UIAlertAction(title: item.localizedLabel, style: .default) {_ in
                    self.openLink(item.link)
                })
            }
            alertController.popoverPresentationController?.sourceView = self
            alertController.popoverPresentationController?.sourceRect = self.bounds
            alertController.addAction(UIAlertAction(title: "back".localize(type: .button), style: .cancel, handler: nil))
            hostViewController.present(alertController, animated:animated, completion:nil)
        } else {
            // If there is only one link, we open it immediately
            self.openLink(termsAndConditionsList.first!.link)
        }
    }
    
    private func openLink(_ url: URL) {
        let browser = SFSafariViewController(url: url)
        browser.delegate = self
        browser.modalPresentationStyle = .currentContext
        self.hostViewController.present(browser, animated: true, completion: nil)
    }
    
    // MARK: UI Actions
    @objc private func didClickOnTerms(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            backgroundColor = theme.secondaryBackgroundColor  // BGCOLOR container
        } else if sender.state == .ended {
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundColor = .clear // self.theme.primaryBackgroundColor  // BGCOLOR container
            }, completion: {_ in
                self.displayTermsAndCondtionSheet(animated: true)
            } )
        }
    }
    
    @objc private func didClickOnAmount(sender: Any){
        hostViewController.view.endEditing(false)
        amountBreakdownPopover.open(in: hostViewController, from: self ) {[weak self] in
            if self != nil {
                self!.refreshAmountBreakdownButton()
            }
        }
        refreshAmountBreakdownButton()
    }
    
    // MARK: SFSafariViewControllerDelegate
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if termsAndConditionsList.count > 1 {
            displayTermsAndCondtionSheet(animated: false)
        }
    }
}
