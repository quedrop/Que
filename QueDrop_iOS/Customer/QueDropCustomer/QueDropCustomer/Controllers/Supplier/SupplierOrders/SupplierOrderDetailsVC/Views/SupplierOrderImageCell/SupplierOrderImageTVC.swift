//
//  SupplierOrderImageTVC.swift
//  QueDrop
//
//  Created by C100-105 on 03/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierOrderImageTVC: BaseTableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgBlackTransparent: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func setupUI() {
        super.setupUI()
        
        viewContainer.showBorder(.clear, 10)
        lblQty.showBorder(.white, 5, 0.5)
        
        lblName.textColor = .white
        lblQty.textColor = .white
    }
    
    func bindDetail(ofProduct product: SupplierProducts) {
        setupUI()
        
        let url = URL_PRODUCT_IMAGES + product.productImage.asString()
        imgView.setWebImage(url, .noImagePlaceHolder)
        
        lblName.text = product.productName
        lblQty.text = "Qty: " + product.quantity.asInt().description
        
    }
    
}
