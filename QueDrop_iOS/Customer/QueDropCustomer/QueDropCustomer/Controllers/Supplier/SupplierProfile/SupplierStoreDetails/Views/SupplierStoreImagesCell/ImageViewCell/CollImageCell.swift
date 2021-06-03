//
//  CollImageCell.swift
//  Dentist
//
//  Created by C100-105 on 31/05/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import UIKit

class CollImageCell: UICollectionViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var imgProblem: UIImageView!
    
    var callbackForDelete: Callback?
    
    override func awakeFromNib() {
        
    }
    
    @IBAction func btnDeleteClick(_ sender: Any) {
        callbackForDelete?()
    }
    
}
