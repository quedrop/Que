//
//  SettingCell.swift
//  QueDrop
//
//  Created by C100-174 on 14/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.backgroundColor = .clear
        imgView.contentMode = .scaleAspectFit
        lblTitle.textColor = .black
        lblTitle.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 16.0))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func bindDetails(data: Struct_SettingData) {
        imgView.image = data.image
        lblTitle.text = data.title
    }
    
}
