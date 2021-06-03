//
//  ItemAddOnTVC.swift
//  QueDrop
//
//  Created by C100-104 on 12/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class ItemAddOnTVC: UITableViewCell {

	@IBOutlet var imageAddOnType: UIImageView!
	@IBOutlet var imageRadioButton: UIImageView!
	@IBOutlet var lblAddOnTitle: UILabel!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
