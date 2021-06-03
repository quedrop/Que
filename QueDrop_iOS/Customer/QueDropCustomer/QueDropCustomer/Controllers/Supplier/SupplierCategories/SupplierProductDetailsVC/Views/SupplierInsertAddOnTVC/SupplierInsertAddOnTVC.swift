//
//  SupplierInsertAddOnTVC.swift
//  QueDrop
//
//  Created by C100-105 on 02/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierInsertAddOnTVC: BaseTableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    
    var callbackFornsertAddon: Callback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnAddClick(_ sender: Any) {
        callbackFornsertAddon?()
    }
    
    override func setupUI() {
        super.setupUI()
        
        let text = "Add"
        let attrText = NSMutableAttributedString(string: text)
        attrText.setColorTo(text: text, withColor: .blue)
        attrText.normal(text, 16)
        attrText.underLine(text)
        
        btnAdd.setTitle(nil, for: .normal)
        btnAdd.setAttributedTitle(attrText, for: .normal)
        
    }
    
    func bindDetails(title: String) {
        setupUI()
        
        lblTitle.text = title
    }
    
}
