//
//  AddressIconTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 02/01/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class AddressIconTVCell: UITableViewCell {

	@IBOutlet var btnHome: UIButton!
	@IBOutlet var btnOffice: UIButton!
	@IBOutlet var btnBeach: UIButton!
	@IBOutlet var btnLocation: UIButton!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	@IBAction func actionButtonPressed(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
		for index in 1...4
		{
			if index == 1 && index != sender.tag
			{
				btnHome.isSelected = false
			}
			else if index == 2 && index != sender.tag
			{
				btnOffice.isSelected = false
			}
			else if index == 3 && index != sender.tag
			{
				btnBeach.isSelected = false
			}
			else if index == 4 && index != sender.tag
			{
				btnLocation.isSelected = false
			}
			
		}
	}
}
