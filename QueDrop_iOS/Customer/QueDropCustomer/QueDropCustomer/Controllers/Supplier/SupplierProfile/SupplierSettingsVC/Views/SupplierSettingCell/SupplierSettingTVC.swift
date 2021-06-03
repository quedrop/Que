//
//  SupplierSettingTVC.swift
//  QueDrop
//
//  Created by C100-105 on 09/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierSettingTVC: BaseTableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func setupUI() {
        super.setupUI()
        
        viewContainer.backgroundColor = .clear
        imgView.contentMode = .scaleAspectFit
        lblTitle.textColor = .black
        lblTitle.font = UIFont.systemFont(ofSize: 17, weight: .medium).getAppFont()
    }
    
    func bindDetails(data: Struct_SettingData) {
        imgView.image = data.image
        lblTitle.text = data.title
    }
    
}
