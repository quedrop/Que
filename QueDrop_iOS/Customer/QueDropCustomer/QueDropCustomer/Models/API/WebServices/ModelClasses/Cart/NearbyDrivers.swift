//
//  NearbyDrivers.swift
//
//  Created by C100-174 on 22/09/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class NearbyDrivers: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let latitude = "latitude"
    static let userId = "user_id"
    static let email = "email"
    static let longitude = "longitude"
    static let distance = "distance"
  }

  // MARK: Properties
  public var latitude: String?
  public var userId: Int?
  public var email: String?
  public var longitude: String?
  public var distance: Float?

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
    latitude = json[SerializationKeys.latitude].string
    userId = json[SerializationKeys.userId].int
    email = json[SerializationKeys.email].string
    longitude = json[SerializationKeys.longitude].string
    distance = json[SerializationKeys.distance].float
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = latitude { dictionary[SerializationKeys.latitude] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    if let value = email { dictionary[SerializationKeys.email] = value }
    if let value = longitude { dictionary[SerializationKeys.longitude] = value }
    if let value = distance { dictionary[SerializationKeys.distance] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.latitude = aDecoder.decodeObject(forKey: SerializationKeys.latitude) as? String
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? Int
    self.email = aDecoder.decodeObject(forKey: SerializationKeys.email) as? String
    self.longitude = aDecoder.decodeObject(forKey: SerializationKeys.longitude) as? String
    self.distance = aDecoder.decodeObject(forKey: SerializationKeys.distance) as? Float
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(latitude, forKey: SerializationKeys.latitude)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
    aCoder.encode(email, forKey: SerializationKeys.email)
    aCoder.encode(longitude, forKey: SerializationKeys.longitude)
    aCoder.encode(distance, forKey: SerializationKeys.distance)
  }

}
