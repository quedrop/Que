//
//  ServiceCategories.swift
//
//  Created by C100-104 on 03/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class ServiceCategories: NSObject, NSCoding,JSONable  {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kServiceCategoriesServiceCategoryImageKey: String = "service_category_image"
  private let kServiceCategoriesServiceCategoryNameKey: String = "service_category_name"
  private let kServiceCategoriesServiceCategoryIdKey: String = "service_category_id"
  private let kServiceCategoriesServiceCategoryDescriptionKey: String = "service_category_description"

  // MARK: Properties
  public var serviceCategoryImage: String?
  public var serviceCategoryName: String?
  public var serviceCategoryId: Int?
  public var serviceCategoryDescription: String?

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
    serviceCategoryImage = json[kServiceCategoriesServiceCategoryImageKey].string
    serviceCategoryName = json[kServiceCategoriesServiceCategoryNameKey].string
    serviceCategoryId = json[kServiceCategoriesServiceCategoryIdKey].int
    serviceCategoryDescription = json[kServiceCategoriesServiceCategoryDescriptionKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = serviceCategoryImage { dictionary[kServiceCategoriesServiceCategoryImageKey] = value }
    if let value = serviceCategoryName { dictionary[kServiceCategoriesServiceCategoryNameKey] = value }
    if let value = serviceCategoryId { dictionary[kServiceCategoriesServiceCategoryIdKey] = value }
    if let value = serviceCategoryDescription { dictionary[kServiceCategoriesServiceCategoryDescriptionKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.serviceCategoryImage = aDecoder.decodeObject(forKey: kServiceCategoriesServiceCategoryImageKey) as? String
    self.serviceCategoryName = aDecoder.decodeObject(forKey: kServiceCategoriesServiceCategoryNameKey) as? String
    self.serviceCategoryId = aDecoder.decodeObject(forKey: kServiceCategoriesServiceCategoryIdKey) as? Int
    self.serviceCategoryDescription = aDecoder.decodeObject(forKey: kServiceCategoriesServiceCategoryDescriptionKey) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(serviceCategoryImage, forKey: kServiceCategoriesServiceCategoryImageKey)
    aCoder.encode(serviceCategoryName, forKey: kServiceCategoriesServiceCategoryNameKey)
    aCoder.encode(serviceCategoryId, forKey: kServiceCategoriesServiceCategoryIdKey)
    aCoder.encode(serviceCategoryDescription, forKey: kServiceCategoriesServiceCategoryDescriptionKey)
  }

}
