//
//  CurrentOrder.swift
//
//  Created by C100-104 on 27/03/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class CurrentOrder: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kCurrentOrderOrderAmountKey: String = "order_amount"
  private let kCurrentOrderOrderStatusKey: String = "order_status"
  private let kCurrentOrderAdvanceOrderDatetimeKey: String = "advance_order_datetime"
  private let kCurrentOrderOrderIdKey: String = "order_id"
    private let kCurrentOrderTimerValueKey: String = "timer_value"
  private let kCurrentOrderIsAdvancedOrderKey: String = "is_advanced_order"
  private let kCurrentOrderOrderTotalAmountKey: String = "order_total_amount"
  private let kCurrentOrderStoresKey: String = "stores"
    private let kCurrentOrderUpdatedServerTimeKey : String = "updated_server_time"
	private let kCurrentOrderDriverDetailKey: String = "driver_detail"
  private let kCurrentOrderDeliveryChargeKey: String = "delivery_charge"
  private let kCurrentOrderServiceChargeKey: String = "service_charge"
  private let kCurrentOrderOrderDateKey: String = "order_date"
   private let kCurrentOrderDeliveryOptionKey: String = "delivery_option"

  // MARK: Properties
  public var orderAmount: Float?
  public var orderStatus: String?
  public var advanceOrderDatetime: String?
  public var orderId: Int?
    public var timerValue: Int?
  public var isAdvancedOrder: Int?
  public var orderTotalAmount: Float?
  public var stores: [CurrentOrderStores]?
    public var updatedServerTime : String?
	public var driver: DriverDetail?
  public var deliveryCharge: Int?
  public var serviceCharge: Int?
  public var orderDate: String?
    public var deliveryOption: String?

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
    orderAmount = json[kCurrentOrderOrderAmountKey].float
    orderStatus = json[kCurrentOrderOrderStatusKey].string
    advanceOrderDatetime = json[kCurrentOrderAdvanceOrderDatetimeKey].string
    orderId = json[kCurrentOrderOrderIdKey].int
    timerValue = json[kCurrentOrderTimerValueKey].int
    isAdvancedOrder = json[kCurrentOrderIsAdvancedOrderKey].int
    orderTotalAmount = json[kCurrentOrderOrderTotalAmountKey].float
    if let items = json[kCurrentOrderStoresKey].array { stores = items.map { CurrentOrderStores(json: $0) } }
    updatedServerTime = json[kCurrentOrderUpdatedServerTimeKey].string
	driver = DriverDetail(json: json[kCurrentOrderDriverDetailKey])
    deliveryCharge = json[kCurrentOrderDeliveryChargeKey].int
    serviceCharge = json[kCurrentOrderServiceChargeKey].int
    orderDate = json[kCurrentOrderOrderDateKey].string
    deliveryOption = json[kCurrentOrderDeliveryOptionKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = orderAmount { dictionary[kCurrentOrderOrderAmountKey] = value }
    if let value = orderStatus { dictionary[kCurrentOrderOrderStatusKey] = value }
    if let value = advanceOrderDatetime { dictionary[kCurrentOrderAdvanceOrderDatetimeKey] = value }
    if let value = orderId { dictionary[kCurrentOrderOrderIdKey] = value }
    if let value = timerValue { dictionary[kCurrentOrderTimerValueKey] = value }
    if let value = isAdvancedOrder { dictionary[kCurrentOrderIsAdvancedOrderKey] = value }
    if let value = orderTotalAmount { dictionary[kCurrentOrderOrderTotalAmountKey] = value }
    if let value = stores { dictionary[kCurrentOrderStoresKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = updatedServerTime { dictionary[kCurrentOrderUpdatedServerTimeKey] = value }
	if let value = driver { dictionary[kCurrentOrderDriverDetailKey] = value.dictionaryRepresentation() }
    if let value = deliveryCharge { dictionary[kCurrentOrderDeliveryChargeKey] = value }
    if let value = serviceCharge { dictionary[kCurrentOrderServiceChargeKey] = value }
    if let value = orderDate { dictionary[kCurrentOrderOrderDateKey] = value }
    if let value = deliveryOption { dictionary[kCurrentOrderDeliveryOptionKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.orderAmount = aDecoder.decodeObject(forKey: kCurrentOrderOrderAmountKey) as? Float
    self.orderStatus = aDecoder.decodeObject(forKey: kCurrentOrderOrderStatusKey) as? String
    self.advanceOrderDatetime = aDecoder.decodeObject(forKey: kCurrentOrderAdvanceOrderDatetimeKey) as? String
    self.orderId = aDecoder.decodeObject(forKey: kCurrentOrderOrderIdKey) as? Int
    self.timerValue = aDecoder.decodeObject(forKey: kCurrentOrderTimerValueKey) as? Int
    self.isAdvancedOrder = aDecoder.decodeObject(forKey: kCurrentOrderIsAdvancedOrderKey) as? Int
    self.orderTotalAmount = aDecoder.decodeObject(forKey: kCurrentOrderOrderTotalAmountKey) as? Float
    self.stores = aDecoder.decodeObject(forKey: kCurrentOrderStoresKey) as? [CurrentOrderStores]
    self.updatedServerTime = aDecoder.decodeObject(forKey: kCurrentOrderUpdatedServerTimeKey) as? String
	self.driver = aDecoder.decodeObject(forKey: kCurrentOrderDriverDetailKey) as? DriverDetail
    self.deliveryCharge = aDecoder.decodeObject(forKey: kCurrentOrderDeliveryChargeKey) as? Int
    self.serviceCharge = aDecoder.decodeObject(forKey: kCurrentOrderServiceChargeKey) as? Int
    self.orderDate = aDecoder.decodeObject(forKey: kCurrentOrderOrderDateKey) as? String
    self.deliveryOption = aDecoder.decodeObject(forKey: kCurrentOrderDeliveryOptionKey) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(orderAmount, forKey: kCurrentOrderOrderAmountKey)
    aCoder.encode(orderStatus, forKey: kCurrentOrderOrderStatusKey)
    aCoder.encode(advanceOrderDatetime, forKey: kCurrentOrderAdvanceOrderDatetimeKey)
    aCoder.encode(orderId, forKey: kCurrentOrderOrderIdKey)
    aCoder.encode(timerValue, forKey: kCurrentOrderTimerValueKey)
    aCoder.encode(isAdvancedOrder, forKey: kCurrentOrderIsAdvancedOrderKey)
    aCoder.encode(orderTotalAmount, forKey: kCurrentOrderOrderTotalAmountKey)
    aCoder.encode(stores, forKey: kCurrentOrderStoresKey)
	aCoder.encode(updatedServerTime, forKey: kCurrentOrderUpdatedServerTimeKey)
    aCoder.encode(driver, forKey: kCurrentOrderDriverDetailKey)
    aCoder.encode(deliveryCharge, forKey: kCurrentOrderDeliveryChargeKey)
    aCoder.encode(serviceCharge, forKey: kCurrentOrderServiceChargeKey)
    aCoder.encode(orderDate, forKey: kCurrentOrderOrderDateKey)
    aCoder.encode(deliveryOption, forKey: kCurrentOrderDeliveryOptionKey)
  }

}
