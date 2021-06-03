//
//  SupplierStoreLogoCell.swift
//  QueDropCustomer
//
//  Created by C100-174 on 04/11/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class SupplierStoreLogoCell: BaseTableViewCell {
        
    
    @IBOutlet weak var lblStoreLogo: UILabel!
    @IBOutlet weak var lblStoreName: UILabel!
    @IBOutlet weak var lblServiceCategory: UILabel!
    @IBOutlet weak var viewTextBox1: UIView!
    @IBOutlet weak var viewTextBox2: UIView!
    @IBOutlet weak var txtValueName: UITextField!
    @IBOutlet weak var txtValueCategory: UITextField!
    @IBOutlet weak var imgStoreLogo: UIImageView!
    @IBOutlet weak var imgDownArrow: UIImageView!
    @IBOutlet weak var btnPickStoreLogo: UIButton!
       
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setupUI() {
       super.setupUI()
       makeCircular(view: imgStoreLogo)
        drawBorder(view: imgStoreLogo, color: .lightGray, width: 1.0, radius: Float(CGFloat(imgStoreLogo.frame.height)/2.0))
       txtValueName.autocapitalizationType = .sentences
       txtValueCategory.autocapitalizationType = .sentences
       
       viewTextBox1.showBorder(.lightGray, 10)
       viewTextBox2.showBorder(.lightGray, 10)
    

        
       lblStoreName.text = "Store Name"
       lblStoreLogo.text = "Store Logo"
       lblServiceCategory.text = "Service Category"
       txtValueName.placeholder = lblStoreName.text
       txtValueCategory.placeholder = lblServiceCategory.text
   }
   
   func bindDetails(objStore: Struct_StoreDetails) {
       setupUI()
       
    txtValueName.text = objStore.name
    txtValueCategory.text = objStore.serviceCategory
    
    if let img = objStore.logoImage {
        imgStoreLogo.image = img
    } else {
        imgStoreLogo.setWebImage(objStore.logo, QUE_AVTAR)
    }
    
               
    
   }
  
    
}
