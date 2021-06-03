//
//  FathestStoreDetails.swift
//
//  Created by C100-174 on 22/09/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class FathestStoreDetails: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let userStoreLogo = "user_store_logo"
    static let storeLogo = "store_logo"
    static let storeAddress = "store_address"
    static let storeLat = "store_lat"
    static let cartId = "cart_id"
    static let storeId = "store_id"
    static let userStoreName = "user_store_name"
    static let distance = "distance"
    static let storeLong = "store_long"
    static let userStoreAddress = "user_store_address"
    static let storeName = "store_name"
    static let userStoreId = "user_store_id"
  }

  // MARK: Properties
  public var userStoreLogo: String?
  public var storeLogo: String?
  public var storeAddress: String?
  public var storeLat: String?
  public var cartId: Int?
  public var storeId: Int?
  public var userStoreName: String?
  public var distance: Float?
  public var storeLong: String?
  public var userStoreAddress: String?
  public var storeName: String?
  public var userStoreId: Int?

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
    userStoreLogo = json[SerializationKeys.userStoreLogo].string
    storeLogo = json[SerializationKeys.storeLogo].string
    storeAddress = json[SerializationKeys.storeAddress].string
    storeLat = json[SerializationKeys.storeLat].string
    cartId = json[SerializationKeys.cartId].int
    storeId = json[SerializationKeys.storeId].int
    userStoreName = json[SerializationKeys.userStoreName].string
    distance = json[SerializationKeys.distance].float
    storeLong = json[SerializationKeys.storeLong].string
    userStoreAddress = json[SerializationKeys.userStoreAddress].string
    storeName = json[SerializationKeys.storeName].string
    userStoreId = json[SerializationKeys.userStoreId].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = userStoreLogo { dictionary[SerializationKeys.userStoreLogo] = value }
    if let value = storeLogo { dictionary[SerializationKeys.storeLogo] = value }
    if let value = storeAddress { dictionary[SerializationKeys.storeAddress] = value }
    if let value = storeLat { dictionary[SerializationKeys.storeLat] = value }
    if let value = cartId { dictionary[SerializationKeys.cartId] = value }
    if let value = storeId { dictionary[SerializationKeys.storeId] = value }
    if let value = userStoreName { dictionary[SerializationKeys.userStoreName] = value }
    if let value = distance { dictionary[SerializationKeys.distance] = value }
    if let value = storeLong { dictionary[SerializationKeys.storeLong] = value }
    if let value = userStoreAddress { dictionary[SerializationKeys.userStoreAddress] = value }
    if let value = storeName { dictionary[SerializationKeys.storeName] = value }
    if let value = userStoreId { dictionary[SerializationKeys.userStoreId] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.userStoreLogo = aDecoder.decodeObject(forKey: SerializationKeys.userStoreLogo) as? String
    self.storeLogo = aDecoder.decodeObject(forKey: SerializationKeys.storeLogo) as? String
    self.storeAddress = aDecoder.decodeObject(forKey: SerializationKeys.storeAddress) as? String
    self.storeLat = aDecoder.decodeObject(forKey: SerializationKeys.storeLat) as? String
    self.cartId = aDecoder.decodeObject(forKey: SerializationKeys.cartId) as? Int
    self.storeId = aDecoder.decodeObject(forKey: SerializationKeys.storeId) as? Int
    self.userStoreName = aDecoder.decodeObject(forKey: SerializationKeys.userStoreName) as? String
    self.distance = aDecoder.decodeObject(forKey: SerializationKeys.distance) as? Float
    self.storeLong = aDecoder.decodeObject(forKey: SerializationKeys.storeLong) as? String
    self.userStoreAddress = aDecoder.decodeObject(forKey: SerializationKeys.userStoreAddress) as? String
    self.storeName = aDecoder.decodeObject(forKey: SerializationKeys.storeName) as? String
    self.userStoreId = aDecoder.decodeObject(forKey: SerializationKeys.userStoreId) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(userStoreLogo, forKey: SerializationKeys.userStoreLogo)
    aCoder.encode(storeLogo, forKey: SerializationKeys.storeLogo)
    aCoder.encode(storeAddress, forKey: SerializationKeys.storeAddress)
    aCoder.encode(storeLat, forKey: SerializationKeys.storeLat)
    aCoder.encode(cartId, forKey: SerializationKeys.cartId)
    aCoder.encode(storeId, forKey: SerializationKeys.storeId)
    aCoder.encode(userStoreName, forKey: SerializationKeys.userStoreName)
    aCoder.encode(distance, forKey: SerializationKeys.distance)
    aCoder.encode(storeLong, forKey: SerializationKeys.storeLong)
    aCoder.encode(userStoreAddress, forKey: SerializationKeys.userStoreAddress)
    aCoder.encode(storeName, forKey: SerializationKeys.storeName)
    aCoder.encode(userStoreId, forKey: SerializationKeys.userStoreId)
  }

}
