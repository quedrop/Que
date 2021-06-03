//
//  SupplierCategoryCell.swift
//  QueDrop
//
//  Created by C100-105 on 30/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierCategoryCell: BaseTableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
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
    
    func bindDetails(ofCategory category: FoodCategory) {
        viewContainer.showBorder(.clear, 10)
        imgView.showBorder(.clear, 5)
        
        lblName.text = category.storeCategoryTitle
        let url = URL_STORE_CATEGORY_IMAGES+category.storeCategoryImage.asString()
        imgView.setWebImage(url, .noImagePlaceHolder)
    }
}
