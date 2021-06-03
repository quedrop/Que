//
//  CustomerDetail.swift
//
//  Created by C100-174 on 24/03/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class CustomerDetail: NSObject, NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let latitude = "latitude"
    static let lastName = "last_name"
    static let email = "email"
    static let countryCode = "country_code"
    static let firstName = "first_name"
    static let address = "address"
    static let phoneNumber = "phone_number"
    static let rating = "rating"
    static let longitude = "longitude"
    static let userId = "user_id"
    static let userImage = "user_image"
  }

  // MARK: Properties
  public var latitude: String?
  public var lastName: String?
  public var email: String?
  public var countryCode: Int?
  public var firstName: String?
  public var address: String?
  public var phoneNumber: String?
  public var rating: Int?
  public var longitude: String?
  public var userId: Int?
  public var userImage: String?

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
    lastName = json[SerializationKeys.lastName].string
    email = json[SerializationKeys.email].string
    countryCode = json[SerializationKeys.countryCode].int
    firstName = json[SerializationKeys.firstName].string
    address = json[SerializationKeys.address].string
    phoneNumber = json[SerializationKeys.phoneNumber].string
    rating = json[SerializationKeys.rating].int
    longitude = json[SerializationKeys.longitude].string
    userId = json[SerializationKeys.userId].int
    userImage = json[SerializationKeys.userImage].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = latitude { dictionary[SerializationKeys.latitude] = value }
    if let value = lastName { dictionary[SerializationKeys.lastName] = value }
    if let value = email { dictionary[SerializationKeys.email] = value }
    if let value = countryCode { dictionary[SerializationKeys.countryCode] = value }
    if let value = firstName { dictionary[SerializationKeys.firstName] = value }
    if let value = address { dictionary[SerializationKeys.address] = value }
    if let value = phoneNumber { dictionary[SerializationKeys.phoneNumber] = value }
    if let value = rating { dictionary[SerializationKeys.rating] = value }
    if let value = longitude { dictionary[SerializationKeys.longitude] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    if let value = userImage { dictionary[SerializationKeys.userImage] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.latitude = aDecoder.decodeObject(forKey: SerializationKeys.latitude) as? String
    self.lastName = aDecoder.decodeObject(forKey: SerializationKeys.lastName) as? String
    self.email = aDecoder.decodeObject(forKey: SerializationKeys.email) as? String
    self.countryCode = aDecoder.decodeObject(forKey: SerializationKeys.countryCode) as? Int
    self.firstName = aDecoder.decodeObject(forKey: SerializationKeys.firstName) as? String
    self.address = aDecoder.decodeObject(forKey: SerializationKeys.address) as? String
    self.phoneNumber = aDecoder.decodeObject(forKey: SerializationKeys.phoneNumber) as? String
    self.rating = aDecoder.decodeObject(forKey: SerializationKeys.rating) as? Int
    self.longitude = aDecoder.decodeObject(forKey: SerializationKeys.longitude) as? String
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? Int
    self.userImage = aDecoder.decodeObject(forKey: SerializationKeys.userImage) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(latitude, forKey: SerializationKeys.latitude)
    aCoder.encode(lastName, forKey: SerializationKeys.lastName)
    aCoder.encode(email, forKey: SerializationKeys.email)
    aCoder.encode(countryCode, forKey: SerializationKeys.countryCode)
    aCoder.encode(firstName, forKey: SerializationKeys.firstName)
    aCoder.encode(address, forKey: SerializationKeys.address)
    aCoder.encode(phoneNumber, forKey: SerializationKeys.phoneNumber)
    aCoder.encode(rating, forKey: SerializationKeys.rating)
    aCoder.encode(longitude, forKey: SerializationKeys.longitude)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
    aCoder.encode(userImage, forKey: SerializationKeys.userImage)
  }

}
