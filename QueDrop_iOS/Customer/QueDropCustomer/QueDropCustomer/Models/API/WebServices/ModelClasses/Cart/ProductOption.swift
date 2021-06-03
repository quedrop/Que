//
//  ProductOption.swift
//
//  Created by C100-104 on 25/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class ProductOption: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kProductOptionOptionNameKey: String = "option_name"
  private let kProductOptionOptionIdKey: String = "option_id"
  private let kProductOptionIsDefaultKey: String = "is_default"
  private let kProductOptionPriceKey: String = "price"

  // MARK: Properties
  public var optionName: String?
  public var optionId: Int?
  public var isDefault: Int?
  public var price: Float?

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
    optionName = json[kProductOptionOptionNameKey].string
    optionId = json[kProductOptionOptionIdKey].int
    isDefault = json[kProductOptionIsDefaultKey].int
    price = json[kProductOptionPriceKey].float
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = optionName { dictionary[kProductOptionOptionNameKey] = value }
    if let value = optionId { dictionary[kProductOptionOptionIdKey] = value }
    if let value = isDefault { dictionary[kProductOptionIsDefaultKey] = value }
    if let value = price { dictionary[kProductOptionPriceKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.optionName = aDecoder.decodeObject(forKey: kProductOptionOptionNameKey) as? String
    self.optionId = aDecoder.decodeObject(forKey: kProductOptionOptionIdKey) as? Int
    self.isDefault = aDecoder.decodeObject(forKey: kProductOptionIsDefaultKey) as? Int
    self.price = aDecoder.decodeObject(forKey: kProductOptionPriceKey) as? Float
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(optionName, forKey: kProductOptionOptionNameKey)
    aCoder.encode(optionId, forKey: kProductOptionOptionIdKey)
    aCoder.encode(isDefault, forKey: kProductOptionIsDefaultKey)
    aCoder.encode(price, forKey: kProductOptionPriceKey)
  }

}
