//
//  ViewDriverCell.swift
//  QueDropCustomer
//
//  Created by C100-174 on 22/09/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class ViewDriverCell: UITableViewCell {
    
    @IBOutlet var imgDeliveryMan: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        DispatchQueue.main.async {
            addDashedBorder(withColor: THEME_COLOR, view: self.viewContainer)
        }
        
        //viewContainer.AddDashedborderTov()
        // Configure the view for the selected state
    }

}
