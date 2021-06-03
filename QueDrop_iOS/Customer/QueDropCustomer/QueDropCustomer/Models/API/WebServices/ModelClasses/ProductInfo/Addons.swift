//
//  Addons.swift
//
//  Created by C100-104 on 13/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class Addons: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kAddonsAddonPriceKey: String = "addon_price"
  private let kAddonsAddonNameKey: String = "addon_name"
  private let kAddonsAddonIdKey: String = "addon_id"

  // MARK: Properties
  public var addonPrice: Float?
  public var addonName: String?
  public var addonId: Int?

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
    addonPrice = json[kAddonsAddonPriceKey].float
    addonName = json[kAddonsAddonNameKey].string
    addonId = json[kAddonsAddonIdKey].int
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = addonPrice { dictionary[kAddonsAddonPriceKey] = value }
    if let value = addonName { dictionary[kAddonsAddonNameKey] = value }
    if let value = addonId { dictionary[kAddonsAddonIdKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.addonPrice = aDecoder.decodeObject(forKey: kAddonsAddonPriceKey) as? Float
    self.addonName = aDecoder.decodeObject(forKey: kAddonsAddonNameKey) as? String
    self.addonId = aDecoder.decodeObject(forKey: kAddonsAddonIdKey) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(addonPrice, forKey: kAddonsAddonPriceKey)
    aCoder.encode(addonName, forKey: kAddonsAddonNameKey)
    aCoder.encode(addonId, forKey: kAddonsAddonIdKey)
  }

}
