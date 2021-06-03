//
//  StoreSlidingCell.swift
//  QueDrop
//
//  Created by C100-174 on 31/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class StoreSlidingCell: UICollectionViewCell {
    
    
    @IBOutlet weak var lblKms: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblStoreName: UILabel!
    @IBOutlet weak var btnRating: UIButton!
    @IBOutlet weak var imgStore: UIImageView!
    @IBOutlet weak var viewContainer: CardView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        drawBorder(view: imgStore, color: .lightGray, width: 1.0, radius: 5.0)
        
        lblStoreName.textColor = .black
        lblStoreName.font = UIFont(name: fFONT_SEMIBOLD, size: 18.0)
        
        lblLocation.textColor = .gray
        lblLocation.font = UIFont(name: fFONT_REGULAR, size: 13.0)
                
        lblKms.textColor = .black
        lblKms.font = UIFont(name: fFONT_REGULAR, size: 14.0)
        
    }

}
