//
//  SelectedItemsOfStoreTVC.swift
//  QueDrop
//
//  Created by C100-104 on 25/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SelectedItemsOfStoreTVC: UITableViewCell {

	@IBOutlet var imgFoodType: UIImageView!
	@IBOutlet var lblProductName: UILabel!
	@IBOutlet var lblProductAddons: UILabel!
	@IBOutlet var lblTotalPrice: UILabel!
	@IBOutlet var btnCustomise: UIButton!
	
	@IBOutlet var ViewQty: UIView!
	@IBOutlet var btnDecreaseQty: UIButton!
	@IBOutlet var lblQty: UILabel!
	@IBOutlet var btnIncreaseQty: UIButton!
	@IBOutlet var OuterView: UIView!
	@IBOutlet var InnerView: UIView!
	@IBOutlet var btnCustomiseHeight: NSLayoutConstraint!
	@IBOutlet var btnRemoveItem: UIButton!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		let origImage = UIImage(named: "bin_gray")
		let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
		btnRemoveItem.setImage(tintedImage, for: .normal)
		btnRemoveItem.tintColor = .red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }

}
