//
//  StoreOffer.swift
//
//  Created by C100-104 on 06/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class StoreOffer: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kStoreOfferStoreNameKey: String = "store_name"
  private let kStoreOfferCouponCodeKey: String = "coupon_code"
  private let kStoreOfferOfferDescriptionKey: String = "offer_description"
  private let kStoreOfferAdminOfferIdKey: String = "admin_offer_id"
  private let kStoreOfferLatitudeKey: String = "latitude"
  private let kStoreOfferStoreLogoKey: String = "store_logo"
  private let kStoreOfferExpirationDateKey: String = "expiration_date"
  private let kStoreOfferStoreIdKey: String = "store_id"
  private let kStoreOfferDiscountPriceKey: String = "discount_price"
  private let kStoreOfferOfferTypeKey: String = "offer_type"
  private let kStoreOfferLongitudeKey: String = "longitude"
  private let kStoreOfferDiscountPercentageKey: String = "discount_percentage"
  private let kStoreOfferStartDateKey: String = "start_date"
  private let kStoreOfferStoreRatingKey: String = "store_rating"

  // MARK: Properties
  public var storeName: String?
  public var couponCode: String?
  public var offerDescription: String?
  public var adminOfferId: Int?
  public var latitude: String?
  public var storeLogo: String?
  public var expirationDate: String?
  public var storeId: Int?
  public var discountPrice: Int?
  public var offerType: String?
  public var longitude: String?
  public var discountPercentage: Int?
  public var startDate: String?
  public var storeRating: Float?

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
    storeName = json[kStoreOfferStoreNameKey].string
    couponCode = json[kStoreOfferCouponCodeKey].string
    offerDescription = json[kStoreOfferOfferDescriptionKey].string
    adminOfferId = json[kStoreOfferAdminOfferIdKey].int
    latitude = json[kStoreOfferLatitudeKey].string
    storeLogo = json[kStoreOfferStoreLogoKey].string
    expirationDate = json[kStoreOfferExpirationDateKey].string
    storeId = json[kStoreOfferStoreIdKey].int
    discountPrice = json[kStoreOfferDiscountPriceKey].int
    offerType = json[kStoreOfferOfferTypeKey].string
    longitude = json[kStoreOfferLongitudeKey].string
    discountPercentage = json[kStoreOfferDiscountPercentageKey].int
    startDate = json[kStoreOfferStartDateKey].string
    storeRating = json[kStoreOfferStoreRatingKey].float
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = storeName { dictionary[kStoreOfferStoreNameKey] = value }
    if let value = couponCode { dictionary[kStoreOfferCouponCodeKey] = value }
    if let value = offerDescription { dictionary[kStoreOfferOfferDescriptionKey] = value }
    if let value = adminOfferId { dictionary[kStoreOfferAdminOfferIdKey] = value }
    if let value = latitude { dictionary[kStoreOfferLatitudeKey] = value }
    if let value = storeLogo { dictionary[kStoreOfferStoreLogoKey] = value }
    if let value = expirationDate { dictionary[kStoreOfferExpirationDateKey] = value }
    if let value = storeId { dictionary[kStoreOfferStoreIdKey] = value }
    if let value = discountPrice { dictionary[kStoreOfferDiscountPriceKey] = value }
    if let value = offerType { dictionary[kStoreOfferOfferTypeKey] = value }
    if let value = longitude { dictionary[kStoreOfferLongitudeKey] = value }
    if let value = discountPercentage { dictionary[kStoreOfferDiscountPercentageKey] = value }
    if let value = startDate { dictionary[kStoreOfferStartDateKey] = value }
    if let value = storeRating { dictionary[kStoreOfferStoreRatingKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.storeName = aDecoder.decodeObject(forKey: kStoreOfferStoreNameKey) as? String
    self.couponCode = aDecoder.decodeObject(forKey: kStoreOfferCouponCodeKey) as? String
    self.offerDescription = aDecoder.decodeObject(forKey: kStoreOfferOfferDescriptionKey) as? String
    self.adminOfferId = aDecoder.decodeObject(forKey: kStoreOfferAdminOfferIdKey) as? Int
    self.latitude = aDecoder.decodeObject(forKey: kStoreOfferLatitudeKey) as? String
    self.storeLogo = aDecoder.decodeObject(forKey: kStoreOfferStoreLogoKey) as? String
    self.expirationDate = aDecoder.decodeObject(forKey: kStoreOfferExpirationDateKey) as? String
    self.storeId = aDecoder.decodeObject(forKey: kStoreOfferStoreIdKey) as? Int
    self.discountPrice = aDecoder.decodeObject(forKey: kStoreOfferDiscountPriceKey) as? Int
    self.offerType = aDecoder.decodeObject(forKey: kStoreOfferOfferTypeKey) as? String
    self.longitude = aDecoder.decodeObject(forKey: kStoreOfferLongitudeKey) as? String
    self.discountPercentage = aDecoder.decodeObject(forKey: kStoreOfferDiscountPercentageKey) as? Int
    self.startDate = aDecoder.decodeObject(forKey: kStoreOfferStartDateKey) as? String
    self.storeRating = aDecoder.decodeObject(forKey: kStoreOfferStoreRatingKey) as? Float
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(storeName, forKey: kStoreOfferStoreNameKey)
    aCoder.encode(couponCode, forKey: kStoreOfferCouponCodeKey)
    aCoder.encode(offerDescription, forKey: kStoreOfferOfferDescriptionKey)
    aCoder.encode(adminOfferId, forKey: kStoreOfferAdminOfferIdKey)
    aCoder.encode(latitude, forKey: kStoreOfferLatitudeKey)
    aCoder.encode(storeLogo, forKey: kStoreOfferStoreLogoKey)
    aCoder.encode(expirationDate, forKey: kStoreOfferExpirationDateKey)
    aCoder.encode(storeId, forKey: kStoreOfferStoreIdKey)
    aCoder.encode(discountPrice, forKey: kStoreOfferDiscountPriceKey)
    aCoder.encode(offerType, forKey: kStoreOfferOfferTypeKey)
    aCoder.encode(longitude, forKey: kStoreOfferLongitudeKey)
    aCoder.encode(discountPercentage, forKey: kStoreOfferDiscountPercentageKey)
    aCoder.encode(startDate, forKey: kStoreOfferStartDateKey)
    aCoder.encode(storeRating, forKey: kStoreOfferStoreRatingKey)
  }

}
