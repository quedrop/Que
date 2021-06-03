//
//  ViewAllOrderCell.swift
//  QueDropDriver
//
//  Created by C100-174 on 22/05/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class ViewAllOrderCell: UITableViewCell {

    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var lblOrderAmount: UILabel!
    @IBOutlet weak var lblOrderTime: UILabel!
    @IBOutlet weak var lblCustomerName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        drawBorder(view: viewContent, color: .lightGray, width: 1.0, radius: 5.0)
        
        lblOrderId.textColor = .black
        lblOrderId.font = UIFont(name: fFONT_BOLD, size: calculateFontForWidth(size: 17.0))
        
        lblOrderAmount.textColor = .black
        lblOrderAmount.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 15.0))
        
        lblCustomerName.textColor = .darkGray
        lblCustomerName.font = UIFont(name: fFONT_LIGHT, size: calculateFontForWidth(size: 14.0))
        
        lblOrderTime.textColor = .darkGray
        lblOrderTime.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 12.0))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
