//
//  PaymentMethodViewController.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 14/11/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


class PaymentMethodsViewController: UITableViewController {
    // MARK: Instance properties
    weak var ctx: AMCheckoutContext? = AMCheckoutContext.sharedContext
    private var theme = Theme.sharedInstance
    var bookingDetailsView: BookingDetailsView!
    
    // MARK: IBOutlets
    
    // MARK: Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Instance methods
    override func viewDidLoad() {
        super.viewDidLoad()

        theme.apply(tableView: tableView)
        if let bar = navigationController?.navigationBar {
            theme.apply(navigationBar: bar)
        }

        if let bookingDetails = ctx?.options.bookingDetails {
            bookingDetailsView = BookingDetailsView(bookingDetails)
            bookingDetailsView.tableView = tableView
            tableView.tableHeaderView = bookingDetailsView
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        ctx?.closeWithStatus(.cancellation, error:nil)
    }
    
    
    // MARK: UITableViewDelegate
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "select_payment_method".localize(type: .label)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ctx?.dataModel?.paymentMethods.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let mop = ctx?.dataModel?.paymentMethods[indexPath.row] {
            let cellType = mop is CreditCardPaymentMethod ? StoryboardConstants.PaymentMethodCCCell : StoryboardConstants.PaymentMethodAmopCell
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType, for: indexPath)
            cell.textLabel?.text = AMPaymentMethodType.make(from: mop).description
            cell.accessoryView = IconViewFactory.disclosureIndicator.createView(color: theme.secondaryForegroundColor)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let dataModel = ctx?.dataModel {
            dataModel.selectedPaymentMethod = ctx?.dataModel?.paymentMethods[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor = theme.primaryLighterForegroundColor
    }
}
