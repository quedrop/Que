//
//  OrderDetails.swift
//
//  Created by C100-104 on 07/04/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class OrderDetails:  NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kOrderDetailsOrderAmountKey: String = "order_amount"
  private let kOrderDetailsAdvanceOrderDatetimeKey: String = "advance_order_datetime"
  private let kOrderDetailsOrderIdKey: String = "order_id"
  private let kOrderDetailsTimerValueKey: String = "timer_value"
  private let kOrderDetailsDeliveryLatitudeKey: String = "delivery_latitude"
  private let kOrderDetailsDriverNoteKey: String = "driver_note"
  private let kOrderDetailsDeliveryAddressKey: String = "delivery_address"
  private let kOrderDetailsStoresKey: String = "stores"
  private let kOrderDetailsDeliveryChargeKey: String = "delivery_charge"
  private let kOrderDetailsOrderTypeKey: String = "order_type"
  private let kOrderDetailsOrderDateKey: String = "order_date"
  private let kOrderDetailsOrderStatusKey: String = "order_status"
  private let kOrderDetailsCustomerDetailKey: String = "customer_detail"
  private let kOrderDetailsOrderTotalAmountKey: String = "order_total_amount"
  private let kOrderDetailsIsAdvancedOrderKey: String = "is_advanced_order"
  private let kOrderDetailsServiceChargeKey: String = "service_charge"
  private let kOrderDetailsUserIdKey: String = "user_id"
  private let kCurrentOrderUpdatedServerTimeKey : String = "updated_server_time"
  private let kOrderDetailsDriverDetailKey: String = "driver_detail"
  private let kOrderDetailsDeliveryLongitudeKey: String = "delivery_longitude"
  private let kOrderDetailsBillingDetailKey: String = "billing_detail"
  private let kOrderDetailsDeliveryOptionKey: String = "delivery_option"

  // MARK: Properties
  public var orderAmount: Int?
  public var advanceOrderDatetime: String?
  public var orderId: Int?
  public var timerValue: Int?
  public var deliveryLatitude: String?
  public var driverNote: String?
  public var deliveryAddress: String?
  public var stores: [CurrentOrderStores]?
  public var deliveryCharge: Int?
  public var orderType: String?
  public var orderDate: String?
  public var orderStatus: String?
  public var customerDetail: CustomerDetail?
  public var orderTotalAmount: Float?
  public var isAdvancedOrder: Int?
  public var serviceCharge: Int?
  public var userId: Int?
  public var updatedServerTime : String?
  public var driverDetail: DriverDetail?
  public var deliveryLongitude: String?
  public var billingDetail: BillingDetail?
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
    orderAmount = json[kOrderDetailsOrderAmountKey].int
    advanceOrderDatetime = json[kOrderDetailsAdvanceOrderDatetimeKey].string
    orderId = json[kOrderDetailsOrderIdKey].int
    timerValue = json[kOrderDetailsTimerValueKey].int
    deliveryLatitude = json[kOrderDetailsDeliveryLatitudeKey].string
    driverNote = json[kOrderDetailsDriverNoteKey].string
    deliveryAddress = json[kOrderDetailsDeliveryAddressKey].string
    if let items = json[kOrderDetailsStoresKey].array { stores = items.map { CurrentOrderStores(json: $0) } }
    deliveryCharge = json[kOrderDetailsDeliveryChargeKey].int
    orderType = json[kOrderDetailsOrderTypeKey].string
    orderDate = json[kOrderDetailsOrderDateKey].string
    orderStatus = json[kOrderDetailsOrderStatusKey].string
    customerDetail = CustomerDetail(json: json[kOrderDetailsCustomerDetailKey])
    orderTotalAmount = json[kOrderDetailsOrderTotalAmountKey].float
    isAdvancedOrder = json[kOrderDetailsIsAdvancedOrderKey].int
    serviceCharge = json[kOrderDetailsServiceChargeKey].int
    userId = json[kOrderDetailsUserIdKey].int
    updatedServerTime = json[kCurrentOrderUpdatedServerTimeKey].string
    driverDetail = DriverDetail(json: json[kOrderDetailsDriverDetailKey])
    deliveryLongitude = json[kOrderDetailsDeliveryLongitudeKey].string
    billingDetail = BillingDetail(json: json[kOrderDetailsBillingDetailKey])
    deliveryOption = json[kOrderDetailsDeliveryOptionKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = orderAmount { dictionary[kOrderDetailsOrderAmountKey] = value }
    if let value = advanceOrderDatetime { dictionary[kOrderDetailsAdvanceOrderDatetimeKey] = value }
    if let value = orderId { dictionary[kOrderDetailsOrderIdKey] = value }
    if let value = timerValue { dictionary[kOrderDetailsTimerValueKey] = value }
    if let value = deliveryLatitude { dictionary[kOrderDetailsDeliveryLatitudeKey] = value }
    if let value = driverNote { dictionary[kOrderDetailsDriverNoteKey] = value }
    if let value = deliveryAddress { dictionary[kOrderDetailsDeliveryAddressKey] = value }
    if let value = stores { dictionary[kOrderDetailsStoresKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = deliveryCharge { dictionary[kOrderDetailsDeliveryChargeKey] = value }
    if let value = orderType { dictionary[kOrderDetailsOrderTypeKey] = value }
    if let value = orderDate { dictionary[kOrderDetailsOrderDateKey] = value }
    if let value = orderStatus { dictionary[kOrderDetailsOrderStatusKey] = value }
    if let value = customerDetail { dictionary[kOrderDetailsCustomerDetailKey] = value.dictionaryRepresentation() }
    if let value = orderTotalAmount { dictionary[kOrderDetailsOrderTotalAmountKey] = value }
    if let value = isAdvancedOrder { dictionary[kOrderDetailsIsAdvancedOrderKey] = value }
    if let value = serviceCharge { dictionary[kOrderDetailsServiceChargeKey] = value }
    if let value = userId { dictionary[kOrderDetailsUserIdKey] = value }
    if let value = updatedServerTime { dictionary[kCurrentOrderUpdatedServerTimeKey] = value }
    if let value = driverDetail { dictionary[kOrderDetailsDriverDetailKey] = value.dictionaryRepresentation() }
    if let value = deliveryLongitude { dictionary[kOrderDetailsDeliveryLongitudeKey] = value }
    if let value = billingDetail { dictionary[kOrderDetailsBillingDetailKey] = value.dictionaryRepresentation() }
    if let value = deliveryOption { dictionary[kOrderDetailsDeliveryOptionKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.orderAmount = aDecoder.decodeObject(forKey: kOrderDetailsOrderAmountKey) as? Int
    self.advanceOrderDatetime = aDecoder.decodeObject(forKey: kOrderDetailsAdvanceOrderDatetimeKey) as? String
    self.orderId = aDecoder.decodeObject(forKey: kOrderDetailsOrderIdKey) as? Int
    self.timerValue = aDecoder.decodeObject(forKey: kOrderDetailsTimerValueKey) as? Int
    self.deliveryLatitude = aDecoder.decodeObject(forKey: kOrderDetailsDeliveryLatitudeKey) as? String
    self.driverNote = aDecoder.decodeObject(forKey: kOrderDetailsDriverNoteKey) as? String
    self.deliveryAddress = aDecoder.decodeObject(forKey: kOrderDetailsDeliveryAddressKey) as? String
    self.stores = aDecoder.decodeObject(forKey: kOrderDetailsStoresKey) as? [CurrentOrderStores]
    self.deliveryCharge = aDecoder.decodeObject(forKey: kOrderDetailsDeliveryChargeKey) as? Int
    self.orderType = aDecoder.decodeObject(forKey: kOrderDetailsOrderTypeKey) as? String
    self.orderDate = aDecoder.decodeObject(forKey: kOrderDetailsOrderDateKey) as? String
    self.orderStatus = aDecoder.decodeObject(forKey: kOrderDetailsOrderStatusKey) as? String
    self.customerDetail = aDecoder.decodeObject(forKey: kOrderDetailsCustomerDetailKey) as? CustomerDetail
    self.orderTotalAmount = aDecoder.decodeObject(forKey: kOrderDetailsOrderTotalAmountKey) as? Float
    self.isAdvancedOrder = aDecoder.decodeObject(forKey: kOrderDetailsIsAdvancedOrderKey) as? Int
    self.serviceCharge = aDecoder.decodeObject(forKey: kOrderDetailsServiceChargeKey) as? Int
    self.userId = aDecoder.decodeObject(forKey: kOrderDetailsUserIdKey) as? Int
    self.updatedServerTime = aDecoder.decodeObject(forKey: kCurrentOrderUpdatedServerTimeKey) as? String
    self.driverDetail = aDecoder.decodeObject(forKey: kOrderDetailsDriverDetailKey) as? DriverDetail
    self.deliveryLongitude = aDecoder.decodeObject(forKey: kOrderDetailsDeliveryLongitudeKey) as? String
    self.billingDetail = aDecoder.decodeObject(forKey: kOrderDetailsBillingDetailKey) as? BillingDetail
    self.deliveryOption = aDecoder.decodeObject(forKey: kOrderDetailsDeliveryOptionKey) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(orderAmount, forKey: kOrderDetailsOrderAmountKey)
    aCoder.encode(advanceOrderDatetime, forKey: kOrderDetailsAdvanceOrderDatetimeKey)
    aCoder.encode(orderId, forKey: kOrderDetailsOrderIdKey)
    aCoder.encode(timerValue, forKey: kOrderDetailsTimerValueKey)
    aCoder.encode(deliveryLatitude, forKey: kOrderDetailsDeliveryLatitudeKey)
    aCoder.encode(driverNote, forKey: kOrderDetailsDriverNoteKey)
    aCoder.encode(deliveryAddress, forKey: kOrderDetailsDeliveryAddressKey)
    aCoder.encode(stores, forKey: kOrderDetailsStoresKey)
    aCoder.encode(deliveryCharge, forKey: kOrderDetailsDeliveryChargeKey)
    aCoder.encode(orderType, forKey: kOrderDetailsOrderTypeKey)
    aCoder.encode(orderDate, forKey: kOrderDetailsOrderDateKey)
    aCoder.encode(orderStatus, forKey: kOrderDetailsOrderStatusKey)
    aCoder.encode(customerDetail, forKey: kOrderDetailsCustomerDetailKey)
    aCoder.encode(orderTotalAmount, forKey: kOrderDetailsOrderTotalAmountKey)
    aCoder.encode(isAdvancedOrder, forKey: kOrderDetailsIsAdvancedOrderKey)
    aCoder.encode(serviceCharge, forKey: kOrderDetailsServiceChargeKey)
    aCoder.encode(userId, forKey: kOrderDetailsUserIdKey)
    aCoder.encode(updatedServerTime, forKey: kCurrentOrderUpdatedServerTimeKey)
    aCoder.encode(driverDetail, forKey: kOrderDetailsDriverDetailKey)
    aCoder.encode(deliveryLongitude, forKey: kOrderDetailsDeliveryLongitudeKey)
    aCoder.encode(billingDetail, forKey: kOrderDetailsBillingDetailKey)
    aCoder.encode(deliveryOption, forKey: kOrderDetailsDeliveryOptionKey)
  }

}
