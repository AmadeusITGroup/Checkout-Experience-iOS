//
//  ColorPicker.swift
//  SwiftShowcase
//
//  Created by Yann Armelin on 11/09/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import UIKit


class SmallSlider: UISlider {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setThumbImage(UIImage(named: "thumb"), for: .normal)
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return super.point(inside: point, with: event) && bounds.contains(point)
    }
}

class ColorPickerPopup: UIViewController {
    weak var colorPicker: ColorPicker!
    
    @IBOutlet var rSlider: SmallSlider!
    @IBOutlet var gSlider: SmallSlider!
    @IBOutlet var bSlider: SmallSlider!
    @IBOutlet var aSlider: SmallSlider!
    @IBOutlet var rLabel: UILabel!
    @IBOutlet var gLabel: UILabel!
    @IBOutlet var bLabel: UILabel!
    @IBOutlet var aLabel: UILabel!
    
    var color: UIColor? = nil {
        didSet {
            refresh()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init() {
        super.init(nibName: "ColorPickerPopup", bundle: nil)
    }
    
    override func viewDidLoad() {
        preferredContentSize = view.frame.size
        refresh()
    }
    
    @IBAction func onChange(_ sender: Any) {
        color = UIColor(
            red: CGFloat(rSlider.value)/255.0,
            green: CGFloat(gSlider.value)/255.0,
            blue: CGFloat(bSlider.value)/255.0,
            alpha: CGFloat(aSlider.value)
        )
        colorPicker.internalSetColor(color:color)
    }
    
    func refresh() {
        if rSlider == nil {
            return
        }
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        color?.getRed(&r, green: &g, blue: &b, alpha: &a)
        rSlider.value = Float(255.0*r)
        gSlider.value = Float(255.0*g)
        bSlider.value = Float(255.0*b)
        aSlider.value = Float(a)
        rLabel.text = String(Int(255.0*r))
        gLabel.text = String(Int(255.0*g))
        bLabel.text = String(Int(255.0*b))
        aLabel.text = String(format: "%.2f", arguments: [a])
    }
}

@IBDesignable
class ColorPicker: UIControl, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var hostViewController: UIViewController!
    
    var touchDown: Bool = false
    @IBInspectable var color: UIColor? = nil {
        didSet {
            refresh()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func configure() {
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1.0
        refresh()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return adaptivePresentationStyle(for: controller)
    }
    
    func openPopUp() {
        let popUp = ColorPickerPopup()
        popUp.color = color
        popUp.colorPicker = self
        popUp.modalPresentationStyle = .popover
        popUp.popoverPresentationController?.permittedArrowDirections = .up
        popUp.popoverPresentationController?.delegate = self
        popUp.popoverPresentationController?.sourceView = self
        popUp.popoverPresentationController?.sourceRect = self.bounds
        hostViewController.present(popUp, animated: true, completion: nil)
    }
    
    fileprivate func internalSetColor(color: UIColor?) {
        self.color = color
        self.sendActions(for: .valueChanged)
    }
    
    func refresh() {
        backgroundColor = color
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDown = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchDown {
            touchDown = false
            openPopUp()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDown = false
    }
}
