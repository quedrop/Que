//
//  ReceiverMessageCell.swift
//  QueDropDeliveryCustomer
//
//  Created by C100-132 on 10/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class ReceiverMessageCell: UITableViewCell {
    
    @IBOutlet var lblDateTime: UILabel!
       @IBOutlet var lblMessageText: UILabel!
       @IBOutlet var imgReceiverMsgBG: UIImageView!
       @IBOutlet var vwDateHeight: NSLayoutConstraint!
    @IBOutlet weak var viewMessageContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewMessageContainer.clipsToBounds = true
        viewMessageContainer.layer.cornerRadius = 15
        viewMessageContainer.layer.maskedCorners = [.layerMaxXMinYCorner,
                                                    .layerMinXMaxYCorner,
                                                    .layerMaxXMaxYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }    
}
