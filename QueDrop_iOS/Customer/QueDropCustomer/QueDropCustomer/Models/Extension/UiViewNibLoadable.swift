//
//  UiViewNibLoadable.swift
//  QueDrop
//
//  Created by C100-104 on 05/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//
/*
* Protocol, extension and base class to load any UIView from nib in Interface Builder or programmatically.
* Example sage:
* @IBDesignable class MyView: UIViewNibLoadable {
*   // IBOutlets, IBActions, other view logic here
* }
*
* let myView = MyView() // will load from MyView.xib and attach all outlets / actions
*/
import Foundation

 
import UIKit

public protocol NibLoadable {
    func loadFromNib()
}

public extension NibLoadable where Self: UIView {
    
    func loadFromNib() {
        
        let bundle = Bundle(for: Self.self)
        
        let nibName = (String(describing: type(of: self)) as NSString).components(separatedBy: ".").last!
                
        guard let view = bundle.loadNibNamed(nibName, owner: self, options: nil)?.first as? UIView else {

            print("Could not load nib with name: \(nibName)")
            return
        }
		view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        view.frame = bounds

        self.addSubview(view)
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

open class UIViewNibLoadable: UIView, NibLoadable {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadFromNib()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadFromNib()
        
        awakeFromNib()
    }
    
    public convenience init() {
        self.init(frame: .zero)
    }
}
