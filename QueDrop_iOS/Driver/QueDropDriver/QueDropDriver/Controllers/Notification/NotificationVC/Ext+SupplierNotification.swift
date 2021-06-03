//
//  Ext+SupplierNotification.swift
//  QueDropDeliveryCustomer
//
//  Created by C100-105 on 07/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import Foundation

extension SupplierNotifications {
    
    var notificationEnumType: Enum_NotificationType {
        
        if let notificationType = notificationType,
            let type = Enum_NotificationType(rawValue: notificationType) {
            return type
        }
        
        return .unKnownType
    }
}
