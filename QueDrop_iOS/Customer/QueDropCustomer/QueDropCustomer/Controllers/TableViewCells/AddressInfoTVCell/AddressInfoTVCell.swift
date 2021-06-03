//
//  AddressInfoTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 02/01/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class InfoTVCell: UITableViewCell {

	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var textView: UITextView!
    @IBOutlet weak var btnClear: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
