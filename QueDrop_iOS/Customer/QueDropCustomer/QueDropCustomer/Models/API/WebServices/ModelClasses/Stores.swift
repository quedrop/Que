//
//  Stores.swift
//
//  Created by C100-104 on 03/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class Store:  NSObject, NSCoding,JSONable  {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kStoresLatitudeKey: String = "latitude"
  private let kStoresStoreLogoKey: String = "store_logo"
  private let kStoresStoreAddressKey: String = "store_address"
  private let kStoresIsActiveKey: String = "is_active"
  private let kStoresStoreIdKey: String = "store_id"
  private let kStoresCanProvideServiceKey: String = "can_provide_service"
  private let kStoresUserIdKey: String = "user_id"
  private let kStoresLongitudeKey: String = "longitude"
  private let kStoresServiceCategoryIdKey: String = "service_category_id"
  private let kStoreDetailScheduleKey: String = "schedule"
  private let kStoresStoreNameKey: String = "store_name"

  // MARK: Properties
  public var latitude: String?
  public var storeLogo: String?
  public var storeAddress: String?
  public var isActive: Int?
  public var storeId: Int?
  public var canProvideService: Int?
  public var userId: Int?
  public var longitude: String?
  public var serviceCategoryId: Int?
  public var schedule: [Schedule]?
  public var storeName: String?

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
    latitude = json[kStoresLatitudeKey].string
    storeLogo = json[kStoresStoreLogoKey].string
    storeAddress = json[kStoresStoreAddressKey].string
    isActive = json[kStoresIsActiveKey].int
    storeId = json[kStoresStoreIdKey].int
    canProvideService = json[kStoresCanProvideServiceKey].int
    userId = json[kStoresUserIdKey].int
    longitude = json[kStoresLongitudeKey].string
    serviceCategoryId = json[kStoresServiceCategoryIdKey].int
    if let items = json[kStoreDetailScheduleKey].array { schedule = items.map { Schedule(json: $0) } }
    storeName = json[kStoresStoreNameKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = latitude { dictionary[kStoresLatitudeKey] = value }
    if let value = storeLogo { dictionary[kStoresStoreLogoKey] = value }
    if let value = storeAddress { dictionary[kStoresStoreAddressKey] = value }
    if let value = isActive { dictionary[kStoresIsActiveKey] = value }
    if let value = storeId { dictionary[kStoresStoreIdKey] = value }
    if let value = canProvideService { dictionary[kStoresCanProvideServiceKey] = value }
    if let value = userId { dictionary[kStoresUserIdKey] = value }
    if let value = longitude { dictionary[kStoresLongitudeKey] = value }
    if let value = serviceCategoryId { dictionary[kStoresServiceCategoryIdKey] = value }
    if let value = schedule { dictionary[kStoreDetailScheduleKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = storeName { dictionary[kStoresStoreNameKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.latitude = aDecoder.decodeObject(forKey: kStoresLatitudeKey) as? String
    self.storeLogo = aDecoder.decodeObject(forKey: kStoresStoreLogoKey) as? String
    self.storeAddress = aDecoder.decodeObject(forKey: kStoresStoreAddressKey) as? String
    self.isActive = aDecoder.decodeObject(forKey: kStoresIsActiveKey) as? Int
    self.storeId = aDecoder.decodeObject(forKey: kStoresStoreIdKey) as? Int
    self.canProvideService = aDecoder.decodeObject(forKey: kStoresCanProvideServiceKey) as? Int
    self.userId = aDecoder.decodeObject(forKey: kStoresUserIdKey) as? Int
    self.longitude = aDecoder.decodeObject(forKey: kStoresLongitudeKey) as? String
    self.serviceCategoryId = aDecoder.decodeObject(forKey: kStoresServiceCategoryIdKey) as? Int
    self.schedule = aDecoder.decodeObject(forKey: kStoreDetailScheduleKey) as? [Schedule]
    self.storeName = aDecoder.decodeObject(forKey: kStoresStoreNameKey) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(latitude, forKey: kStoresLatitudeKey)
    aCoder.encode(storeLogo, forKey: kStoresStoreLogoKey)
    aCoder.encode(storeAddress, forKey: kStoresStoreAddressKey)
    aCoder.encode(isActive, forKey: kStoresIsActiveKey)
    aCoder.encode(storeId, forKey: kStoresStoreIdKey)
    aCoder.encode(canProvideService, forKey: kStoresCanProvideServiceKey)
    aCoder.encode(userId, forKey: kStoresUserIdKey)
    aCoder.encode(longitude, forKey: kStoresLongitudeKey)
    aCoder.encode(serviceCategoryId, forKey: kStoresServiceCategoryIdKey)
    aCoder.encode(schedule, forKey: kStoreDetailScheduleKey)
    aCoder.encode(storeName, forKey: kStoresStoreNameKey)
  }
}
