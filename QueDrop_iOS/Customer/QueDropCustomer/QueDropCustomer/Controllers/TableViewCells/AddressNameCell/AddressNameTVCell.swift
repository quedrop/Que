//
//  AddressNameTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 02/01/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class NameTVCell: UITableViewCell {

	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var textField: UITextField!
	@IBOutlet var btnLocation: UIButton!
    @IBOutlet weak var btnClearText: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    self.textField.setLeftRightPadding(5.0)
        if self.btnClearText != nil
        {
            self.btnClearText.isHidden = true
            self.textField.setRightPadding(45)
            self.textField.setLeftPadding(5)
        }
        // Initialization code
	
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		
        // Configure the view for the selected state
    }

}
