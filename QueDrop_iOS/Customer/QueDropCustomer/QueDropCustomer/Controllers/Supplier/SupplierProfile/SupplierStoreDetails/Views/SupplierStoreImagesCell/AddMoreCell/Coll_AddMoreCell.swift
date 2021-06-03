//
//  Coll_AddMoreCell.swift
//  Dentist
//
//  Created by C100-105 on 31/05/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import UIKit

class Coll_AddMoreCell: UICollectionViewCell {
    
    var callbackForAddMore: Callback?
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnAddMore: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func btnAddMoreClick(_ sender: Any) {
        callbackForAddMore?()
    }
    
    
}
