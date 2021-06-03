//
//  GradientView.swift
//  Solitaire
//
//  Created by mac6 on 04/11/19.
//  Copyright © 2019 mac6. All rights reserved.
//

import UIKit


class GradientView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        
    }

    override func layoutSubviews() {
        gradientLayer.frame = self.bounds
        applyGradientBG(ColorSet: GRADIENT_ARRAY, direction: .topToBottom)
    }
    
    func applyGradientBG(ColorSet arrColor : [CGColor], direction : GradientDirection)  {
        gradientLayer.frame = self.bounds
        gradientLayer.colors = arrColor
        
        switch direction {
        case .leftToRight:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            break;
            
        case .rightToLeft:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
            break;
            
        case .bottomToTop:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
            break;
            
        case .TopLeftToBottomRight:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            break;
            
        case .TopRightToBottomLeft:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
            break;
            
        case .BottomLeftToTopRight:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
            break;
            
        case .BottomRightToTopLeft:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
            break;
            
        default: //Default Case is Top To Bottom
            break;
        }
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
