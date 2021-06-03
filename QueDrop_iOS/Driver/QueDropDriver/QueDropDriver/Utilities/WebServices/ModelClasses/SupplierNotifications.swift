//
//  Notifications.swift
//
//  Created by C100-105 on 07/04/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class SupplierNotifications: NSObject, NSCoding, JSONable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kNotificationsNotificationKey: String = "notification"
    private let kNotificationsNotificationDatetimeKey: String = "notification_datetime"
    private let kNotificationsNotificationIdKey: String = "notification_id"
    private let kNotificationsNotificationTypeKey: String = "notification_type"
    private let kNotificationsDataIdKey: String = "data_id"
    
    // MARK: Properties
    public var notification: String?
    public var notificationDatetime: String?
    public var notificationId: Int?
    public var notificationType: Int?
    public var dataId: Int?
    
    // MARK: SwiftyJSON Initalizers
    /**
     Initates the instance based on the object
     - parameter object: The object of either Dictionary or Array kind that was passed.
     - returns: An initalized instance of the class.
     */
    convenience public init(object: Any) {
        self.init(json: JSON(object))
    }
    
    /**
     Initates the instance based on the JSON that was passed.
     - parameter json: JSON object from SwiftyJSON.
     - returns: An initalized instance of the class.
     */
    required public init(json: JSON) {
        notification = json[kNotificationsNotificationKey].string
        notificationDatetime = json[kNotificationsNotificationDatetimeKey].string
        notificationId = json[kNotificationsNotificationIdKey].int
        notificationType = json[kNotificationsNotificationTypeKey].int
        dataId = json[kNotificationsDataIdKey].int
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = notification { dictionary[kNotificationsNotificationKey] = value }
        if let value = notificationDatetime { dictionary[kNotificationsNotificationDatetimeKey] = value }
        if let value = notificationId { dictionary[kNotificationsNotificationIdKey] = value }
        if let value = notificationType { dictionary[kNotificationsNotificationTypeKey] = value }
        if let value = dataId { dictionary[kNotificationsDataIdKey] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.notification = aDecoder.decodeObject(forKey: kNotificationsNotificationKey) as? String
        self.notificationDatetime = aDecoder.decodeObject(forKey: kNotificationsNotificationDatetimeKey) as? String
        self.notificationId = aDecoder.decodeObject(forKey: kNotificationsNotificationIdKey) as? Int
        self.notificationType = aDecoder.decodeObject(forKey: kNotificationsNotificationTypeKey) as? Int
        self.dataId = aDecoder.decodeObject(forKey: kNotificationsDataIdKey) as? Int
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(notification, forKey: kNotificationsNotificationKey)
        aCoder.encode(notificationDatetime, forKey: kNotificationsNotificationDatetimeKey)
        aCoder.encode(notificationId, forKey: kNotificationsNotificationIdKey)
        aCoder.encode(notificationType, forKey: kNotificationsNotificationTypeKey)
        aCoder.encode(dataId, forKey: kNotificationsDataIdKey)
    }
    
}
