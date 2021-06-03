//
//  ChangePasswordCell.swift
//  ProfileRatingApp
//
//  Created by C100-105 on 22/03/20.
//  Copyright © 2020 Narola. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
class SupplierChangePasswordCell: BaseTableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewTxtContainer: UIView!
    
    @IBOutlet weak var txt: JVFloatLabeledTextField!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var btnEye: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func btnSeePasswordClick(_ sender: Any) {
        txt.isSecureTextEntry = !txt.isSecureTextEntry
        setImage()
    }
    
    override func setupUI() {
        txt.addBottomLine()
        txt.setRightPadding(60.0)
        setupFloatingTextField(textField: txt)
        txt.font = UIFont.systemFont(ofSize: 17).getAppFont()
        txt.isSecureTextEntry = true
        txt.autocapitalizationType = .none
        
        viewTxtContainer.backgroundColor = .tableViewBg
      //  viewTxtContainer.showBorder(.lightGray, 5)
        setImage()
    }
    
    func setImage() {
        let image = txt.isSecureTextEntry ? #imageLiteral(resourceName: "eye_disabled") : #imageLiteral(resourceName: "eye_enabled")
        btnEye.setImage(image, for: .normal)
    }
    
}
