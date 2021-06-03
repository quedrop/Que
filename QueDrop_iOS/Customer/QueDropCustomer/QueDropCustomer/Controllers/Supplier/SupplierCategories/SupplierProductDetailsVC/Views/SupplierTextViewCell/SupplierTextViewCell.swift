//
//  Tbl_TextViewCell.swift
//  Dentist
//
//  Created by C100-105 on 12/04/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import UIKit

class SupplierTextViewCell: BaseTableViewCell {

    
    @IBOutlet weak var txtBox: NISLTextView!
    @IBOutlet weak var lblInfo: UILabel!
    
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func setupUI() {
        super.setupUI()
        
        txtBox.autocapitalizationType = .sentences
        
        self.txtBox.keyboardType = .default
        self.txtBox.showBorder(.lightGray, 10)
    }
    
    func bindDetails(title: String) {
        setupUI()
        
        self.lblInfo.text = title
        self.txtBox.placeholder = title
    }
}
