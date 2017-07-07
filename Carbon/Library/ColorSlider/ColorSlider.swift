//
//  ColorSlider.swift
//  Carbon
//
//  Created by Mobile on 9/17/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit

class ColorSlider: UISlider {

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 6.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
        
    }

    public func addLayer() {
        let drawLayer = CAGradientLayer()
        
        drawLayer.masksToBounds = true
        drawLayer.cornerRadius = 3.0
        drawLayer.startPoint = CGPoint(x: 0, y: 0.5)
        drawLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Draw gradient
        let hues: [CGFloat] = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
        drawLayer.locations = hues as [NSNumber]?
        drawLayer.colors = hues.map({ (hue) -> CGColor in
            return UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1).cgColor
        })
        
        drawLayer.frame = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 6.0))
        
        self.layer.insertSublayer(drawLayer, at: 2)
        
        // set thumbnail image
        setThumbImage(UIImage(named: "CarbonThumb"), for: UIControlState.normal)
        setThumbImage(UIImage(named: "CarbonThumb"), for: UIControlState.highlighted)
        
        super.awakeFromNib()
    }
}
