//
//  NewOrderProduct.swift
//
//  Created by C100-104 on 19/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class NewOrderProduct: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kNewOrderProductIsUserCreatedStoreKey: String = "is_user_created_store"
  private let kNewOrderProductProductDescriptionKey: String = "product_description"
  private let kNewOrderProductStoreIdKey: String = "store_id"
  private let kNewOrderProductUserProductIdKey: String = "user_product_id"
  private let kNewOrderProductQuantityKey: String = "quantity"
  private let kNewOrderProductUserIdKey: String = "user_id"
  private let kNewOrderProductProductNameKey: String = "product_name"
  private let kNewOrderProductProductImageKey: String = "product_image"
  private let kNewOrderProductUserStoreIdKey: String = "user_store_id"

  // MARK: Properties
  public var isUserCreatedStore: Int?
  public var productDescription: String?
  public var storeId: Int?
  public var userProductId: Int?
  public var quantity: Int?
  public var userId: Int?
  public var productName: String?
  public var productImage: String?
  public var userStoreId: Int?

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
    isUserCreatedStore = json[kNewOrderProductIsUserCreatedStoreKey].int
    productDescription = json[kNewOrderProductProductDescriptionKey].string
    storeId = json[kNewOrderProductStoreIdKey].int
    userProductId = json[kNewOrderProductUserProductIdKey].int
    quantity = json[kNewOrderProductQuantityKey].int
    userId = json[kNewOrderProductUserIdKey].int
    productName = json[kNewOrderProductProductNameKey].string
    productImage = json[kNewOrderProductProductImageKey].string
    userStoreId = json[kNewOrderProductUserStoreIdKey].int
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = isUserCreatedStore { dictionary[kNewOrderProductIsUserCreatedStoreKey] = value }
    if let value = productDescription { dictionary[kNewOrderProductProductDescriptionKey] = value }
    if let value = storeId { dictionary[kNewOrderProductStoreIdKey] = value }
    if let value = userProductId { dictionary[kNewOrderProductUserProductIdKey] = value }
    if let value = quantity { dictionary[kNewOrderProductQuantityKey] = value }
    if let value = userId { dictionary[kNewOrderProductUserIdKey] = value }
    if let value = productName { dictionary[kNewOrderProductProductNameKey] = value }
    if let value = productImage { dictionary[kNewOrderProductProductImageKey] = value }
    if let value = userStoreId { dictionary[kNewOrderProductUserStoreIdKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.isUserCreatedStore = aDecoder.decodeObject(forKey: kNewOrderProductIsUserCreatedStoreKey) as? Int
    self.productDescription = aDecoder.decodeObject(forKey: kNewOrderProductProductDescriptionKey) as? String
    self.storeId = aDecoder.decodeObject(forKey: kNewOrderProductStoreIdKey) as? Int
    self.userProductId = aDecoder.decodeObject(forKey: kNewOrderProductUserProductIdKey) as? Int
    self.quantity = aDecoder.decodeObject(forKey: kNewOrderProductQuantityKey) as? Int
    self.userId = aDecoder.decodeObject(forKey: kNewOrderProductUserIdKey) as? Int
    self.productName = aDecoder.decodeObject(forKey: kNewOrderProductProductNameKey) as? String
    self.productImage = aDecoder.decodeObject(forKey: kNewOrderProductProductImageKey) as? String
    self.userStoreId = aDecoder.decodeObject(forKey: kNewOrderProductUserStoreIdKey) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(isUserCreatedStore, forKey: kNewOrderProductIsUserCreatedStoreKey)
    aCoder.encode(productDescription, forKey: kNewOrderProductProductDescriptionKey)
    aCoder.encode(storeId, forKey: kNewOrderProductStoreIdKey)
    aCoder.encode(userProductId, forKey: kNewOrderProductUserProductIdKey)
    aCoder.encode(quantity, forKey: kNewOrderProductQuantityKey)
    aCoder.encode(userId, forKey: kNewOrderProductUserIdKey)
    aCoder.encode(productName, forKey: kNewOrderProductProductNameKey)
    aCoder.encode(productImage, forKey: kNewOrderProductProductImageKey)
    aCoder.encode(userStoreId, forKey: kNewOrderProductUserStoreIdKey)
  }

}
