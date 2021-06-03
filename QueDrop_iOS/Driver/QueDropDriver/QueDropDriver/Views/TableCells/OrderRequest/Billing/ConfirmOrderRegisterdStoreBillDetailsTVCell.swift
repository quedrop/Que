//
//  ConfirmOrderRegisterdStoreBillDetailsTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 07/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class ConfirmOrderRegisterdStoreBillDetailsTVCell: UITableViewCell {

	@IBOutlet var billDetailsHeaderHeight: NSLayoutConstraint!
	@IBOutlet var lblRegisterdStoreName: UILabel!
	@IBOutlet var lblRegisterdStoreItemTotalAmt: UILabel!
	@IBOutlet var lblStoreNameDiscount: UILabel!
	@IBOutlet var lblStoreDiscountAmt: UILabel!
	@IBOutlet var StoreDiscountView: UIView!
	@IBOutlet var viewOrderAndCouponDiscount: UIView!
	@IBOutlet var viewOrderDiscount: UIView!
	@IBOutlet var lblOrderDiscountAmt: UILabel!
	@IBOutlet var viewCouponDiscount: UIView!
	@IBOutlet var lblCouponDiscountAmt: UILabel!
	
	@IBOutlet var viewRegisterdStoreDetails: UIView!
	
	@IBOutlet var viewBottomSaperator: UIView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
