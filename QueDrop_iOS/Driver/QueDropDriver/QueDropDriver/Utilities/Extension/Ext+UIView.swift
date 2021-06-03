//
//  Ext+UIView.swift
//  Assignment10
//
//  Created by C100-105 on 04/02/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import UIKit

extension UIView {
    
    func showBorder(_ color: UIColor, _ cornerRadius: CGFloat, _ borderWidth: CGFloat = 1) {
        clipsToBounds = true
        layer.borderColor = color.cgColor
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
    }
    
    func circlularView(_ borderWidth: CGFloat = 0, radius: CGFloat? = nil) {
        clipsToBounds = true
        if let radius = radius {
            layer.cornerRadius = radius
        } else {
            layer.cornerRadius = frame.width / 2
        }
        
        layer.borderWidth = borderWidth
    }
    
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview.map { $0.superview(of: type)! }
    }
    
    func subview<T>(of type: T.Type) -> T? {
        return subviews.compactMap { $0 as? T ?? $0.subview(of: type) }.first
    }
    
    func fixInView(_ container: UIView) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        
        NSLayoutConstraint(
            item: self, attribute: .leading, relatedBy: .equal,
            toItem: container, attribute: .leading, multiplier: 1.0, constant: 0)
            .isActive = true
        
        NSLayoutConstraint(
            item: self, attribute: .trailing, relatedBy: .equal,
            toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0)
            .isActive = true
        
        NSLayoutConstraint(
            item: self, attribute: .top, relatedBy: .equal,
            toItem: container, attribute: .top, multiplier: 1.0, constant: 0)
            .isActive = true
        
        NSLayoutConstraint(
            item: self, attribute: .bottom, relatedBy: .equal,
            toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0)
            .isActive = true
    }
    
    func getEmptyView(title: String, message: String, font: UIFont) -> UIView {
        let emptyView = UIView(
            frame: CGRect(
                x: self.center.x,
                y: self.center.y,
                width: self.bounds.size.width,
                height: self.bounds.size.height
            )
        )
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColor.black
        titleLabel.font = font
        
        messageLabel.textColor = UIColor.black
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        titleLabel.text = title
        messageLabel.text = message
        
        return emptyView
    }
    
    func showShadow(color: UIColor) {
        layer.shadowColor = color.cgColor
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shadowRadius = 5
        layer.shadowOffset = .zero
        layer.shadowOpacity = 1
        
        
    }
    
    func showShadowBorder(color: UIColor) {
        layer.shadowColor = color.cgColor
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shadowRadius = 5
        layer.shadowOffset = .zero
        layer.shadowOpacity = 1
        layer.borderColor = color.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
    }
}
