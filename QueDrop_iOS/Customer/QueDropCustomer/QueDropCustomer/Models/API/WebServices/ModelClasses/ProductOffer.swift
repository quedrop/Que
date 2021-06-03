//
//  ProductOffer.swift
//
//  Created by C100-104 on 06/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class ProductOffer: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kProductOfferStoreNameKey: String = "store_name"
  private let kProductOfferStartTimeKey: String = "start_time"
  private let kProductOfferStoreCategoryIdKey: String = "store_category_id"
  private let kProductOfferIsActiveKey: String = "is_active"
  private let kProductOfferStoreCategoryTitleKey: String = "store_category_title"
  private let kProductOfferProductNameKey: String = "product_name"
  private let kProductOfferOfferPercentageKey: String = "offer_percentage"
  private let kProductOfferOfferCodeKey: String = "offer_code"
  private let kProductOfferLatitudeKey: String = "latitude"
  private let kProductOfferProductIdKey: String = "product_id"
  private let kProductOfferExpirationDateKey: String = "expiration_date"
  private let kProductOfferStoreIdKey: String = "store_id"
  private let kProductOfferAdditionalInfoKey: String = "additional_info"
  private let kProductOfferProductOfferIdKey: String = "product_offer_id"
  private let kProductOfferLongitudeKey: String = "longitude"
  private let kProductOfferStartDateKey: String = "start_date"
  private let kProductOfferExpirationTimeKey: String = "expiration_time"
  private let kProductOfferProductImageKey: String = "product_image"

  // MARK: Properties
  public var storeName: String?
  public var startTime: String?
  public var storeCategoryId: Int?
  public var isActive: Int?
  public var storeCategoryTitle: String?
  public var productName: String?
  public var offerPercentage: Int?
  public var offerCode: String?
  public var latitude: String?
  public var productId: Int?
  public var expirationDate: String?
  public var storeId: Int?
  public var additionalInfo: String?
  public var productOfferId: Int?
  public var longitude: String?
  public var startDate: String?
  public var expirationTime: String?
  public var productImage: String?

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
    storeName = json[kProductOfferStoreNameKey].string
    startTime = json[kProductOfferStartTimeKey].string
    storeCategoryId = json[kProductOfferStoreCategoryIdKey].int
    isActive = json[kProductOfferIsActiveKey].int
    storeCategoryTitle = json[kProductOfferStoreCategoryTitleKey].string
    productName = json[kProductOfferProductNameKey].string
    offerPercentage = json[kProductOfferOfferPercentageKey].int
    offerCode = json[kProductOfferOfferCodeKey].string
    latitude = json[kProductOfferLatitudeKey].string
    productId = json[kProductOfferProductIdKey].int
    expirationDate = json[kProductOfferExpirationDateKey].string
    storeId = json[kProductOfferStoreIdKey].int
    additionalInfo = json[kProductOfferAdditionalInfoKey].string
    productOfferId = json[kProductOfferProductOfferIdKey].int
    longitude = json[kProductOfferLongitudeKey].string
    startDate = json[kProductOfferStartDateKey].string
    expirationTime = json[kProductOfferExpirationTimeKey].string
    productImage = json[kProductOfferProductImageKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = storeName { dictionary[kProductOfferStoreNameKey] = value }
    if let value = startTime { dictionary[kProductOfferStartTimeKey] = value }
    if let value = storeCategoryId { dictionary[kProductOfferStoreCategoryIdKey] = value }
    if let value = isActive { dictionary[kProductOfferIsActiveKey] = value }
    if let value = storeCategoryTitle { dictionary[kProductOfferStoreCategoryTitleKey] = value }
    if let value = productName { dictionary[kProductOfferProductNameKey] = value }
    if let value = offerPercentage { dictionary[kProductOfferOfferPercentageKey] = value }
    if let value = offerCode { dictionary[kProductOfferOfferCodeKey] = value }
    if let value = latitude { dictionary[kProductOfferLatitudeKey] = value }
    if let value = productId { dictionary[kProductOfferProductIdKey] = value }
    if let value = expirationDate { dictionary[kProductOfferExpirationDateKey] = value }
    if let value = storeId { dictionary[kProductOfferStoreIdKey] = value }
    if let value = additionalInfo { dictionary[kProductOfferAdditionalInfoKey] = value }
    if let value = productOfferId { dictionary[kProductOfferProductOfferIdKey] = value }
    if let value = longitude { dictionary[kProductOfferLongitudeKey] = value }
    if let value = startDate { dictionary[kProductOfferStartDateKey] = value }
    if let value = expirationTime { dictionary[kProductOfferExpirationTimeKey] = value }
    if let value = productImage { dictionary[kProductOfferProductImageKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.storeName = aDecoder.decodeObject(forKey: kProductOfferStoreNameKey) as? String
    self.startTime = aDecoder.decodeObject(forKey: kProductOfferStartTimeKey) as? String
    self.storeCategoryId = aDecoder.decodeObject(forKey: kProductOfferStoreCategoryIdKey) as? Int
    self.isActive = aDecoder.decodeObject(forKey: kProductOfferIsActiveKey) as? Int
    self.storeCategoryTitle = aDecoder.decodeObject(forKey: kProductOfferStoreCategoryTitleKey) as? String
    self.productName = aDecoder.decodeObject(forKey: kProductOfferProductNameKey) as? String
    self.offerPercentage = aDecoder.decodeObject(forKey: kProductOfferOfferPercentageKey) as? Int
    self.offerCode = aDecoder.decodeObject(forKey: kProductOfferOfferCodeKey) as? String
    self.latitude = aDecoder.decodeObject(forKey: kProductOfferLatitudeKey) as? String
    self.productId = aDecoder.decodeObject(forKey: kProductOfferProductIdKey) as? Int
    self.expirationDate = aDecoder.decodeObject(forKey: kProductOfferExpirationDateKey) as? String
    self.storeId = aDecoder.decodeObject(forKey: kProductOfferStoreIdKey) as? Int
    self.additionalInfo = aDecoder.decodeObject(forKey: kProductOfferAdditionalInfoKey) as? String
    self.productOfferId = aDecoder.decodeObject(forKey: kProductOfferProductOfferIdKey) as? Int
    self.longitude = aDecoder.decodeObject(forKey: kProductOfferLongitudeKey) as? String
    self.startDate = aDecoder.decodeObject(forKey: kProductOfferStartDateKey) as? String
    self.expirationTime = aDecoder.decodeObject(forKey: kProductOfferExpirationTimeKey) as? String
    self.productImage = aDecoder.decodeObject(forKey: kProductOfferProductImageKey) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(storeName, forKey: kProductOfferStoreNameKey)
    aCoder.encode(startTime, forKey: kProductOfferStartTimeKey)
    aCoder.encode(storeCategoryId, forKey: kProductOfferStoreCategoryIdKey)
    aCoder.encode(isActive, forKey: kProductOfferIsActiveKey)
    aCoder.encode(storeCategoryTitle, forKey: kProductOfferStoreCategoryTitleKey)
    aCoder.encode(productName, forKey: kProductOfferProductNameKey)
    aCoder.encode(offerPercentage, forKey: kProductOfferOfferPercentageKey)
    aCoder.encode(offerCode, forKey: kProductOfferOfferCodeKey)
    aCoder.encode(latitude, forKey: kProductOfferLatitudeKey)
    aCoder.encode(productId, forKey: kProductOfferProductIdKey)
    aCoder.encode(expirationDate, forKey: kProductOfferExpirationDateKey)
    aCoder.encode(storeId, forKey: kProductOfferStoreIdKey)
    aCoder.encode(additionalInfo, forKey: kProductOfferAdditionalInfoKey)
    aCoder.encode(productOfferId, forKey: kProductOfferProductOfferIdKey)
    aCoder.encode(longitude, forKey: kProductOfferLongitudeKey)
    aCoder.encode(startDate, forKey: kProductOfferStartDateKey)
    aCoder.encode(expirationTime, forKey: kProductOfferExpirationTimeKey)
    aCoder.encode(productImage, forKey: kProductOfferProductImageKey)
  }

}
