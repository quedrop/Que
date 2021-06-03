//
//  OrderStoreProductCell.swift
//  QueDrop
//
//  Created by C100-174 on 23/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class OrderStoreProductCell: UITableViewHeaderFooterView {

    @IBOutlet weak var imgStore: UIImageView!
    @IBOutlet weak var lblStoreName: UILabel!
    @IBOutlet weak var lblStoreLocation: UILabel!
    @IBOutlet weak var btnAddReceipt: UIButton!
    @IBOutlet weak var constraintBtnReceiptWidth: NSLayoutConstraint!
     @IBOutlet weak var constraintimgCloseWidth: NSLayoutConstraint!
     @IBOutlet weak var imgReceipt: UIImageView!
    @IBOutlet weak var imgClose: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
         lblStoreName.textColor = .black
         lblStoreName.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 15.0))
         drawBorder(view: imgStore, color: .lightGray, width: 1.0, radius: 5.0)
    }
    
}
