//
//  DeliveryTimeOptionTVC.swift
//  QueDrop
//
//  Created by C100-104 on 25/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class DeliveryTimeOptionTVC: UITableViewCell {

	
	@IBOutlet var btnDeliveryNowSelection: UIButton!
	@IBOutlet var btnAdvanceOrder: UIButton!
	@IBOutlet var btnAdvanceOrderSelection: UIButton!
	
    @IBOutlet var btnStandard: UIButton!
    @IBOutlet var btnExpress: UIButton!
    @IBOutlet var imgStandard: UIImageView!
    @IBOutlet var imgExpress: UIImageView!
    
	override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
	@IBAction func actionDeliveryNow(_ sender: Any) {
		self.btnDeliveryNowSelection.isSelected = true
		self.btnAdvanceOrderSelection.isSelected = false
	}
	
	@IBAction func actionAdvanceDelivery(_ sender: Any) {
		self.btnAdvanceOrderSelection.isSelected = true
		self.btnDeliveryNowSelection.isSelected = false
	}
}
