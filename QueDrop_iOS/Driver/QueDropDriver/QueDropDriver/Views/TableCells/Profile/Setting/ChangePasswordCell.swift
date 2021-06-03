//
//  ChangePasswordCell.swift
//  QueDrop
//
//  Created by C100-174 on 14/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class ChangePasswordCell: UITableViewCell {
    @IBOutlet weak var viewContainer: UIView!
       @IBOutlet weak var viewTxtContainer: UIView!
       
       @IBOutlet weak var txt: JVFloatLabeledTextField!
       @IBOutlet weak var lbl: UILabel!
       @IBOutlet weak var btnEye: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        txt.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 16.0))
               txt.isSecureTextEntry = true
               txt.autocapitalizationType = .none
        txt.tintColor = .black
        txt.backgroundColor = .clear
               //viewTxtContainer.backgroundColor = VIEW_BACKGROUND_COLOR
              // viewTxtContainer.showBorder(.lightGray, 5)
               setImage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        txt.setRightPadding(60.0)
        setupFloatingTextField(textField: txt)
        DispatchQueue.main.async {
            self.txt.addBottomLine()
        }
    }
    
    func setImage() {
        let image = txt.isSecureTextEntry ? #imageLiteral(resourceName: "eye_disabled") : #imageLiteral(resourceName: "eye_enabled")
        btnEye.setImage(image, for: .normal)
    }
    
    @IBAction func btnSeePasswordClick(_ sender: Any) {
           txt.isSecureTextEntry = !txt.isSecureTextEntry
           setImage()
       }
}
