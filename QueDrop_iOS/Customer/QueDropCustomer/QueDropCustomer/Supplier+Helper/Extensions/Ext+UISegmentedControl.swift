//
//  UISegmentedControl+Helper.swift
//  Motive8
//
//  Created by C100-105 on 22/01/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import Foundation
import UIKit

extension UISegmentedControl {
    
    func setupCustomSegment() {
        
        let selectedColor = UIColor.white
        let unselectedColor = UIColor.clear
        
        self.backgroundColor = .clear//.white
        
        if #available(iOS 13.0, *) {
            self.selectedSegmentTintColor = selectedColor
            //self.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        } else {
            self.tintColor = selectedColor
        }
        
        setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        //let unselectFont = UIFont.systemFont(ofSize: fontSize, weight: .light).getAppFont()
        let selectFont = UIFont(name: fFONT_MEDIUM, size: 17.0) // UIFont.systemFont(ofSize: 16, weight: .medium)
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: THEME_COLOR,
            NSAttributedString.Key.font: selectFont
        ]
        
        let unselectedAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: selectFont
        ]
        
        self.setTitleTextAttributes(unselectedAttributes, for: .normal)
        self.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
    
    func addCustomSegmentBackground(heightOfUnderLine: CGFloat? = nil) {
        let underLineTag = 123
        if let underline = self.viewWithTag(underLineTag) {
            underline.removeFromSuperview()
        }
        
        let underlineWidth: CGFloat = frame.width / CGFloat(numberOfSegments)
        
        let underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))
        
        var underLineHeight: CGFloat = frame.height
        if let heightOfUnderLine = heightOfUnderLine {
            underLineHeight = heightOfUnderLine
        }
        
        let underLineYPosition: CGFloat = frame.height-underLineHeight
        
        let underlineFrame = CGRect(
            x: underlineXPosition,
            y: underLineYPosition,
            width: underlineWidth,
            height: underLineHeight)
        
        
        let underline = UIView(frame: underlineFrame)
        underline.backgroundColor = .clear// .appColor
        underline.tag = underLineTag
        
        //if #available(iOS 13.0, *) {
        self.addSubview(underline)
        self.bringSubviewToFront(underline)
        //}
    }
    
    func updateCustomSegment() {
        let underLineTag = 123
        guard let underline = self.viewWithTag(underLineTag) else { return }
        let underlineWidth: CGFloat = frame.width / CGFloat(numberOfSegments)
        let underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))
        
        UIView.animate(withDuration: 0.1, animations: {
            underline.frame.origin.x = underlineXPosition
        })
    }
}
