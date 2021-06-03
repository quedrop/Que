//
//  Offer.swift
//
//  Created by C100-104 on 25/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class CartProductOffer: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kOfferExpirationDateKey: String = "expiration_date"
  private let kOfferStartTimeKey: String = "start_time"
  private let kOfferStartDateKey: String = "start_date"
  private let kOfferIsActiveKey: String = "is_active"
  private let kOfferAdditionalInfoKey: String = "additional_info"
  private let kOfferProductOfferIdKey: String = "product_offer_id"
  private let kOfferOfferPercentageKey: String = "offer_percentage"
  private let kOfferOfferCodeKey: String = "offer_code"
  private let kOfferExpirationTimeKey: String = "expiration_time"

  // MARK: Properties
  public var expirationDate: String?
  public var startTime: String?
  public var startDate: String?
  public var isActive: Int?
  public var additionalInfo: String?
  public var productOfferId: Int?
  public var offerPercentage: Float?
  public var offerCode: String?
  public var expirationTime: String?

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
    expirationDate = json[kOfferExpirationDateKey].string
    startTime = json[kOfferStartTimeKey].string
    startDate = json[kOfferStartDateKey].string
    isActive = json[kOfferIsActiveKey].int
    additionalInfo = json[kOfferAdditionalInfoKey].string
    productOfferId = json[kOfferProductOfferIdKey].int
    offerPercentage = json[kOfferOfferPercentageKey].float
    offerCode = json[kOfferOfferCodeKey].string
    expirationTime = json[kOfferExpirationTimeKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = expirationDate { dictionary[kOfferExpirationDateKey] = value }
    if let value = startTime { dictionary[kOfferStartTimeKey] = value }
    if let value = startDate { dictionary[kOfferStartDateKey] = value }
    if let value = isActive { dictionary[kOfferIsActiveKey] = value }
    if let value = additionalInfo { dictionary[kOfferAdditionalInfoKey] = value }
    if let value = productOfferId { dictionary[kOfferProductOfferIdKey] = value }
    if let value = offerPercentage { dictionary[kOfferOfferPercentageKey] = value }
    if let value = offerCode { dictionary[kOfferOfferCodeKey] = value }
    if let value = expirationTime { dictionary[kOfferExpirationTimeKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.expirationDate = aDecoder.decodeObject(forKey: kOfferExpirationDateKey) as? String
    self.startTime = aDecoder.decodeObject(forKey: kOfferStartTimeKey) as? String
    self.startDate = aDecoder.decodeObject(forKey: kOfferStartDateKey) as? String
    self.isActive = aDecoder.decodeObject(forKey: kOfferIsActiveKey) as? Int
    self.additionalInfo = aDecoder.decodeObject(forKey: kOfferAdditionalInfoKey) as? String
    self.productOfferId = aDecoder.decodeObject(forKey: kOfferProductOfferIdKey) as? Int
    self.offerPercentage = aDecoder.decodeObject(forKey: kOfferOfferPercentageKey) as? Float
    self.offerCode = aDecoder.decodeObject(forKey: kOfferOfferCodeKey) as? String
    self.expirationTime = aDecoder.decodeObject(forKey: kOfferExpirationTimeKey) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(expirationDate, forKey: kOfferExpirationDateKey)
    aCoder.encode(startTime, forKey: kOfferStartTimeKey)
    aCoder.encode(startDate, forKey: kOfferStartDateKey)
    aCoder.encode(isActive, forKey: kOfferIsActiveKey)
    aCoder.encode(additionalInfo, forKey: kOfferAdditionalInfoKey)
    aCoder.encode(productOfferId, forKey: kOfferProductOfferIdKey)
    aCoder.encode(offerPercentage, forKey: kOfferOfferPercentageKey)
    aCoder.encode(offerCode, forKey: kOfferOfferCodeKey)
    aCoder.encode(expirationTime, forKey: kOfferExpirationTimeKey)
  }

}
