//
//  PaymentMethodTVC.swift
//  QueDrop
//
//  Created by C100-104 on 25/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class PaymentMethodTVC: UITableViewCell {

	@IBOutlet var imageCardType: UIImageView!
	@IBOutlet var lblCardNumber: UILabel!
	@IBOutlet var lblCardExpireDate: UILabel!
	@IBOutlet var btnChangePaymentMethod: UIButton!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
