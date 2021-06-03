//
//  FutureOrders.swift
//
//  Created by C100-174 on 15/06/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class FutureOrders:  NSObject, NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let recurringOrderId = "recurring_order_id"
    static let deliveryLatitude = "delivery_latitude"
    static let driverNote = "driver_note"
    static let deliveryAddress = "delivery_address"
    static let repeatUntilDate = "repeat_until_date"
    static let recurringTime = "recurring_time"
    static let stores = "stores"
    static let deliveryCharge = "delivery_charge"
    static let shoppingFee = "shopping_fee"
    static let deliveryTime = "delivery_time"
    static let recurringTypeId = "recurring_type_id"
    static let label = "label"
    static let customerDetail = "customer_detail"
    static let orderTotalAmount = "order_total_amount"
    static let serviceCharge = "service_charge"
    static let recurredOn = "recurred_on"
    static let userId = "user_id"
    static let deliveryLongitude = "delivery_longitude"
    static let recurringType = "recurring_type"
    static let recurringOrderEntries = "recurring_order_entries"
  }

  // MARK: Properties
  public var recurringOrderId: Int?
  public var deliveryLatitude: String?
  public var driverNote: String?
  public var deliveryAddress: String?
  public var repeatUntilDate: String?
  public var recurringTime: String?
  public var stores: [Stores]?
  public var deliveryCharge: Int?
  public var shoppingFee: Int?
  public var deliveryTime: Int?
  public var recurringTypeId: Int?
  public var label: String?
  public var customerDetail: CustomerDetail?
  public var orderTotalAmount: Int?
  public var serviceCharge: Int?
  public var recurredOn: String?
  public var userId: Int?
  public var deliveryLongitude: String?
  public var recurringType: String?
    public var recurringOrderEntries: [RecurringOrderEntries]?

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
    recurringOrderId = json[SerializationKeys.recurringOrderId].int
    deliveryLatitude = json[SerializationKeys.deliveryLatitude].string
    driverNote = json[SerializationKeys.driverNote].string
    deliveryAddress = json[SerializationKeys.deliveryAddress].string
    repeatUntilDate = json[SerializationKeys.repeatUntilDate].string
    recurringTime = json[SerializationKeys.recurringTime].string
    if let items = json[SerializationKeys.stores].array { stores = items.map { Stores(json: $0) } }
    deliveryCharge = json[SerializationKeys.deliveryCharge].int
    shoppingFee = json[SerializationKeys.shoppingFee].int
    deliveryTime = json[SerializationKeys.deliveryTime].int
    recurringTypeId = json[SerializationKeys.recurringTypeId].int
    label = json[SerializationKeys.label].string
    customerDetail = CustomerDetail(json: json[SerializationKeys.customerDetail])
    orderTotalAmount = json[SerializationKeys.orderTotalAmount].int
    serviceCharge = json[SerializationKeys.serviceCharge].int
    recurredOn = json[SerializationKeys.recurredOn].string
    userId = json[SerializationKeys.userId].int
    deliveryLongitude = json[SerializationKeys.deliveryLongitude].string
    recurringType = json[SerializationKeys.recurringType].string
    if let items = json[SerializationKeys.recurringOrderEntries].array { recurringOrderEntries = items.map { RecurringOrderEntries(json: $0) } }
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = recurringOrderId { dictionary[SerializationKeys.recurringOrderId] = value }
    if let value = deliveryLatitude { dictionary[SerializationKeys.deliveryLatitude] = value }
    if let value = driverNote { dictionary[SerializationKeys.driverNote] = value }
    if let value = deliveryAddress { dictionary[SerializationKeys.deliveryAddress] = value }
    if let value = repeatUntilDate { dictionary[SerializationKeys.repeatUntilDate] = value }
    if let value = recurringTime { dictionary[SerializationKeys.recurringTime] = value }
    if let value = stores { dictionary[SerializationKeys.stores] = value.map { $0.dictionaryRepresentation() } }
    if let value = deliveryCharge { dictionary[SerializationKeys.deliveryCharge] = value }
    if let value = shoppingFee { dictionary[SerializationKeys.shoppingFee] = value }
    if let value = deliveryTime { dictionary[SerializationKeys.deliveryTime] = value }
    if let value = recurringTypeId { dictionary[SerializationKeys.recurringTypeId] = value }
    if let value = label { dictionary[SerializationKeys.label] = value }
    if let value = customerDetail { dictionary[SerializationKeys.customerDetail] = value.dictionaryRepresentation() }
    if let value = orderTotalAmount { dictionary[SerializationKeys.orderTotalAmount] = value }
    if let value = serviceCharge { dictionary[SerializationKeys.serviceCharge] = value }
    if let value = recurredOn { dictionary[SerializationKeys.recurredOn] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    if let value = deliveryLongitude { dictionary[SerializationKeys.deliveryLongitude] = value }
    if let value = recurringType { dictionary[SerializationKeys.recurringType] = value }
    if let value = recurringOrderEntries { dictionary[SerializationKeys.recurringOrderEntries] = value.map { $0.dictionaryRepresentation() } }
    
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.recurringOrderId = aDecoder.decodeObject(forKey: SerializationKeys.recurringOrderId) as? Int
    self.deliveryLatitude = aDecoder.decodeObject(forKey: SerializationKeys.deliveryLatitude) as? String
    self.driverNote = aDecoder.decodeObject(forKey: SerializationKeys.driverNote) as? String
    self.deliveryAddress = aDecoder.decodeObject(forKey: SerializationKeys.deliveryAddress) as? String
    self.repeatUntilDate = aDecoder.decodeObject(forKey: SerializationKeys.repeatUntilDate) as? String
    self.recurringTime = aDecoder.decodeObject(forKey: SerializationKeys.recurringTime) as? String
    self.stores = aDecoder.decodeObject(forKey: SerializationKeys.stores) as? [Stores]
    self.deliveryCharge = aDecoder.decodeObject(forKey: SerializationKeys.deliveryCharge) as? Int
    self.shoppingFee = aDecoder.decodeObject(forKey: SerializationKeys.shoppingFee) as? Int
    self.deliveryTime = aDecoder.decodeObject(forKey: SerializationKeys.deliveryTime) as? Int
    self.recurringTypeId = aDecoder.decodeObject(forKey: SerializationKeys.recurringTypeId) as? Int
    self.label = aDecoder.decodeObject(forKey: SerializationKeys.label) as? String
    self.customerDetail = aDecoder.decodeObject(forKey: SerializationKeys.customerDetail) as? CustomerDetail
    self.orderTotalAmount = aDecoder.decodeObject(forKey: SerializationKeys.orderTotalAmount) as? Int
    self.serviceCharge = aDecoder.decodeObject(forKey: SerializationKeys.serviceCharge) as? Int
    self.recurredOn = aDecoder.decodeObject(forKey: SerializationKeys.recurredOn) as? String
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? Int
    self.deliveryLongitude = aDecoder.decodeObject(forKey: SerializationKeys.deliveryLongitude) as? String
    self.recurringType = aDecoder.decodeObject(forKey: SerializationKeys.recurringType) as? String
    self.recurringOrderEntries = aDecoder.decodeObject(forKey: SerializationKeys.recurringOrderEntries) as? [RecurringOrderEntries]
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(recurringOrderId, forKey: SerializationKeys.recurringOrderId)
    aCoder.encode(deliveryLatitude, forKey: SerializationKeys.deliveryLatitude)
    aCoder.encode(driverNote, forKey: SerializationKeys.driverNote)
    aCoder.encode(deliveryAddress, forKey: SerializationKeys.deliveryAddress)
    aCoder.encode(repeatUntilDate, forKey: SerializationKeys.repeatUntilDate)
    aCoder.encode(recurringTime, forKey: SerializationKeys.recurringTime)
    aCoder.encode(stores, forKey: SerializationKeys.stores)
    aCoder.encode(deliveryCharge, forKey: SerializationKeys.deliveryCharge)
    aCoder.encode(shoppingFee, forKey: SerializationKeys.shoppingFee)
    aCoder.encode(deliveryTime, forKey: SerializationKeys.deliveryTime)
    aCoder.encode(recurringTypeId, forKey: SerializationKeys.recurringTypeId)
    aCoder.encode(label, forKey: SerializationKeys.label)
    aCoder.encode(customerDetail, forKey: SerializationKeys.customerDetail)
    aCoder.encode(orderTotalAmount, forKey: SerializationKeys.orderTotalAmount)
    aCoder.encode(serviceCharge, forKey: SerializationKeys.serviceCharge)
    aCoder.encode(recurredOn, forKey: SerializationKeys.recurredOn)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
    aCoder.encode(deliveryLongitude, forKey: SerializationKeys.deliveryLongitude)
    aCoder.encode(recurringType, forKey: SerializationKeys.recurringType)
    aCoder.encode(recurringOrderEntries, forKey: SerializationKeys.recurringOrderEntries)
  }

}
