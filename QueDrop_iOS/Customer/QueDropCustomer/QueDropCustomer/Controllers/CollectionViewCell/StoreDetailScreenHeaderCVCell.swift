//
//  StoreDetailScreenHeaderCVCell.swift
//  QueDrop
//
//  Created by C100-104 on 08/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import ImageSlideshow

class StoreDetailScreenHeaderCVCell: UICollectionViewCell {
	
	@IBOutlet var imageSlider: ImageSlideshow!
	@IBOutlet var imageStoreLogo: UIImageView!
	@IBOutlet var lblDistance: UILabel!
	@IBOutlet var lblstoretitle: UILabel!
	@IBOutlet var lblStoreAddress: UILabel!
	@IBOutlet var lblStoreTiming: UILabel!
	@IBOutlet var lblRating: UILabel!
	@IBOutlet var lblCollectionTitle: UILabel!
	@IBOutlet var viewRating: UIView!
	
	@IBOutlet var calendarImageHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet var StoreTimingBottomConstraint: NSLayoutConstraint!
	
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnFreshProduce: UIButton!
    @IBOutlet weak var viewSeparator: UIView!
    
    var arrimg: [InputSource] = []
	
	override func awakeFromNib() {
		   super.awakeFromNib()
		   // Initialization code
		viewRating.layer.borderColor = UIColor.darkGray.cgColor
	   }

}
