//
//  TableViewCheckBoxCell.swift
//  QueDrop
//
//  Created by C100-105 on 03/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class TableViewCheckBoxCell: BaseTableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var imgCheckBox: UIImageView!
    @IBOutlet weak var btnCheckBox: UIButton!
    
    var callbackForSelection: Callback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func btnCheckBoxClick(_ sender: Any) {
        callbackForSelection?()
    }
    
    override func setupUI() {
        super.setupUI()
        
        contentView.backgroundColor = .clear
        viewContainer.backgroundColor = .white
        viewContainer.showBorder(.clear, 10)
        
        btnCheckBox.setTitleColor(.black, for: .normal)
    }
    
    func bindDetails(title: String, isSelected: Bool) {
        setupUI()
        
        btnCheckBox.setTitle(title, for: .normal)
        
        let image = isSelected ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "checkbox_unchecked")
        //btnCheckBox.setImage(image, for: .normal)
        imgCheckBox.image = image
    }
    
}
