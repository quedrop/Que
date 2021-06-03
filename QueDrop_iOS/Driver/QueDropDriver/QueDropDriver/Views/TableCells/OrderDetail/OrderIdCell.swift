//
//  OrderIdCell.swift
//  QueDropDriver
//
//  Created by C100-174 on 24/09/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class OrderIdCell: UITableViewCell {
    
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var imgSeparator: UIImageView!
    @IBOutlet weak var imgExpress: UIImageView!
    @IBOutlet weak var constraintImgExpressWidth: NSLayoutConstraint! //26
    @IBOutlet weak var constraintLabelExpressWidth: NSLayoutConstraint! //60
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgExpress.image = setImageViewTintColor(img: imgExpress, color: .black)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
