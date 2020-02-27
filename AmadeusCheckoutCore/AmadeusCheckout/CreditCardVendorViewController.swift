//
//  CreditCardVendorViewController.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 11/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import UIKit



class CreditCardVendorViewController: UITableViewController {
    // MARK: Instance properties
    var creditCardMethod: CreditCardPaymentMethod?
    var selectedVendorIndex: Int?
    var theme = Theme.sharedInstance
    
    // MARK: IBOutlets
    
    // MARK: Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Instance methods
    override func viewDidLoad() {
        super.viewDidLoad()
        updateAppearance()
        
        self.selectedVendorIndex = creditCardMethod?.allowedVendors.firstIndex(where: { $0.id == creditCardMethod?.vendor.id })
    }
    
    func updateAppearance() {
        theme.apply(tableView: tableView)
    }
    
    // MARK: IBActions
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditCardMethod?.allowedVendors.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VendorCell", for: indexPath)
        
        let vendor = (creditCardMethod?.allowedVendors[indexPath.row])!
        cell.textLabel?.text = vendor.name
        
        var im = UIImage(named: "vendor_\(vendor.id)", in: FileTools.mainBundle, compatibleWith:nil)
        if im == nil {
            im = UIImage(named: "vendor_generic", in: FileTools.mainBundle, compatibleWith:nil)
        }
        cell.imageView?.image = im
        
        if creditCardMethod?.vendor.id == vendor.id {
            cell.accessoryView = IconViewFactory.checkmark.createView(color: theme.accentColor)
        } else {
            cell.accessoryView = nil
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Other row is selected - need to deselect it
        if let index = selectedVendorIndex {
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
            cell?.accessoryView = nil
        }
        selectedVendorIndex = indexPath.row
        
        if let selectedVendor = creditCardMethod?.allowedVendors[indexPath.row] {
            creditCardMethod?.vendor = selectedVendor
        }
        
        // update the checkmark for the current row
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryView = IconViewFactory.checkmark.createView(color: theme.accentColor)
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
