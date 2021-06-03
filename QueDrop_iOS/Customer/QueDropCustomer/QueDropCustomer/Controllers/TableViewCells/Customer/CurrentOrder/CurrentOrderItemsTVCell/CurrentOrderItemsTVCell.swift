//
//  CurrentOrderItemsTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 27/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class CurrentOrderItemsTVCell: UITableViewCell {

	@IBOutlet var outerView: UIView!
	@IBOutlet var innerView: UIView!
	@IBOutlet var imgItemTypeLogo: UIImageView!
	@IBOutlet var imageTypeLogoWidth: NSLayoutConstraint!
	
	@IBOutlet var lblProductName: UILabel!
	@IBOutlet var lblProductDetails: UILabel!
	@IBOutlet var lblOrderCount: UILabel!
	@IBOutlet var bottomCountViewHeight: NSLayoutConstraint!
	
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
