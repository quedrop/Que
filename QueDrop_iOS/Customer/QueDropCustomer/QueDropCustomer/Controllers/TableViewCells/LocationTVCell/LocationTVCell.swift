//
//  LocationTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 01/01/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class LocationTVCell: UITableViewCell {

	@IBOutlet var imageViewLeft: UIImageView!
	@IBOutlet var lblHeader: UILabel!
	@IBOutlet var lblContent: UILabel!
	@IBOutlet var btnRight: UIButton!
	
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
