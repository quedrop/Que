//
//  OrderUserCell.swift
//  QueDrop
//
//  Created by C100-174 on 23/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import FloatRatingView
class OrderUserCell: UITableViewHeaderFooterView {
    
    //IBOUTLET
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var viewTimer: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblMinutes: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var lblTimer: MZTimerLabel!
    @IBOutlet weak var imgDash: UIImageView!
    @IBOutlet weak var btnChat: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblName.textColor = .black
        lblName.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 15.0))
        
        lblTimer.textColor = SKYBLUE_COLOR
        lblTimer.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 10.0))
        lblTimer.text = "01:00"
        makeCircular(view: imgUser)
        addDashedCircle(withColor: .darkGray, view: viewTimer)
        
        lblLocation.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 11.0))
        lblLocation.textColor =  UIColor.darkGray
        
        btnChat.backgroundColor = THEME_COLOR
        btnChat.setTitle("Chat", for: .normal)
        btnChat.setTitleColor(.white, for: .normal)
        btnChat.titleLabel?.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 12.0))
        drawBorder(view: btnChat, color: .clear, width: 0.0, radius: 5.0)
        
        ratingView.isUserInteractionEnabled = false
        
        if lblOrderId != nil {
            lblOrderId.text = ""
        }
    }


}
