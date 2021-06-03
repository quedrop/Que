//
//  CurrentOrderDetailsTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 27/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class CurrentOrderDetailsTVCell: UITableViewCell {

	
	@IBOutlet var outerView: UIView!
	@IBOutlet var innerView: UIView!
	@IBOutlet var lblOrderDateTime: UILabel!
	@IBOutlet var lblOrderAmount: UILabel!
	@IBOutlet var btnRepeatOrder: UIButton!
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
		if btnRepeatOrder != nil
		{
			btnRepeatOrder.layer.borderColor = UIColor.gray.cgColor
		}
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
