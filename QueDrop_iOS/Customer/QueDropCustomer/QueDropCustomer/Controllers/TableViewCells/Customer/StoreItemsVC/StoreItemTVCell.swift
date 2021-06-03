//
//  StoreItemTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 10/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class StoreItemTVCell: UITableViewCell {

	@IBOutlet var imageItem: UIImageView!
	@IBOutlet var lblItemName: UILabel!
	@IBOutlet var lblItemPrice: UILabel!
	@IBOutlet var btnPriceTag: UIButton!
	@IBOutlet var btnAdd: UIButton!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	@IBAction func actionShowPriceTagDetails(_ sender: Any) {
	}
	
	@IBAction func actionAddItem(_ sender: Any) {
	}
}
