//
//  CurrentOrderDetailsTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 27/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class CurrentOrderDetailsTVCell: UITableViewCell {

	
	@IBOutlet var outerView: UIView!
	@IBOutlet var innerView: UIView!
	@IBOutlet var lblOrderDateTime: UILabel!
	@IBOutlet var lblOrderAmount: UILabel!
	@IBOutlet var btnStatus: UIButton!
	@IBOutlet var lblOrderId: UILabel!
	@IBOutlet var btnAccept: UIButton!
    @IBOutlet var btnReject: UIButton!
    @IBOutlet var btnCalendar: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
		if btnStatus != nil
		{
            drawBorder(view: btnStatus, color: .gray, width: 0.5, radius: 5.0)
            btnStatus.setTitleColor(THEME_COLOR, for: .normal)
            btnStatus.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: 13.0)
		}
        lblOrderDateTime.textColor = .black
       lblOrderDateTime.font = UIFont(name: fFONT_MEDIUM, size: 14.0)
       lblOrderAmount.textColor = .black
       lblOrderAmount.font = UIFont(name: fFONT_MEDIUM, size: 14.0)
        
        if lblOrderId != nil {
            lblOrderId.font = UIFont(name: fFONT_MEDIUM, size: 14.0)
        }
        
        if btnAccept != nil && btnReject != nil
        {
            drawBorder(view: btnAccept, color: .clear, width: 0.0, radius: 5.0)
            drawBorder(view: btnReject, color: .clear, width: 0.0, radius: 5.0)
            btnAccept.setTitleColor(.white, for: .normal)
            btnAccept.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: 13.0)
            btnAccept.setTitle("ACCEPT", for: .normal)
            btnAccept.backgroundColor = GREEN_COLOR
                
            btnReject.setTitleColor(.white, for: .normal)
            btnReject.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: 13.0)
            btnReject.setTitle("REJECT", for: .normal)
            btnReject.backgroundColor = RED_COLOR
        }
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
