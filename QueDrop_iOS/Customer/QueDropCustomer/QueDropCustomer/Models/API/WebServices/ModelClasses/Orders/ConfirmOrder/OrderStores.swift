//
//  OrderStores.swift
//
//  Created by C100-104 on 07/04/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class OrderStores:  NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kOrderStoresStoreAmountKey: String = "store_amount"
  private let kOrderStoresStoreFinalAmountKey: String = "store_final_amount"
  private let kOrderStoresStoreDiscountKey: String = "store_discount"
  private let kOrderStoresIsStoreOfferKey: String = "is_store_offer"
  private let kOrderStoresStoreNameKey: String = "store_name"

  // MARK: Properties
  public var storeAmount: Float?
  public var storeFinalAmount: Float?
  public var storeDiscount: Float?
  public var isStoreOffer: Int?
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
    storeAmount = json[kOrderStoresStoreAmountKey].float
    storeFinalAmount = json[kOrderStoresStoreFinalAmountKey].float
    storeDiscount = json[kOrderStoresStoreDiscountKey].float
    isStoreOffer = json[kOrderStoresIsStoreOfferKey].int
    storeName = json[kOrderStoresStoreNameKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = storeAmount { dictionary[kOrderStoresStoreAmountKey] = value }
    if let value = storeFinalAmount { dictionary[kOrderStoresStoreFinalAmountKey] = value }
    if let value = storeDiscount { dictionary[kOrderStoresStoreDiscountKey] = value }
    if let value = isStoreOffer { dictionary[kOrderStoresIsStoreOfferKey] = value }
    if let value = storeName { dictionary[kOrderStoresStoreNameKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.storeAmount = aDecoder.decodeObject(forKey: kOrderStoresStoreAmountKey) as? Float
    self.storeFinalAmount = aDecoder.decodeObject(forKey: kOrderStoresStoreFinalAmountKey) as? Float
    self.storeDiscount = aDecoder.decodeObject(forKey: kOrderStoresStoreDiscountKey) as? Float
    self.isStoreOffer = aDecoder.decodeObject(forKey: kOrderStoresIsStoreOfferKey) as? Int
    self.storeName = aDecoder.decodeObject(forKey: kOrderStoresStoreNameKey) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(storeAmount, forKey: kOrderStoresStoreAmountKey)
    aCoder.encode(storeFinalAmount, forKey: kOrderStoresStoreFinalAmountKey)
    aCoder.encode(storeDiscount, forKey: kOrderStoresStoreDiscountKey)
    aCoder.encode(isStoreOffer, forKey: kOrderStoresIsStoreOfferKey)
    aCoder.encode(storeName, forKey: kOrderStoresStoreNameKey)
  }

}
