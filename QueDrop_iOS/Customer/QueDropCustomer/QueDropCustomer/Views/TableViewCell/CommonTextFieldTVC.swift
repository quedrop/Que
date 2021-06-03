//
//  CommonTextFieldTVC.swift
//  QueDrop
//
//  Created by C100-104 on 27/12/19.
//  Copyright © 2019 C100-104. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class CommonTextFieldTVC: UITableViewCell {

	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var textField: JVFloatLabeledTextField!
	@IBOutlet var btnAction: UIButton!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textField.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 14.5))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//		let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: self.textField.frame.height))
//		textField.leftView = paddingView
//		textField.leftViewMode = .always
		
		//self.textField.setLeftRightPadding(CGFloat(10))
        // Configure the view for the selected state
        DispatchQueue.main.async {
            self.textField.addBottomLine()
            setupFloatingTextField(textField: self.textField)
        }
        
    }
    
}
