//
//  IdentityPhotoCell.swift
//  QueDrop
//
//  Created by C100-174 on 04/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class IdentityPhotoCell: UITableViewCell {
    
    
    @IBOutlet weak var lblField: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       lblField.textColor = .gray
       lblField.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 13.0))
        btnAction.imageView?.contentMode = .scaleAspectFill
    }
    
}
