//
//  ConfirmedOrderDetailsTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 02/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit


class ConfirmedOrderDetailsTVCell: UITableViewCell {

	
	
	@IBOutlet var btnTip1: UIButton!
	@IBOutlet var btnTip2: UIButton!
	@IBOutlet var btnTip3: UIButton!
	@IBOutlet var btnNoTip: UIButton!
	@IBOutlet var btnHelp: UIButton!
	@IBOutlet var btnPayNow: UIButton!
    @IBOutlet weak var viewContainerApplePay: UIStackView!
    
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        drawBorder(view: btnHelp, color: .darkGray, width: 1.0, radius: 5.0)
        // Configure the view for the selected state
    }
 
	@IBAction func actionAddTip1(_ sender: UIButton) {
		sender.isSelected = true
		sender.backgroundColor = THEME_COLOR
		
		btnTip2.isSelected = false
		btnTip2.backgroundColor = .white
		btnTip3.isSelected = false
		btnTip3.backgroundColor = .white
		btnNoTip.isSelected = false
		btnNoTip.backgroundColor = .white
	}
	@IBAction func actionAddTip2(_ sender: UIButton) {
		sender.isSelected = true
		sender.backgroundColor = THEME_COLOR
		
		btnTip1.isSelected = false
		btnTip1.backgroundColor = .white
		btnTip3.isSelected = false
		btnTip3.backgroundColor = .white
		btnNoTip.isSelected = false
		btnNoTip.backgroundColor = .white
	}
	@IBAction func actionAddTip3(_ sender: UIButton) {
		sender.isSelected = true
		sender.backgroundColor = THEME_COLOR
		
		btnTip2.isSelected = false
		btnTip2.backgroundColor = .white
		btnTip1.isSelected = false
		btnTip1.backgroundColor = .white
		btnNoTip.isSelected = false
		btnNoTip.backgroundColor = .white
	}
	@IBAction func actionNoTip(_ sender: UIButton) {
		sender.isSelected = true
		sender.backgroundColor = THEME_COLOR
		
		btnTip2.isSelected = false
		btnTip2.backgroundColor = .white
		btnTip1.isSelected = false
		btnTip1.backgroundColor = .white
		btnTip3.isSelected = false
		btnTip3.backgroundColor = .white
	}
	
	@IBAction func actionHelp(_ sender: Any) {
	}
	
	@IBAction func actionPayNow(_ sender: Any) {
	}
}
