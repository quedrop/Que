//
//  BillDetailsOptionTVC.swift
//  QueDrop
//
//  Created by C100-104 on 25/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class BillDetailsOptionTVC: UITableViewCell {

	@IBOutlet var lblItemTotal: UILabel!
	@IBOutlet var lblServiceCharges: UILabel!
	@IBOutlet var lblShoppingFee: UILabel!
	@IBOutlet var lblDeliveryCharges: UILabel!
	@IBOutlet var lblFinalAmount: UILabel!
	@IBOutlet var viewMainDiscount: UIView!
	@IBOutlet var viewOrderDiscount: UIView!
	@IBOutlet var viewCoupenDiscount: UIView!
	@IBOutlet var lblOrderDiscount: UILabel!
	@IBOutlet var lblCoupenDiscount: UILabel!
    @IBOutlet weak var shoppingLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var lblShoppingFeeLabel: UILabel!
    @IBOutlet weak var btnShowServiceCharge: UIButton!
    @IBOutlet weak var btnShowShoppingFee: UIButton!
    @IBOutlet weak var btnShowDeliveryFee: UIButton!
    
	
	override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
