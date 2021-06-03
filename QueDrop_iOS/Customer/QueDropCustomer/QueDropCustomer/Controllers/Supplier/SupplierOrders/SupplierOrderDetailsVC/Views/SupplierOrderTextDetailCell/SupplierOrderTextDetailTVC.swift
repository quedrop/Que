//
//  SupplierOrderTextDetailTVC.swift
//  QueDrop
//
//  Created by C100-105 on 03/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierOrderTextDetailTVC: BaseTableViewCell {

    @IBOutlet weak var constraintLeftBorderTrailling: NSLayoutConstraint!
    @IBOutlet weak var constraintRightBorderTrailling: NSLayoutConstraint!
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewLeft: UIView!
    @IBOutlet weak var viewRight: UIView!
    
    @IBOutlet weak var lblLeftTitle: UILabel!
    @IBOutlet weak var lblRightTitle: UILabel!
    
    @IBOutlet weak var lblLeftValue: UILabel!
    @IBOutlet weak var lblRightValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func setupUI() {
        super.setupUI()
        
        lblLeftTitle.text = ""
        lblLeftValue.text = ""
        
        lblRightTitle.text = ""
        lblRightValue.text = ""
        
        viewRight.isHidden = true
        
        let titleFont = UIFont.systemFont(ofSize: 17, weight: .regular).getAppFont()
        let valueFont = UIFont.systemFont(ofSize: 17, weight: .semibold).getAppFont()
        
        lblLeftTitle.font = titleFont
        lblRightValue.font = titleFont
        
        lblLeftValue.font = valueFont
        lblRightValue.font = valueFont
        
        lblLeftTitle.textColor = .lightGray
        lblRightTitle.textColor = .lightGray
        
        lblLeftValue.textColor = .black
        lblRightValue.textColor = .black
    }
    
}
