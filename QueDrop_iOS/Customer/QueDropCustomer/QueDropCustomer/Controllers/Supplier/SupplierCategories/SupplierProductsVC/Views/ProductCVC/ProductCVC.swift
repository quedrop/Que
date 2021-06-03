//
//  ProductCVC.swift
//  QueDrop
//
//  Created by C100-105 on 01/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class ProductCVC: UICollectionViewCell {

    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnOption: UIButton!
    @IBOutlet weak var constraintBtnWidth: NSLayoutConstraint!
    
    var callbackForBtnOptionClick: Callback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    @IBAction func btnOptionsClick(_ sender: Any) {
        callbackForBtnOptionClick?()
    }
    
    func bindDetails(ofProduct product: ProductInfo) {
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        viewContainer.showBorder(.clear, 10)
        
        lblName.text = product.productName
        lblPrice.text = Currency + " " + (product.productPrice.asInt()).description
        
        let url = product.productImage.asString()
        let imageUrl = URL_PRODUCT_IMAGES+url
        imgView.setWebImage(imageUrl, .noImagePlaceHolder, complete: { isDone, image in
            if isDone {
                self.imgView.image = image
            }
        })
    }
}
