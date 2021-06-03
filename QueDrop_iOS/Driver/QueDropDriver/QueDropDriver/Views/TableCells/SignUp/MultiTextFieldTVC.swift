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
    @IBOutlet var lblFirstName: UILabel!
    @IBOutlet var lblLastName: UILabel!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		//self.txtFirstName.setLeftRightPadding(CGFloat(10))
		//self.txtLastName.setLeftRightPadding(CGFloat(10))
        
//        lblFirstName.text = "First Name"
//        lblFirstName.textColor = .gray
//        lblFirstName.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 13.0))
//
//        lblLastName.text = "Last Name"
//        lblLastName.textColor = lblFirstName.textColor
//        lblLastName.font = lblFirstName.font
               
        txtFirstName.textColor = .black
        txtFirstName.font =  UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 14.5))
        txtFirstName.tintColor = .black
               
        txtLastName.textColor = txtFirstName.textColor
        txtLastName.font = txtFirstName.font
        txtLastName.tintColor = .black
        
        self.txtFirstName.addBottomLine()
        self.txtLastName.addBottomLine()
        setupFloatingTextField(textField: self.txtFirstName)
        setupFloatingTextField(textField: self.txtLastName)
        
    }
    
}
