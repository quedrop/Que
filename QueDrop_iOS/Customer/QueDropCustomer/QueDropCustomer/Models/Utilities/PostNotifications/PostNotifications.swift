//
//  PostNotifications.swift
//  QueDrop
//
//  Created by C100-104 on 31/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import Foundation

//MARK:- NOTIFICATION CENTER
let nc = NotificationCenter.default

//MARK:- SEND NOTIFICATION CENTER NOTIFICATION
func postNotification(withName notificationName: String, userInfo : [AnyHashable : Any]) {
  nc.post(name: Notification.Name(rawValue: notificationName), object: nil, userInfo: userInfo)
}

//MARK:- NOTIFICATION KEYS
enum notificationCenterKeys : String {
	case orderStatus = "order_Status"
	case orderAccepted = "order_accepted"
	case orderCancelled = "order_cancelled"
    case driverLocationChanged = "driver_location_changed"
    case updateCartBadge = "update_cart_badge"
    case timerValueUpdated = "timer_value_updated"
}
