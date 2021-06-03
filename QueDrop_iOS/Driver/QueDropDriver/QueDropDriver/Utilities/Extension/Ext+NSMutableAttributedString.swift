//
//  Ext+String.swift
//  ChatDemo
//
//  Created by C100-105 on 06/04/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import UIKit

extension String {
    func isPasswordValid() -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{6,}$")
        return passwordTest.evaluate(with: self)
    }
}

extension NSMutableAttributedString {
    
    func setColorToTextFromStart(count: Int, withColor color: UIColor) {
        let range = NSRange(location: 0, length: count)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    
    func setColorTo(text: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: text, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    
    func font(_ text: String, _ font: UIFont) {
        let range: NSRange = self.mutableString.range(of: text, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.font, value: font, range: range)
    }
    
    func bold(_ text: String, _ fontSize: CGFloat) {
        let font = UIFont.boldSystemFont(ofSize: fontSize)
        
        let range: NSRange = self.mutableString.range(of: text, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.font, value: font, range: range)
    }
    
    func underLine(_ text: String) {
        let range: NSRange = self.mutableString.range(of: text, options: .caseInsensitive)
        self.addAttribute(
            NSAttributedString.Key.underlineStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: range)
    }
    
    func normal(_ text: String, _ fontSize: CGFloat) {
        let font = UIFont.systemFont(ofSize: fontSize)
        
        let range: NSRange = self.mutableString.range(of: text, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.font, value: font, range: range)
    }
    
    func strikethroughStyle(text: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: text, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: range)
        self.addAttribute(NSAttributedString.Key.strikethroughColor, value: color, range: range)
    }
    
    func getRange(ofText text: String) -> NSRange {
        return self.mutableString.range(of: text, options: .caseInsensitive)
    }
}
