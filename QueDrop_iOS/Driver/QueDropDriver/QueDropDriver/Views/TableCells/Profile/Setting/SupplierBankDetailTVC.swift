//
//  SupplierBankDetailTVC.swift
//  QueDrop
//
//  Created by C100-105 on 14/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierBankDetailTVC: UITableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewImgIcon: UIView!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCardNo: UILabel!
    @IBOutlet weak var btnIsPrimary: UIButton!

    var callbackForIsPrimary: Callback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func btnPrimaryClick(_ sender: UIButton) {
        callbackForIsPrimary?()
    }
    
   func setupUI() {
      backgroundColor = .clear
      contentView.backgroundColor = .clear
      
      imageView?.image = nil
      textLabel?.text = nil
      
      selectionStyle = .none
        
        imgIcon.showBorder(VIEW_BACKGROUND_COLOR, 5)
        imgIcon.contentMode = .scaleAspectFit
        lblTitle.textColor = .black
        btnIsPrimary.isHidden = false
        lblCardNo.isHidden = false
    }
    
    func bindDetails(ofBank bank: BankDetails) {
        setupUI()
        
        lblTitle.text = bank.bankName
        lblCardNo.text = "**** **** **** " + bank.accountNumber.asString().suffix(4).description
        btnIsPrimary.setTitle("  Primary", for: .normal)
        
        let isPrimary = bank.isPrimary.asInt() == 1
        let image = isPrimary ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "checkbox_unchecked")
        btnIsPrimary.setImage(image, for: .normal)
        
        btnIsPrimary.isHidden = !isPrimary
        
        let url = URL_BANKS_LOGO + bank.bankLogo.asString()
        imgIcon.setWebImage(url, .noImagePlaceHolder)
    }
    
}
