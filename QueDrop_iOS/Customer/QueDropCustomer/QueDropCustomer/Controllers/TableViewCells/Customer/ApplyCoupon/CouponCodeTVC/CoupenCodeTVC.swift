//
//  CoupenCodeTVC.swift
//  QueDrop
//
//  Created by C100-104 on 26/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class CoupenCodeTVC: UITableViewCell {

	@IBOutlet var btnCheck: UIButton!
	@IBOutlet var textCoupenCode: UITextField!
	@IBOutlet var lblCouponTitle: UILabel!
	@IBOutlet var lblCouponDiscription: UILabel!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		//textCoupenCode.setLeftRightPadding(10)
		textCoupenCode.textColor = THEME_COLOR
    }
	//MARK:- Action
	@IBAction func actionCheck(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
		if sender.isSelected
		{
			sender.backgroundColor = THEME_COLOR
		}
		else
		{
			sender.backgroundColor = .clear
		}
	}
	//MARK:- Function
	
}
