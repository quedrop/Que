//
//  Products.swift
//
//  Created by C100-104 on 25/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class CartProducts:  NSObject, NSCoding,JSONable  {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kProductsProductOptionKey: String = "product_option"
  private let kProductsOptionIdKey: String = "option_id"
  private let kProductsOfferKey: String = "offer"
  private let kProductHasAddonsKey: String = "has_addons"
  private let kProductsQuantityKey: String = "quantity"
  private let kProductsProductNameKey: String = "product_name"
  private let kProductsProductIdKey: String = "product_id"
  private let kProductsProductFinalPriceKey: String = "product_final_price"
  private let kProductsProductDescriptionKey: String = "product_description"
  private let kProductsNeedExtraFeesKey: String = "need_extra_fees"
  private let kProductsAddonsKey: String = "addons"
  private let kProductsUserProductIdKey: String = "user_product_id"
  private let kProductsExtraFeesKey: String = "extra_fees"
  private let kProductsProductOriginalPriceKey: String = "product_original_price"
  private let kProductsCartProductIdKey: String = "cart_product_id"
  private let kProductsProductImageKey: String = "product_image"

  // MARK: Properties
  public var productOption: [ProductOption]?
  public var optionId: Int?
  public var offer: CartProductOffer?
  public var hasAddons: Int?
  public var quantity: Int?
  public var productName: String?
  public var productId: Int?
  public var productFinalPrice: Float?
  public var productDescription: Int?
  public var needExtraFees: Int?
  public var addons: [Addons]?
  public var userProductId: Int?
  public var extraFees: Int?
  public var productOriginalPrice: Int?
  public var cartProductId: Int?
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
    if let items = json[kProductsProductOptionKey].array { productOption = items.map { ProductOption(json: $0) } }
    optionId = json[kProductsOptionIdKey].int
    offer = CartProductOffer(json: json[kProductsOfferKey])
	hasAddons = json[kProductHasAddonsKey].int
    quantity = json[kProductsQuantityKey].int
    productName = json[kProductsProductNameKey].string
    productId = json[kProductsProductIdKey].int
    productFinalPrice = json[kProductsProductFinalPriceKey].float
    productDescription = json[kProductsProductDescriptionKey].int
    needExtraFees = json[kProductsNeedExtraFeesKey].int
    if let items = json[kProductsAddonsKey].array { addons = items.map { Addons(json: $0) } }
    userProductId = json[kProductsUserProductIdKey].int
    extraFees = json[kProductsExtraFeesKey].int
    productOriginalPrice = json[kProductsProductOriginalPriceKey].int
    cartProductId = json[kProductsCartProductIdKey].int
    productImage = json[kProductsProductImageKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = productOption { dictionary[kProductsProductOptionKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = optionId { dictionary[kProductsOptionIdKey] = value }
    if let value = offer { dictionary[kProductsOfferKey] = value.dictionaryRepresentation() }
	if let value = hasAddons { dictionary[kProductHasAddonsKey] = value }
    if let value = quantity { dictionary[kProductsQuantityKey] = value }
    if let value = productName { dictionary[kProductsProductNameKey] = value }
    if let value = productId { dictionary[kProductsProductIdKey] = value }
    if let value = productFinalPrice { dictionary[kProductsProductFinalPriceKey] = value }
    if let value = productDescription { dictionary[kProductsProductDescriptionKey] = value }
    if let value = needExtraFees { dictionary[kProductsNeedExtraFeesKey] = value }
    if let value = addons { dictionary[kProductsAddonsKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = userProductId { dictionary[kProductsUserProductIdKey] = value }
    if let value = extraFees { dictionary[kProductsExtraFeesKey] = value }
    if let value = productOriginalPrice { dictionary[kProductsProductOriginalPriceKey] = value }
    if let value = cartProductId { dictionary[kProductsCartProductIdKey] = value }
    if let value = productImage { dictionary[kProductsProductImageKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.productOption = aDecoder.decodeObject(forKey: kProductsProductOptionKey) as? [ProductOption]
    self.optionId = aDecoder.decodeObject(forKey: kProductsOptionIdKey) as? Int
    self.offer = aDecoder.decodeObject(forKey: kProductsOfferKey) as? CartProductOffer
	self.hasAddons = aDecoder.decodeObject(forKey: kProductHasAddonsKey) as? Int
    self.quantity = aDecoder.decodeObject(forKey: kProductsQuantityKey) as? Int
    self.productName = aDecoder.decodeObject(forKey: kProductsProductNameKey) as? String
    self.productId = aDecoder.decodeObject(forKey: kProductsProductIdKey) as? Int
    self.productFinalPrice = aDecoder.decodeObject(forKey: kProductsProductFinalPriceKey) as? Float
    self.productDescription = aDecoder.decodeObject(forKey: kProductsProductDescriptionKey) as? Int
    self.needExtraFees = aDecoder.decodeObject(forKey: kProductsNeedExtraFeesKey) as? Int
    self.addons = aDecoder.decodeObject(forKey: kProductsAddonsKey) as? [Addons]
    self.userProductId = aDecoder.decodeObject(forKey: kProductsUserProductIdKey) as? Int
    self.extraFees = aDecoder.decodeObject(forKey: kProductsExtraFeesKey) as? Int
    self.productOriginalPrice = aDecoder.decodeObject(forKey: kProductsProductOriginalPriceKey) as? Int
    self.cartProductId = aDecoder.decodeObject(forKey: kProductsCartProductIdKey) as? Int
    self.productImage = aDecoder.decodeObject(forKey: kProductsProductImageKey) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(productOption, forKey: kProductsProductOptionKey)
    aCoder.encode(optionId, forKey: kProductsOptionIdKey)
    aCoder.encode(offer, forKey: kProductsOfferKey)
	aCoder.encode(hasAddons, forKey: kProductHasAddonsKey)
    aCoder.encode(quantity, forKey: kProductsQuantityKey)
    aCoder.encode(productName, forKey: kProductsProductNameKey)
    aCoder.encode(productId, forKey: kProductsProductIdKey)
    aCoder.encode(productFinalPrice, forKey: kProductsProductFinalPriceKey)
    aCoder.encode(productDescription, forKey: kProductsProductDescriptionKey)
    aCoder.encode(needExtraFees, forKey: kProductsNeedExtraFeesKey)
    aCoder.encode(addons, forKey: kProductsAddonsKey)
    aCoder.encode(userProductId, forKey: kProductsUserProductIdKey)
    aCoder.encode(extraFees, forKey: kProductsExtraFeesKey)
    aCoder.encode(productOriginalPrice, forKey: kProductsProductOriginalPriceKey)
    aCoder.encode(cartProductId, forKey: kProductsCartProductIdKey)
    aCoder.encode(productImage, forKey: kProductsProductImageKey)
  }

}
