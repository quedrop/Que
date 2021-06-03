//
//  SupplierProfileTextBoxCell.swift
//  QueDrop
//
//  Created by C100-105 on 10/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierProfileTextBoxCell: BaseTableViewCell {

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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setupUI() {
        super.setupUI()
        
        txtLeftValue.autocapitalizationType = .none
        txtRightValue.autocapitalizationType = .sentences
        
        contentView.backgroundColor = .clear
        viewContainer.backgroundColor = .clear//.white
        viewLeftTextBox.backgroundColor = .clear//.white
        viewRightTextBox.backgroundColor = .clear//.white
        viewLeftTextBoxContainer.backgroundColor = .white
        viewRightTextBoxContainer.backgroundColor = .white
        
    }
    
    func bindDetails(title: String) {
        setupUI()
        
        lblLeftName.text = title
        txtLeftValue.placeholder = title
        viewRightTextBox.isHidden = true
    }
}
