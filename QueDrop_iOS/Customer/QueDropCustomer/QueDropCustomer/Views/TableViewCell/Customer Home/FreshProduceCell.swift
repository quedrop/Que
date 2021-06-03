//
//  FreshProduceCell.swift
//  QueDropCustomer
//
//  Created by C100-174 on 01/10/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class FreshProduceCell: UICollectionViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var lblCategory: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        drawBorder(view: viewContainer, color: .clear, width: 0.0, radius: 5.0)
    }

}
