//
//  UITextField+Extensions.swift
//  QueDrop
//
//  Created by C100-104 on 27/12/19.
//  Copyright © 2019 C100-104. All rights reserved.
//

import Foundation
import UIKit

extension UITextField{
	
	func setLeftRightPadding(_ size : CGFloat)  {
		let leftpaddingView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: frame.height))
		let rightpaddingView = UIView(frame: CGRect(x: frame.width - size, y: 0, width: size, height: frame.height))
		leftView = leftpaddingView
		rightView = rightpaddingView
		leftViewMode = .always
		rightViewMode = .always
	}
	
	func setLeftPadding(_ size : CGFloat)  {
		let leftpaddingView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: frame.height))
		leftView = leftpaddingView
		leftViewMode = .always
	}
	func setRightPadding(_ size : CGFloat)  {
		let rightpaddingView = UIView(frame: CGRect(x: frame.width - size, y: 0, width: size, height: frame.height))
		rightView = rightpaddingView
		rightViewMode = .always
	}
    
    func addBottomLine(){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: self.frame.height - 1, width: self.frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(bottomLine)
    }
    
}
extension UITextView{
    func setRightPadding(_ size : CGFloat)  {
       // let rightpaddingView = UIView(frame: CGRect(x: frame.width - size, y: 0, width: size, height: frame.height))
        contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: size)
    }
    
    func setLeftPadding(_ size : CGFloat)  {
          contentInset = UIEdgeInsets(top: 5, left: size, bottom: 5, right: 5)
    }
    func setLeftRightPadding(_ leftSize : CGFloat,_ rightSize : CGFloat)  {
        contentInset = UIEdgeInsets(top: 5, left: leftSize, bottom: 5, right: rightSize)
    }
}
