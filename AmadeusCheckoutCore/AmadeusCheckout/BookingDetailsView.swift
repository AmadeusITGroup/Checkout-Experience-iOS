//
//  BookingDetailsView.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 10/10/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import UIKit


class BookingDetailsView: UIView {
    weak var tableView: UITableView?
    
    private var contentView: UIView!
    private var theme: Theme
    private weak var details: AMBookingDetails?
    private weak var currentAnchor: NSLayoutYAxisAnchor?
    
    private var isFlightOpened = true
    private var isPassengersOpened = true

    
    init(_ details: AMBookingDetails?) {
        theme = Theme.sharedInstance
        self.details = details
        super.init(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
        initSubviews()
        updateFrame(animate:false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() {
        clipsToBounds = true
        
        initContentView(maxWidth: 700, leftRightMargins: 16)
        
        if let flightList = details?.flightList, flightList.count > 0 {
            appendView(makeTitle("Flight(s)", opened:isFlightOpened, tag:1, chevonIconSize: 20), marginTop: 8, leftRightMargins:0)
            if isFlightOpened {
                for flight in flightList {
                    let flightBlock = makeFlightBlock(
                        departurAirport: flight.departureAirport,
                        departureTime: flight.departureDate,
                        arrivalAirport: flight.arrivalAirport,
                        arrivalTime: flight.arrivalDate,
                        iconWidth: 24 ,
                        iconMargin: 16
                    )
                    appendView(flightBlock, marginTop: 8, leftRightMargins:8)
                }
            }
        }
        
        if let passengerList = details?.passengerList, passengerList.count > 0 {
            appendView(makeTitle("Passenger(s)",opened:isPassengersOpened, tag:2, chevonIconSize: 20), marginTop: isFlightOpened ? 16 : 0, leftRightMargins:0)
            if isPassengersOpened {
                for passenger in passengerList {
                    appendView(makeLabel(passenger), marginTop: 8, leftRightMargins:8)
                }
            }
        }
        
        finalizeContraints(16)
        
    }
    
    private func updateFrame(animate: Bool) {
        tableView?.beginUpdates()
        layoutIfNeeded()
        if animate {
            UIView.animate(withDuration: 0.2, animations: {
                self.frame =  CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.contentView.frame.height)
            })
        } else {
            frame =  CGRect(x: 0, y: 0, width: frame.size.width, height: contentView.frame.height)
        }
        self.tableView?.endUpdates()
    }
    
    private func makeTitle(_ title: String, opened: Bool , tag: Int, chevonIconSize: CGFloat) -> UIView {
        let button = UIButton()
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(didClick(_:)), for: .touchUpInside)
        button.tag = tag
        button.setAttributedTitle(NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.foregroundColor:theme.primaryForegroundColor as Any,
            NSAttributedString.Key.font:theme.emphasisFont as Any,
        ]), for: .normal)
        let icon = opened ? IconViewFactory.chevronUp : IconViewFactory.chevronDown
        let iconView = icon.createView(color: theme.accentColor, scaleToFit: true)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.isUserInteractionEnabled = false
        button.addSubview(iconView)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: button.topAnchor),
            iconView.bottomAnchor.constraint(equalTo: button.bottomAnchor),
            iconView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            iconView.widthAnchor.constraint(equalToConstant: chevonIconSize)
        ])
        
        return button
    }
    
    @objc func didClick(_ sender: UIButton) {
        if sender.tag == 1 {
            isFlightOpened = !isFlightOpened
        } else if sender.tag == 2  {
            isPassengersOpened = !isPassengersOpened
        }
        refresh()
    }
    
    private func makeLabel(_ text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = theme.smallFont
        label.textColor = theme.primaryForegroundColor
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        //label.backgroundColor = .green
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }
    
    private func makeFlightBlock(departurAirport: String, departureTime: String, arrivalAirport: String, arrivalTime: String, iconWidth: CGFloat, iconMargin: CGFloat) -> UIView {
        let container = UIView()
        //container.backgroundColor = .orange
        let l1 = makeLabel(departurAirport) as! UILabel
        let l2 = makeLabel(departureTime) as! UILabel
        let r1 = makeLabel(arrivalAirport) as! UILabel
        let r2 = makeLabel(arrivalTime) as! UILabel
        let icon = IconViewFactory.plane.createView(color: theme.accentColor, scaleToFit: true)
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        l1.textAlignment = .center
        l2.textAlignment = .center
        r1.textAlignment = .center
        r2.textAlignment = .center
        
        
        container.addSubview(l1)
        container.addSubview(l2)
        container.addSubview(r1)
        container.addSubview(r2)
        container.addSubview(icon)
        
        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: container.topAnchor),
            icon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            icon.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            icon.widthAnchor.constraint(equalToConstant: iconWidth),
            
            l1.topAnchor.constraint(equalTo: container.topAnchor),
            l1.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            l1.trailingAnchor.constraint(equalTo: icon.leadingAnchor, constant: -iconMargin),
            
            l2.topAnchor.constraint(equalTo: l1.bottomAnchor),
            l2.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            l2.trailingAnchor.constraint(equalTo: icon.leadingAnchor, constant: -iconMargin),
            
            r1.topAnchor.constraint(equalTo: container.topAnchor),
            r1.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant:iconMargin),
            r1.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            r2.topAnchor.constraint(equalTo: r1.bottomAnchor),
            r2.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant:iconMargin),
            r2.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            l2.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func initContentView(maxWidth: CGFloat, leftRightMargins: CGFloat) {
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        //contentView.backgroundColor = .red
        addSubview(contentView)
        currentAnchor = contentView.topAnchor
        
        let a = contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftRightMargins)
        let b = contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -leftRightMargins)
        a.priority = .defaultHigh
        b.priority = .defaultHigh
        NSLayoutConstraint.activate([
            a,
            b,
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth)
        ])
    }
    
    private func appendView(_ view: UIView, marginTop: CGFloat, leftRightMargins: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: currentAnchor!, constant: marginTop),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leftRightMargins),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -leftRightMargins),
        ])
        currentAnchor = view.bottomAnchor
    }
    
    private func finalizeContraints(_ marginBottom: CGFloat) {
        NSLayoutConstraint.activate([
            currentAnchor!.constraint(equalTo: contentView.bottomAnchor, constant: -marginBottom)
        ])
    }
    
    private func refresh() {
        subviews.forEach({ $0.removeFromSuperview() })
        initSubviews()
        updateFrame(animate:true)
    }
}
