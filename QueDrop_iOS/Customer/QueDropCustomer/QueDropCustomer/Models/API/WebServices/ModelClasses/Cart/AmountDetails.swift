//
//  AmountDetails.swift
//
//  Created by C100-104 on 24/03/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class AmountDetails:  NSObject, NSCoding,JSONable  {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kAmountDetailsTotalDeliveryTimeKey: String = "total_delivery_time"
  private let kAmountDetailsCouponAppliedOnServiceChargeKey: String = "coupon_applied_on_service_charge"
  private let kAmountDetailsOrderDiscountValueKey: String = "order_discount_value"
  private let kAmountDetailsCouponDiscountPriceKey: String = "coupon_discount_price"
  private let kAmountDetailsCouponAppliedOnDeliveryKey: String = "coupon_applied_on_delivery"
  private let kAmountDetailsServiceChargeKey: String = "service_charge"
  private let kAmountDetailsDeliveryChargeKey: String = "delivery_charge"
  private let kAmountDetailsTotalItemsPriceKey: String = "total_items_price"
  private let kAmountDetailsShoppingFeeKey: String = "shopping_fee"
  private let kAmountDetailsIsCouponAppliedKey: String = "is_coupon_applied"
  private let kAmountDetailsGrandTotalKey: String = "grand_total"

  // MARK: Properties
  public var totalDeliveryTime: Int?
  public var couponAppliedOnServiceCharge: Int?
  public var orderDiscountValue: Float?
  public var couponDiscountPrice: Float?
  public var couponAppliedOnDelivery: Int?
  public var serviceCharge: Float?
  public var deliveryCharge: Float?
  public var totalItemsPrice: Float?
  public var shoppingFee: Float?
  public var isCouponApplied: Int?
  public var grandTotal: Float?

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
    totalDeliveryTime = json[kAmountDetailsTotalDeliveryTimeKey].int
    couponAppliedOnServiceCharge = json[kAmountDetailsCouponAppliedOnServiceChargeKey].int
    orderDiscountValue = json[kAmountDetailsOrderDiscountValueKey].float
    couponDiscountPrice = json[kAmountDetailsCouponDiscountPriceKey].float
    couponAppliedOnDelivery = json[kAmountDetailsCouponAppliedOnDeliveryKey].int
    serviceCharge = json[kAmountDetailsServiceChargeKey].float
    deliveryCharge = json[kAmountDetailsDeliveryChargeKey].float
    totalItemsPrice = json[kAmountDetailsTotalItemsPriceKey].float
    shoppingFee = json[kAmountDetailsShoppingFeeKey].float
    isCouponApplied = json[kAmountDetailsIsCouponAppliedKey].int
    grandTotal = json[kAmountDetailsGrandTotalKey].float
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = totalDeliveryTime { dictionary[kAmountDetailsTotalDeliveryTimeKey] = value }
    if let value = couponAppliedOnServiceCharge { dictionary[kAmountDetailsCouponAppliedOnServiceChargeKey] = value }
    if let value = orderDiscountValue { dictionary[kAmountDetailsOrderDiscountValueKey] = value }
    if let value = couponDiscountPrice { dictionary[kAmountDetailsCouponDiscountPriceKey] = value }
    if let value = couponAppliedOnDelivery { dictionary[kAmountDetailsCouponAppliedOnDeliveryKey] = value }
    if let value = serviceCharge { dictionary[kAmountDetailsServiceChargeKey] = value }
    if let value = deliveryCharge { dictionary[kAmountDetailsDeliveryChargeKey] = value }
    if let value = totalItemsPrice { dictionary[kAmountDetailsTotalItemsPriceKey] = value }
    if let value = shoppingFee { dictionary[kAmountDetailsShoppingFeeKey] = value }
    if let value = isCouponApplied { dictionary[kAmountDetailsIsCouponAppliedKey] = value }
    if let value = grandTotal { dictionary[kAmountDetailsGrandTotalKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.totalDeliveryTime = aDecoder.decodeObject(forKey: kAmountDetailsTotalDeliveryTimeKey) as? Int
    self.couponAppliedOnServiceCharge = aDecoder.decodeObject(forKey: kAmountDetailsCouponAppliedOnServiceChargeKey) as? Int
    self.orderDiscountValue = aDecoder.decodeObject(forKey: kAmountDetailsOrderDiscountValueKey) as? Float
    self.couponDiscountPrice = aDecoder.decodeObject(forKey: kAmountDetailsCouponDiscountPriceKey) as? Float
    self.couponAppliedOnDelivery = aDecoder.decodeObject(forKey: kAmountDetailsCouponAppliedOnDeliveryKey) as? Int
    self.serviceCharge = aDecoder.decodeObject(forKey: kAmountDetailsServiceChargeKey) as? Float
    self.deliveryCharge = aDecoder.decodeObject(forKey: kAmountDetailsDeliveryChargeKey) as? Float
    self.totalItemsPrice = aDecoder.decodeObject(forKey: kAmountDetailsTotalItemsPriceKey) as? Float
    self.shoppingFee = aDecoder.decodeObject(forKey: kAmountDetailsShoppingFeeKey) as? Float
    self.isCouponApplied = aDecoder.decodeObject(forKey: kAmountDetailsIsCouponAppliedKey) as? Int
    self.grandTotal = aDecoder.decodeObject(forKey: kAmountDetailsGrandTotalKey) as? Float
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(totalDeliveryTime, forKey: kAmountDetailsTotalDeliveryTimeKey)
    aCoder.encode(couponAppliedOnServiceCharge, forKey: kAmountDetailsCouponAppliedOnServiceChargeKey)
    aCoder.encode(orderDiscountValue, forKey: kAmountDetailsOrderDiscountValueKey)
    aCoder.encode(couponDiscountPrice, forKey: kAmountDetailsCouponDiscountPriceKey)
    aCoder.encode(couponAppliedOnDelivery, forKey: kAmountDetailsCouponAppliedOnDeliveryKey)
    aCoder.encode(serviceCharge, forKey: kAmountDetailsServiceChargeKey)
    aCoder.encode(deliveryCharge, forKey: kAmountDetailsDeliveryChargeKey)
    aCoder.encode(totalItemsPrice, forKey: kAmountDetailsTotalItemsPriceKey)
    aCoder.encode(shoppingFee, forKey: kAmountDetailsShoppingFeeKey)
    aCoder.encode(isCouponApplied, forKey: kAmountDetailsIsCouponAppliedKey)
    aCoder.encode(grandTotal, forKey: kAmountDetailsGrandTotalKey)
  }

}
