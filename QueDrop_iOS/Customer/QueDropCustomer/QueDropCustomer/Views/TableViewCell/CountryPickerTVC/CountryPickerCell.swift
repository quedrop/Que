//
//  CountryPickerCell.swift
//  GoferDriver
//
//  Created by C100-174 on 03/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class CountryPickerCell: UITableViewCell {
    //IBOUTLETS
    @IBOutlet weak var lblCountryName: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var imgFlag: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //makeCircular(view: imgFlag)
        
        lblCountryName.textColor = .darkGray
        lblCountryName.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 16.0))
        
        lblCode.textColor = .gray
        lblCode.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 14.0))

    }

}
