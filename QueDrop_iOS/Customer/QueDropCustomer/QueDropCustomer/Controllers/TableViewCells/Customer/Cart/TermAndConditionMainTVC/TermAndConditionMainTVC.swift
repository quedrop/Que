//
//  TermAndConditionMainTVC.swift
//  QueDrop
//
//  Created by C100-104 on 24/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class TermAndConditionMainTVC: UITableViewCell {

	
	@IBOutlet var lblTnCHeader: UILabel!
	@IBOutlet var btnTnC: UIButton!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	@IBAction func actionTnC(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
		if sender.isSelected
		{
			sender.backgroundColor = THEME_COLOR
		} else {
			sender.backgroundColor = .white
		}
	}
}
