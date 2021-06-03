//
//  CurrentOrderHeaderTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 27/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import FloatRatingView
class CurrentOrderHeaderTVCell: UITableViewCell {

    @IBOutlet var viewCustomer: UIView!
	@IBOutlet var imgStoreLogo: UIImageView!
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var lblCustomerName: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var viewRating: FloatRatingView!
    
	@IBOutlet var lblStoreName: UILabel!
	@IBOutlet var lblStoreAddress: UILabel!
	@IBOutlet var outerView: UIView!
	@IBOutlet var innerView: UIView!
	@IBOutlet var btnRating: UIButton!
	@IBOutlet var imgExpress: UIImageView!
    @IBOutlet var constraintExpressWidth: NSLayoutConstraint!
    
    var isdrawBorder : Bool = true
	
	override func awakeFromNib() {
        super.awakeFromNib()
        lblStoreName.textColor = .black
        lblStoreName.font = UIFont(name: fFONT_SEMIBOLD, size: 17.0)
        lblStoreAddress.textColor = .gray
        lblStoreAddress.font = UIFont(name: fFONT_REGULAR, size: 13.0)
        
        if btnRating != nil
        {
            if isdrawBorder {
                drawBorder(view: btnRating, color: UIColor.gray.withAlphaComponent(0.8), width: 0.5, radius: 5.0)
            }
            btnRating.setTitleColor(.darkGray, for: .normal)
            btnRating.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: 12.0)
        }
        
        if viewCustomer != nil {
            makeCircular(view: imgUser)
            viewRating.isUserInteractionEnabled = false
            lblCustomerName.font = UIFont(name: fFONT_SEMIBOLD, size: 17.0)
            lblAddress.font = UIFont(name: fFONT_REGULAR, size: 13.0)
        }
        
        if imgExpress != nil {
           // drawBorder(view: imgExpress, color: THEME_COLOR, width: 1.0, radius: 5.0)
            imgExpress.image = setImageViewTintColor(img: imgExpress, color: .black)
        }
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	func setBorderLayout(forLayout : String)
	{
		if forLayout == "top"
		{
			self.outerView.clipsToBounds = true
			self.outerView.layer.cornerRadius = 8
			self.outerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
			self.innerView.clipsToBounds = true
			self.innerView.layer.cornerRadius = 8
			self.innerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		}
	}
}
