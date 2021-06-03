//
//  StoreOffer.swift
//
//  Created by C100-104 on 25/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class CartStoreOffer: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kStoreOfferExpirationDateKey: String = "expiration_date"
  private let kStoreOfferCouponCodeKey: String = "coupon_code"
  private let kStoreOfferStoreIdKey: String = "store_id"
  private let kStoreOfferOfferOnKey: String = "offer_on"
  private let kStoreOfferOfferDescriptionKey: String = "offer_description"
  private let kStoreOfferOfferRangeKey: String = "offer_range"
  private let kStoreOfferIsActiveKey: String = "is_active"
  private let kStoreOfferOfferTypeKey: String = "offer_type"
  private let kStoreOfferDiscountPercentageKey: String = "discount_percentage"
  private let kStoreOfferStartDateKey: String = "start_date"
  private let kStoreOfferAdminOfferIdKey: String = "admin_offer_id"

  // MARK: Properties
  public var expirationDate: String?
  public var couponCode: String?
  public var storeId: Int?
  public var offerOn: String?
  public var offerDescription: String?
  public var offerRange: Int?
  public var isActive: Int?
  public var offerType: String?
  public var discountPercentage: Int?
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
  public init(json: JSON) {
    expirationDate = json[kStoreOfferExpirationDateKey].string
    couponCode = json[kStoreOfferCouponCodeKey].string
    storeId = json[kStoreOfferStoreIdKey].int
    offerOn = json[kStoreOfferOfferOnKey].string
    offerDescription = json[kStoreOfferOfferDescriptionKey].string
    offerRange = json[kStoreOfferOfferRangeKey].int
    isActive = json[kStoreOfferIsActiveKey].int
    offerType = json[kStoreOfferOfferTypeKey].string
    discountPercentage = json[kStoreOfferDiscountPercentageKey].int
    startDate = json[kStoreOfferStartDateKey].string
    adminOfferId = json[kStoreOfferAdminOfferIdKey].int
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = expirationDate { dictionary[kStoreOfferExpirationDateKey] = value }
    if let value = couponCode { dictionary[kStoreOfferCouponCodeKey] = value }
    if let value = storeId { dictionary[kStoreOfferStoreIdKey] = value }
    if let value = offerOn { dictionary[kStoreOfferOfferOnKey] = value }
    if let value = offerDescription { dictionary[kStoreOfferOfferDescriptionKey] = value }
    if let value = offerRange { dictionary[kStoreOfferOfferRangeKey] = value }
    if let value = isActive { dictionary[kStoreOfferIsActiveKey] = value }
    if let value = offerType { dictionary[kStoreOfferOfferTypeKey] = value }
    if let value = discountPercentage { dictionary[kStoreOfferDiscountPercentageKey] = value }
    if let value = startDate { dictionary[kStoreOfferStartDateKey] = value }
    if let value = adminOfferId { dictionary[kStoreOfferAdminOfferIdKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.expirationDate = aDecoder.decodeObject(forKey: kStoreOfferExpirationDateKey) as? String
    self.couponCode = aDecoder.decodeObject(forKey: kStoreOfferCouponCodeKey) as? String
    self.storeId = aDecoder.decodeObject(forKey: kStoreOfferStoreIdKey) as? Int
    self.offerOn = aDecoder.decodeObject(forKey: kStoreOfferOfferOnKey) as? String
    self.offerDescription = aDecoder.decodeObject(forKey: kStoreOfferOfferDescriptionKey) as? String
    self.offerRange = aDecoder.decodeObject(forKey: kStoreOfferOfferRangeKey) as? Int
    self.isActive = aDecoder.decodeObject(forKey: kStoreOfferIsActiveKey) as? Int
    self.offerType = aDecoder.decodeObject(forKey: kStoreOfferOfferTypeKey) as? String
    self.discountPercentage = aDecoder.decodeObject(forKey: kStoreOfferDiscountPercentageKey) as? Int
    self.startDate = aDecoder.decodeObject(forKey: kStoreOfferStartDateKey) as? String
    self.adminOfferId = aDecoder.decodeObject(forKey: kStoreOfferAdminOfferIdKey) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(expirationDate, forKey: kStoreOfferExpirationDateKey)
    aCoder.encode(couponCode, forKey: kStoreOfferCouponCodeKey)
    aCoder.encode(storeId, forKey: kStoreOfferStoreIdKey)
    aCoder.encode(offerOn, forKey: kStoreOfferOfferOnKey)
    aCoder.encode(offerDescription, forKey: kStoreOfferOfferDescriptionKey)
    aCoder.encode(offerRange, forKey: kStoreOfferOfferRangeKey)
    aCoder.encode(isActive, forKey: kStoreOfferIsActiveKey)
    aCoder.encode(offerType, forKey: kStoreOfferOfferTypeKey)
    aCoder.encode(discountPercentage, forKey: kStoreOfferDiscountPercentageKey)
    aCoder.encode(startDate, forKey: kStoreOfferStartDateKey)
    aCoder.encode(adminOfferId, forKey: kStoreOfferAdminOfferIdKey)
  }

}
