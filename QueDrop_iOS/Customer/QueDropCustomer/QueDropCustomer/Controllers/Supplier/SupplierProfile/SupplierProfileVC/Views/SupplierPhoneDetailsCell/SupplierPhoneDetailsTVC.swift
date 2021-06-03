//
//  SupplierPhoneDetailsTVC.swift
//  QueDrop
//
//  Created by C100-105 on 08/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierPhoneDetailsTVC: BaseTableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewTxtContainer: UIView!
    
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var btnCountry: UIButton!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var btnAddOrChange: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func setupUI() {
        super.setupUI()
        
        lblCountryCode.textColor = .black
        lblCountryCode.font = UIFont.systemFont(ofSize: 17, weight: .regular).getAppFont()
        lblCountryCode.adjustsFontSizeToFitWidth = true
        
        txtPhoneNumber.textColor = .black
        txtPhoneNumber.font = UIFont.systemFont(ofSize: 19, weight: .medium).getAppFont()
        txtPhoneNumber.placeholder = "Phone number"
        
        let borderColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        viewTxtContainer.showBorder(borderColor, 5)
        
        viewContainer.backgroundColor = .clear
        viewTxtContainer.backgroundColor = .white
        imgFlag.circlularView()
    }
    
    func bindDetails(country: [String: Any], phoneNumber: String) {
        setupUI()
        
        txtPhoneNumber.text = phoneNumber
        lblCountryCode.text = country["dial_code"] as? String
        imgFlag.image = UIImage(named: country["code"] as! String)
    }
    
    
    
}
