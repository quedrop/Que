//
//  SupplierOrderCompleteTVC.swift
//  QueDrop
//
//  Created by C100-105 on 08/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierOrderCompleteTVC: BaseTableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    
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
        
        viewContainer.showBorder(.clear, 10)
        viewContainer.backgroundColor = .cyan
    }
}
