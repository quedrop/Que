//
//  SupllierOfferTVC.swift
//  QueDrop
//
//  Created by C100-105 on 05/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupllierOfferTVC: BaseTableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgOffer: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblOffer: UILabel!
    
    @IBOutlet weak var btnOption: UIButton!
    
    var callbackForBtnOptionClick: Callback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func btnOptionsClick(_ sender: Any) {
        callbackForBtnOptionClick?()
    }
    
    override func setupUI() {
        super.setupUI()
        
        viewContainer.showBorder(.clear, 10)
        imgView.showBorder(.clear, 5)
        imgView.contentMode = .scaleAspectFill
        
        lblOffer.text = nil
    }
    
    func bindDetails(ofOffer offer: SupplierOffer) {
        setupUI()
        
        let url = URL_PRODUCT_IMAGES + offer.productImage.asString()
        imgView.setWebImage(url, .noImagePlaceHolder)
        
        var text = ""
        if offer.offerCode.asString().count == 0 {
            text = offer.offerPercentage.asInt().description + " off"
        } else {
           text = offer.offerPercentage.asInt().description + " off | Use Coupon " + offer.offerCode.asString()
        }
        
        let attrText = NSMutableAttributedString(string: text)
        attrText.setColorTo(text: text, withColor: #colorLiteral(red: 0.8039215686, green: 0.3058823529, blue: 0.2, alpha: 1))
        attrText.font(text, UIFont.systemFont(ofSize: 12, weight: .semibold).getAppFont())
        
        lblOffer.attributedText = attrText
        lblName.text = offer.productName
        lblCategory.text = offer.storeCategoryTitle
        
    }
}
