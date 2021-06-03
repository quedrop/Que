//
//  Address.swift
//
//  Created by C100-104 on 29/01/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class Address: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kAddressLatitudeKey: String = "latitude"
  private let kAddressIsDefaultAddressKey: String = "is_default_address"
  private let kAddressAddressTypeKey: String = "address_type"
  private let kAddressAddressKey: String = "address"
  private let kAddressAddressTitleKey: String = "address_title"
  private let kAddressUnitNumberKey: String = "unit_number"
  private let kAddressAdditionalInfoKey: String = "additional_info"
  private let kAddressUserIdKey: String = "user_id"
  private let kAddressLongitudeKey: String = "longitude"
  private let kAddressAddressIdKey: String = "address_id"

  // MARK: Properties
  public var latitude: String?
  public var isDefaultAddress: Int?
  public var addressType: String?
  public var address: String?
  public var addressTitle: String?
	public var unitNumber: String?
  public var additionalInfo: String?
  public var userId: Int?
  public var longitude: String?
  public var addressId: Int?

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
    latitude = json[kAddressLatitudeKey].string
    isDefaultAddress = json[kAddressIsDefaultAddressKey].int
    addressType = json[kAddressAddressTypeKey].string
	unitNumber = json[kAddressUnitNumberKey].string
    address = json[kAddressAddressKey].string
    addressTitle = json[kAddressAddressTitleKey].string
    additionalInfo = json[kAddressAdditionalInfoKey].string
    userId = json[kAddressUserIdKey].int
    longitude = json[kAddressLongitudeKey].string
    addressId = json[kAddressAddressIdKey].int
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = latitude { dictionary[kAddressLatitudeKey] = value }
    if let value = isDefaultAddress { dictionary[kAddressIsDefaultAddressKey] = value }
    if let value = addressType { dictionary[kAddressAddressTypeKey] = value }
    if let value = address { dictionary[kAddressAddressKey] = value }
    if let value = addressTitle { dictionary[kAddressAddressTitleKey] = value }
	if let value = unitNumber { dictionary[kAddressUnitNumberKey] = value }
    if let value = additionalInfo { dictionary[kAddressAdditionalInfoKey] = value }
    if let value = userId { dictionary[kAddressUserIdKey] = value }
    if let value = longitude { dictionary[kAddressLongitudeKey] = value }
    if let value = addressId { dictionary[kAddressAddressIdKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.latitude = aDecoder.decodeObject(forKey: kAddressLatitudeKey) as? String
    self.isDefaultAddress = aDecoder.decodeObject(forKey: kAddressIsDefaultAddressKey) as? Int
    self.addressType = aDecoder.decodeObject(forKey: kAddressAddressTypeKey) as? String
    self.address = aDecoder.decodeObject(forKey: kAddressAddressKey) as? String
    self.addressTitle = aDecoder.decodeObject(forKey: kAddressAddressTitleKey) as? String
	self.unitNumber = aDecoder.decodeObject(forKey: kAddressUnitNumberKey) as? String
    self.additionalInfo = aDecoder.decodeObject(forKey: kAddressAdditionalInfoKey) as? String
    self.userId = aDecoder.decodeObject(forKey: kAddressUserIdKey) as? Int
    self.longitude = aDecoder.decodeObject(forKey: kAddressLongitudeKey) as? String
    self.addressId = aDecoder.decodeObject(forKey: kAddressAddressIdKey) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(latitude, forKey: kAddressLatitudeKey)
    aCoder.encode(isDefaultAddress, forKey: kAddressIsDefaultAddressKey)
    aCoder.encode(addressType, forKey: kAddressAddressTypeKey)
    aCoder.encode(address, forKey: kAddressAddressKey)
    aCoder.encode(addressTitle, forKey: kAddressAddressTitleKey)
	aCoder.encode(unitNumber, forKey: kAddressUnitNumberKey)
    aCoder.encode(additionalInfo, forKey: kAddressAdditionalInfoKey)
    aCoder.encode(userId, forKey: kAddressUserIdKey)
    aCoder.encode(longitude, forKey: kAddressLongitudeKey)
    aCoder.encode(addressId, forKey: kAddressAddressIdKey)
  }

}
