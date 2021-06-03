//
//  Addons.swift
//
//  Created by C100-174 on 24/03/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class Addons: NSObject, NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let addonPrice = "addon_price"
    static let addonName = "addon_name"
    static let addonId = "addon_id"
  }

  // MARK: Properties
  public var addonPrice: Int?
  public var addonName: String?
  public var addonId: Int?

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
    addonPrice = json[SerializationKeys.addonPrice].int
    addonName = json[SerializationKeys.addonName].string
    addonId = json[SerializationKeys.addonId].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = addonPrice { dictionary[SerializationKeys.addonPrice] = value }
    if let value = addonName { dictionary[SerializationKeys.addonName] = value }
    if let value = addonId { dictionary[SerializationKeys.addonId] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.addonPrice = aDecoder.decodeObject(forKey: SerializationKeys.addonPrice) as? Int
    self.addonName = aDecoder.decodeObject(forKey: SerializationKeys.addonName) as? String
    self.addonId = aDecoder.decodeObject(forKey: SerializationKeys.addonId) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(addonPrice, forKey: SerializationKeys.addonPrice)
    aCoder.encode(addonName, forKey: SerializationKeys.addonName)
    aCoder.encode(addonId, forKey: SerializationKeys.addonId)
  }

}
