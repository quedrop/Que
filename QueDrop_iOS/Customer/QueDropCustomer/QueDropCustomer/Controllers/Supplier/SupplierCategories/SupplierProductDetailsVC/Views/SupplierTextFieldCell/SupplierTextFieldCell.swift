//
//  Tbl_ImgTextboxCell.swift
//  Tournament
//
//  Created by C100-105 on 26/12/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import UIKit

class SupplierTextFieldCell: BaseTableViewCell {

    @IBOutlet weak var constraintsImgHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var viewTextBox: UIView!
    @IBOutlet weak var txtValue: UITextField!
    @IBOutlet weak var imgRightIcon: UIImageView!
    
    var callbackForImageTap: Callback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setupUI() {
        super.setupUI()
        
        txtValue.autocapitalizationType = .sentences
        
        imgRightIcon.contentMode = .scaleAspectFit
        contentView.backgroundColor = .clear
        viewContainer.backgroundColor = .clear
        
        viewTextBox.showBorder(.lightGray, 10)
        
        imgRightIcon.image = nil
        imgRightIcon.isHidden = true
        constraintsImgHeight.constant = 0
    }
    
    func bindDetails(title: String) {
        setupUI()
        
        lblName.text = title
        txtValue.placeholder = title
        
    }
    
    func setImage(image: UIImage?) {
        let isHide = image == nil
        imgRightIcon.isHidden = isHide
        imgRightIcon.image = image
        constraintsImgHeight.constant = isHide ? 0 : 25
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapImageView))
        imgRightIcon.addGestureRecognizer(tap)
        imgRightIcon.isUserInteractionEnabled = !isHide
    }
 
    @objc func tapImageView() {
        callbackForImageTap?()
    }
}
