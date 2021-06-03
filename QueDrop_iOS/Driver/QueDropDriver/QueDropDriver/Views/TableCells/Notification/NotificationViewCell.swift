//
//  NotificationViewCell.swift
//  ProfileRatingApp
//
//  Created by C100-105 on 22/03/20.
//  Copyright © 2020 Narola. All rights reserved.
//

import UIKit

class NotificationViewCell: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var imgNotificationType: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        //viewContainer.showShadow(color: .gray)
    }
    
    func setupUI() {
        
        //viewContainer.showBorder(.clear, 10)
        lblDescription.numberOfLines = 0
        lblTime.adjustsFontSizeToFitWidth = true
        
        lblTime.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 11.0))
        lblDescription.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 15.0))
    }
    
    func bindDetails(ofNotification notification: SupplierNotifications) {
        setupUI()
        
        lblDescription.text = notification.notification
       // let time = notification.notificationDatetime?.toDate()?.toString(format: "hh:mm a")
       // lblTime.text = time
        
        let dateStr = (notification.notificationDatetime)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var ratingDate = dateFormatter.date(from:dateStr)!
        ratingDate = ratingDate.UTCtoLocal().toDate()!
        let timeAgo = ratingDate.timeAgo()
        lblTime.text = timeAgo
        
        setImage(type: notification.notificationEnumType)
    }
    
    func setImage(type: Enum_NotificationType) {
       var typeImage: UIImage? = #imageLiteral(resourceName: "curr_location_orange")
        
        switch type {
            case .Order_Request,
            .Order_Accept,
            .Order_Reject,
            .Order_Request_Timeout,
            .Recurring_Order_Placed,
            .order_dispatch,
            .Order_receipt,
            .order_cancelled:
            typeImage = #imageLiteral(resourceName: "notification_order")
            break
            
        case .order_delivered:
            typeImage = #imageLiteral(resourceName: "notification_favourite")
            break
            
        case .Driver_verification:
            break
            
        case .Rating:
            typeImage = #imageLiteral(resourceName: "notification_like")
            break
            
        case .Near_By_Place:
            typeImage = #imageLiteral(resourceName: "curr_location_orange")
            break
        
        case .manualStorePayment,
            .driverWeeklyPayment,
            .supplierWeeklyPayment:
            typeImage = #imageLiteral(resourceName: "home_earning")
            break
        case .unKnownType,
             .chat:
            typeImage = nil
            break
            
        }
        imgNotificationType.image = typeImage
    }
    
}
