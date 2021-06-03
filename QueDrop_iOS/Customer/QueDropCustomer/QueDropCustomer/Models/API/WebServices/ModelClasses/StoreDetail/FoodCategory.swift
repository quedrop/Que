//
//  FoodCategory.swift
//
//  Created by C100-104 on 08/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class FoodCategory: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kFoodCategoryStoreCategoryImageKey: String = "store_category_image"
  private let kFoodCategoryStoreCategoryTitleKey: String = "store_category_title"
  private let kFoodCategoryProductsKey: String = "products"
  private let kFoodCategoryIsActiveKey: String = "is_active"
  private let kFoodCategoryStoreCategoryIdKey: String = "store_category_id"
  private let kFoodCategoryFreshProduceCategoryIdKey: String = "fresh_produce_category_id"
    
  // MARK: Properties
  public var storeCategoryImage: String?
  public var storeCategoryTitle: String?
  public var products: [Products]?
  public var isActive: Int?
  public var storeCategoryId: Int?
  public var freshProduceCategoryId: Int?
    
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
    storeCategoryImage = json[kFoodCategoryStoreCategoryImageKey].string
    storeCategoryTitle = json[kFoodCategoryStoreCategoryTitleKey].string
    if let items = json[kFoodCategoryProductsKey].array { products = items.map { Products(json: $0) } }
    isActive = json[kFoodCategoryIsActiveKey].int
    storeCategoryId = json[kFoodCategoryStoreCategoryIdKey].int
    freshProduceCategoryId = json[kFoodCategoryFreshProduceCategoryIdKey].int
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = storeCategoryImage { dictionary[kFoodCategoryStoreCategoryImageKey] = value }
    if let value = storeCategoryTitle { dictionary[kFoodCategoryStoreCategoryTitleKey] = value }
    if let value = products { dictionary[kFoodCategoryProductsKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = isActive { dictionary[kFoodCategoryIsActiveKey] = value }
    if let value = storeCategoryId { dictionary[kFoodCategoryStoreCategoryIdKey] = value }
    if let value = freshProduceCategoryId { dictionary[kFoodCategoryFreshProduceCategoryIdKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.storeCategoryImage = aDecoder.decodeObject(forKey: kFoodCategoryStoreCategoryImageKey) as? String
    self.storeCategoryTitle = aDecoder.decodeObject(forKey: kFoodCategoryStoreCategoryTitleKey) as? String
    self.products = aDecoder.decodeObject(forKey: kFoodCategoryProductsKey) as? [Products]
    self.isActive = aDecoder.decodeObject(forKey: kFoodCategoryIsActiveKey) as? Int
    self.storeCategoryId = aDecoder.decodeObject(forKey: kFoodCategoryStoreCategoryIdKey) as? Int
    self.freshProduceCategoryId = aDecoder.decodeObject(forKey: kFoodCategoryFreshProduceCategoryIdKey) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(storeCategoryImage, forKey: kFoodCategoryStoreCategoryImageKey)
    aCoder.encode(storeCategoryTitle, forKey: kFoodCategoryStoreCategoryTitleKey)
    aCoder.encode(products, forKey: kFoodCategoryProductsKey)
    aCoder.encode(isActive, forKey: kFoodCategoryIsActiveKey)
    aCoder.encode(storeCategoryId, forKey: kFoodCategoryStoreCategoryIdKey)
    aCoder.encode(freshProduceCategoryId, forKey: kFoodCategoryFreshProduceCategoryIdKey)
  }

}
