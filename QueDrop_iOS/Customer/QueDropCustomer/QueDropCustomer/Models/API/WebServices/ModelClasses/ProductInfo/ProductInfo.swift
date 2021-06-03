//
//  ProductInfo.swift
//
//  Created by C100-104 on 13/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class ProductInfo: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kProductInfoProductIdKey: String = "product_id"
private let kProductsProductOptionKey: String = "product_option"
  private let kProductInfoProductDescriptionKey: String = "product_description"
  private let kProductInfoIsActiveKey: String = "is_active"
  private let kProductInfoNeedExtraFeesKey: String = "need_extra_fees"
  private let kProductInfoAddonsKey: String = "addons"
  private let kProductInfoExtraFeesKey: String = "extra_fees"
  private let kProductInfoProductNameKey: String = "product_name"
  private let kProductInfoProductPriceKey: String = "product_price"
  private let kProductInfoProductImageKey: String = "product_image"
  private let kProductInfoStoreCategoryIdKey: String = "store_category_id"

  // MARK: Properties
  public var productId: Int?
	public var productOption: [ProductOption]?
  public var productDescription: String?
  public var isActive: Int?
  public var needExtraFees: Int?
  public var addons: [Addons]?
  public var extraFees: Int?
  public var productName: String?
  public var productPrice: Int?
  public var productImage: String?
  public var storeCategoryId: Int?

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
    productId = json[kProductInfoProductIdKey].int
    productDescription = json[kProductInfoProductDescriptionKey].string
    isActive = json[kProductInfoIsActiveKey].int
    needExtraFees = json[kProductInfoNeedExtraFeesKey].int
    if let items = json[kProductInfoAddonsKey].array { addons = items.map { Addons(json: $0) } }
    extraFees = json[kProductInfoExtraFeesKey].int
    productName = json[kProductInfoProductNameKey].string
    productPrice = json[kProductInfoProductPriceKey].int
    productImage = json[kProductInfoProductImageKey].string
    storeCategoryId = json[kProductInfoStoreCategoryIdKey].int
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
	if let value = productOption { dictionary[kProductsProductOptionKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = productId { dictionary[kProductInfoProductIdKey] = value }
    if let value = productDescription { dictionary[kProductInfoProductDescriptionKey] = value }
    if let value = isActive { dictionary[kProductInfoIsActiveKey] = value }
    if let value = needExtraFees { dictionary[kProductInfoNeedExtraFeesKey] = value }
    if let value = addons { dictionary[kProductInfoAddonsKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = extraFees { dictionary[kProductInfoExtraFeesKey] = value }
    if let value = productName { dictionary[kProductInfoProductNameKey] = value }
    if let value = productPrice { dictionary[kProductInfoProductPriceKey] = value }
    if let value = productImage { dictionary[kProductInfoProductImageKey] = value }
    if let value = storeCategoryId { dictionary[kProductInfoStoreCategoryIdKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
	self.productOption = aDecoder.decodeObject(forKey: kProductsProductOptionKey) as? [ProductOption]
    self.productId = aDecoder.decodeObject(forKey: kProductInfoProductIdKey) as? Int
    self.productDescription = aDecoder.decodeObject(forKey: kProductInfoProductDescriptionKey) as? String
    self.isActive = aDecoder.decodeObject(forKey: kProductInfoIsActiveKey) as? Int
    self.needExtraFees = aDecoder.decodeObject(forKey: kProductInfoNeedExtraFeesKey) as? Int
    self.addons = aDecoder.decodeObject(forKey: kProductInfoAddonsKey) as? [Addons]
    self.extraFees = aDecoder.decodeObject(forKey: kProductInfoExtraFeesKey) as? Int
    self.productName = aDecoder.decodeObject(forKey: kProductInfoProductNameKey) as? String
    self.productPrice = aDecoder.decodeObject(forKey: kProductInfoProductPriceKey) as? Int
    self.productImage = aDecoder.decodeObject(forKey: kProductInfoProductImageKey) as? String
    self.storeCategoryId = aDecoder.decodeObject(forKey: kProductInfoStoreCategoryIdKey) as? Int
  }

  public func encode(with aCoder: NSCoder) {
	aCoder.encode(productOption, forKey: kProductsProductOptionKey)
    aCoder.encode(productId, forKey: kProductInfoProductIdKey)
    aCoder.encode(productDescription, forKey: kProductInfoProductDescriptionKey)
    aCoder.encode(isActive, forKey: kProductInfoIsActiveKey)
    aCoder.encode(needExtraFees, forKey: kProductInfoNeedExtraFeesKey)
    aCoder.encode(addons, forKey: kProductInfoAddonsKey)
    aCoder.encode(extraFees, forKey: kProductInfoExtraFeesKey)
    aCoder.encode(productName, forKey: kProductInfoProductNameKey)
    aCoder.encode(productPrice, forKey: kProductInfoProductPriceKey)
    aCoder.encode(productImage, forKey: kProductInfoProductImageKey)
    aCoder.encode(storeCategoryId, forKey: kProductInfoStoreCategoryIdKey)
  }

}
