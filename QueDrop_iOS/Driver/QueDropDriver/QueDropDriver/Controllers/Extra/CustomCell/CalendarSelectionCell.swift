//
//  CalendarSelectionCell.swift
//  QueDropDriver
//
//  Created by C100-174 on 22/05/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class CalendarSelectionCell: UITableViewCell {
    
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var btnDate: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        drawBorder(view: viewDate, color: .lightGray, width: 1.0, radius: 8.0)
        btnDate.setTitleColor(.darkGray, for: .normal)
        btnDate.setTitle("22 May 2020", for: .normal)
        btnDate.titleLabel?.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 15.0))
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
