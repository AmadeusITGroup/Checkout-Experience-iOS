//
//  CreditCardVendorViewController.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 11/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation



class ValueSelectorViewController: UITableViewController, UISearchResultsUpdating {

    
    // MARK: Instance properties
    var binding: DataModelBinding?
    var values: [(code:String, label:String)] = [] {
        didSet {
            filteredValues = values
        }
    }
    
    private var filteredValues: [(code:String, label:String)] = []
    private var selectedIndex: Int?
    private var theme = Theme.sharedInstance
    private var searchController : UISearchController!
    
    // MARK: IBOutlets
    
    // MARK: Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Instance methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedIndex = filteredValues.firstIndex(where: { $0.code == binding?.value })
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        updateAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // As soon as the value selector is displayed, we can set the binding as touched
        // so that a mandatory warning icon can be displayed if not value is selected.
        binding?.touched = true
    }
    
    func updateAppearance() {
        theme.apply(tableView: tableView)
        theme.apply(searchBar: searchController.searchBar)
    }
    
    // MARK: IBActions
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredValues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath)
        
        let value = filteredValues[indexPath.row]
        cell.textLabel?.text = value.label
        
        if binding?.value == value.code {
            cell.accessoryView = IconViewFactory.checkmark.createView(color: theme.accentColor)
        } else {
            cell.accessoryView = nil
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Other row is selected - need to deselect it
        if let index = selectedIndex {
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
            cell?.accessoryView = nil
        }
        selectedIndex = indexPath.row
        
        binding?.value = filteredValues[indexPath.row].code
        
        // update the checkmark for the current row
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryView = IconViewFactory.checkmark.createView(color: theme.accentColor)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text!.lowercased()
        filteredValues = values.filter({ (value) -> Bool in
            searchString.isEmpty || value.code.lowercased().contains(searchString) || value.label.lowercased().contains(searchString)
        })
        tableView.reloadData()
    }
}
