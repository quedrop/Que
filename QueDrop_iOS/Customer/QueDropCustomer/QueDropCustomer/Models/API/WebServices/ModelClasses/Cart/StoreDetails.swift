//
//  StoreDetails.swift
//
//  Created by C100-104 on 25/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class StoreDetails: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kStoreDetailsLatitudeKey: String = "latitude"
  private let kStoreDetailsStoreLogoKey: String = "store_logo"
  private let kStoreDetailsStoreAddressKey: String = "store_address"
  private let kStoreDetailsIsActiveKey: String = "is_active"
  private let kStoreDetailsStoreOfferKey: String = "store_offer"
  private let kStoreDetailsCanProvideServiceKey: String = "can_provide_service"
  private let kStoreDetailsStoreTotalAmountKey: String = "store_total_amount"
  private let kStoreDetailsStoreIdKey: String = "store_id"
  private let kStoreDetailScheduleKey: String = "schedule"
  private let kStoreDetailsLongitudeKey: String = "longitude"
  private let kStoreDetailsStoreNameKey: String = "store_name"
  private let kStoreDetailsUserStoreIdKey: String = "user_store_id"

  // MARK: Properties
  public var latitude: String?
  public var storeLogo: String?
  public var storeAddress: String?
  public var isActive: Int?
  public var storeOffer: CartStoreOffer?
  public var canProvideService: Int?
  public var storeTotalAmount: Float?
  public var storeId: Int?
  public var schedule: [Schedule]?
  public var longitude: String?
  public var storeName: String?
  public var userStoreId: Int?

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
    latitude = json[kStoreDetailsLatitudeKey].string
    storeLogo = json[kStoreDetailsStoreLogoKey].string
    storeAddress = json[kStoreDetailsStoreAddressKey].string
    isActive = json[kStoreDetailsIsActiveKey].int
    storeOffer = CartStoreOffer(json: json[kStoreDetailsStoreOfferKey])
    canProvideService = json[kStoreDetailsCanProvideServiceKey].int
    storeTotalAmount = json[kStoreDetailsStoreTotalAmountKey].float
    storeId = json[kStoreDetailsStoreIdKey].int
    if let items = json[kStoreDetailScheduleKey].array { schedule = items.map { Schedule(json: $0) } }
    longitude = json[kStoreDetailsLongitudeKey].string
    storeName = json[kStoreDetailsStoreNameKey].string
    userStoreId = json[kStoreDetailsUserStoreIdKey].int
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = latitude { dictionary[kStoreDetailsLatitudeKey] = value }
    if let value = storeLogo { dictionary[kStoreDetailsStoreLogoKey] = value }
    if let value = storeAddress { dictionary[kStoreDetailsStoreAddressKey] = value }
    if let value = isActive { dictionary[kStoreDetailsIsActiveKey] = value }
    if let value = storeOffer { dictionary[kStoreDetailsStoreOfferKey] = value.dictionaryRepresentation() }
    if let value = canProvideService { dictionary[kStoreDetailsCanProvideServiceKey] = value }
    if let value = storeTotalAmount { dictionary[kStoreDetailsStoreTotalAmountKey] = value }
    if let value = storeId { dictionary[kStoreDetailsStoreIdKey] = value }
    if let value = schedule { dictionary[kStoreDetailScheduleKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = longitude { dictionary[kStoreDetailsLongitudeKey] = value }
    if let value = storeName { dictionary[kStoreDetailsStoreNameKey] = value }
    if let value = userStoreId { dictionary[kStoreDetailsUserStoreIdKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.latitude = aDecoder.decodeObject(forKey: kStoreDetailsLatitudeKey) as? String
    self.storeLogo = aDecoder.decodeObject(forKey: kStoreDetailsStoreLogoKey) as? String
    self.storeAddress = aDecoder.decodeObject(forKey: kStoreDetailsStoreAddressKey) as? String
    self.isActive = aDecoder.decodeObject(forKey: kStoreDetailsIsActiveKey) as? Int
    self.storeOffer = aDecoder.decodeObject(forKey: kStoreDetailsStoreOfferKey) as? CartStoreOffer
    self.canProvideService = aDecoder.decodeObject(forKey: kStoreDetailsCanProvideServiceKey) as? Int
    self.storeTotalAmount = aDecoder.decodeObject(forKey: kStoreDetailsStoreTotalAmountKey) as? Float
    self.storeId = aDecoder.decodeObject(forKey: kStoreDetailsStoreIdKey) as? Int
    self.schedule = aDecoder.decodeObject(forKey: kStoreDetailScheduleKey) as? [Schedule]
    self.longitude = aDecoder.decodeObject(forKey: kStoreDetailsLongitudeKey) as? String
    self.storeName = aDecoder.decodeObject(forKey: kStoreDetailsStoreNameKey) as? String
    self.userStoreId = aDecoder.decodeObject(forKey: kStoreDetailsUserStoreIdKey) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(latitude, forKey: kStoreDetailsLatitudeKey)
    aCoder.encode(storeLogo, forKey: kStoreDetailsStoreLogoKey)
    aCoder.encode(storeAddress, forKey: kStoreDetailsStoreAddressKey)
    aCoder.encode(isActive, forKey: kStoreDetailsIsActiveKey)
    aCoder.encode(storeOffer, forKey: kStoreDetailsStoreOfferKey)
    aCoder.encode(canProvideService, forKey: kStoreDetailsCanProvideServiceKey)
    aCoder.encode(storeTotalAmount, forKey: kStoreDetailsStoreTotalAmountKey)
    aCoder.encode(storeId, forKey: kStoreDetailsStoreIdKey)
    aCoder.encode(schedule, forKey: kStoreDetailScheduleKey)
    aCoder.encode(longitude, forKey: kStoreDetailsLongitudeKey)
    aCoder.encode(storeName, forKey: kStoreDetailsStoreNameKey)
    aCoder.encode(userStoreId, forKey: kStoreDetailsUserStoreIdKey)
  }

}
