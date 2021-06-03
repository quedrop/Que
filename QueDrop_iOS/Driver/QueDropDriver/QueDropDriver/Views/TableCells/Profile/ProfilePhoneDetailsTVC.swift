//
//  ProfilePhoneDetailsTVC.swift
//  QueDrop
//
//  Created by C100-105 on 08/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class ProfilePhoneDetailsTVC: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewTxtContainer: UIView!
    
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var btnCountry: UIButton!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var imgDropArrow: UIImageView!
    @IBOutlet weak var lblTitlePhoneNumber: UILabel!
    @IBOutlet weak var btnChangePhone: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        viewTxtContainer.addShadow(location: .bottom)
    }
    
    func setupUI() {
                
        lblCountryCode.textColor = .black
        lblCountryCode.font = UIFont(name: fFONT_MEDIUM, size:  calculateFontForWidth(size: 16.0))
        lblCountryCode.adjustsFontSizeToFitWidth = true
        
        txtPhoneNumber.textColor = .black
        txtPhoneNumber.font = UIFont(name: fFONT_MEDIUM, size:  calculateFontForWidth(size: 16.0))
        txtPhoneNumber.placeholder = "Phone number"
        
        lblTitlePhoneNumber.textColor = .gray
        lblTitlePhoneNumber.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 13.0))
        let borderColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        viewTxtContainer.showBorder(.clear, 5)
        
        //viewTxtContainer.showShadow(color: .tableViewBg)
        
        imgDropArrow.image = setImageViewTintColor(img: imgDropArrow, color: .black)
        
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
