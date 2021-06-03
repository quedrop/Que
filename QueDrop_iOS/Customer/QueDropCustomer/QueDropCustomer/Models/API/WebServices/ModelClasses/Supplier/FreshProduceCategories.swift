//
//  FreshProduceCategories.swift
//
//  Created by C100-174 on 30/09/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class FreshProduceCategories: NSObject, NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let freshProduceTitle = "fresh_produce_title"
    static let freshCategoryId = "fresh_category_id"
    static let freshProduceImage = "fresh_produce_image"
  }

  // MARK: Properties
  public var freshProduceTitle: String?
  public var freshCategoryId: Int?
  public var freshProduceImage: String?

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
    freshProduceTitle = json[SerializationKeys.freshProduceTitle].string
    freshCategoryId = json[SerializationKeys.freshCategoryId].int
    freshProduceImage = json[SerializationKeys.freshProduceImage].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = freshProduceTitle { dictionary[SerializationKeys.freshProduceTitle] = value }
    if let value = freshCategoryId { dictionary[SerializationKeys.freshCategoryId] = value }
    if let value = freshProduceImage { dictionary[SerializationKeys.freshProduceImage] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.freshProduceTitle = aDecoder.decodeObject(forKey: SerializationKeys.freshProduceTitle) as? String
    self.freshCategoryId = aDecoder.decodeObject(forKey: SerializationKeys.freshCategoryId) as? Int
    self.freshProduceImage = aDecoder.decodeObject(forKey: SerializationKeys.freshProduceImage) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(freshProduceTitle, forKey: SerializationKeys.freshProduceTitle)
    aCoder.encode(freshCategoryId, forKey: SerializationKeys.freshCategoryId)
    aCoder.encode(freshProduceImage, forKey: SerializationKeys.freshProduceImage)
  }

}
