//
//  SupplierProductFooterView.swift
//  QueDrop
//
//  Created by C100-105 on 03/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierProductFooterView: UIView {

    @IBOutlet weak var parentViewContainer: UIView!
    @IBOutlet weak var viewContainer: UIView!

    @IBOutlet weak var lblDriverName: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("SupplierProductFooterView", owner: self, options: nil)
        parentViewContainer.fixInView(self)
        lblDriverName.textColor = #colorLiteral(red: 0, green: 0.3490196078, blue: 0.3882352941, alpha: 1)
        viewContainer.showBorder(.clear, 10, 0.5)
    }
    
    func setBorder(isCorner: Bool) {
        
        let corner: CGFloat = isCorner ? 10 : 0
        let rectShape = CAShapeLayer()
        rectShape.bounds = viewContainer.frame
        rectShape.position = viewContainer.center
        rectShape.path = UIBezierPath(
            roundedRect: viewContainer.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: corner, height: corner))
            .cgPath
        
        viewContainer.layer.backgroundColor = UIColor.white.cgColor
        viewContainer.layer.mask = rectShape
    }
    
}
