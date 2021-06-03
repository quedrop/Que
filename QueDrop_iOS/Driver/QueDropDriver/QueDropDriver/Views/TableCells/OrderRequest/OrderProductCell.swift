//
//  OrderProductCell.swift
//  QueDrop
//
//  Created by C100-174 on 23/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class OrderProductCell: UITableViewCell {
    
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var imgSeparator: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
