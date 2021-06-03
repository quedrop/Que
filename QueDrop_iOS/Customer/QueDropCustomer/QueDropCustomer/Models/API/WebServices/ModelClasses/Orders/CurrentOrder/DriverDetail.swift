//
//  DriverDetail.swift
//
//  Created by C100-104 on 31/03/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class DriverDetail: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kDriverDetailLatitudeKey: String = "latitude"
  private let kDriverDetailLastNameKey: String = "last_name"
  private let kDriverDetailEmailKey: String = "email"
  private let kDriverDetailCountryCodeKey: String = "country_code"
  private let kDriverDetailFirstNameKey: String = "first_name"
  private let kDriverDetailAddressKey: String = "address"
  private let kDriverDetailPhoneNumberKey: String = "phone_number"
  private let kDriverDetailRatingKey: String = "rating"
  private let kDriverDetailLongitudeKey: String = "longitude"
  private let kDriverDetailUserIdKey: String = "user_id"
  private let kDriverDetailUserImageKey: String = "user_image"

  // MARK: Properties
  public var latitude: String?
  public var lastName: String?
  public var email: String?
  public var countryCode: Int?
  public var firstName: String?
  public var address: String?
  public var phoneNumber: String?
  public var rating: Float?
  public var longitude: String?
  public var userId: Int?
  public var userImage: String?

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
    latitude = json[kDriverDetailLatitudeKey].string
    lastName = json[kDriverDetailLastNameKey].string
    email = json[kDriverDetailEmailKey].string
    countryCode = json[kDriverDetailCountryCodeKey].int
    firstName = json[kDriverDetailFirstNameKey].string
    address = json[kDriverDetailAddressKey].string
    phoneNumber = json[kDriverDetailPhoneNumberKey].string
    rating = json[kDriverDetailRatingKey].float
    longitude = json[kDriverDetailLongitudeKey].string
    userId = json[kDriverDetailUserIdKey].int
    userImage = json[kDriverDetailUserImageKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = latitude { dictionary[kDriverDetailLatitudeKey] = value }
    if let value = lastName { dictionary[kDriverDetailLastNameKey] = value }
    if let value = email { dictionary[kDriverDetailEmailKey] = value }
    if let value = countryCode { dictionary[kDriverDetailCountryCodeKey] = value }
    if let value = firstName { dictionary[kDriverDetailFirstNameKey] = value }
    if let value = address { dictionary[kDriverDetailAddressKey] = value }
    if let value = phoneNumber { dictionary[kDriverDetailPhoneNumberKey] = value }
    if let value = rating { dictionary[kDriverDetailRatingKey] = value }
    if let value = longitude { dictionary[kDriverDetailLongitudeKey] = value }
    if let value = userId { dictionary[kDriverDetailUserIdKey] = value }
    if let value = userImage { dictionary[kDriverDetailUserImageKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.latitude = aDecoder.decodeObject(forKey: kDriverDetailLatitudeKey) as? String
    self.lastName = aDecoder.decodeObject(forKey: kDriverDetailLastNameKey) as? String
    self.email = aDecoder.decodeObject(forKey: kDriverDetailEmailKey) as? String
    self.countryCode = aDecoder.decodeObject(forKey: kDriverDetailCountryCodeKey) as? Int
    self.firstName = aDecoder.decodeObject(forKey: kDriverDetailFirstNameKey) as? String
    self.address = aDecoder.decodeObject(forKey: kDriverDetailAddressKey) as? String
    self.phoneNumber = aDecoder.decodeObject(forKey: kDriverDetailPhoneNumberKey) as? String
    self.rating = aDecoder.decodeObject(forKey: kDriverDetailRatingKey) as? Float
    self.longitude = aDecoder.decodeObject(forKey: kDriverDetailLongitudeKey) as? String
    self.userId = aDecoder.decodeObject(forKey: kDriverDetailUserIdKey) as? Int
    self.userImage = aDecoder.decodeObject(forKey: kDriverDetailUserImageKey) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(latitude, forKey: kDriverDetailLatitudeKey)
    aCoder.encode(lastName, forKey: kDriverDetailLastNameKey)
    aCoder.encode(email, forKey: kDriverDetailEmailKey)
    aCoder.encode(countryCode, forKey: kDriverDetailCountryCodeKey)
    aCoder.encode(firstName, forKey: kDriverDetailFirstNameKey)
    aCoder.encode(address, forKey: kDriverDetailAddressKey)
    aCoder.encode(phoneNumber, forKey: kDriverDetailPhoneNumberKey)
    aCoder.encode(rating, forKey: kDriverDetailRatingKey)
    aCoder.encode(longitude, forKey: kDriverDetailLongitudeKey)
    aCoder.encode(userId, forKey: kDriverDetailUserIdKey)
    aCoder.encode(userImage, forKey: kDriverDetailUserImageKey)
  }

}
