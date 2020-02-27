//
//  CheckBox.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 04/09/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import UIKit

@IBDesignable
open class Checkbox: UIControl {
    @IBInspectable
    var borderWidth: CGFloat = 1
    
    @IBInspectable
    var margin: CGFloat = 2
    
    @IBInspectable
    var color: UIColor = #colorLiteral(red: 0.039, green: 0.447, blue: 0.996, alpha: 1.0)
    
    //Used to increase the touchable area for the component
    var increasedTouchRadius: CGFloat = 12.0
    
    var useHapticFeedback: Bool = true
    
    @IBInspectable
    var isChecked: Bool = false {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    
    // MARK: Intialisers
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: User interactions
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Define the UIImpactFeedbackGenerator object, and prepare the engine to be ready to provide feedback.
        super.touchesBegan(touches, with: event)
        self.feedbackGenerator = UIImpactFeedbackGenerator.init(style: .light)
        self.feedbackGenerator?.prepare()
    }
    

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // On touches ended, changes the selected state of the component.
        // After usage of feedback generator object, we make it nil.
        self.isChecked = !isChecked
        self.sendActions(for: .valueChanged)
        if useHapticFeedback {
            self.feedbackGenerator?.impactOccurred()
            self.feedbackGenerator = nil
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // The following method is overriden to increase the hit frame for this component
        
        let relativeFrame = self.bounds
        let hitTestEdgeInsets = UIEdgeInsets(top: -increasedTouchRadius, left: -increasedTouchRadius, bottom: -increasedTouchRadius, right: -increasedTouchRadius)
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
    
    
    // MARK: View drawing
    open override func draw(_ rect: CGRect) {
        // Draw the outlined component
        let newRect = rect.insetBy(dx: borderWidth / 2.0, dy: borderWidth / 2.0)
        
        let shapePath = UIBezierPath(roundedRect: newRect, cornerRadius: 3.5)
        color.set()
        shapePath.lineWidth = borderWidth
        shapePath.stroke()
        
        // Draw the inner part of the component UI.
        if isChecked {
            IconViewFactory.checkmark.draw(in: newRect, margin: margin)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
}
