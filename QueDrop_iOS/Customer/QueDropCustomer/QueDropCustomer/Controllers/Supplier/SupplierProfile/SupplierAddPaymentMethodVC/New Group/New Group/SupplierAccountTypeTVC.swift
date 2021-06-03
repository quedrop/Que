//
//  SupplierAccountTypeTVC.swift
//  QueDrop
//
//  Created by C100-105 on 14/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierAccountTypeTVC: BaseTableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSaving: UIButton!
    @IBOutlet weak var btnCurrent: UIButton!
    
    var callbackForAccountTypeChange: ((Enum_BankAccountType)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func btnAccountTypeClick(_ sender: UIButton) {
        callbackForAccountTypeChange?(sender.tag == 1 ? .Saving : .Current)
    }
    
    override func setupUI() {
        super.setupUI()
        
        btnSaving.tag = 1
        btnCurrent.tag = 2
        
    }
    
    func bindDetail(isSaving: Bool) {
        let selectedImage = #imageLiteral(resourceName: "supplier_circle_checked")
        let nonSelectedImage = #imageLiteral(resourceName: "supplier_circle_nonchecked")
        
        btnSaving.setImage(nonSelectedImage, for: .normal)
        btnCurrent.setImage(nonSelectedImage, for: .normal)
        
        if isSaving {
            btnSaving.setImage(selectedImage, for: .normal)
        } else {
            btnCurrent.setImage(selectedImage, for: .normal)
        }
        
        
    }
    
}
