//
//  Order.swift
//
//  Created by C100-104 on 13/03/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class Order:  NSObject, NSCoding,JSONable  {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kOrderDriverIdsKey: String = "driver_ids"
  private let kOrderOrderIdKey: String = "order_id"
  private let kOrderRecurringOrderIdKey: String = "recurring_order_id"
   private let kOrderServerTimeKey: String = "server_time"

  // MARK: Properties
  public var driverIds: String?
  public var orderId: Int?
  public var recurringOrderId: Int?
    public var serverTime: String?

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
    driverIds = json[kOrderDriverIdsKey].string
    orderId = json[kOrderOrderIdKey].int
    recurringOrderId = json[kOrderRecurringOrderIdKey].int
    serverTime = json[kOrderServerTimeKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = driverIds { dictionary[kOrderDriverIdsKey] = value }
    if let value = orderId { dictionary[kOrderOrderIdKey] = value }
    if let value = recurringOrderId { dictionary[kOrderRecurringOrderIdKey] = value }
    if let value = serverTime { dictionary[kOrderServerTimeKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.driverIds = aDecoder.decodeObject(forKey: kOrderDriverIdsKey) as? String
    self.orderId = aDecoder.decodeObject(forKey: kOrderOrderIdKey) as? Int
    self.recurringOrderId = aDecoder.decodeObject(forKey: kOrderRecurringOrderIdKey) as? Int
    self.serverTime = aDecoder.decodeObject(forKey: kOrderServerTimeKey) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(driverIds, forKey: kOrderDriverIdsKey)
    aCoder.encode(orderId, forKey: kOrderOrderIdKey)
    aCoder.encode(recurringOrderId, forKey: kOrderRecurringOrderIdKey)
    aCoder.encode(serverTime, forKey: kOrderServerTimeKey)
  }

}
