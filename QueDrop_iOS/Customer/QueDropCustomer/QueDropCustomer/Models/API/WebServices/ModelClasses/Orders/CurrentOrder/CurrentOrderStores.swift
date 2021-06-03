//
//  Stores.swift
//
//  Created by C100-104 on 27/03/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class CurrentOrderStores: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kStoresOrderAmountKey: String = "order_amount"
  private let kStoresOrderReceiptKey: String = "order_receipt"
  private let kStoresIsActiveKey: String = "is_active"
  private let kStoresProductsKey: String = "products"
  private let kStoresOrderStoreIdKey: String = "order_store_id"
  private let kStoresOfferPercentageKey: String = "offer_percentage"
  private let kStoresAdminOfferIdKey: String = "admin_offer_id"
  private let kStoresLatitudeKey: String = "latitude"
  private let kStoresStoreLogoKey: String = "store_logo"
  private let kStoresUserStoreIdKey: String = "user_store_id"
  private let kStoresStoreAddressKey: String = "store_address"
  private let kStoresCanProvideServiceKey: String = "can_provide_service"
  private let kStoresStoreIdKey: String = "store_id"
  private let kStoresLongitudeKey: String = "longitude"
  private let kStoresStoreNameKey: String = "store_name"

  // MARK: Properties
  public var orderAmount: Int?
  public var orderReceipt: String?
  public var isActive: Int?
  public var products: [CurrentOrderProducts]?
  public var orderStoreId: Int?
  public var offerPercentage: Int?
  public var adminOfferId: Int?
  public var latitude: String?
  public var storeLogo: String?
  public var userStoreId: Int?
  public var storeAddress: String?
  public var canProvideService: Int?
  public var storeId: Int?
  public var longitude: String?
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
    orderAmount = json[kStoresOrderAmountKey].int
    orderReceipt = json[kStoresOrderReceiptKey].string
    isActive = json[kStoresIsActiveKey].int
    if let items = json[kStoresProductsKey].array { products = items.map { CurrentOrderProducts(json: $0) } }
    orderStoreId = json[kStoresOrderStoreIdKey].int
    offerPercentage = json[kStoresOfferPercentageKey].int
    adminOfferId = json[kStoresAdminOfferIdKey].int
    latitude = json[kStoresLatitudeKey].string
    storeLogo = json[kStoresStoreLogoKey].string
    userStoreId = json[kStoresUserStoreIdKey].int
    storeAddress = json[kStoresStoreAddressKey].string
    canProvideService = json[kStoresCanProvideServiceKey].int
    storeId = json[kStoresStoreIdKey].int
    longitude = json[kStoresLongitudeKey].string
    storeName = json[kStoresStoreNameKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = orderAmount { dictionary[kStoresOrderAmountKey] = value }
    if let value = orderReceipt { dictionary[kStoresOrderReceiptKey] = value }
    if let value = isActive { dictionary[kStoresIsActiveKey] = value }
    if let value = products { dictionary[kStoresProductsKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = orderStoreId { dictionary[kStoresOrderStoreIdKey] = value }
    if let value = offerPercentage { dictionary[kStoresOfferPercentageKey] = value }
    if let value = adminOfferId { dictionary[kStoresAdminOfferIdKey] = value }
    if let value = latitude { dictionary[kStoresLatitudeKey] = value }
    if let value = storeLogo { dictionary[kStoresStoreLogoKey] = value }
    if let value = userStoreId { dictionary[kStoresUserStoreIdKey] = value }
    if let value = storeAddress { dictionary[kStoresStoreAddressKey] = value }
    if let value = canProvideService { dictionary[kStoresCanProvideServiceKey] = value }
    if let value = storeId { dictionary[kStoresStoreIdKey] = value }
    if let value = longitude { dictionary[kStoresLongitudeKey] = value }
    if let value = storeName { dictionary[kStoresStoreNameKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.orderAmount = aDecoder.decodeObject(forKey: kStoresOrderAmountKey) as? Int
    self.orderReceipt = aDecoder.decodeObject(forKey: kStoresOrderReceiptKey) as? String
    self.isActive = aDecoder.decodeObject(forKey: kStoresIsActiveKey) as? Int
    self.products = aDecoder.decodeObject(forKey: kStoresProductsKey) as? [CurrentOrderProducts]
    self.orderStoreId = aDecoder.decodeObject(forKey: kStoresOrderStoreIdKey) as? Int
    self.offerPercentage = aDecoder.decodeObject(forKey: kStoresOfferPercentageKey) as? Int
    self.adminOfferId = aDecoder.decodeObject(forKey: kStoresAdminOfferIdKey) as? Int
    self.latitude = aDecoder.decodeObject(forKey: kStoresLatitudeKey) as? String
    self.storeLogo = aDecoder.decodeObject(forKey: kStoresStoreLogoKey) as? String
    self.userStoreId = aDecoder.decodeObject(forKey: kStoresUserStoreIdKey) as? Int
    self.storeAddress = aDecoder.decodeObject(forKey: kStoresStoreAddressKey) as? String
    self.canProvideService = aDecoder.decodeObject(forKey: kStoresCanProvideServiceKey) as? Int
    self.storeId = aDecoder.decodeObject(forKey: kStoresStoreIdKey) as? Int
    self.longitude = aDecoder.decodeObject(forKey: kStoresLongitudeKey) as? String
    self.storeName = aDecoder.decodeObject(forKey: kStoresStoreNameKey) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(orderAmount, forKey: kStoresOrderAmountKey)
    aCoder.encode(orderReceipt, forKey: kStoresOrderReceiptKey)
    aCoder.encode(isActive, forKey: kStoresIsActiveKey)
    aCoder.encode(products, forKey: kStoresProductsKey)
    aCoder.encode(orderStoreId, forKey: kStoresOrderStoreIdKey)
    aCoder.encode(offerPercentage, forKey: kStoresOfferPercentageKey)
    aCoder.encode(adminOfferId, forKey: kStoresAdminOfferIdKey)
    aCoder.encode(latitude, forKey: kStoresLatitudeKey)
    aCoder.encode(storeLogo, forKey: kStoresStoreLogoKey)
    aCoder.encode(userStoreId, forKey: kStoresUserStoreIdKey)
    aCoder.encode(storeAddress, forKey: kStoresStoreAddressKey)
    aCoder.encode(canProvideService, forKey: kStoresCanProvideServiceKey)
    aCoder.encode(storeId, forKey: kStoresStoreIdKey)
    aCoder.encode(longitude, forKey: kStoresLongitudeKey)
    aCoder.encode(storeName, forKey: kStoresStoreNameKey)
  }

}
