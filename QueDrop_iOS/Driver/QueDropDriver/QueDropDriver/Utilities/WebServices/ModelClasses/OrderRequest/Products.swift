//
//  Products.swift
//
//  Created by C100-174 on 24/03/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class Products: NSObject, NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let optionId = "option_id"
    static let orderStoreProductId = "order_store_product_id"
    static let quantity = "quantity"
    static let productName = "product_name"
    static let productPrice = "product_price"
    static let offerPercentage = "offer_percentage"
    static let productId = "product_id"
    static let productDescription = "product_description"
    static let userProductId = "user_product_id"
    static let addons = "addons"
    static let productOfferId = "product_offer_id"
    static let extraFees = "extra_fees"
    static let productImage = "product_image"
    static let productFinalPrice = "product_final_price"
    static let recurringOrderStoreProductId = "recurring_order_store_product_id"
  }

  // MARK: Properties
  public var optionId: Int?
  public var orderStoreProductId: Int?
  public var quantity: Int?
  public var productName: String?
  public var productPrice: Float?
  public var offerPercentage: Float?
  public var productId: Int?
  public var productDescription: String?
  public var userProductId: Int?
  public var addons: [Addons]?
  public var productOfferId: Int?
  public var extraFees: Int?
  public var productImage: String?
  public var productFinalPrice: Float?
   public var recurringOrderStoreProductId: Int?
    
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
    optionId = json[SerializationKeys.optionId].int
    orderStoreProductId = json[SerializationKeys.orderStoreProductId].int
    quantity = json[SerializationKeys.quantity].int
    productName = json[SerializationKeys.productName].string
    productPrice = json[SerializationKeys.productPrice].float
    offerPercentage = json[SerializationKeys.offerPercentage].float
    productId = json[SerializationKeys.productId].int
    productDescription = json[SerializationKeys.productDescription].string
    userProductId = json[SerializationKeys.userProductId].int
    if let items = json[SerializationKeys.addons].array { addons = items.map { Addons(json: $0) } }
    productOfferId = json[SerializationKeys.productOfferId].int
    extraFees = json[SerializationKeys.extraFees].int
    productImage = json[SerializationKeys.productImage].string
    productFinalPrice = json[SerializationKeys.productFinalPrice].float
    recurringOrderStoreProductId = json[SerializationKeys.recurringOrderStoreProductId].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = optionId { dictionary[SerializationKeys.optionId] = value }
    if let value = orderStoreProductId { dictionary[SerializationKeys.orderStoreProductId] = value }
    if let value = quantity { dictionary[SerializationKeys.quantity] = value }
    if let value = productName { dictionary[SerializationKeys.productName] = value }
    if let value = productPrice { dictionary[SerializationKeys.productPrice] = value }
    if let value = offerPercentage { dictionary[SerializationKeys.offerPercentage] = value }
    if let value = productId { dictionary[SerializationKeys.productId] = value }
    if let value = productDescription { dictionary[SerializationKeys.productDescription] = value }
    if let value = userProductId { dictionary[SerializationKeys.userProductId] = value }
    if let value = addons { dictionary[SerializationKeys.addons] = value.map { $0.dictionaryRepresentation() } }
    if let value = productOfferId { dictionary[SerializationKeys.productOfferId] = value }
    if let value = extraFees { dictionary[SerializationKeys.extraFees] = value }
    if let value = productImage { dictionary[SerializationKeys.productImage] = value }
     if let value = productFinalPrice { dictionary[SerializationKeys.productFinalPrice] = value }
     if let value = recurringOrderStoreProductId { dictionary[SerializationKeys.recurringOrderStoreProductId] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.optionId = aDecoder.decodeObject(forKey: SerializationKeys.optionId) as? Int
    self.orderStoreProductId = aDecoder.decodeObject(forKey: SerializationKeys.orderStoreProductId) as? Int
    self.quantity = aDecoder.decodeObject(forKey: SerializationKeys.quantity) as? Int
    self.productName = aDecoder.decodeObject(forKey: SerializationKeys.productName) as? String
    self.productPrice = aDecoder.decodeObject(forKey: SerializationKeys.productPrice) as? Float
    self.offerPercentage = aDecoder.decodeObject(forKey: SerializationKeys.offerPercentage) as? Float
    self.productId = aDecoder.decodeObject(forKey: SerializationKeys.productId) as? Int
    self.productDescription = aDecoder.decodeObject(forKey: SerializationKeys.productDescription) as? String
    self.userProductId = aDecoder.decodeObject(forKey: SerializationKeys.userProductId) as? Int
    self.addons = aDecoder.decodeObject(forKey: SerializationKeys.addons) as? [Addons]
    self.productOfferId = aDecoder.decodeObject(forKey: SerializationKeys.productOfferId) as? Int
    self.extraFees = aDecoder.decodeObject(forKey: SerializationKeys.extraFees) as? Int
    self.productImage = aDecoder.decodeObject(forKey: SerializationKeys.productImage) as? String
    self.productFinalPrice = aDecoder.decodeObject(forKey: SerializationKeys.productFinalPrice) as? Float
    self.recurringOrderStoreProductId = aDecoder.decodeObject(forKey: SerializationKeys.recurringOrderStoreProductId) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(optionId, forKey: SerializationKeys.optionId)
    aCoder.encode(orderStoreProductId, forKey: SerializationKeys.orderStoreProductId)
    aCoder.encode(quantity, forKey: SerializationKeys.quantity)
    aCoder.encode(productName, forKey: SerializationKeys.productName)
    aCoder.encode(productPrice, forKey: SerializationKeys.productPrice)
    aCoder.encode(offerPercentage, forKey: SerializationKeys.offerPercentage)
    aCoder.encode(productId, forKey: SerializationKeys.productId)
    aCoder.encode(productDescription, forKey: SerializationKeys.productDescription)
    aCoder.encode(userProductId, forKey: SerializationKeys.userProductId)
    aCoder.encode(addons, forKey: SerializationKeys.addons)
    aCoder.encode(productOfferId, forKey: SerializationKeys.productOfferId)
    aCoder.encode(extraFees, forKey: SerializationKeys.extraFees)
    aCoder.encode(productImage, forKey: SerializationKeys.productImage)
    aCoder.encode(productFinalPrice, forKey: SerializationKeys.productFinalPrice)
    aCoder.encode(recurringOrderStoreProductId, forKey: SerializationKeys.recurringOrderStoreProductId)
  }

}
