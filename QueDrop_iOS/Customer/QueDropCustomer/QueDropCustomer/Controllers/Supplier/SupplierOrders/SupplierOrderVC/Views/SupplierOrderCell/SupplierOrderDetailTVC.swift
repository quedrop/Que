//
//  SupplierOrderDetailTVC.swift
//  QueDrop
//
//  Created by C100-105 on 03/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierOrderDetailTVC: BaseTableViewCell {

    @IBOutlet weak var viewProduct: SupplierProductHeaderView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setupUI() {
        super.setupUI()
        
        viewProduct.viewContainer.showBorder(.clear, 0, 0)
        viewProduct.constraintsViewContainerTop.constant = 0
        viewProduct.backgroundColor = .clear
        
    }
    
    func bindDetails(ofProduct product: SupplierProducts, order: SupplierOrder, isPastOrder: Bool) {
        viewProduct.bindDetails(ofProduct: product, order: order, isPastOrder: isPastOrder)
        viewProduct.parentViewContainer.isUserInteractionEnabled = false
        
        setupUI()
    }
}
