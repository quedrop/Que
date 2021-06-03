//
//  OrderDetail.swift
//
//  Created by C100-174 on 24/03/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class OrderDetail: NSObject, NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let orderAmount = "order_amount"
    static let advanceOrderDatetime = "advance_order_datetime"
    static let orderId = "order_id"
    static let deliveryLatitude = "delivery_latitude"
    static let driverNote = "driver_note"
    static let deliveryAddress = "delivery_address"
    static let stores = "stores"
    static let deliveryCharge = "delivery_charge"
    static let orderType = "order_type"
    static let orderDate = "order_date"
    static let orderStatus = "order_status"
    static let customerDetail = "customer_detail"
    static let orderTotalAmount = "order_total_amount"
    static let isAdvanceOrder = "is_advance_order"
    static let serviceCharge = "service_charge"
    static let userId = "user_id"
    static let deliveryLongitude = "delivery_longitude"
    static let rating = "rating"
    static let billingDetail = "billing_detail"
    static let requestDate = "request_date"
    static let isPaymentDone = "is_payment_done"
    static let deliveryOption = "delivery_option"
  }

  // MARK: Properties
  public var orderAmount: Float?
  public var advanceOrderDatetime: String?
  public var orderId: Int?
  public var deliveryLatitude: String?
  public var driverNote: String?
  public var deliveryAddress: String?
  public var stores: [Stores]?
  public var deliveryCharge: Int?
  public var orderType: String?
  public var orderDate: String?
  public var orderStatus: String?
  public var customerDetail: CustomerDetail?
  public var orderTotalAmount: Float?
  public var isAdvanceOrder: Int?
  public var serviceCharge: Int?
  public var userId: Int?
  public var deliveryLongitude: String?
  public var rating: Float?
  public var billingDetail: BillingDetail?
  public var requestDate: String?
  public var isPaymentDone: Int?
  public var deliveryOption: String?
    
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
    orderAmount = json[SerializationKeys.orderAmount].float
    advanceOrderDatetime = json[SerializationKeys.advanceOrderDatetime].string
    orderId = json[SerializationKeys.orderId].int
    deliveryLatitude = json[SerializationKeys.deliveryLatitude].string
    driverNote = json[SerializationKeys.driverNote].string
    deliveryAddress = json[SerializationKeys.deliveryAddress].string
    if let items = json[SerializationKeys.stores].array { stores = items.map { Stores(json: $0) } }
    deliveryCharge = json[SerializationKeys.deliveryCharge].int
    orderType = json[SerializationKeys.orderType].string
    orderDate = json[SerializationKeys.orderDate].string
    orderStatus = json[SerializationKeys.orderStatus].string
    customerDetail = CustomerDetail(json: json[SerializationKeys.customerDetail])
    orderTotalAmount = json[SerializationKeys.orderTotalAmount].float
    isAdvanceOrder = json[SerializationKeys.isAdvanceOrder].int
    serviceCharge = json[SerializationKeys.serviceCharge].int
    userId = json[SerializationKeys.userId].int
    deliveryLongitude = json[SerializationKeys.deliveryLongitude].string
    rating = json[SerializationKeys.rating].float
    billingDetail = BillingDetail(json: json[SerializationKeys.billingDetail])
    requestDate = json[SerializationKeys.requestDate].string
    isPaymentDone = json[SerializationKeys.isPaymentDone].int
    deliveryOption = json[SerializationKeys.deliveryOption].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = orderAmount { dictionary[SerializationKeys.orderAmount] = value }
    if let value = advanceOrderDatetime { dictionary[SerializationKeys.advanceOrderDatetime] = value }
    if let value = orderId { dictionary[SerializationKeys.orderId] = value }
    if let value = deliveryLatitude { dictionary[SerializationKeys.deliveryLatitude] = value }
    if let value = driverNote { dictionary[SerializationKeys.driverNote] = value }
    if let value = deliveryAddress { dictionary[SerializationKeys.deliveryAddress] = value }
    if let value = stores { dictionary[SerializationKeys.stores] = value.map { $0.dictionaryRepresentation() } }
    if let value = deliveryCharge { dictionary[SerializationKeys.deliveryCharge] = value }
    if let value = orderType { dictionary[SerializationKeys.orderType] = value }
    if let value = orderDate { dictionary[SerializationKeys.orderDate] = value }
    if let value = orderStatus { dictionary[SerializationKeys.orderStatus] = value }
    if let value = customerDetail { dictionary[SerializationKeys.customerDetail] = value.dictionaryRepresentation() }
    if let value = orderTotalAmount { dictionary[SerializationKeys.orderTotalAmount] = value }
    if let value = isAdvanceOrder { dictionary[SerializationKeys.isAdvanceOrder] = value }
    if let value = serviceCharge { dictionary[SerializationKeys.serviceCharge] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    if let value = deliveryLongitude { dictionary[SerializationKeys.deliveryLongitude] = value }
    if let value = rating { dictionary[SerializationKeys.rating] = value }
    if let value = billingDetail { dictionary[SerializationKeys.billingDetail] = value.dictionaryRepresentation() }
    if let value = requestDate { dictionary[SerializationKeys.requestDate] = value }
    if let value = isPaymentDone { dictionary[SerializationKeys.isPaymentDone] = value }
    if let value = deliveryOption { dictionary[SerializationKeys.deliveryOption] = value }
    
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.orderAmount = aDecoder.decodeObject(forKey: SerializationKeys.orderAmount) as? Float
    self.advanceOrderDatetime = aDecoder.decodeObject(forKey: SerializationKeys.advanceOrderDatetime) as? String
    self.orderId = aDecoder.decodeObject(forKey: SerializationKeys.orderId) as? Int
    self.deliveryLatitude = aDecoder.decodeObject(forKey: SerializationKeys.deliveryLatitude) as? String
    self.driverNote = aDecoder.decodeObject(forKey: SerializationKeys.driverNote) as? String
    self.deliveryAddress = aDecoder.decodeObject(forKey: SerializationKeys.deliveryAddress) as? String
    self.stores = aDecoder.decodeObject(forKey: SerializationKeys.stores) as? [Stores]
    self.deliveryCharge = aDecoder.decodeObject(forKey: SerializationKeys.deliveryCharge) as? Int
    self.orderType = aDecoder.decodeObject(forKey: SerializationKeys.orderType) as? String
    self.orderDate = aDecoder.decodeObject(forKey: SerializationKeys.orderDate) as? String
    self.orderStatus = aDecoder.decodeObject(forKey: SerializationKeys.orderStatus) as? String
    self.customerDetail = aDecoder.decodeObject(forKey: SerializationKeys.customerDetail) as? CustomerDetail
    self.orderTotalAmount = aDecoder.decodeObject(forKey: SerializationKeys.orderTotalAmount) as? Float
    self.isAdvanceOrder = aDecoder.decodeObject(forKey: SerializationKeys.isAdvanceOrder) as? Int
    self.serviceCharge = aDecoder.decodeObject(forKey: SerializationKeys.serviceCharge) as? Int
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? Int
    self.deliveryLongitude = aDecoder.decodeObject(forKey: SerializationKeys.deliveryLongitude) as? String
    self.rating = aDecoder.decodeObject(forKey: SerializationKeys.rating) as? Float
    self.billingDetail = aDecoder.decodeObject(forKey: SerializationKeys.billingDetail) as? BillingDetail
    self.requestDate = aDecoder.decodeObject(forKey: SerializationKeys.requestDate) as? String
    self.isPaymentDone = aDecoder.decodeObject(forKey: SerializationKeys.isPaymentDone) as? Int
    self.deliveryOption = aDecoder.decodeObject(forKey: SerializationKeys.deliveryOption) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(orderAmount, forKey: SerializationKeys.orderAmount)
    aCoder.encode(advanceOrderDatetime, forKey: SerializationKeys.advanceOrderDatetime)
    aCoder.encode(orderId, forKey: SerializationKeys.orderId)
    aCoder.encode(deliveryLatitude, forKey: SerializationKeys.deliveryLatitude)
    aCoder.encode(driverNote, forKey: SerializationKeys.driverNote)
    aCoder.encode(deliveryAddress, forKey: SerializationKeys.deliveryAddress)
    aCoder.encode(stores, forKey: SerializationKeys.stores)
    aCoder.encode(deliveryCharge, forKey: SerializationKeys.deliveryCharge)
    aCoder.encode(orderType, forKey: SerializationKeys.orderType)
    aCoder.encode(orderDate, forKey: SerializationKeys.orderDate)
    aCoder.encode(orderStatus, forKey: SerializationKeys.orderStatus)
    aCoder.encode(customerDetail, forKey: SerializationKeys.customerDetail)
    aCoder.encode(orderTotalAmount, forKey: SerializationKeys.orderTotalAmount)
    aCoder.encode(isAdvanceOrder, forKey: SerializationKeys.isAdvanceOrder)
    aCoder.encode(serviceCharge, forKey: SerializationKeys.serviceCharge)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
    aCoder.encode(deliveryLongitude, forKey: SerializationKeys.deliveryLongitude)
    aCoder.encode(rating, forKey: SerializationKeys.rating)
    aCoder.encode(billingDetail, forKey: SerializationKeys.billingDetail)
    aCoder.encode(requestDate, forKey: SerializationKeys.requestDate)
    aCoder.encode(isPaymentDone, forKey: SerializationKeys.isPaymentDone)
    aCoder.encode(requestDate, forKey: SerializationKeys.deliveryOption)
  }

}
