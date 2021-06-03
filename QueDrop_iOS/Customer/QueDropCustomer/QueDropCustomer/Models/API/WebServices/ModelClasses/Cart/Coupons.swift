//
//  Coupons.swift
//
//  Created by C100-104 on 26/03/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class Coupons: NSObject, NSCoding,JSONable  {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kCouponsExpirationDateKey: String = "expiration_date"
  private let kCouponsCouponCodeKey: String = "coupon_code"
  private let kCouponsStoreIdKey: String = "store_id"
  private let kCouponsOfferRangeKey: String = "offer_range"
  private let kCouponsOfferDescriptionKey: String = "offer_description"
  private let kCouponsOfferOnKey: String = "offer_on"
  private let kCouponsOfferTypeKey: String = "offer_type"
  private let kCouponsDiscountPercentageKey: String = "discount_percentage"
  private let kCouponsStartDateKey: String = "start_date"
  private let kCouponsAdminOfferIdKey: String = "admin_offer_id"

  // MARK: Properties
  public var expirationDate: String?
  public var couponCode: String?
  public var storeId: Int?
  public var offerRange: Int?
  public var offerDescription: String?
  public var offerOn: String?
  public var offerType: String?
  public var discountPercentage: Float?
  public var startDate: String?
  public var adminOfferId: Int?

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
    expirationDate = json[kCouponsExpirationDateKey].string
    couponCode = json[kCouponsCouponCodeKey].string
    storeId = json[kCouponsStoreIdKey].int
    offerRange = json[kCouponsOfferRangeKey].int
    offerDescription = json[kCouponsOfferDescriptionKey].string
    offerOn = json[kCouponsOfferOnKey].string
    offerType = json[kCouponsOfferTypeKey].string
    discountPercentage = json[kCouponsDiscountPercentageKey].float
    startDate = json[kCouponsStartDateKey].string
    adminOfferId = json[kCouponsAdminOfferIdKey].int
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = expirationDate { dictionary[kCouponsExpirationDateKey] = value }
    if let value = couponCode { dictionary[kCouponsCouponCodeKey] = value }
    if let value = storeId { dictionary[kCouponsStoreIdKey] = value }
    if let value = offerRange { dictionary[kCouponsOfferRangeKey] = value }
    if let value = offerDescription { dictionary[kCouponsOfferDescriptionKey] = value }
    if let value = offerOn { dictionary[kCouponsOfferOnKey] = value }
    if let value = offerType { dictionary[kCouponsOfferTypeKey] = value }
    if let value = discountPercentage { dictionary[kCouponsDiscountPercentageKey] = value }
    if let value = startDate { dictionary[kCouponsStartDateKey] = value }
    if let value = adminOfferId { dictionary[kCouponsAdminOfferIdKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.expirationDate = aDecoder.decodeObject(forKey: kCouponsExpirationDateKey) as? String
    self.couponCode = aDecoder.decodeObject(forKey: kCouponsCouponCodeKey) as? String
    self.storeId = aDecoder.decodeObject(forKey: kCouponsStoreIdKey) as? Int
    self.offerRange = aDecoder.decodeObject(forKey: kCouponsOfferRangeKey) as? Int
    self.offerDescription = aDecoder.decodeObject(forKey: kCouponsOfferDescriptionKey) as? String
    self.offerOn = aDecoder.decodeObject(forKey: kCouponsOfferOnKey) as? String
    self.offerType = aDecoder.decodeObject(forKey: kCouponsOfferTypeKey) as? String
    self.discountPercentage = aDecoder.decodeObject(forKey: kCouponsDiscountPercentageKey) as? Float
    self.startDate = aDecoder.decodeObject(forKey: kCouponsStartDateKey) as? String
    self.adminOfferId = aDecoder.decodeObject(forKey: kCouponsAdminOfferIdKey) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(expirationDate, forKey: kCouponsExpirationDateKey)
    aCoder.encode(couponCode, forKey: kCouponsCouponCodeKey)
    aCoder.encode(storeId, forKey: kCouponsStoreIdKey)
    aCoder.encode(offerRange, forKey: kCouponsOfferRangeKey)
    aCoder.encode(offerDescription, forKey: kCouponsOfferDescriptionKey)
    aCoder.encode(offerOn, forKey: kCouponsOfferOnKey)
    aCoder.encode(offerType, forKey: kCouponsOfferTypeKey)
    aCoder.encode(discountPercentage, forKey: kCouponsDiscountPercentageKey)
    aCoder.encode(startDate, forKey: kCouponsStartDateKey)
    aCoder.encode(adminOfferId, forKey: kCouponsAdminOfferIdKey)
  }

}
