//
//  EarningPagerCell.swift
//  QueDropDriver
//
//  Created by C100-174 on 22/05/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class EarningPagerCell: UICollectionViewCell {
    //IBOUTLETS
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var lblTitle1: UILabel!
    @IBOutlet weak var lblTitle2: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var viewPrice: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewPrice.backgroundColor = .white
                
        lblTitle1.textColor = .darkGray
        lblTitle1.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 17.0))
        
        lblTitle2.textColor = .darkGray
        lblTitle2.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 18.0))
                
        lblPrice.textColor = .white
        lblPrice.font = UIFont(name: fFONT_BOLD, size: calculateFontForWidth(size: 23.0))
        lblPrice.backgroundColor = THEME_COLOR
        
        btnView.setTitle("VIEW ALL ORDER", for: .normal)
        btnView.backgroundColor = THEME_COLOR
        btnView.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 15.0))
        
        
    }
}
