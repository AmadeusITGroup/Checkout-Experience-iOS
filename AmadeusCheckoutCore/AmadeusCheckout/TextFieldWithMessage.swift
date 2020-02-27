//
//  MyTextField.swift
//  ErrorTextField
//
//  Created by Yann Armelin on 31/05/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import UIKit


class TextFieldWithMessage: UITextField {
    // Padding left of error icon (and spinner)
    var iconPadding: CGFloat = 4.0
    
    // Height of error label
    var messageLabelHeight: CGFloat = 16.0
    
    // Left and right padding of error label
    var messageLabelPadding: CGFloat = 0.0
    
    // Font of error message
    var messageFont: UIFont? {
        didSet {
            messageLabel?.font = messageFont
        }
    }
    
    // Color of error message
    var errorColor: UIColor? {
        didSet {
            IconViewFactory.setColor(view: errorRightView, color: errorColor)
            refresh()
        }
    }
    
    // Value of error message (hidden is value is nil)
    var errorText: String? {
        didSet {
            animateRefresh()
        }
    }
    
    // Color of error message
    var infoColor: UIColor? {
        didSet {
            IconViewFactory.setColor(view: infoRightView, color: infoColor)
            refresh()
        }
    }
    
    // Value of info message (hidden is value is nil)
    var infoText: String? {
        didSet {
            animateRefresh()
        }
    }
    
    // If true, a spinner is displayed at the location of error icon
    var isLoading = false {
        didSet {
            updateRightView()
        }
    }
    
    // Color of spinner
    var loaderColor: UIColor? {
        didSet {
            loaderRightView?.color = loaderColor
        }
    }
    
    override var font: UIFont? {
        didSet {
            messageLabel?.font = messageFont ?? font
        }
    }
    
    override var textColor: UIColor? {
        didSet {
            if !isRefreshing {
                labelColor = textColor
            }
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            if !isRefreshing {
                labelBackgroundColor = backgroundColor
            }
        }
    }
    
    fileprivate var messageContainer: UIView?
    fileprivate var messageLabel: UILabel?
    fileprivate var hasFocus = false
    fileprivate var liveErrors = false
    fileprivate var isRefreshing = false
    fileprivate var errorIconSize = CGSize.zero
    
    fileprivate var labelColor: UIColor?
    fileprivate var labelBackgroundColor: UIColor?
    
    fileprivate var errorRightView: UIView?
    fileprivate var infoRightView: UIView?
    fileprivate var loaderRightView: UIActivityIndicatorView?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initMessageView(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initMessageView(frame: frame)
    }
    
    fileprivate func initMessageView(frame: CGRect) {
        clipsToBounds = true
        
        if let iVar = class_getInstanceVariable(UITextField.self, "_placeholderLabel"), let placeholder =  object_getIvar(self, iVar) as? UILabel {
            // This is a trick to get the placeholder view, and configure it
            placeholder.minimumScaleFactor = 0.7
            placeholder.adjustsFontSizeToFitWidth = true
        }
        
        messageContainer = UIView(frame: CGRect(x:0,y:frame.size.height,width:frame.size.width,height:messageLabelHeight))
        messageContainer?.autoresizingMask =  [.flexibleWidth, .flexibleTopMargin]
        messageContainer?.backgroundColor = nil
        messageContainer?.layer.cornerRadius = 0
        messageContainer?.layer.masksToBounds = true
        
        messageLabel = UILabel(frame: CGRect(x:messageLabelPadding,y:0,width:frame.size.width - 2*messageLabelPadding,height:messageLabelHeight))
        messageLabel?.autoresizingMask =  [.flexibleWidth, .flexibleHeight]
        messageLabel?.textColor = errorColor
        messageLabel?.font = messageFont ?? font
        messageLabel?.textAlignment = .right
        messageLabel?.allowsDefaultTighteningForTruncation = true
        messageLabel?.minimumScaleFactor = 0.7
        messageLabel?.adjustsFontSizeToFitWidth = true
        messageLabel?.isUserInteractionEnabled = false
        
        messageContainer?.addSubview(messageLabel!)
        addSubview(messageContainer!)
        
        errorRightView = IconViewFactory.warning.createView(color: errorColor)
        errorRightView?.layer.opacity = 0
        errorRightView?.isUserInteractionEnabled = false
        
        infoRightView = IconViewFactory.detail.createView(color: infoColor)
        infoRightView?.layer.opacity = 0
        infoRightView?.isUserInteractionEnabled = false
        
        loaderRightView = UIActivityIndicatorView(style: .gray)
        loaderRightView?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        loaderRightView?.color = loaderColor
        loaderRightView?.isUserInteractionEnabled = false
        
        
        rightView = errorRightView
        errorIconSize = errorRightView!.frame.size
        rightViewMode = .always
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelColor = textColor
    }
    
    func updateRightView() {
        if isLoading {
            rightView = loaderRightView
            loaderRightView?.startAnimating()
        } else {
            loaderRightView?.stopAnimating()
            if errorText == nil && infoText != nil {
                rightView = infoRightView
            } else {
                rightView = errorRightView
            }
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        liveErrors = errorText != nil
        hasFocus = true
        animateRefresh()
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        hasFocus = false
        animateRefresh()
        return super.resignFirstResponder()
    }
    
    fileprivate func shouldDisplayErrorStyle() -> Bool {
        return errorText != nil && (!hasFocus || liveErrors)
    }
    fileprivate func shouldDisplaymessageLabel() -> Bool {
        return (hasFocus && liveErrors && errorText != nil) || (errorText == nil && infoText != nil)
    }
    
    fileprivate func animateRefresh() {
        UIView.animate(withDuration: 0.2, animations: {
            self.refresh()
        }, completion: nil )
    }
    
    fileprivate func refresh() {
        isRefreshing = true
        
        updateRightView()
        
        if shouldDisplayErrorStyle() {
            errorRightView?.layer.opacity = 1.0
        } else {
            errorRightView?.layer.opacity = 0
        }
        
        if infoText != nil {
            infoRightView?.layer.opacity = 1.0
        } else {
            infoRightView?.layer.opacity = 0
        }
        
        if shouldDisplaymessageLabel() {
            if errorText != nil {
                messageLabel?.text = errorText
                messageLabel?.textColor = errorColor
            } else if infoText != nil {
                messageLabel?.text = infoText
                messageLabel?.textColor = infoColor
            }
            self.messageContainer?.frame = CGRect(x:0,y:frame.size.height-messageLabelHeight,width:frame.size.width,height:messageLabelHeight)
        } else {
            self.messageContainer?.frame = CGRect(x:0,y:frame.size.height,width:frame.size.width,height:messageLabelHeight)
        }
        
        setNeedsLayout()
        
        isRefreshing = false
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let topPadding: CGFloat = 1
        let rightPadding: CGFloat = iconPadding + errorIconSize.width
        var bottomPadding: CGFloat = 0
        var leftPadding: CGFloat = (leftView?.frame.width  ?? 0)
        
        if shouldDisplaymessageLabel() {
            bottomPadding = messageLabelHeight
        }
        
        if let leftView = leftView {
            leftPadding = leftView.frame.width + iconPadding
        }
        
        return CGRect(
            x: bounds.origin.x + leftPadding,
            y: bounds.origin.y + topPadding,
            width: bounds.size.width - rightPadding - leftPadding ,
            height: bounds.size.height - topPadding - bottomPadding
        )
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(
            x:bounds.size.width /*- errorIconPadding*/ - errorIconSize.width  ,
            y:(0.5 * (bounds.size.height - errorIconSize.height - (shouldDisplaymessageLabel() ? messageLabelHeight : 0))).rounded(),
            width:errorIconSize.width,
            height:errorIconSize.height
        )
    }
}

