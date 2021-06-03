//
//  BillingDetail.swift
//
//  Created by C100-174 on 07/04/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class BillingDetail: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let isManualStoreAvailable = "is_manual_store_available"
    static let manualStores = "manual_stores"
    static let isOrderDiscount = "is_order_discount"
    static let registeredStores = "registered_stores"
    static let totalPay = "total_pay"
    static let isCouponDiscount = "is_coupon_discount"
    static let serviceCharge = "service_charge"
    static let deliveryCharge = "delivery_charge"
    static let orderDiscount = "order_discount"
    static let shoppingFee = "shopping_fee"
    static let couponDiscount = "coupon_discount"
    static let tip = "tip"
    static let shoppingFeeDriver = "shopping_fee_driver"
    static let driverTotalEarn = "driver_total_earn"
  }

  // MARK: Properties
  public var isManualStoreAvailable: Int?
  public var manualStores: [ManualStores]?
  public var isOrderDiscount: Int?
  public var registeredStores: [RegisteredStores]?
  public var totalPay: Float?
  public var isCouponDiscount: Int?
  public var serviceCharge: Float?
  public var deliveryCharge: Float?
  public var orderDiscount: Float?
  public var shoppingFee: Float?
  public var couponDiscount: Float?
  public var tip: Float?
  public var shoppingFeeDriver: Float?
  public var driverTotalEarn: Float?

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
    isManualStoreAvailable = json[SerializationKeys.isManualStoreAvailable].int
    if let items = json[SerializationKeys.manualStores].array { manualStores = items.map { ManualStores(json: $0) } }
    isOrderDiscount = json[SerializationKeys.isOrderDiscount].int
    if let items = json[SerializationKeys.registeredStores].array { registeredStores = items.map { RegisteredStores(json: $0) } }
    totalPay = json[SerializationKeys.totalPay].float
    isCouponDiscount = json[SerializationKeys.isCouponDiscount].int
    serviceCharge = json[SerializationKeys.serviceCharge].float
    deliveryCharge = json[SerializationKeys.deliveryCharge].float
    orderDiscount = json[SerializationKeys.orderDiscount].float
    shoppingFee = json[SerializationKeys.shoppingFee].float
    couponDiscount = json[SerializationKeys.couponDiscount].float
    tip = json[SerializationKeys.tip].float
    shoppingFeeDriver = json[SerializationKeys.shoppingFeeDriver].float
    driverTotalEarn = json[SerializationKeys.driverTotalEarn].float
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = isManualStoreAvailable { dictionary[SerializationKeys.isManualStoreAvailable] = value }
    if let value = manualStores { dictionary[SerializationKeys.manualStores] = value.map { $0.dictionaryRepresentation() } }
    if let value = isOrderDiscount { dictionary[SerializationKeys.isOrderDiscount] = value }
    if let value = registeredStores { dictionary[SerializationKeys.registeredStores] = value.map { $0.dictionaryRepresentation() } }
    if let value = totalPay { dictionary[SerializationKeys.totalPay] = value }
    if let value = isCouponDiscount { dictionary[SerializationKeys.isCouponDiscount] = value }
    if let value = serviceCharge { dictionary[SerializationKeys.serviceCharge] = value }
    if let value = deliveryCharge { dictionary[SerializationKeys.deliveryCharge] = value }
    if let value = orderDiscount { dictionary[SerializationKeys.orderDiscount] = value }
    if let value = shoppingFee { dictionary[SerializationKeys.shoppingFee] = value }
    if let value = couponDiscount { dictionary[SerializationKeys.couponDiscount] = value }
    if let value = tip { dictionary[SerializationKeys.tip] = value }
    if let value = shoppingFeeDriver { dictionary[SerializationKeys.shoppingFeeDriver] = value }
    if let value = driverTotalEarn { dictionary[SerializationKeys.driverTotalEarn] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.isManualStoreAvailable = aDecoder.decodeObject(forKey: SerializationKeys.isManualStoreAvailable) as? Int
    self.manualStores = aDecoder.decodeObject(forKey: SerializationKeys.manualStores) as? [ManualStores]
    self.isOrderDiscount = aDecoder.decodeObject(forKey: SerializationKeys.isOrderDiscount) as? Int
    self.registeredStores = aDecoder.decodeObject(forKey: SerializationKeys.registeredStores) as? [RegisteredStores]
    self.totalPay = aDecoder.decodeObject(forKey: SerializationKeys.totalPay) as? Float
    self.isCouponDiscount = aDecoder.decodeObject(forKey: SerializationKeys.isCouponDiscount) as? Int
    self.serviceCharge = aDecoder.decodeObject(forKey: SerializationKeys.serviceCharge) as? Float
    self.deliveryCharge = aDecoder.decodeObject(forKey: SerializationKeys.deliveryCharge) as? Float
    self.orderDiscount = aDecoder.decodeObject(forKey: SerializationKeys.orderDiscount) as? Float
    self.shoppingFee = aDecoder.decodeObject(forKey: SerializationKeys.shoppingFee) as? Float
    self.couponDiscount = aDecoder.decodeObject(forKey: SerializationKeys.couponDiscount) as? Float
    self.tip = aDecoder.decodeObject(forKey: SerializationKeys.tip) as? Float
    self.shoppingFeeDriver = aDecoder.decodeObject(forKey: SerializationKeys.shoppingFeeDriver) as? Float
    self.driverTotalEarn = aDecoder.decodeObject(forKey: SerializationKeys.driverTotalEarn) as? Float
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(isManualStoreAvailable, forKey: SerializationKeys.isManualStoreAvailable)
    aCoder.encode(manualStores, forKey: SerializationKeys.manualStores)
    aCoder.encode(isOrderDiscount, forKey: SerializationKeys.isOrderDiscount)
    aCoder.encode(registeredStores, forKey: SerializationKeys.registeredStores)
    aCoder.encode(totalPay, forKey: SerializationKeys.totalPay)
    aCoder.encode(isCouponDiscount, forKey: SerializationKeys.isCouponDiscount)
    aCoder.encode(serviceCharge, forKey: SerializationKeys.serviceCharge)
    aCoder.encode(deliveryCharge, forKey: SerializationKeys.deliveryCharge)
    aCoder.encode(orderDiscount, forKey: SerializationKeys.orderDiscount)
    aCoder.encode(shoppingFee, forKey: SerializationKeys.shoppingFee)
    aCoder.encode(couponDiscount, forKey: SerializationKeys.couponDiscount)
    aCoder.encode(tip, forKey: SerializationKeys.tip)
    aCoder.encode(shoppingFeeDriver, forKey: SerializationKeys.shoppingFeeDriver)
    aCoder.encode(driverTotalEarn, forKey: SerializationKeys.driverTotalEarn)
  }

}
