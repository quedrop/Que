//
//  CustomerDetail.swift
//
//  Created by C100-105 on 03/04/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class CustomerDetail: NSObject, NSCoding, JSONable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kCustomerDetailLatitudeKey: String = "latitude"
    private let kCustomerDetailLastNameKey: String = "last_name"
    private let kCustomerDetailEmailKey: String = "email"
    private let kCustomerDetailCountryCodeKey: String = "country_code"
    private let kCustomerDetailFirstNameKey: String = "first_name"
    private let kCustomerDetailAddressKey: String = "address"
    private let kCustomerDetailPhoneNumberKey: String = "phone_number"
    private let kCustomerDetailRatingKey: String = "rating"
    private let kCustomerDetailLongitudeKey: String = "longitude"
    private let kCustomerDetailUserIdKey: String = "user_id"
    private let kCustomerDetailUserImageKey: String = "user_image"
    
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
        latitude = json[kCustomerDetailLatitudeKey].string
        lastName = json[kCustomerDetailLastNameKey].string
        email = json[kCustomerDetailEmailKey].string
        countryCode = json[kCustomerDetailCountryCodeKey].int
        firstName = json[kCustomerDetailFirstNameKey].string
        address = json[kCustomerDetailAddressKey].string
        phoneNumber = json[kCustomerDetailPhoneNumberKey].string
        rating = json[kCustomerDetailRatingKey].float
        longitude = json[kCustomerDetailLongitudeKey].string
        userId = json[kCustomerDetailUserIdKey].int
        userImage = json[kCustomerDetailUserImageKey].string
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = latitude { dictionary[kCustomerDetailLatitudeKey] = value }
        if let value = lastName { dictionary[kCustomerDetailLastNameKey] = value }
        if let value = email { dictionary[kCustomerDetailEmailKey] = value }
        if let value = countryCode { dictionary[kCustomerDetailCountryCodeKey] = value }
        if let value = firstName { dictionary[kCustomerDetailFirstNameKey] = value }
        if let value = address { dictionary[kCustomerDetailAddressKey] = value }
        if let value = phoneNumber { dictionary[kCustomerDetailPhoneNumberKey] = value }
        if let value = rating { dictionary[kCustomerDetailRatingKey] = value }
        if let value = longitude { dictionary[kCustomerDetailLongitudeKey] = value }
        if let value = userId { dictionary[kCustomerDetailUserIdKey] = value }
        if let value = userImage { dictionary[kCustomerDetailUserImageKey] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.latitude = aDecoder.decodeObject(forKey: kCustomerDetailLatitudeKey) as? String
        self.lastName = aDecoder.decodeObject(forKey: kCustomerDetailLastNameKey) as? String
        self.email = aDecoder.decodeObject(forKey: kCustomerDetailEmailKey) as? String
        self.countryCode = aDecoder.decodeObject(forKey: kCustomerDetailCountryCodeKey) as? Int
        self.firstName = aDecoder.decodeObject(forKey: kCustomerDetailFirstNameKey) as? String
        self.address = aDecoder.decodeObject(forKey: kCustomerDetailAddressKey) as? String
        self.phoneNumber = aDecoder.decodeObject(forKey: kCustomerDetailPhoneNumberKey) as? String
        self.rating = aDecoder.decodeObject(forKey: kCustomerDetailRatingKey) as? Float
        self.longitude = aDecoder.decodeObject(forKey: kCustomerDetailLongitudeKey) as? String
        self.userId = aDecoder.decodeObject(forKey: kCustomerDetailUserIdKey) as? Int
        self.userImage = aDecoder.decodeObject(forKey: kCustomerDetailUserImageKey) as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(latitude, forKey: kCustomerDetailLatitudeKey)
        aCoder.encode(lastName, forKey: kCustomerDetailLastNameKey)
        aCoder.encode(email, forKey: kCustomerDetailEmailKey)
        aCoder.encode(countryCode, forKey: kCustomerDetailCountryCodeKey)
        aCoder.encode(firstName, forKey: kCustomerDetailFirstNameKey)
        aCoder.encode(address, forKey: kCustomerDetailAddressKey)
        aCoder.encode(phoneNumber, forKey: kCustomerDetailPhoneNumberKey)
        aCoder.encode(rating, forKey: kCustomerDetailRatingKey)
        aCoder.encode(longitude, forKey: kCustomerDetailLongitudeKey)
        aCoder.encode(userId, forKey: kCustomerDetailUserIdKey)
        aCoder.encode(userImage, forKey: kCustomerDetailUserImageKey)
    }
    
}
