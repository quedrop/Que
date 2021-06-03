//
//  RecurringOrderEntries.swift
//
//  Created by C100-174 on 16/06/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class RecurringOrderEntries:  NSObject, NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let orderDeliveryDatetime = "order_delivery_datetime"
    static let orderPlaceDatetime = "order_place_datetime"
    static let recurringType = "recurring_type"
    static let recurringTime = "recurring_time"
    static let recurringEntryId = "recurring_entry_id"
    static let driverId = "driver_id"
    static let isAccepted = "is_accepted"
    static let rejectedDrivers = "rejected_drivers"
  }

  // MARK: Properties
  public var orderDeliveryDatetime: String?
  public var orderPlaceDatetime: String?
  public var recurringType: String?
  public var recurringTime: String?
  public var recurringEntryId: Int?
  public var driverId: Int?
  public var isAccepted: Int?
  public var rejectedDrivers: String?
    
  // MARK: SwiftyJSON Initializers
  /// Initiates the instance based on the object.
  ///
  /// - parameter object: The object of either Dictionary or Array kind that was passed.
  /// - returns: An initialized instance of the class.
  public convenience init(object: Any) {
    self.init(json: JSON(object))
  }

  /// Initiates the instance based on the JSON that was passed.
  ///
  /// - parameter json: JSON object from SwiftyJSON.
  public required init(json: JSON) {
    orderDeliveryDatetime = json[SerializationKeys.orderDeliveryDatetime].string
    orderPlaceDatetime = json[SerializationKeys.orderPlaceDatetime].string
    recurringType = json[SerializationKeys.recurringType].string
    recurringTime = json[SerializationKeys.recurringTime].string
    recurringEntryId = json[SerializationKeys.recurringEntryId].int
    driverId = json[SerializationKeys.driverId].int
    isAccepted = json[SerializationKeys.isAccepted].int
    rejectedDrivers = json[SerializationKeys.rejectedDrivers].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = orderDeliveryDatetime { dictionary[SerializationKeys.orderDeliveryDatetime] = value }
    if let value = orderPlaceDatetime { dictionary[SerializationKeys.orderPlaceDatetime] = value }
    if let value = recurringType { dictionary[SerializationKeys.recurringType] = value }
    if let value = recurringTime { dictionary[SerializationKeys.recurringTime] = value }
    if let value = recurringEntryId { dictionary[SerializationKeys.recurringEntryId] = value }
    if let value = driverId { dictionary[SerializationKeys.driverId] = value }
    if let value = isAccepted { dictionary[SerializationKeys.isAccepted] = value }
    if let value = rejectedDrivers { dictionary[SerializationKeys.rejectedDrivers] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.orderDeliveryDatetime = aDecoder.decodeObject(forKey: SerializationKeys.orderDeliveryDatetime) as? String
    self.orderPlaceDatetime = aDecoder.decodeObject(forKey: SerializationKeys.orderPlaceDatetime) as? String
    self.recurringType = aDecoder.decodeObject(forKey: SerializationKeys.recurringType) as? String
    self.recurringTime = aDecoder.decodeObject(forKey: SerializationKeys.recurringTime) as? String
    self.recurringEntryId = aDecoder.decodeObject(forKey: SerializationKeys.recurringEntryId) as? Int
    self.driverId = aDecoder.decodeObject(forKey: SerializationKeys.driverId) as? Int
    self.isAccepted = aDecoder.decodeObject(forKey: SerializationKeys.isAccepted) as? Int
    self.rejectedDrivers = aDecoder.decodeObject(forKey: SerializationKeys.rejectedDrivers) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(orderDeliveryDatetime, forKey: SerializationKeys.orderDeliveryDatetime)
    aCoder.encode(orderPlaceDatetime, forKey: SerializationKeys.orderPlaceDatetime)
    aCoder.encode(recurringType, forKey: SerializationKeys.recurringType)
    aCoder.encode(recurringTime, forKey: SerializationKeys.recurringTime)
    aCoder.encode(recurringEntryId, forKey: SerializationKeys.recurringEntryId)
    aCoder.encode(driverId, forKey: SerializationKeys.driverId)
    aCoder.encode(isAccepted, forKey: SerializationKeys.isAccepted)
    aCoder.encode(rejectedDrivers, forKey: SerializationKeys.rejectedDrivers)
  }

}
