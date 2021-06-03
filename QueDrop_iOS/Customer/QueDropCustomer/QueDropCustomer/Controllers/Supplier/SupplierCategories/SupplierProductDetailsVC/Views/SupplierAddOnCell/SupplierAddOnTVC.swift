//
//  SupplierAddOnTVC.swift
//  QueDrop
//
//  Created by C100-105 on 02/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierAddOnTVC: BaseTableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var btnDelete: UIButton!
    
    var callbackForDelete: Callback?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func btnDeleteClick(_ sender: Any) {
        callbackForDelete?()
    }
    
    override func setupUI() {
        super.setupUI()
        
        btnDelete.setImage(#imageLiteral(resourceName: "supplier_delete"), for: .normal)
        
        txtName.autocapitalizationType = .sentences
        txtPrice.keyboardType = .decimalPad
        
        contentView.backgroundColor = .clear
        viewContainer.backgroundColor = .clear
        
        txtName.backgroundColor = .white
        txtPrice.backgroundColor = .white
        
        txtName.placeholder = "Title"
        txtPrice.placeholder = "Price"
        
        txtName.showBorder(.lightGray, 10)
        txtPrice.showBorder(.lightGray, 10)
    }
    
    func bindDetails(ofAddOn addOn: Struct_AddAddOnDetails, isEdit: Bool) {
        setupUI()
        
        txtName.text = addOn.name
        txtPrice.text = (isEdit ? "" : (Currency + " ")) + addOn.price.description
        
    }
    
}
