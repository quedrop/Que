//
//  SupplierOffer.swift
//  QueDrop
//
//  Created by C100-105 on 06/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import Foundation
import SwiftyJSON

public class SupplierOffer: NSObject, NSCoding, JSONable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kOffersStoreCategoryIdKey: String = "store_category_id"
    private let kOffersStartTimeKey: String = "start_time"
    private let kOffersIsActiveKey: String = "is_active"
    private let kOffersStoreCategoryTitleKey: String = "store_category_title"
    private let kOffersProductNameKey: String = "product_name"
    private let kOffersOfferPercentageKey: String = "offer_percentage"
    private let kOffersOfferCodeKey: String = "offer_code"
    private let kOffersProductIdKey: String = "product_id"
    private let kOffersExpirationDateKey: String = "expiration_date"
    private let kOffersStoreIdKey: String = "store_id"
    private let kOffersAdditionalInfoKey: String = "additional_info"
    private let kOffersProductOfferIdKey: String = "product_offer_id"
    private let kOffersStartDateKey: String = "start_date"
    private let kOffersExpirationTimeKey: String = "expiration_time"
    private let kOffersProductImageKey: String = "product_image"
    
    // MARK: Properties
    public var storeCategoryId: Int?
    public var startTime: String?
    public var isActive: Int?
    public var storeCategoryTitle: String?
    public var productName: String?
    public var offerPercentage: Int?
    public var offerCode: String?
    public var productId: Int?
    public var expirationDate: String?
    public var storeId: Int?
    public var additionalInfo: String?
    public var productOfferId: Int?
    public var startDate: String?
    public var expirationTime: String?
    public var productImage: String?
    
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
        storeCategoryId = json[kOffersStoreCategoryIdKey].int
        startTime = json[kOffersStartTimeKey].string
        isActive = json[kOffersIsActiveKey].int
        storeCategoryTitle = json[kOffersStoreCategoryTitleKey].string
        productName = json[kOffersProductNameKey].string
        offerPercentage = json[kOffersOfferPercentageKey].int
        offerCode = json[kOffersOfferCodeKey].string
        productId = json[kOffersProductIdKey].int
        expirationDate = json[kOffersExpirationDateKey].string
        storeId = json[kOffersStoreIdKey].int
        additionalInfo = json[kOffersAdditionalInfoKey].string
        productOfferId = json[kOffersProductOfferIdKey].int
        startDate = json[kOffersStartDateKey].string
        expirationTime = json[kOffersExpirationTimeKey].string
        productImage = json[kOffersProductImageKey].string
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = storeCategoryId { dictionary[kOffersStoreCategoryIdKey] = value }
        if let value = startTime { dictionary[kOffersStartTimeKey] = value }
        if let value = isActive { dictionary[kOffersIsActiveKey] = value }
        if let value = storeCategoryTitle { dictionary[kOffersStoreCategoryTitleKey] = value }
        if let value = productName { dictionary[kOffersProductNameKey] = value }
        if let value = offerPercentage { dictionary[kOffersOfferPercentageKey] = value }
        if let value = offerCode { dictionary[kOffersOfferCodeKey] = value }
        if let value = productId { dictionary[kOffersProductIdKey] = value }
        if let value = expirationDate { dictionary[kOffersExpirationDateKey] = value }
        if let value = storeId { dictionary[kOffersStoreIdKey] = value }
        if let value = additionalInfo { dictionary[kOffersAdditionalInfoKey] = value }
        if let value = productOfferId { dictionary[kOffersProductOfferIdKey] = value }
        if let value = startDate { dictionary[kOffersStartDateKey] = value }
        if let value = expirationTime { dictionary[kOffersExpirationTimeKey] = value }
        if let value = productImage { dictionary[kOffersProductImageKey] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.storeCategoryId = aDecoder.decodeObject(forKey: kOffersStoreCategoryIdKey) as? Int
        self.startTime = aDecoder.decodeObject(forKey: kOffersStartTimeKey) as? String
        self.isActive = aDecoder.decodeObject(forKey: kOffersIsActiveKey) as? Int
        self.storeCategoryTitle = aDecoder.decodeObject(forKey: kOffersStoreCategoryTitleKey) as? String
        self.productName = aDecoder.decodeObject(forKey: kOffersProductNameKey) as? String
        self.offerPercentage = aDecoder.decodeObject(forKey: kOffersOfferPercentageKey) as? Int
        self.offerCode = aDecoder.decodeObject(forKey: kOffersOfferCodeKey) as? String
        self.productId = aDecoder.decodeObject(forKey: kOffersProductIdKey) as? Int
        self.expirationDate = aDecoder.decodeObject(forKey: kOffersExpirationDateKey) as? String
        self.storeId = aDecoder.decodeObject(forKey: kOffersStoreIdKey) as? Int
        self.additionalInfo = aDecoder.decodeObject(forKey: kOffersAdditionalInfoKey) as? String
        self.productOfferId = aDecoder.decodeObject(forKey: kOffersProductOfferIdKey) as? Int
        self.startDate = aDecoder.decodeObject(forKey: kOffersStartDateKey) as? String
        self.expirationTime = aDecoder.decodeObject(forKey: kOffersExpirationTimeKey) as? String
        self.productImage = aDecoder.decodeObject(forKey: kOffersProductImageKey) as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(storeCategoryId, forKey: kOffersStoreCategoryIdKey)
        aCoder.encode(startTime, forKey: kOffersStartTimeKey)
        aCoder.encode(isActive, forKey: kOffersIsActiveKey)
        aCoder.encode(storeCategoryTitle, forKey: kOffersStoreCategoryTitleKey)
        aCoder.encode(productName, forKey: kOffersProductNameKey)
        aCoder.encode(offerPercentage, forKey: kOffersOfferPercentageKey)
        aCoder.encode(offerCode, forKey: kOffersOfferCodeKey)
        aCoder.encode(productId, forKey: kOffersProductIdKey)
        aCoder.encode(expirationDate, forKey: kOffersExpirationDateKey)
        aCoder.encode(storeId, forKey: kOffersStoreIdKey)
        aCoder.encode(additionalInfo, forKey: kOffersAdditionalInfoKey)
        aCoder.encode(productOfferId, forKey: kOffersProductOfferIdKey)
        aCoder.encode(startDate, forKey: kOffersStartDateKey)
        aCoder.encode(expirationTime, forKey: kOffersExpirationTimeKey)
        aCoder.encode(productImage, forKey: kOffersProductImageKey)
    }
    
}
