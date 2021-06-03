//
//  RecurranceCell.swift
//  QueDrop
//
//  Created by C100-174 on 16/06/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class RecurranceCell: UITableViewCell {

    @IBOutlet weak var viewEntry: UIView!
    @IBOutlet weak var stackButton: UIStackView!
    @IBOutlet weak var btnRejected: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var lblEntry: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        drawBorder(view: btnRejected, color: RED_COLOR, width: 0.5, radius: 5.0)
        drawBorder(view: btnAccept, color: .clear, width: 0.0, radius: 5.0)
        drawBorder(view: btnReject, color: .clear, width: 0.0, radius: 5.0)
        
        drawBorder(view: viewEntry, color: .lightGray, width: 1.0, radius: 5.0)
        
        btnAccept.backgroundColor = GREEN_COLOR
        btnReject.backgroundColor = RED_COLOR
        btnRejected.backgroundColor = .clear
        
        btnAccept.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: 13.0)
        btnReject.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: 13.0)
        btnRejected.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: 13.0)
        
        btnAccept.setTitleColor(.white, for: .normal)
        btnReject.setTitleColor(.white, for: .normal)
        btnRejected.setTitleColor(RED_COLOR, for: .normal)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
