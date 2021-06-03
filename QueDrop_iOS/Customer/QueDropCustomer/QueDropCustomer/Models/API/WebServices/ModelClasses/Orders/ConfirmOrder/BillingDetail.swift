//
//  BillingDetail.swift
//
//  Created by C100-104 on 07/04/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class BillingDetail:  NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kBillingDetailIsManualStoreAvailableKey: String = "is_manual_store_available"
  private let kBillingDetailManualStoresKey: String = "manual_stores"
  private let kBillingDetailIsOrderDiscountKey: String = "is_order_discount"
  private let kBillingDetailRegisteredStoresKey: String = "registered_stores"
  private let kBillingDetailTotalPayKey: String = "total_pay"
  private let kBillingDetailIsCouponDiscountKey: String = "is_coupon_discount"
  private let kBillingDetailServiceChargeKey: String = "service_charge"
  private let kBillingDetailDeliveryChargeKey: String = "delivery_charge"
  private let kBillingDetailOrderDiscountKey: String = "order_discount"
  private let kBillingDetailShoppingFeeKey: String = "shopping_fee"
  private let kBillingDetailCouponDiscountKey: String = "coupon_discount"

  // MARK: Properties
  public var isManualStoreAvailable: Int?
  public var manualStores: [OrderStores]?
  public var isOrderDiscount: Int?
  public var registeredStores: [OrderStores]?
  public var totalPay: Float?
  public var isCouponDiscount: Int?
  public var serviceCharge: Float?
  public var deliveryCharge: Float?
  public var orderDiscount: Float?
  public var shoppingFee: Float?
  public var couponDiscount: Float?

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
  required  public init(json: JSON) {
    isManualStoreAvailable = json[kBillingDetailIsManualStoreAvailableKey].int
    if let items = json[kBillingDetailManualStoresKey].array { manualStores = items.map { OrderStores(json: $0) } }
    isOrderDiscount = json[kBillingDetailIsOrderDiscountKey].int
    if let items = json[kBillingDetailRegisteredStoresKey].array { registeredStores = items.map { OrderStores(json: $0) } }
    totalPay = json[kBillingDetailTotalPayKey].float
    isCouponDiscount = json[kBillingDetailIsCouponDiscountKey].int
    serviceCharge = json[kBillingDetailServiceChargeKey].float
    deliveryCharge = json[kBillingDetailDeliveryChargeKey].float
    orderDiscount = json[kBillingDetailOrderDiscountKey].float
    shoppingFee = json[kBillingDetailShoppingFeeKey].float
    couponDiscount = json[kBillingDetailCouponDiscountKey].float
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = isManualStoreAvailable { dictionary[kBillingDetailIsManualStoreAvailableKey] = value }
    if let value = manualStores { dictionary[kBillingDetailManualStoresKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = isOrderDiscount { dictionary[kBillingDetailIsOrderDiscountKey] = value }
    if let value = registeredStores { dictionary[kBillingDetailRegisteredStoresKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = totalPay { dictionary[kBillingDetailTotalPayKey] = value }
    if let value = isCouponDiscount { dictionary[kBillingDetailIsCouponDiscountKey] = value }
    if let value = serviceCharge { dictionary[kBillingDetailServiceChargeKey] = value }
    if let value = deliveryCharge { dictionary[kBillingDetailDeliveryChargeKey] = value }
    if let value = orderDiscount { dictionary[kBillingDetailOrderDiscountKey] = value }
    if let value = shoppingFee { dictionary[kBillingDetailShoppingFeeKey] = value }
    if let value = couponDiscount { dictionary[kBillingDetailCouponDiscountKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.isManualStoreAvailable = aDecoder.decodeObject(forKey: kBillingDetailIsManualStoreAvailableKey) as? Int
    self.manualStores = aDecoder.decodeObject(forKey: kBillingDetailManualStoresKey) as? [OrderStores]
    self.isOrderDiscount = aDecoder.decodeObject(forKey: kBillingDetailIsOrderDiscountKey) as? Int
    self.registeredStores = aDecoder.decodeObject(forKey: kBillingDetailRegisteredStoresKey) as? [OrderStores]
    self.totalPay = aDecoder.decodeObject(forKey: kBillingDetailTotalPayKey) as? Float
    self.isCouponDiscount = aDecoder.decodeObject(forKey: kBillingDetailIsCouponDiscountKey) as? Int
    self.serviceCharge = aDecoder.decodeObject(forKey: kBillingDetailServiceChargeKey) as? Float
    self.deliveryCharge = aDecoder.decodeObject(forKey: kBillingDetailDeliveryChargeKey) as? Float
    self.orderDiscount = aDecoder.decodeObject(forKey: kBillingDetailOrderDiscountKey) as? Float
    self.shoppingFee = aDecoder.decodeObject(forKey: kBillingDetailShoppingFeeKey) as? Float
    self.couponDiscount = aDecoder.decodeObject(forKey: kBillingDetailCouponDiscountKey) as? Float
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(isManualStoreAvailable, forKey: kBillingDetailIsManualStoreAvailableKey)
    aCoder.encode(manualStores, forKey: kBillingDetailManualStoresKey)
    aCoder.encode(isOrderDiscount, forKey: kBillingDetailIsOrderDiscountKey)
    aCoder.encode(registeredStores, forKey: kBillingDetailRegisteredStoresKey)
    aCoder.encode(totalPay, forKey: kBillingDetailTotalPayKey)
    aCoder.encode(isCouponDiscount, forKey: kBillingDetailIsCouponDiscountKey)
    aCoder.encode(serviceCharge, forKey: kBillingDetailServiceChargeKey)
    aCoder.encode(deliveryCharge, forKey: kBillingDetailDeliveryChargeKey)
    aCoder.encode(orderDiscount, forKey: kBillingDetailOrderDiscountKey)
    aCoder.encode(shoppingFee, forKey: kBillingDetailShoppingFeeKey)
    aCoder.encode(couponDiscount, forKey: kBillingDetailCouponDiscountKey)
  }

}
