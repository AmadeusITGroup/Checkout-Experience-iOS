//
//  IconViewFactory.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 15/07/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation
import UIKit

enum IconViewFactory {
    case disclosureIndicator
    case checkmark
    case warning
    case detail
    case plane
    case chevronUp
    case chevronDown
    
    func createView(color: UIColor?, scaleToFit: Bool = false) -> UIView {
        let icon = IconViewFactoryView(size:size, color:color, type:self)
        if scaleToFit {
            icon.scaleToFit = true
        }
        return icon
    }
    
    var size: CGSize {
        switch self {
        case .disclosureIndicator: return CGSize(width: 18, height: 18)
        case .chevronUp: return CGSize(width: 14, height: 8)
        case .chevronDown: return CGSize(width: 14, height: 8)
        case .checkmark: return CGSize(width: 13, height: 10)
        case .warning: return CGSize(width: 14, height: 14)
        case .detail: return CGSize(width: 14, height: 14)
        case .plane: return CGSize(width: 48, height: 45)
        }
    }
    
    func draw(in frame:CGRect, margin:CGFloat) {
        let size = self.size
        let scale = min(frame.size.width/(size.width+2*margin), frame.size.height/(size.height+2*margin))
        let origin = CGPoint(x: frame.midX - 0.5*size.width*scale, y: frame.midY - 0.5*size.height*scale)
        
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        context.translateBy(x: origin.x, y: origin.y)
        context.scaleBy(x: scale, y: scale)
        
        draw()
        
        context.restoreGState()
    }
    
    func draw() {
        var path = UIBezierPath()
        switch self {
        case .disclosureIndicator:
            path.lineWidth = 1.75
            path.move(to: CGPoint(x:10.75,y:3.25))
            path.addLine(to: CGPoint(x:16.5,y:9.0))
            path.addLine(to: CGPoint(x:10.75,y:14.75))
            path.stroke()
        case .chevronUp:
            // SVG equivalent path: M 1.25 1.75 L 7 7.5 L 12.75 1.75
            path.lineWidth = 1.75
            path.move(to: CGPoint(x:1.25,y:1.75))
            path.addLine(to: CGPoint(x:7.0,y:7.5))
            path.addLine(to: CGPoint(x:12.75,y:1.75))
            path.stroke()
        case .chevronDown:
            // SVG equivalent path: M 1.25 7.75 L 7 2 L 12.75 7.75
            path.lineWidth = 1.75
            path.move(to: CGPoint(x:1.25,y:7.75))
            path.addLine(to: CGPoint(x:7.0,y:2.0))
            path.addLine(to: CGPoint(x:12.75,y:7.75))
            path.stroke()
        case .checkmark:
            path.lineWidth = 1.75
            path.move(to: CGPoint(x:0.75,y:5.25))
            path.addLine(to: CGPoint(x:4.25,y:8.5))
            path.addLine(to: CGPoint(x:12.25,y:0.75))
            path.stroke()
        case .warning:
            path.move(to: CGPoint(x:7.0,y:8.5))
            path.addQuadCurve(to: CGPoint(x:6,y:5), controlPoint: CGPoint(x:6.25,y:6.5))
            path.addQuadCurve(to: CGPoint(x:8,y:5), controlPoint: CGPoint(x:7,y:3) )
            path.addQuadCurve(to: CGPoint(x:7,y:8.5), controlPoint: CGPoint(x:7.75,y:6.5))
            path.close()
            path.fill()
            
            path = UIBezierPath(ovalIn: CGRect(x: 7-6, y: 7-6, width: 6*2, height: 6*2))
            path.lineWidth = 0.5
            path.stroke()
            
            path = UIBezierPath(ovalIn: CGRect(x: 7-0.75, y: 9.5-0.75, width: 0.75*2, height: 0.75*2))
            path.fill()
        case .detail:
            path.move(to: CGPoint(x:7,y:5.5))
            path.addLine(to: CGPoint(x:7,y:10.5))
            path.lineWidth = 1
            path.stroke()
            
            path.removeAllPoints()
            path.move(to: CGPoint(x:6,y:5.625))
            path.addLine(to: CGPoint(x:7,y:5.625))
            path.move(to: CGPoint(x:6,y:10.5))
            path.addLine(to: CGPoint(x:8,y:10.5))
            path.lineWidth = 0.25
            path.stroke()
            
            path = UIBezierPath(ovalIn: CGRect(x: 7-6, y: 7-6, width: 6*2, height: 6*2))
            path.lineWidth = 0.5
            path.stroke()
            
            path = UIBezierPath(ovalIn: CGRect(x: 7-0.75, y: 4-0.75, width: 0.75*2, height: 0.75*2))
            path.fill()
        case .plane:
            /* SVG equivalent Path:
             M 18.41 25.17 C 19.1 25.21 18.86 26 18.86 26 L 17.6 32.2 L 12.73 45 C 15.13 45 15.38 44.62 15.8 44.06 L 28.9 25.8 C 28.9 25.8 34.9 25.31 40.19 25.31 C 42.64 25.31 48 24.13 48 22.6 C 48 21.07 42.56 19.89 40.19 19.89 C 35.17 19.89 28.9 19.4 28.9 19.4 L 15.8 1.14 C 15.3 0.43 15.03 0.2 12.73 0.2 L 17.6 13 L 18.86 19.19 C 18.86 19.19 19.1 19.98 18.41 20.02 C 17.72 20.06 11.5 19.9 8.2 20.61 C 7.76 20.7 7.73 20.36 7.46 20.13 L 4.18 14.94 C 3.99 14.77 3.45 14.69 3.45 14.69 L 1.6 14.59 L 3.2 21.39 L 0 22.59 L 3.2 23.79 L 1.6 30.59 L 3.45 30.49 C 3.45 30.5 3.99 30.42 4.18 30.25 L 7.46 25.06 C 7.73 24.83 7.76 24.49 8.2 24.58 C 11.5 25.27 17.72 25.13 18.41 25.17 Z
            */
            path.move(to: CGPoint(x: 18.41, y: 25.17))
            path.addCurve(to: CGPoint(x: 18.86, y: 26), controlPoint1: CGPoint(x: 19.1, y: 25.21), controlPoint2: CGPoint(x: 18.86, y: 26))
            path.addLine(to: CGPoint(x: 17.6, y: 32.2))
            path.addLine(to: CGPoint(x: 12.73, y: 45))
            path.addCurve(to: CGPoint(x: 15.8, y: 44.06), controlPoint1: CGPoint(x: 15.13, y: 45), controlPoint2: CGPoint(x: 15.38, y: 44.62))
            path.addLine(to: CGPoint(x: 28.9, y: 25.8))
            path.addCurve(to: CGPoint(x: 40.19, y: 25.31), controlPoint1: CGPoint(x: 28.9, y: 25.8), controlPoint2: CGPoint(x: 34.9, y: 25.31))
            path.addCurve(to: CGPoint(x: 48, y: 22.6), controlPoint1: CGPoint(x: 42.64, y: 25.31), controlPoint2: CGPoint(x: 48, y: 24.13))
            path.addCurve(to: CGPoint(x: 40.19, y: 19.89), controlPoint1: CGPoint(x: 48, y: 21.07), controlPoint2: CGPoint(x: 42.56, y: 19.89))
            path.addCurve(to: CGPoint(x: 28.9, y: 19.4), controlPoint1: CGPoint(x: 35.17, y: 19.89), controlPoint2: CGPoint(x: 28.9, y: 19.4))
            path.addLine(to: CGPoint(x: 15.8, y: 1.14))
            path.addCurve(to: CGPoint(x: 12.73, y: 0.2), controlPoint1: CGPoint(x: 15.3, y: 0.43), controlPoint2: CGPoint(x: 15.03, y: 0.2))
            path.addLine(to: CGPoint(x: 17.6, y: 13))
            path.addLine(to: CGPoint(x: 18.86, y: 19.19))
            path.addCurve(to: CGPoint(x: 18.41, y: 20.02), controlPoint1: CGPoint(x: 18.86, y: 19.19), controlPoint2: CGPoint(x: 19.1, y: 19.98))
            path.addCurve(to: CGPoint(x: 8.2, y: 20.61), controlPoint1: CGPoint(x: 17.72, y: 20.06), controlPoint2: CGPoint(x: 11.5, y: 19.9))
            path.addCurve(to: CGPoint(x: 7.46, y: 20.13), controlPoint1: CGPoint(x: 7.76, y: 20.7), controlPoint2: CGPoint(x: 7.73, y: 20.36))
            path.addLine(to: CGPoint(x: 4.18, y: 14.94))
            path.addCurve(to: CGPoint(x: 3.45, y: 14.69), controlPoint1: CGPoint(x: 3.99, y: 14.77), controlPoint2: CGPoint(x: 3.45, y: 14.69))
            path.addLine(to: CGPoint(x: 1.6, y: 14.59))
            path.addLine(to: CGPoint(x: 3.2, y: 21.39))
            path.addLine(to: CGPoint(x: 0, y: 22.59))
            path.addLine(to: CGPoint(x: 3.2, y: 23.79))
            path.addLine(to: CGPoint(x: 1.6, y: 30.59))
            path.addLine(to: CGPoint(x: 3.45, y: 30.49))
            path.addCurve(to: CGPoint(x: 4.18, y: 30.25), controlPoint1: CGPoint(x: 3.45, y: 30.5), controlPoint2: CGPoint(x: 3.99, y: 30.42))
            path.addLine(to: CGPoint(x: 7.46, y: 25.06))
            path.addCurve(to: CGPoint(x: 8.2, y: 24.58), controlPoint1: CGPoint(x: 7.73, y: 24.83), controlPoint2: CGPoint(x: 7.76, y: 24.49))
            path.addCurve(to: CGPoint(x: 18.41, y: 25.17), controlPoint1: CGPoint(x: 11.5, y: 25.27), controlPoint2: CGPoint(x: 17.72, y: 25.13))
            path.close()
            path.fill()
        }
    }
    
    static func setColor(view: UIView?, color: UIColor?) {
        if let view = view as? IconViewFactoryView, let color = color {
            view.color = color
            view.setNeedsDisplay()
        }
    }
}


class IconViewFactoryView: UIView {
    var color = UIColor.gray
    var type = IconViewFactory.disclosureIndicator
    var scaleToFit = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isOpaque = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
    }
    
    
    convenience init(size: CGSize, color: UIColor?, type: IconViewFactory) {
        self.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        if let color = color {
            self.color = color
        }
        self.type = type
    }
    
    override func draw(_ rect: CGRect) {
        color.set()
        if scaleToFit {
            type.draw(in: rect, margin: 0)
        } else {
            type.draw()
        }
    }
}
