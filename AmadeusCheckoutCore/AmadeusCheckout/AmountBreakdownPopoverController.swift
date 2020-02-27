//
//  AmountBreakdownPopoverController.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 13/11/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//


class AmountBreakdownPopoverController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    var amountBreakdown: [AMAmountDetails] = []
    var currency: String = ""

    weak var hostViewController: UIViewController?
    var theme: Theme
    var tableView: UITableView!
    var onCloseCallback: (() -> Void)? = nil

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented.")
    }

    init(theme: Theme) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }

    func open(in hostViewController: UIViewController, from view: UIView, completion: (() -> Void)? = nil) {
        if !isBeingPresented {
            self.hostViewController = hostViewController
            self.modalPresentationStyle = .popover
            self.popoverPresentationController?.backgroundColor = theme.primaryBackgroundColor
            self.popoverPresentationController?.permittedArrowDirections = .down
            self.popoverPresentationController?.delegate = self
            self.popoverPresentationController?.sourceView = view
            self.popoverPresentationController?.sourceRect = view.bounds
            
            hostViewController.present(self, animated: true, completion: nil)
            onCloseCallback = completion
        }
    }
    
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        view.frame = CGRect(x: 0, y: 0, width: 400, height: 200)
        
        tableView = UITableView(frame: view.frame, style: .plain)
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        // We add an empty, 1px height, footer, so that the last row separator of the table is not displayed
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 1))
        
        theme.apply(tableView: tableView)

        view.addSubview(tableView)
        
        
        var guideView = view.layoutMarginsGuide
        if #available(iOS 11.0, *) {
            guideView = view.safeAreaLayoutGuide
        }

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: guideView.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: guideView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: guideView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guideView.trailingAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // We reload the table so that we know its size, and we can adjust the popover size accordingly
        tableView.reloadData()
        tableView.layoutIfNeeded()
        preferredContentSize = CGSize(width: 320.0, height: tableView.contentSize.height)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let ccController = hostViewController as? CreditCardViewController {
            ccController.displayOverlay = false
        }
        if onCloseCallback != nil {
            onCloseCallback!()
        }
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return amountBreakdown.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "amountRow")
        if cell == nil {
            cell = StyledTableViewCell(style: .value1, reuseIdentifier:  "amountRow")
            cell?.detailTextLabel?.textColor = theme.primaryForegroundColor
        }
        
        cell?.textLabel?.text = amountBreakdown[indexPath.row].label
        cell?.detailTextLabel?.text = Translator.formatAmount(amountBreakdown[indexPath.row].amount, currency: currency)
        
        return cell!
    }
    
    
    // MARK: UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return adaptivePresentationStyle(for: controller)
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        if let ccController = hostViewController as? CreditCardViewController {
            ccController.displayOverlay = true
        }
    }
}


