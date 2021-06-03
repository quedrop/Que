//
//  ProfileNameratingCell.swift
//  QueDrop
//
//  Created by C100-174 on 13/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import FloatRatingView

class ProfileNameratingCell: UITableViewCell {
    @IBOutlet weak var viewRating: FloatRatingView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblBasicDetails: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblName.textColor = .darkGray
        lblName.font = UIFont(name: fFONT_BOLD, size:  20.0)
        lblBasicDetails.textColor = .black
        lblBasicDetails.font = UIFont(name: fFONT_SEMIBOLD, size:  20.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
