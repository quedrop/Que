//
//  Stores.swift
//
//  Created by C100-174 on 24/03/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class Stores: NSObject, NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let orderAmount = "order_amount"
    static let orderId = "order_id"
    static let updatedAt = "updated_at"
    static let orderReceipt = "order_receipt"
    static let isDelete = "is_delete"
    static let isActive = "is_active"
    static let products = "products"
    static let orderStoreId = "order_store_id"
    static let offerPercentage = "offer_percentage"
    static let adminOfferId = "admin_offer_id"
    static let latitude = "latitude"
    static let userStoreId = "user_store_id"
    static let storeLogo = "store_logo"
    static let storeAddress = "store_address"
    static let isTestdata = "is_testdata"
    static let canProvideService = "can_provide_service"
    static let createdAt = "created_at"
    static let storeId = "store_id"
    static let longitude = "longitude"
    static let storeName = "store_name"
  }

  // MARK: Properties
  public var orderAmount: Int?
  public var orderId: Int?
  public var updatedAt: String?
  public var orderReceipt: String?
  public var isDelete: Int?
  public var isActive: Int?
  public var products: [Products]?
  public var orderStoreId: Int?
  public var offerPercentage: Int?
  public var adminOfferId: Int?
  public var latitude: String?
  public var userStoreId: Int?
  public var storeLogo: String?
  public var storeAddress: String?
  public var isTestdata: Int?
  public var canProvideService: Int?
  public var createdAt: String?
  public var storeId: Int?
  public var longitude: String?
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
    orderAmount = json[SerializationKeys.orderAmount].int
    orderId = json[SerializationKeys.orderId].int
    updatedAt = json[SerializationKeys.updatedAt].string
    orderReceipt = json[SerializationKeys.orderReceipt].string
    isDelete = json[SerializationKeys.isDelete].int
    isActive = json[SerializationKeys.isActive].int
    if let items = json[SerializationKeys.products].array { products = items.map { Products(json: $0) } }
    orderStoreId = json[SerializationKeys.orderStoreId].int
    offerPercentage = json[SerializationKeys.offerPercentage].int
    adminOfferId = json[SerializationKeys.adminOfferId].int
    latitude = json[SerializationKeys.latitude].string
    userStoreId = json[SerializationKeys.userStoreId].int
    storeLogo = json[SerializationKeys.storeLogo].string
    storeAddress = json[SerializationKeys.storeAddress].string
    isTestdata = json[SerializationKeys.isTestdata].int
    canProvideService = json[SerializationKeys.canProvideService].int
    createdAt = json[SerializationKeys.createdAt].string
    storeId = json[SerializationKeys.storeId].int
    longitude = json[SerializationKeys.longitude].string
    storeName = json[SerializationKeys.storeName].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = orderAmount { dictionary[SerializationKeys.orderAmount] = value }
    if let value = orderId { dictionary[SerializationKeys.orderId] = value }
    if let value = updatedAt { dictionary[SerializationKeys.updatedAt] = value }
    if let value = orderReceipt { dictionary[SerializationKeys.orderReceipt] = value }
    if let value = isDelete { dictionary[SerializationKeys.isDelete] = value }
    if let value = isActive { dictionary[SerializationKeys.isActive] = value }
    if let value = products { dictionary[SerializationKeys.products] = value.map { $0.dictionaryRepresentation() } }
    if let value = orderStoreId { dictionary[SerializationKeys.orderStoreId] = value }
    if let value = offerPercentage { dictionary[SerializationKeys.offerPercentage] = value }
    if let value = adminOfferId { dictionary[SerializationKeys.adminOfferId] = value }
    if let value = latitude { dictionary[SerializationKeys.latitude] = value }
    if let value = userStoreId { dictionary[SerializationKeys.userStoreId] = value }
    if let value = storeLogo { dictionary[SerializationKeys.storeLogo] = value }
    if let value = storeAddress { dictionary[SerializationKeys.storeAddress] = value }
    if let value = isTestdata { dictionary[SerializationKeys.isTestdata] = value }
    if let value = canProvideService { dictionary[SerializationKeys.canProvideService] = value }
    if let value = createdAt { dictionary[SerializationKeys.createdAt] = value }
    if let value = storeId { dictionary[SerializationKeys.storeId] = value }
    if let value = longitude { dictionary[SerializationKeys.longitude] = value }
    if let value = storeName { dictionary[SerializationKeys.storeName] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.orderAmount = aDecoder.decodeObject(forKey: SerializationKeys.orderAmount) as? Int
    self.orderId = aDecoder.decodeObject(forKey: SerializationKeys.orderId) as? Int
    self.updatedAt = aDecoder.decodeObject(forKey: SerializationKeys.updatedAt) as? String
    self.orderReceipt = aDecoder.decodeObject(forKey: SerializationKeys.orderReceipt) as? String
    self.isDelete = aDecoder.decodeObject(forKey: SerializationKeys.isDelete) as? Int
    self.isActive = aDecoder.decodeObject(forKey: SerializationKeys.isActive) as? Int
    self.products = aDecoder.decodeObject(forKey: SerializationKeys.products) as? [Products]
    self.orderStoreId = aDecoder.decodeObject(forKey: SerializationKeys.orderStoreId) as? Int
    self.offerPercentage = aDecoder.decodeObject(forKey: SerializationKeys.offerPercentage) as? Int
    self.adminOfferId = aDecoder.decodeObject(forKey: SerializationKeys.adminOfferId) as? Int
    self.latitude = aDecoder.decodeObject(forKey: SerializationKeys.latitude) as? String
    self.userStoreId = aDecoder.decodeObject(forKey: SerializationKeys.userStoreId) as? Int
    self.storeLogo = aDecoder.decodeObject(forKey: SerializationKeys.storeLogo) as? String
    self.storeAddress = aDecoder.decodeObject(forKey: SerializationKeys.storeAddress) as? String
    self.isTestdata = aDecoder.decodeObject(forKey: SerializationKeys.isTestdata) as? Int
    self.canProvideService = aDecoder.decodeObject(forKey: SerializationKeys.canProvideService) as? Int
    self.createdAt = aDecoder.decodeObject(forKey: SerializationKeys.createdAt) as? String
    self.storeId = aDecoder.decodeObject(forKey: SerializationKeys.storeId) as? Int
    self.longitude = aDecoder.decodeObject(forKey: SerializationKeys.longitude) as? String
    self.storeName = aDecoder.decodeObject(forKey: SerializationKeys.storeName) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(orderAmount, forKey: SerializationKeys.orderAmount)
    aCoder.encode(orderId, forKey: SerializationKeys.orderId)
    aCoder.encode(updatedAt, forKey: SerializationKeys.updatedAt)
    aCoder.encode(orderReceipt, forKey: SerializationKeys.orderReceipt)
    aCoder.encode(isDelete, forKey: SerializationKeys.isDelete)
    aCoder.encode(isActive, forKey: SerializationKeys.isActive)
    aCoder.encode(products, forKey: SerializationKeys.products)
    aCoder.encode(orderStoreId, forKey: SerializationKeys.orderStoreId)
    aCoder.encode(offerPercentage, forKey: SerializationKeys.offerPercentage)
    aCoder.encode(adminOfferId, forKey: SerializationKeys.adminOfferId)
    aCoder.encode(latitude, forKey: SerializationKeys.latitude)
    aCoder.encode(userStoreId, forKey: SerializationKeys.userStoreId)
    aCoder.encode(storeLogo, forKey: SerializationKeys.storeLogo)
    aCoder.encode(storeAddress, forKey: SerializationKeys.storeAddress)
    aCoder.encode(isTestdata, forKey: SerializationKeys.isTestdata)
    aCoder.encode(canProvideService, forKey: SerializationKeys.canProvideService)
    aCoder.encode(createdAt, forKey: SerializationKeys.createdAt)
    aCoder.encode(storeId, forKey: SerializationKeys.storeId)
    aCoder.encode(longitude, forKey: SerializationKeys.longitude)
    aCoder.encode(storeName, forKey: SerializationKeys.storeName)
  }

}
