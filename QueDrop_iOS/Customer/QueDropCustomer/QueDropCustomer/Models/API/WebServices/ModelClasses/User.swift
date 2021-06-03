//
//  User.swift
//
//  Created by C100-104 on 28/01/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class User: NSObject, NSCoding, JSONable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kUserEmailKey: String = "email"
    private let kUserAddressKey: String = "address"
    private let kUserRefferalCodeKey: String = "refferal_code"
    private let kUserGuidKey: String = "guid"
    private let kUserLoginAsKey: String = "login_as"
    private let kUserPhoneNumberKey: String = "phone_number"
    private let kUserActiveStatusKey: String = "active_status"
    private let kUserLatitudeKey: String = "latitude"
    private let kUserIsDriverVerifiedKey: String = "is_driver_verified"
    private let kUserLastNameKey: String = "last_name"
    private let kUserIsGuestKey: String = "is_guest"
    private let kUserCountryCodeKey: String = "country_code"
    private let kUserSocialKeyKey: String = "social_key"
    private let kUserDeviceTokenKey: String = "device_token"
    private let kUserIsPhoneVerifiedKey: String = "is_phone_verified"
    private let kUserOffsetKey: String = "offset"
    private let kUserLoginTypeKey: String = "login_type"
    private let kUserPasswordKey: String = "password"
    private let kUserUserImageKey: String = "user_image"
    private let kUserUserIdKey: String = "user_id"
    private let kUserGuestUserIdKey: String = "guest_user_id"
    private let kUserLongitudeKey: String = "longitude"
    private let kUserFirstNameKey: String = "first_name"
    private let kUserUserNameKey: String = "user_name"
    private let kUserStoreIdKey: String = "store_id"
    private let kUserRatingsKey: String = "rating"
    
    // MARK: Properties
    public var email: String?
    public var address: String?
    public var refferalCode: String?
    public var guid: String?
    public var loginAs: String?
    public var phoneNumber: String?
    public var activeStatus: Int?
    public var latitude: String?
    public var isDriverVerified: Int?
    public var lastName: String?
    public var isGuest: Int?
    public var countryCode: Int?
    public var socialKey: String?
    public var deviceToken: String?
    public var isPhoneVerified: Int?
    public var offset: String?
    public var loginType: String?
    public var password: String?
    public var userImage: String?
    public var userId: Int?
    public var guestUserId: Int?
    public var longitude: String?
    public var firstName: String?
    public var userName: String?
    public var storeId: Int?
    public var rating: Float?
    
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
        email = json[kUserEmailKey].string
        address = json[kUserAddressKey].string
        refferalCode = json[kUserRefferalCodeKey].string
        guid = json[kUserGuidKey].string
        loginAs = json[kUserLoginAsKey].string
        phoneNumber = json[kUserPhoneNumberKey].string
        activeStatus = json[kUserActiveStatusKey].int
        latitude = json[kUserLatitudeKey].string
        isDriverVerified = json[kUserIsDriverVerifiedKey].int
        lastName = json[kUserLastNameKey].string
        isGuest = json[kUserIsGuestKey].int
        countryCode = json[kUserCountryCodeKey].int
        socialKey = json[kUserSocialKeyKey].string
        deviceToken = json[kUserDeviceTokenKey].string
        isPhoneVerified = json[kUserIsPhoneVerifiedKey].int
        offset = json[kUserOffsetKey].string
        loginType = json[kUserLoginTypeKey].string
        password = json[kUserPasswordKey].string
        userImage = json[kUserUserImageKey].string
        userId = json[kUserUserIdKey].int
        guestUserId = json[kUserGuestUserIdKey].int
        longitude = json[kUserLongitudeKey].string
        firstName = json[kUserFirstNameKey].string
        userName = json[kUserUserNameKey].string
        storeId = json[kUserStoreIdKey].int
        rating = json[kUserRatingsKey].float
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = email { dictionary[kUserEmailKey] = value }
        if let value = address { dictionary[kUserAddressKey] = value }
        if let value = refferalCode { dictionary[kUserRefferalCodeKey] = value }
        if let value = guid { dictionary[kUserGuidKey] = value }
        if let value = loginAs { dictionary[kUserLoginAsKey] = value }
        if let value = phoneNumber { dictionary[kUserPhoneNumberKey] = value }
        if let value = activeStatus { dictionary[kUserActiveStatusKey] = value }
        if let value = latitude { dictionary[kUserLatitudeKey] = value }
        if let value = isDriverVerified { dictionary[kUserIsDriverVerifiedKey] = value }
        if let value = lastName { dictionary[kUserLastNameKey] = value }
        if let value = isGuest { dictionary[kUserIsGuestKey] = value }
        if let value = countryCode { dictionary[kUserCountryCodeKey] = value }
        if let value = socialKey { dictionary[kUserSocialKeyKey] = value }
        if let value = deviceToken { dictionary[kUserDeviceTokenKey] = value }
        if let value = isPhoneVerified { dictionary[kUserIsPhoneVerifiedKey] = value }
        if let value = offset { dictionary[kUserOffsetKey] = value }
        if let value = loginType { dictionary[kUserLoginTypeKey] = value }
        if let value = password { dictionary[kUserPasswordKey] = value }
        if let value = userImage { dictionary[kUserUserImageKey] = value }
        if let value = userId { dictionary[kUserUserIdKey] = value }
        if let value = guestUserId { dictionary[kUserGuestUserIdKey] = value }
        if let value = longitude { dictionary[kUserLongitudeKey] = value }
        if let value = firstName { dictionary[kUserFirstNameKey] = value }
        if let value = userName { dictionary[kUserUserNameKey] = value }
        if let value = storeId { dictionary[kUserStoreIdKey] = value }
        if let value = rating { dictionary[kUserRatingsKey] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.email = aDecoder.decodeObject(forKey: kUserEmailKey) as? String
        self.address = aDecoder.decodeObject(forKey: kUserAddressKey) as? String
        self.refferalCode = aDecoder.decodeObject(forKey: kUserRefferalCodeKey) as? String
        self.guid = aDecoder.decodeObject(forKey: kUserGuidKey) as? String
        self.loginAs = aDecoder.decodeObject(forKey: kUserLoginAsKey) as? String
        self.phoneNumber = aDecoder.decodeObject(forKey: kUserPhoneNumberKey) as? String
        self.activeStatus = aDecoder.decodeObject(forKey: kUserActiveStatusKey) as? Int
        self.latitude = aDecoder.decodeObject(forKey: kUserLatitudeKey) as? String
        self.isDriverVerified = aDecoder.decodeObject(forKey: kUserIsDriverVerifiedKey) as? Int
        self.lastName = aDecoder.decodeObject(forKey: kUserLastNameKey) as? String
        self.isGuest = aDecoder.decodeObject(forKey: kUserIsGuestKey) as? Int
        self.countryCode = aDecoder.decodeObject(forKey: kUserCountryCodeKey) as? Int
        self.socialKey = aDecoder.decodeObject(forKey: kUserSocialKeyKey) as? String
        self.deviceToken = aDecoder.decodeObject(forKey: kUserDeviceTokenKey) as? String
        self.isPhoneVerified = aDecoder.decodeObject(forKey: kUserIsPhoneVerifiedKey) as? Int
        self.offset = aDecoder.decodeObject(forKey: kUserOffsetKey) as? String
        self.loginType = aDecoder.decodeObject(forKey: kUserLoginTypeKey) as? String
        self.password = aDecoder.decodeObject(forKey: kUserPasswordKey) as? String
        self.userImage = aDecoder.decodeObject(forKey: kUserUserImageKey) as? String
        self.userId = aDecoder.decodeObject(forKey: kUserUserIdKey) as? Int
        self.guestUserId = aDecoder.decodeObject(forKey: kUserGuestUserIdKey) as? Int
        self.longitude = aDecoder.decodeObject(forKey: kUserLongitudeKey) as? String
        self.firstName = aDecoder.decodeObject(forKey: kUserFirstNameKey) as? String
        self.userName = aDecoder.decodeObject(forKey: kUserUserNameKey) as? String
        self.storeId = aDecoder.decodeObject(forKey: kUserStoreIdKey) as? Int
        self.rating = aDecoder.decodeObject(forKey: kUserRatingsKey) as? Float
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(email, forKey: kUserEmailKey)
        aCoder.encode(address, forKey: kUserAddressKey)
        aCoder.encode(refferalCode, forKey: kUserRefferalCodeKey)
        aCoder.encode(guid, forKey: kUserGuidKey)
        aCoder.encode(loginAs, forKey: kUserLoginAsKey)
        aCoder.encode(phoneNumber, forKey: kUserPhoneNumberKey)
        aCoder.encode(activeStatus, forKey: kUserActiveStatusKey)
        aCoder.encode(latitude, forKey: kUserLatitudeKey)
        aCoder.encode(isDriverVerified, forKey: kUserIsDriverVerifiedKey)
        aCoder.encode(lastName, forKey: kUserLastNameKey)
        aCoder.encode(isGuest, forKey: kUserIsGuestKey)
        aCoder.encode(countryCode, forKey: kUserCountryCodeKey)
        aCoder.encode(socialKey, forKey: kUserSocialKeyKey)
        aCoder.encode(deviceToken, forKey: kUserDeviceTokenKey)
        aCoder.encode(isPhoneVerified, forKey: kUserIsPhoneVerifiedKey)
        aCoder.encode(offset, forKey: kUserOffsetKey)
        aCoder.encode(loginType, forKey: kUserLoginTypeKey)
        aCoder.encode(password, forKey: kUserPasswordKey)
        aCoder.encode(userImage, forKey: kUserUserImageKey)
        aCoder.encode(userId, forKey: kUserUserIdKey)
        aCoder.encode(guestUserId, forKey: kUserGuestUserIdKey)
        aCoder.encode(longitude, forKey: kUserLongitudeKey)
        aCoder.encode(firstName, forKey: kUserFirstNameKey)
        aCoder.encode(userName, forKey: kUserUserNameKey)
        aCoder.encode(storeId, forKey: kUserStoreIdKey)
        aCoder.encode(rating, forKey: kUserRatingsKey)
    }
    
}
