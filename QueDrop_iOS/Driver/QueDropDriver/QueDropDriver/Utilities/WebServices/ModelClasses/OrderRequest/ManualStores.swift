//
//  ManualStores.swift
//
//  Created by C100-174 on 07/04/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class ManualStores: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let storeAmount = "store_amount"
    static let storeFinalAmount = "store_final_amount"
    static let storeDiscount = "store_discount"
    static let isStoreOffer = "is_store_offer"
    static let storeName = "store_name"
  }

  // MARK: Properties
  public var storeAmount: Int?
  public var storeFinalAmount: Int?
  public var storeDiscount: Int?
  public var isStoreOffer: Int?
  public var storeName: String?

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
    storeAmount = json[SerializationKeys.storeAmount].int
    storeFinalAmount = json[SerializationKeys.storeFinalAmount].int
    storeDiscount = json[SerializationKeys.storeDiscount].int
    isStoreOffer = json[SerializationKeys.isStoreOffer].int
    storeName = json[SerializationKeys.storeName].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = storeAmount { dictionary[SerializationKeys.storeAmount] = value }
    if let value = storeFinalAmount { dictionary[SerializationKeys.storeFinalAmount] = value }
    if let value = storeDiscount { dictionary[SerializationKeys.storeDiscount] = value }
    if let value = isStoreOffer { dictionary[SerializationKeys.isStoreOffer] = value }
    if let value = storeName { dictionary[SerializationKeys.storeName] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.storeAmount = aDecoder.decodeObject(forKey: SerializationKeys.storeAmount) as? Int
    self.storeFinalAmount = aDecoder.decodeObject(forKey: SerializationKeys.storeFinalAmount) as? Int
    self.storeDiscount = aDecoder.decodeObject(forKey: SerializationKeys.storeDiscount) as? Int
    self.isStoreOffer = aDecoder.decodeObject(forKey: SerializationKeys.isStoreOffer) as? Int
    self.storeName = aDecoder.decodeObject(forKey: SerializationKeys.storeName) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(storeAmount, forKey: SerializationKeys.storeAmount)
    aCoder.encode(storeFinalAmount, forKey: SerializationKeys.storeFinalAmount)
    aCoder.encode(storeDiscount, forKey: SerializationKeys.storeDiscount)
    aCoder.encode(isStoreOffer, forKey: SerializationKeys.isStoreOffer)
    aCoder.encode(storeName, forKey: SerializationKeys.storeName)
  }

}
