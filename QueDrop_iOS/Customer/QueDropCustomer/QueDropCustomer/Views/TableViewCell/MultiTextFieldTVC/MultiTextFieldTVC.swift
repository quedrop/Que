//
//  MultiTextFieldTVC.swift
//  QueDrop
//
//  Created by C100-104 on 27/12/19.
//  Copyright © 2019 C100-104. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
class MultiTextFieldTVC: UITableViewCell {

	@IBOutlet var txtFirstName: JVFloatLabeledTextField!
	@IBOutlet var txtLastName: JVFloatLabeledTextField!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.txtFirstName.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 14.5))
       self.txtLastName.font = self.txtFirstName.font 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		//self.txtFirstName.setLeftRightPadding(CGFloat(10))
		//self.txtLastName.setLeftRightPadding(CGFloat(10))
        self.txtFirstName.addBottomLine()
       self.txtLastName.addBottomLine()
       setupFloatingTextField(textField: self.txtFirstName)
       setupFloatingTextField(textField: self.txtLastName)
        
    }
    
}
