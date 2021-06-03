//
//  CartItems.swift
//
//  Created by C100-104 on 25/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class CartItems: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kCartItemsCartIdKey: String = "cart_id"
  private let kCartItemsProductsKey: String = "products"
  private let kCartItemsStoreDetailsKey: String = "store_details"

  // MARK: Properties
  public var cartId: Int?
  public var products: [CartProducts]?
  public var storeDetails: StoreDetails?

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
    cartId = json[kCartItemsCartIdKey].int
    if let items = json[kCartItemsProductsKey].array { products = items.map { CartProducts(json: $0) } }
    storeDetails = StoreDetails(json: json[kCartItemsStoreDetailsKey])
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = cartId { dictionary[kCartItemsCartIdKey] = value }
    if let value = products { dictionary[kCartItemsProductsKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = storeDetails { dictionary[kCartItemsStoreDetailsKey] = value.dictionaryRepresentation() }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.cartId = aDecoder.decodeObject(forKey: kCartItemsCartIdKey) as? Int
    self.products = aDecoder.decodeObject(forKey: kCartItemsProductsKey) as? [CartProducts]
    self.storeDetails = aDecoder.decodeObject(forKey: kCartItemsStoreDetailsKey) as? StoreDetails
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(cartId, forKey: kCartItemsCartIdKey)
    aCoder.encode(products, forKey: kCartItemsProductsKey)
    aCoder.encode(storeDetails, forKey: kCartItemsStoreDetailsKey)
  }

}
