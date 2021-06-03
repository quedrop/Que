//
//  OrderOffer.swift
//
//  Created by C100-174 on 30/06/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class OrderOffer: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let expirationDate = "expiration_date"
    static let couponCode = "coupon_code"
    static let discountAmount = "discount_amount"
    static let offerRange = "offer_range"
    static let offerDescription = "offer_description"
    static let offerOn = "offer_on"
    static let offerType = "offer_type"
    static let discountPercentage = "discount_percentage"
    static let startDate = "start_date"
    static let adminOfferId = "admin_offer_id"
  }

  // MARK: Properties
  public var expirationDate: String?
  public var couponCode: String?
  public var discountAmount: Int?
  public var offerRange: Int?
  public var offerDescription: String?
  public var offerOn: String?
  public var offerType: String?
  public var discountPercentage: Int?
  public var startDate: String?
  public var adminOfferId: Int?

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
    expirationDate = json[SerializationKeys.expirationDate].string
    couponCode = json[SerializationKeys.couponCode].string
    discountAmount = json[SerializationKeys.discountAmount].int
    offerRange = json[SerializationKeys.offerRange].int
    offerDescription = json[SerializationKeys.offerDescription].string
    offerOn = json[SerializationKeys.offerOn].string
    offerType = json[SerializationKeys.offerType].string
    discountPercentage = json[SerializationKeys.discountPercentage].int
    startDate = json[SerializationKeys.startDate].string
    adminOfferId = json[SerializationKeys.adminOfferId].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = expirationDate { dictionary[SerializationKeys.expirationDate] = value }
    if let value = couponCode { dictionary[SerializationKeys.couponCode] = value }
    if let value = discountAmount { dictionary[SerializationKeys.discountAmount] = value }
    if let value = offerRange { dictionary[SerializationKeys.offerRange] = value }
    if let value = offerDescription { dictionary[SerializationKeys.offerDescription] = value }
    if let value = offerOn { dictionary[SerializationKeys.offerOn] = value }
    if let value = offerType { dictionary[SerializationKeys.offerType] = value }
    if let value = discountPercentage { dictionary[SerializationKeys.discountPercentage] = value }
    if let value = startDate { dictionary[SerializationKeys.startDate] = value }
    if let value = adminOfferId { dictionary[SerializationKeys.adminOfferId] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.expirationDate = aDecoder.decodeObject(forKey: SerializationKeys.expirationDate) as? String
    self.couponCode = aDecoder.decodeObject(forKey: SerializationKeys.couponCode) as? String
    self.discountAmount = aDecoder.decodeObject(forKey: SerializationKeys.discountAmount) as? Int
    self.offerRange = aDecoder.decodeObject(forKey: SerializationKeys.offerRange) as? Int
    self.offerDescription = aDecoder.decodeObject(forKey: SerializationKeys.offerDescription) as? String
    self.offerOn = aDecoder.decodeObject(forKey: SerializationKeys.offerOn) as? String
    self.offerType = aDecoder.decodeObject(forKey: SerializationKeys.offerType) as? String
    self.discountPercentage = aDecoder.decodeObject(forKey: SerializationKeys.discountPercentage) as? Int
    self.startDate = aDecoder.decodeObject(forKey: SerializationKeys.startDate) as? String
    self.adminOfferId = aDecoder.decodeObject(forKey: SerializationKeys.adminOfferId) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(expirationDate, forKey: SerializationKeys.expirationDate)
    aCoder.encode(couponCode, forKey: SerializationKeys.couponCode)
    aCoder.encode(discountAmount, forKey: SerializationKeys.discountAmount)
    aCoder.encode(offerRange, forKey: SerializationKeys.offerRange)
    aCoder.encode(offerDescription, forKey: SerializationKeys.offerDescription)
    aCoder.encode(offerOn, forKey: SerializationKeys.offerOn)
    aCoder.encode(offerType, forKey: SerializationKeys.offerType)
    aCoder.encode(discountPercentage, forKey: SerializationKeys.discountPercentage)
    aCoder.encode(startDate, forKey: SerializationKeys.startDate)
    aCoder.encode(adminOfferId, forKey: SerializationKeys.adminOfferId)
  }

}
