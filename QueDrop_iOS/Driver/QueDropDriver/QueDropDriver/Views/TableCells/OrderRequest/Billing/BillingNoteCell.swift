//
//  BillingNoteCell.swift
//  QueDrop
//
//  Created by C100-174 on 08/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class BillingNoteCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblTitle.textColor = .black
        lblTitle.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 16.0))
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
