//
//  CreditCardViewController.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 08/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


class CreditCardViewController: UITableViewController, KeyboardToolbarDelegate, UITextFieldDelegate {
    
    // MARK: IBOutlets
    @IBOutlet var formTableView: UITableView!
    @IBOutlet weak var payButton: UIBarButtonItem!
    @IBOutlet weak var expiryPicker: ExpiryPickerView!
    
    var keyboardToolbar: KeyboardToolbar!
    var payToolbar: CreditCardToolbar!
    var bookingDetailsView: BookingDetailsView!
    var overlay: UIView?
    
    // MARK: Instance properties
    weak var ctx: AMCheckoutContext? = AMCheckoutContext.sharedContext
    var theme = Theme.sharedInstance
    var bindingFactory = CreditCardBindingFactory()
    var tableModel = TableModel()
    var creditCardMethod: CreditCardPaymentMethod?
    var autofocus: IndexPath?
    var pendingError = false
    
    
    var bindingsAggregatorObservation: NSKeyValueObservation?
    var ccVendorObservation: NSKeyValueObservation?
    var obFeesObservation: NSKeyValueObservation?
    
    // MARK: Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        deregisterFromKeyboardNotifications()
        if let overlay = overlay {
            overlay.removeFromSuperview()
        }
        payToolbar.removeFromSuperview()
    }
    
    
    // MARK: Instance methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.creditCardMethod = ctx?.dataModel?.selectedPaymentMethod as? CreditCardPaymentMethod
        
        keyboardToolbar = KeyboardToolbar()
        keyboardToolbar.toolBarDelegate = self
        
        payToolbar = CreditCardToolbar(termsAndConditions:(ctx?.options.termsAndConditions) ?? [], theme:theme)
        payToolbar.hostViewController = self
        payToolbar.payButton.addTarget(self, action: #selector(self.pay(_:)), for: .touchUpInside)
        
        if let bookingDetails = ctx?.options.bookingDetails {
            bookingDetailsView = BookingDetailsView(bookingDetails)
            bookingDetailsView.tableView = tableView
            tableView.tableHeaderView = bookingDetailsView
        }
        
        if let navigationController = navigationController {
            // We insert the overlay inside the navigation controller,
            // so that it's above the current view controller, but
            // below the toolbar and the amount breakdown popover.
            overlay = UIView(frame: navigationController.view.frame)
            overlay!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlay!.isUserInteractionEnabled = false
            overlay!.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            overlay!.alpha = 0.0
            navigationController.view.addSubview(overlay!)
        }
        
        
        initFormGroups()
        initBindings()
        updateAppearance()
        
        registerForKeyboardNotifications()
    }
            
    var displayOverlay: Bool = false {
        didSet  {
            let opacity: CGFloat = displayOverlay ? 0.5 : 0.0
            UIView.animate(withDuration: 0.1) {[weak self] in
                self?.overlay?.alpha = opacity
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        payToolbar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.isUserInteractionEnabled = true
        formTableView.reloadData()
        if let unwrappedAutofocus = autofocus {
            transferRowSelectionToField(at: unwrappedAutofocus, openDetails: true)
            autofocus = nil
        }
        
        payToolbar.isHidden = false
        updateLayout(keyboardHeight: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if pendingError {
            pendingError = false
            openPaymentErrorAlert()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        if segue.identifier == StoryboardConstants.SelectVendorSegue,
            let creditCardVendorViewController = segue.destination as? CreditCardVendorViewController
        {
            tableView.endEditing(true)
            creditCardVendorViewController.creditCardMethod = creditCardMethod
            creditCardVendorViewController.title = "vendor".localize(type: .label)
        }
        if segue.identifier == StoryboardConstants.SelectCountrySegue,
            let valueSelectorViewController = segue.destination as? ValueSelectorViewController
        {
            tableView.endEditing(true)
            if let rootModel = ctx?.dataModel {
                valueSelectorViewController.values = rootModel.countries
            }
            valueSelectorViewController.binding = tableModel.getBindings(forCell: .billingAddressCountry)[0]
            valueSelectorViewController.title = "country".localize(type: .label)
        }
    }
    
    func initFormGroups() {
        tableModel.clear()
        
        var section = 0
        
        // Payment card group
        section = tableModel.addSection(title: "ccdetails".localize(type: .label))
        tableModel.addCell(.cardholderName, inSection: section)
        if ctx?.options?.dynamicVendor == true {
        } else {
            tableModel.addCell(.cardVendor, inSection: section)
        }
        tableModel.addCell(.cardNumber, inSection: section)
        tableModel.addCell(.cardExpiry, inSection: section)
        tableModel.addCell(.cardCvv, inSection: section)
        
        // Billing address group
        if let billingAddress = creditCardMethod?.billingAddress {
            var billingAddressFields: [TableModel.Cell] = []
            if billingAddress.billAddressLine1 != nil {
                billingAddressFields.append(.billingAddressLine1)
            }
            if billingAddress.billAddressLine2 != nil {
                billingAddressFields.append(.billingAddressLine2)
            }
            if billingAddress.zipCode != nil {
                billingAddressFields.append(.billingAddressZipCode)
            }
            if billingAddress.city != nil {
                billingAddressFields.append(.billingAddressCity)
            }
            if billingAddress.country != nil {
                billingAddressFields.append(.billingAddressCountry)
            }
            if billingAddressFields.count>0 {
                section = tableModel.addSection(title: "billingAddress".localize(type: .label))
                for field in billingAddressFields {
                    tableModel.addCell(field, inSection: section)
                }
            }
        }
        
        // Pay button group
        if ctx?.options?.displayPayButtonOnTop != true {
            self.navigationItem.rightBarButtonItems?.removeAll(where: { $0 === self.payButton } )
        }
    }

    /**
    Return the amount breakdown to be displayed in the amount breakdown popover.
    If there is no amount provided in the options, the base price is returned instead.
    OB fees are appened at the end of the list.
     */
    private func getAmountBreakdown() -> [AMAmountDetails] {
        var result: [AMAmountDetails] = []
        if let baseBreakdown = ctx?.options?.amountBreakdown, baseBreakdown.count > 0 {
            result = baseBreakdown
        } else if let rootModel = ctx?.dataModel {
            result = [AMAmountDetails(label:"baseamount".localize(type: .label), amount: rootModel.amount.value)]
        }
        if let rootModel = ctx?.dataModel, rootModel.obFeeAmount.value > Double.leastNormalMagnitude {
            result = result + [AMAmountDetails(label: "fees".localize(type: .label), amount: rootModel.obFeeAmount.value)]
        }
        return result
    }
    
    func initBindings() {
        if let rootModel = ctx?.dataModel , let model = creditCardMethod {
            tableModel.setBindings(forCell: .cardVendor, newBindings: bindingFactory.createVendorBindings(model: model))
            tableModel.setBindings(forCell: .cardExpiry, newBindings: bindingFactory.createExpiryBindings(model: model))
            tableModel.setBindings(forCell: .cardholderName, newBindings: bindingFactory.createCardHoldernameBindings(model: model))
            tableModel.setBindings(forCell: .cardNumber, newBindings: bindingFactory.createCardNumberBindings(rootModel: rootModel, model: model, dynamic: ctx?.options?.dynamicVendor == true))
            tableModel.setBindings(forCell: .cardCvv, newBindings: bindingFactory.createCvvBindings(model: model))

            
            if creditCardMethod?.billingAddress != nil {
                if let cfg = rootModel.getFieldConfig(id: "billAddressLine1") {
                    tableModel.setBindings(forCell: .billingAddressLine1, newBindings:bindingFactory.createAddressLine1Bindings(model: model, required: cfg.required))
                    tableModel.setIsOptional(cell: .billingAddressLine1, value: cfg.required)
                }
                if let cfg = rootModel.getFieldConfig(id: "billAddressLine2") {
                    tableModel.setBindings(forCell: .billingAddressLine2, newBindings:bindingFactory.createAddressLine2Bindings(model: model, required: cfg.required))
                    tableModel.setIsOptional(cell: .billingAddressLine2, value: cfg.required)
                }
                if let cfg = rootModel.getFieldConfig(id: "zipCode") {
                    tableModel.setBindings(forCell: .billingAddressZipCode, newBindings:bindingFactory.createAddressZipCodeBindings(model: model, required: cfg.required))
                    tableModel.setIsOptional(cell: .billingAddressZipCode, value: cfg.required)
                }
                if let cfg = rootModel.getFieldConfig(id: "country") {
                    tableModel.setBindings(forCell: .billingAddressCountry, newBindings:bindingFactory.createAddressCountryBindings(rootModel: rootModel, model: model, required: cfg.required))
                    tableModel.setIsOptional(cell: .billingAddressCountry, value: cfg.required)
                }
                if let cfg = rootModel.getFieldConfig(id: "city") {
                    tableModel.setBindings(forCell: .billingAddressCity, newBindings:bindingFactory.createAddressCityBindings(model: model, required: cfg.required))
                    tableModel.setIsOptional(cell: .billingAddressCity, value: cfg.required)

                }
            }
            
            ccVendorObservation = model.observe(\.vendor.id, changeHandler: {[weak self] ccModel, change in
                // When the selected vendor changes, we need to revalidate the CVV and the Card number.
                self?.tableModel.getBindings(forCell: .cardNumber)[0].validate()
                self?.tableModel.getBindings(forCell: .cardCvv)[0].validate()
                self?.tableModel.getBindings(forCell: .cardNumber)[0].formatter = { CardFormatter.format($0, vendor: ccModel.vendor.id) }
            })


            
            payToolbar.setAmounts( total: rootModel.totalAmount.value, currency: rootModel.totalAmount.currency, breakdown: getAmountBreakdown() )
            
            obFeesObservation = rootModel.observe(\.totalAmount, changeHandler: {[weak self] ccModel, change in
                // Refresh the amount in the bottom toolbar:
                self?.payToolbar.setAmounts(total: ccModel.totalAmount.value, currency: ccModel.totalAmount.currency, breakdown: self?.getAmountBreakdown() ?? [])
            })
        } else {
            tableModel.clear()
        }
    }
    
    func updateAppearance() {
        theme.apply(tableView: tableView)
        if let bar = navigationController?.navigationBar {
            theme.apply(navigationBar: bar)
        }
    }
    
    func findFirstResponder() -> UIView? {
        for binding in tableModel.getBindings() {
            if binding.view?.isFirstResponder == true{
                return binding.view
            }
        }
        return nil
    }
    
    func previousAndNextSelectableRow() -> (IndexPath?, IndexPath?) {
        if let selectedPath = tableModel.getFirstResponderPath() {
            return previousAndNextSelectableRow(around: selectedPath)
        }
        return (nil, nil)
    }
    
    func previousAndNextSelectableRow(around: IndexPath) -> (IndexPath?, IndexPath?) {
        var paths: [IndexPath] = []
        for (path,cell) in tableModel.getCells() {
            if cell.selectable {
                paths.append(path)
            }
        }
        if let index = paths.firstIndex(of: around) {
            return (index>0 ? paths[index-1] : nil , index<paths.count-1 ? paths[index+1] : nil)
        }
        return (nil, nil)
    }
    
    func updateLayout(keyboardHeight:CGFloat?) {
        var bottomMargin: CGFloat = 0
        if let keyboardHeight = keyboardHeight {
            UIView.performWithoutAnimation {
                self.payToolbar.display(insideTableView: self)
            }
            bottomMargin = keyboardHeight
            
            // For Device with rounded corners, we need to take into
            // account the safe area inset.
            if #available(iOS 11.0, *) {
                bottomMargin -= view.safeAreaInsets.bottom
            }
            
            
            // We compute the bottom margin of the current view controller
            // because it reduces the space needed for the keyboard.
            if let window = view.window {
                let viewFrame = view.convert(view.bounds, to: nil)
                let windowFrame = window.frame
                bottomMargin -= windowFrame.height - viewFrame.maxY
            }
            
            
            
            // We set the height of the Expiry Picker to be equal to the keyboard height, so that buttons are
            // well aligned when the field type changes.
            if let path = tableModel.getFirstResponderPath() {
                if tableModel.getCell(at:path) != TableModel.Cell.cardExpiry {
                    expiryPicker.intrinsicHeight = keyboardHeight - keyboardToolbar.height
                }
            }
        } else {
            tableView.tableFooterView = nil
            if let navigationController = navigationController {
                UIView.performWithoutAnimation {
                    self.payToolbar.display(inside: navigationController)
                }
            }
            bottomMargin = payToolbar.height
        }

        // We ensure the top contentInset is not changed by this method,
        // because on iOS 10 and below, it's automatically set by the
        // view controller.
        let topInset = tableView.contentInset.top
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: topInset, left: 0.0, bottom: max(0, bottomMargin), right: 0.0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }
    
    
    // MARK: IBActions
    @IBAction func tdsRedirectionCancelledByUser(_ segue: UIStoryboardSegue) {
        print("CreditCardViewController: Back from 3DS: Cancelled")
    }
    
    func openPaymentErrorAlert() {
        let alertController = UIAlertController(title: "error".localize(type: .label), message:"payment".localize(type: .error), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok".localize(type: .button), style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func tdsRedirectionFailed(_ segue: UIStoryboardSegue) {
        print("CreditCardViewController: Back from 3DS: Failure")
        pendingError = true
    }
    
    @IBAction func pay(_ sender: Any) {
        tableView.endEditing(false)
        
        if !tableModel.bindingAggregator.isValid {
            // If the form is invalud, we display a error pop, and
            // we touch all fields to display inline errrors.
            let alertController = UIAlertController(title: nil, message: "invalid_form".localize(type: .error), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "ok".localize(type: .button), style: .default, handler:nil))
            self.present(alertController, animated: true, completion: nil)
            tableModel.bindingAggregator.touchAll()
            return
        }
        if ctx?.options.termsAndConditions.isEmpty == false && !payToolbar.termAndConditionsAccepted {
            // If the terms and condtions were not accepted, we display
            // a error popup.
            let alertController = UIAlertController(title: nil, message: "term_and_conditions".localize(type: .error), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "ok".localize(type: .button), style: .default, handler:nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        LoadIndicator.sharedInstance.start(self) {
            self.ctx?.dataModel?.triggerAdd(successHandler: {[weak self] in
                LoadIndicator.sharedInstance.stop() {[weak self] in
                    if self?.ctx?.dataModel?.pendingRedirection != nil {
                        self?.performSegue(withIdentifier: StoryboardConstants.ExternalRedirectionSegue, sender: self)
                    } else {
                        self?.ctx?.closeWithStatus(.success, error:nil)
                    }
                }
            }, failureHandler: {[weak self] error in
                LoadIndicator.sharedInstance.stop() {[weak self] in
                    if error.isFunctional() {
                        self?.openPaymentErrorAlert()
                    } else if error == .technicalNetworkFailure {
                        self?.ctx?.closeWithStatus(.unknown, error: NSError.checkoutError(type:.networkFailure, feature:.addCreditCard))
                    } else if error == .technicalUnreachableNetwork {
                        self?.ctx?.closeWithStatus(.failure, error: NSError.checkoutError(type:.networkFailure, feature:.addCreditCard))
                    } else {
                        self?.ctx?.closeWithStatus(.unknown, error: NSError.checkoutError(type:.unexpectedError, feature:.addCreditCard))
                    }
                }
            })
        }
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        tableView.endEditing(false)
        ctx?.closeWithStatus(.cancellation, error:nil)
    }
    
    @IBAction func cvvHelper(_ sender: Any) {
        let cvvAlert = self.storyboard?.instantiateViewController(withIdentifier: StoryboardConstants.CreditCardCvvHelpViewController)
            as! CreditCardCvvHelpViewController
        if let cc = creditCardMethod {
            cvvAlert.type = cc.expectedCvvLength == 4 ? .amex : .generic
        }
        self.present(cvvAlert, animated: true, completion: nil)
    }
    
    // MARK: UITableViewDelegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableModel.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.sections[section].cells.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableModel.sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel.getCell(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellModel.identifier, for: indexPath)

        /* If the cell is a InputTextViewCell, we add the toolbar
         * to its keyboard, and we set the delegate. */
        if let cell = cell as? InputTextViewCell {
            keyboardToolbar.associate(toField: cell.inputTextField)
            cell.delegate = self
        }
        
        /* If the cell needs a binding, we configure it here */
        if let cell = cell as? BoundTableViewCell {
            cell.setupBinding(bindingsAggregator: tableModel.bindingAggregator, cellBindings: tableModel.getBindings(forCell: cellModel))
            cell.setupLabels(cell: cellModel, isOptional: tableModel.isOptional(cell: cellModel))
        }

        return cell
    }

    
    func transferRowSelectionToField(at indexPath: IndexPath, openDetails: Bool) {
        let cell = tableView.cellForRow(at: indexPath)
        let cellIdentifier = tableModel.getCell(at: indexPath)
        
        if openDetails, let cell = cell as? DetailTableViewCell {
            tableView.endEditing(true)
            view.isUserInteractionEnabled = false
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if self.presentedViewController == nil {
                    self.performSegue(withIdentifier: cellIdentifier.segueIdentifier!, sender:cell)
                } else {
                    // If there is already a presentedViewController, it means someting
                    // happend during the animation, so we cancel the row selection.
                    self.view.isUserInteractionEnabled = true
                    self.tableView.deselectRow(at: indexPath, animated: false)
                }
            }
            autofocus = previousAndNextSelectableRow(around: indexPath).1
            return
        }
        
        for subView in cell?.contentView.subviews ?? [] {
            if subView is UITextField {
                subView.becomeFirstResponder()
                tableView.deselectRow(at: indexPath, animated: false)
                return
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        transferRowSelectionToField(at: indexPath, openDetails:false)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableModel.getCell(at: indexPath).height
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor = theme.primaryLighterForegroundColor
    }

    
    // MARK: Keyboard Events
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        
        updateLayout(keyboardHeight: keyboardSize!.height)
        
        var aRect : CGRect = view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = findFirstResponder() {
            let activeFieldFrame = activeField.convert(activeField.frame, to: view)
            if (!aRect.contains(activeFieldFrame.origin)){
                tableView.scrollRectToVisible(activeFieldFrame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        updateLayout(keyboardHeight: nil)
    }
    
    // MARK: Keyboard toolbar
    func keyboardToolbar(button: UIBarButtonItem, type: KeyboardToolbarButton, tappedIn toolbar: KeyboardToolbar) {
        let (backRow, forwardRow) = previousAndNextSelectableRow()
        switch type {
        case .back:
            tableView.scrollToRow(at: backRow!, at: .none, animated: true)
            transferRowSelectionToField(at: backRow!, openDetails:true)
            
        case .forward:
            tableView.scrollToRow(at: forwardRow!, at: .none, animated: true)
            transferRowSelectionToField(at: forwardRow!, openDetails:true)
        case .done:
            tableView.endEditing(true)
        case .scan:
            AMCheckoutPluginManager.sharedInstance.scanCardPlugin!.scanCard(host: self) { card in
                if let card = card {
                    self.creditCardMethod?.creditCardNumber = card.number
                    self.creditCardMethod?.cvv = card.cvv
                    self.creditCardMethod?.expiryDate = card.expiry
                    
                    self.tableModel.getBindings(forCell: .cardNumber)[0].touched = true
                    self.tableModel.getBindings(forCell: .cardCvv)[0].touched = true
                    self.tableModel.getBindings(forCell: .cardExpiry)[0].touched = true
                }
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let (backRow, forwardRow) = previousAndNextSelectableRow()
        keyboardToolbar.backButton.isEnabled = (backRow != nil)
        keyboardToolbar.forwardButton.isEnabled = (forwardRow != nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // The following code implement the behavior of the
        // return button:
        //  - if there is a next field, it's selected
        //  - otherwise it closes the keyboard
        let (_, forwardRow) = previousAndNextSelectableRow()
        if forwardRow != nil {
            tableView.scrollToRow(at: forwardRow!, at: .none, animated: true)
            transferRowSelectionToField(at: forwardRow!, openDetails:true)
        } else {
            tableView.endEditing(true)
        }
        return false
    }
}
