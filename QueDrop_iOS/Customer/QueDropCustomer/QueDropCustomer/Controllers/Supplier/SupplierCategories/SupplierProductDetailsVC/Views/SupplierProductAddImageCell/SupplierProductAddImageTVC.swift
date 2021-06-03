//
//  SupplierProductAddImageTVC.swift
//  QueDrop
//
//  Created by C100-105 on 01/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierProductAddImageTVC: BaseTableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setupUI() {
        super.setupUI()
        
        viewContainer.showBorder(.clear, 10)
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
    }
    
    
}
