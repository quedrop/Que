//
//  SupplierOrderFooterTVC.swift
//  QueDrop
//
//  Created by C100-105 on 04/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierOrderFooterTVC: BaseTableViewCell {

    @IBOutlet weak var viewDriver: SupplierProductFooterView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func setupUI() {
        super.setupUI()
        
        viewDriver.viewContainer.showBorder(.clear, 0, 0)
        viewDriver.backgroundColor = .clear
    }
    
    func bindDetails(order: SupplierOrder) {
        viewDriver.setBorder(isCorner: true)
        
        let name = ((order.driverDetail?.firstName).asString() + " " + (order.driverDetail?.lastName).asString())
        viewDriver.lblDriverName.text = name.trimmingCharacters(in: .whitespaces)
        
        setupUI()
    }
    
}
