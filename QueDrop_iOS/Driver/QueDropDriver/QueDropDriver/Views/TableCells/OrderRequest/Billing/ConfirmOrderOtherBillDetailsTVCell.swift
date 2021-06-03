//
//  ConfirmOrderOtherBillDetailsTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 07/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class ConfirmOrderOtherBillDetailsTVCell: UITableViewCell {

	@IBOutlet var lblServiceChargeAmt: UILabel!
	@IBOutlet var lblDeliveryFeeAmt: UILabel!
	@IBOutlet var lblShoppingFeeAmt: UILabel!
	@IBOutlet var lblToPayAmt: UILabel!
	@IBOutlet var viewShoppingCharge: UIView!
    @IBOutlet var viewManualTotal: UIView!
    @IBOutlet var lblManualStoreTotal: UILabel!
    @IBOutlet var constraintViewMnualStoreTotalHeight: NSLayoutConstraint!
    @IBOutlet var viewYouEarn: UIView!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
