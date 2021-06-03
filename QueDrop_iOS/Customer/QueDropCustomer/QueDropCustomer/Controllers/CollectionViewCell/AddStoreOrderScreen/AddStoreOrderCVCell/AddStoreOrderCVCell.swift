//
//  AddStoreOrderCVCell.swift
//  QueDrop
//
//  Created by C100-104 on 13/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class AddStoreOrderCVCell: UICollectionViewCell {
    
	
	@IBOutlet var imageProduct: UIImageView!
	@IBOutlet var textProductName: UITextField!
	@IBOutlet var textProductQty: UITextField!
	@IBOutlet var btnCancel: UIButton!
	@IBOutlet var btnAddMore: UIButton!
	@IBOutlet var viewMain: UIView!
	override func awakeFromNib() {
		super.awakeFromNib()
		viewMain.layer.cornerRadius = 10
		viewMain.layer.borderColor = UIColor.gray.cgColor
		viewMain.layer.borderWidth = 0.5
		textProductQty.layer.borderColor = UIColor.gray.cgColor
		textProductQty.layer.borderWidth = 0.5
	}
	@IBAction func actionCancel(_ sender: Any) {
	}
	
}
