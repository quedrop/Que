//
//  PaymentOfferCVCell.swift
//  QueDrop
//
//  Created by C100-104 on 30/01/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class PaymentOfferCVCell: UICollectionViewCell {
    @IBOutlet weak var imgOfferBG: UIImageView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var btnCouponCode3: UIButton!
    @IBOutlet weak var lblTitle1: UILabel!
    @IBOutlet weak var lblPromocode: UILabel!
    @IBOutlet weak var lblTitle2: UILabel!
    @IBOutlet weak var viewPercentage: UIView!
    @IBOutlet weak var lblPercentageOff: UILabel!
    @IBOutlet weak var constraintViewPercentageWidth: NSLayoutConstraint! //68
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
