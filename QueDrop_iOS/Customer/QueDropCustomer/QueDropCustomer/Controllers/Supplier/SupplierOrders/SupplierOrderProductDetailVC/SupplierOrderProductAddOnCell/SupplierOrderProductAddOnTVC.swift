//
//  SupplierOrderProductAddOnTVC.swift
//  QueDrop
//
//  Created by C100-105 on 04/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierOrderProductAddOnTVC: BaseTableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblAddOn: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLine: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func setupUI() {
        super.setupUI()
        
        lblAddOn.isHidden = true
        lblLine.isHidden = true
    }
    
    func bindDetail(ofAddOn addOn: Addons) {
        setupUI()
        
        let text = addOn.addonName.asString()
        let attrText = NSMutableAttributedString(string: text)
        attrText.bold(text, 17)
        
        lblName.text = nil
        lblName.attributedText = attrText
        imgView.image = #imageLiteral(resourceName: "veg_icon_2")
    }
    
}
