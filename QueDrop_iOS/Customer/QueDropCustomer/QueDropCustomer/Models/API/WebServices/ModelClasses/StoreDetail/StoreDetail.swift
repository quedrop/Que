//
//  StoreDetail.swift
//
//  Created by C100-104 on 08/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class StoreDetail: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kStoreDetailFoodCategoryKey: String = "food_category"
  private let kStoreDetailIsActiveKey: String = "is_active"
  private let kStoreDetailSliderImagesKey: String = "slider_images"
  private let kStoreDetailServiceCategoryIdKey: String = "service_category_id"
  private let kStoreDetailLatitudeKey: String = "latitude"
  private let kStoreDetailStoreLogoKey: String = "store_logo"
  private let kStoreDetailStoreAddressKey: String = "store_address"
  private let kStoreDetailCanProvideServiceKey: String = "can_provide_service"
  private let kStoreDetailStoreIdKey: String = "store_id"
  private let kStoreDetailIsFavouriteKey: String = "is_favourite"
  private let kStoreDetailUserIdKey: String = "user_id"
  private let kStoresUserStoreIdKey: String = "user_store_id"
  private let kStoreDetailLongitudeKey: String = "longitude"
  private let kStoreDetailScheduleKey: String = "schedule"
  private let kStoreDetailStoreNameKey: String = "store_name"
  private let kStoreDetailStoreRatingKey: String = "store_rating"
  private let kStoreDetailServiceCategoryNameKey: String = "service_category_name"
    
  // MARK: Properties
  public var foodCategory: [FoodCategory]?
  public var isActive: Int?
  public var sliderImages: [SliderImages]?
  public var serviceCategoryId: Int?
  public var latitude: String?
  public var storeLogo: String?
  public var storeAddress: String?
  public var canProvideService: Int?
  public var storeId: Int?
  public var userStoreId: Int?
  public var isFavourite: Bool = false
  public var userId: Int?
  public var longitude: String?
  public var schedule: [Schedule]?
  public var storeName: String?
  public var storeRating: Float?
  public var serviceCategoryName: String?
    
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
    if let items = json[kStoreDetailFoodCategoryKey].array { foodCategory = items.map { FoodCategory(json: $0) } }
    isActive = json[kStoreDetailIsActiveKey].int
    if let items = json[kStoreDetailSliderImagesKey].array { sliderImages = items.map { SliderImages(json: $0) } }
    serviceCategoryId = json[kStoreDetailServiceCategoryIdKey].int
    latitude = json[kStoreDetailLatitudeKey].string
    storeLogo = json[kStoreDetailStoreLogoKey].string
    storeAddress = json[kStoreDetailStoreAddressKey].string
    canProvideService = json[kStoreDetailCanProvideServiceKey].int
    storeId = json[kStoreDetailStoreIdKey].int
	userStoreId = json[kStoresUserStoreIdKey].int
    isFavourite = json[kStoreDetailIsFavouriteKey].boolValue
    userId = json[kStoreDetailUserIdKey].int
    longitude = json[kStoreDetailLongitudeKey].string
    if let items = json[kStoreDetailScheduleKey].array { schedule = items.map { Schedule(json: $0) } }
    storeName = json[kStoreDetailStoreNameKey].string
    storeRating = json[kStoreDetailStoreRatingKey].float
    serviceCategoryName = json[kStoreDetailServiceCategoryNameKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = foodCategory { dictionary[kStoreDetailFoodCategoryKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = isActive { dictionary[kStoreDetailIsActiveKey] = value }
    if let value = sliderImages { dictionary[kStoreDetailSliderImagesKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = serviceCategoryId { dictionary[kStoreDetailServiceCategoryIdKey] = value }
    if let value = latitude { dictionary[kStoreDetailLatitudeKey] = value }
    if let value = storeLogo { dictionary[kStoreDetailStoreLogoKey] = value }
    if let value = storeAddress { dictionary[kStoreDetailStoreAddressKey] = value }
    if let value = canProvideService { dictionary[kStoreDetailCanProvideServiceKey] = value }
    if let value = storeId { dictionary[kStoreDetailStoreIdKey] = value }
	if let value = userStoreId { dictionary[kStoresUserStoreIdKey] = value }
    dictionary[kStoreDetailIsFavouriteKey] = isFavourite
    if let value = userId { dictionary[kStoreDetailUserIdKey] = value }
    if let value = longitude { dictionary[kStoreDetailLongitudeKey] = value }
    if let value = schedule { dictionary[kStoreDetailScheduleKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = storeName { dictionary[kStoreDetailStoreNameKey] = value }
    if let value = storeRating { dictionary[kStoreDetailStoreRatingKey] = value }
    if let value = serviceCategoryName { dictionary[kStoreDetailServiceCategoryNameKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.foodCategory = aDecoder.decodeObject(forKey: kStoreDetailFoodCategoryKey) as? [FoodCategory]
    self.isActive = aDecoder.decodeObject(forKey: kStoreDetailIsActiveKey) as? Int
    self.sliderImages = aDecoder.decodeObject(forKey: kStoreDetailSliderImagesKey) as? [SliderImages]
    self.serviceCategoryId = aDecoder.decodeObject(forKey: kStoreDetailServiceCategoryIdKey) as? Int
    self.latitude = aDecoder.decodeObject(forKey: kStoreDetailLatitudeKey) as? String
    self.storeLogo = aDecoder.decodeObject(forKey: kStoreDetailStoreLogoKey) as? String
    self.storeAddress = aDecoder.decodeObject(forKey: kStoreDetailStoreAddressKey) as? String
    self.canProvideService = aDecoder.decodeObject(forKey: kStoreDetailCanProvideServiceKey) as? Int
    self.storeId = aDecoder.decodeObject(forKey: kStoreDetailStoreIdKey) as? Int
    self.isFavourite = aDecoder.decodeBool(forKey: kStoreDetailIsFavouriteKey)
    self.userId = aDecoder.decodeObject(forKey: kStoreDetailUserIdKey) as? Int
	self.userStoreId = aDecoder.decodeObject(forKey: kStoresUserStoreIdKey) as? Int
    self.longitude = aDecoder.decodeObject(forKey: kStoreDetailLongitudeKey) as? String
    self.schedule = aDecoder.decodeObject(forKey: kStoreDetailScheduleKey) as? [Schedule]
    self.storeName = aDecoder.decodeObject(forKey: kStoreDetailStoreNameKey) as? String
    self.storeRating = aDecoder.decodeObject(forKey: kStoreDetailStoreRatingKey) as? Float
    self.serviceCategoryName = aDecoder.decodeObject(forKey: kStoreDetailServiceCategoryNameKey) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(foodCategory, forKey: kStoreDetailFoodCategoryKey)
    aCoder.encode(isActive, forKey: kStoreDetailIsActiveKey)
    aCoder.encode(sliderImages, forKey: kStoreDetailSliderImagesKey)
    aCoder.encode(serviceCategoryId, forKey: kStoreDetailServiceCategoryIdKey)
    aCoder.encode(latitude, forKey: kStoreDetailLatitudeKey)
    aCoder.encode(storeLogo, forKey: kStoreDetailStoreLogoKey)
    aCoder.encode(storeAddress, forKey: kStoreDetailStoreAddressKey)
    aCoder.encode(canProvideService, forKey: kStoreDetailCanProvideServiceKey)
    aCoder.encode(storeId, forKey: kStoreDetailStoreIdKey)
    aCoder.encode(isFavourite, forKey: kStoreDetailIsFavouriteKey)
    aCoder.encode(userId, forKey: kStoreDetailUserIdKey)
	aCoder.encode(userStoreId, forKey: kStoresUserStoreIdKey)
    aCoder.encode(longitude, forKey: kStoreDetailLongitudeKey)
    aCoder.encode(schedule, forKey: kStoreDetailScheduleKey)
    aCoder.encode(storeName, forKey: kStoreDetailStoreNameKey)
    aCoder.encode(storeRating, forKey: kStoreDetailStoreRatingKey)
    aCoder.encode(serviceCategoryName, forKey: kStoreDetailServiceCategoryNameKey)
  }

}
