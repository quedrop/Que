//
//  AddedProductDetails.swift
//
//  Created by C205 on 10/04/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class AddedProductDetails: NSObject, NSCoding,JSONable  {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let totalPrice = "total_price"
    static let totalItems = "total_items"
  }

  // MARK: Properties
  public var totalPrice: Float?
  public var totalItems: Int?

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
  required public init(json: JSON) {
    totalPrice = json[SerializationKeys.totalPrice].float
    totalItems = json[SerializationKeys.totalItems].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = totalPrice { dictionary[SerializationKeys.totalPrice] = value }
    if let value = totalItems { dictionary[SerializationKeys.totalItems] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.totalPrice = aDecoder.decodeObject(forKey: SerializationKeys.totalPrice) as? Float
    self.totalItems = aDecoder.decodeObject(forKey: SerializationKeys.totalItems) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(totalPrice, forKey: SerializationKeys.totalPrice)
    aCoder.encode(totalItems, forKey: SerializationKeys.totalItems)
  }

}
