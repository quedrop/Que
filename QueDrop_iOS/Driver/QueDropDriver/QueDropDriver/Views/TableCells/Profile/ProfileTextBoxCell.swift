//
//  ProfileTextBoxCell.swift
//  QueDrop
//
//  Created by C100-105 on 10/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class ProfileTextBoxCell: UITableViewCell {
    
    var isEdit : Bool = false
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var viewLeftTextBox: UIView!
    @IBOutlet weak var lblLeftName: UILabel!
    @IBOutlet weak var txtLeftValue: UITextField!
    
    @IBOutlet weak var viewRightTextBox: UIView!
    @IBOutlet weak var lblRightName: UILabel!
    @IBOutlet weak var txtRightValue: UITextField!
    
    @IBOutlet weak var viewLeftTextBoxContainer: UIView!
    @IBOutlet weak var viewRightTextBoxContainer: UIView!
    
     override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected stat
        
    }
    
    func setupUI() {
       txtLeftValue.autocapitalizationType = .none
        txtRightValue.autocapitalizationType = .sentences
        
        contentView.backgroundColor = .clear
        viewContainer.backgroundColor = .clear
        viewLeftTextBox.backgroundColor = .clear
        viewRightTextBox.backgroundColor = .clear
        viewLeftTextBoxContainer.backgroundColor = .white
        viewRightTextBoxContainer.backgroundColor = .white
        
        
        
        lblLeftName.textColor = .gray
        lblLeftName.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 13.0))
        
        lblRightName.textColor = .gray
        lblRightName.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 13.0))
        
        txtLeftValue.textColor = .black
        txtLeftValue.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 16.0))
        txtLeftValue.tintColor = .black
        
        txtRightValue.textColor = .black
        txtRightValue.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 16.0))
        txtRightValue.tintColor = .black
        
        let borderColor = UIColor.clear // #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
               viewLeftTextBoxContainer.showBorder(borderColor, 5)
        viewRightTextBoxContainer.showBorder(borderColor, 5)
    }
    
    func bindDetails(title: String) {
        setupUI()
        
        lblLeftName.text = title
        txtLeftValue.placeholder = title
        viewRightTextBox.isHidden = true
        
    
    }
}
