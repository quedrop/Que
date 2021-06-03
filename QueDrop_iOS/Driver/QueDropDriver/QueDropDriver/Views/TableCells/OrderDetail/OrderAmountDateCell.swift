//
//  OrderAmountDateCell.swift
//  QueDrop
//
//  Created by C100-174 on 30/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class OrderAmountDateCell: UITableViewCell {
    @IBOutlet var lblOrderDateTime: UILabel!
    //@IBOutlet var lblOrderAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblOrderDateTime.textColor = .black
        lblOrderDateTime.font = UIFont(name: fFONT_MEDIUM, size: 14.0)
        //lblOrderAmount.textColor = .black
        //lblOrderAmount.font = UIFont(name: fFONT_MEDIUM, size: 14.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
