//
//  SupplierProductActiveStatusTVC.swift
//  QueDrop
//
//  Created by C100-105 on 04/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierProductActiveStatusTVC: BaseTableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var switchActive: UISwitch!
    @IBOutlet weak var lblName: UILabel!
    
    var callbackForSelection: Callback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func switchActiveClick(_ sender: Any) {
        callbackForSelection?()
    }
    
    override func setupUI() {
        super.setupUI()
        
        contentView.backgroundColor = .clear
        viewContainer.backgroundColor = .white
        viewContainer.showBorder(.clear, 10)
        
    }
    
    func bindDetails(title: String, isSelected: Bool) {
        setupUI()
        
        lblName.text = title
        switchActive.setOn(isSelected, animated: true)
    }
}
