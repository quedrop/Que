//
//  SupplierProductHeaderView.swift
//  QueDrop
//
//  Created by C100-105 on 03/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierProductHeaderView: UIView {
    
    
    @IBOutlet weak var constraintsViewContainerTop: NSLayoutConstraint!
    @IBOutlet weak var parentViewContainer: UIView!
    
    @IBOutlet weak var viewDashedBorder: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgProduct: UIImageView!
    
    @IBOutlet weak var lblQty: UILabel!
    
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblCustomerName: UILabel!
    @IBOutlet weak var lblOrderPlacedDate: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("SupplierProductHeaderView", owner: self, options: nil)
        parentViewContainer.fixInView(self)
        
        viewDashedBorder.isHidden = true
        
        imgProduct.contentMode = .scaleAspectFill
        viewContainer.showBorder(.clear, 10, 0.5)

        imgProduct.showBorder(.clear, 5)
        
    }
    
    func addDashedBorder() {
        viewDashedBorder.isHidden = false
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = viewDashedBorder.frame
        rectShape.position = viewDashedBorder.center
        rectShape.path = UIBezierPath(
            roundedRect: viewDashedBorder.bounds,
            byRoundingCorners: [.bottomLeft , .bottomRight],
            cornerRadii: CGSize(width: 0, height: 0))
            .cgPath
        
        rectShape.strokeColor = UIColor.lightGray.cgColor
        rectShape.lineDashPattern = [2, 10]
        rectShape.fillColor = nil
        
        viewDashedBorder.layer.backgroundColor = UIColor.lightGray.cgColor
        viewDashedBorder.layer.mask = rectShape
    }
    
    func setBorder(isCorner: Bool) {
        viewDashedBorder.isHidden = true
        let corner: CGFloat = isCorner ? 10 : 0
        let rectShape = CAShapeLayer()
        rectShape.bounds = viewContainer.frame
        rectShape.position = viewContainer.center
        rectShape.path = UIBezierPath(
            roundedRect: viewContainer.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: corner, height: corner))
            .cgPath
        rectShape.borderWidth = 1.0
        rectShape.borderColor = UIColor.lightGray.cgColor
        
        viewContainer.layer.backgroundColor = UIColor.white.cgColor
        viewContainer.layer.mask = rectShape
    }
    
    func bindDetails(ofProduct product: SupplierProducts, order: SupplierOrder, isPastOrder: Bool) {
        lblQty.adjustsFontSizeToFitWidth = true
    
        var name = ((order.customerDetail?.firstName).asString() + " " /*+ (order.customerDetail?.lastName).asString()*/)
        
        if let lastName =  order.customerDetail?.lastName {
            if lastName.count > 0 {
                name += lastName.prefix(1) + "."
            }
        }
        let url = URL_PRODUCT_IMAGES + product.productImage.asString()
        
        imgProduct.setWebImage(url, .noImagePlaceHolder)
        
        var qtyString = "Qty: " + product.quantity.asInt().description
        var dateTimeString = ""
        
        if let date = order.createdAt?.toDate() {
            dateTimeString = date.toString(format: "dd MMMM yyyy")
        }
        
        if isPastOrder {
            qtyString = order.orderStatus.asString()
            dateTimeString = Currency + " " + product.productPrice.asInt().description
            
        }
        lblQty.text = qtyString
        lblOrderPlacedDate.text = dateTimeString
        lblProductName.text = product.productName
        
        lblCustomerName.text = name.trimmingCharacters(in: .whitespaces)
        
    }
    
}
