//
//  EarningBillDetailCell.swift
//  QueDropDriver
//
//  Created by C100-174 on 21/05/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class EarningBillDetailCell: UITableViewCell {

    @IBOutlet weak var viewReferralEarning: UIView!
    @IBOutlet weak var lblTitleSummary: UILabel!
    @IBOutlet weak var lblTitleDelivery: UILabel!
    @IBOutlet weak var lblTitleShopping: UILabel!
    @IBOutlet weak var lblTitleTip: UILabel!
    @IBOutlet weak var lblTitleReferralEarning: UILabel!
    @IBOutlet weak var lblTitleTotal: UILabel!
    @IBOutlet weak var lblDeliveryTotal: UILabel!
    @IBOutlet weak var lblShoppingTotal: UILabel!
    @IBOutlet weak var lblTipTotal: UILabel!
    @IBOutlet weak var lblRefferalEarningTotal: UILabel!
    @IBOutlet weak var lblGrandTotal: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI() {
        lblTitleSummary.textColor = .black
        lblTitleSummary.text = "Summary"
        lblTitleSummary.font = UIFont(name: fFONT_BOLD, size: calculateFontForWidth(size: 16.0))
        
        lblTitleDelivery.text = "Total Delivery Earning"
        lblTitleShopping.text = "Total Shopping Earning"
        lblTitleTip.text = "Total Tip Received"
        lblTitleReferralEarning.text = "Total Referral Earning"
        lblTitleTotal.text = "Total"
        
        lblTitleDelivery.textColor = .black
        lblTitleDelivery.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 14.0))
        
        lblTitleShopping.textColor = lblTitleDelivery.textColor
        lblTitleShopping.font = lblTitleDelivery.font
        
        lblTitleTip.textColor = lblTitleDelivery.textColor
        lblTitleTip.font = lblTitleDelivery.font
        
        lblTitleReferralEarning.textColor = lblTitleDelivery.textColor
        lblTitleReferralEarning.font = lblTitleDelivery.font
        
        lblDeliveryTotal.textColor = lblTitleDelivery.textColor
        lblDeliveryTotal.font = lblTitleDelivery.font
        
        lblShoppingTotal.textColor = lblTitleDelivery.textColor
        lblShoppingTotal.font = lblTitleDelivery.font
        
        lblTipTotal.textColor = lblTitleDelivery.textColor
        lblTipTotal.font = lblTitleDelivery.font
        
        lblRefferalEarningTotal.textColor = lblTitleDelivery.textColor
        lblRefferalEarningTotal.font = lblTitleDelivery.font
        
        lblTitleTotal.textColor = .black
        lblTitleTotal.font = UIFont(name: fFONT_BOLD, size: calculateFontForWidth(size: 14.0))
        
        lblGrandTotal.textColor = lblTitleTotal.textColor
        lblGrandTotal.font = lblTitleTotal.font
    }
    
}
