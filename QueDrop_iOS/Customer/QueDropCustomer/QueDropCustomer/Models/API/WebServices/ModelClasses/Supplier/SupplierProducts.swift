//
//  Products.swift
//
//  Created by C100-105 on 03/04/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class SupplierProducts: NSObject, NSCoding, JSONable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kProductsProductOptionKey: String = "product_option"
    private let kProductsOptionIdKey: String = "option_id"
    private let kProductsOrderStoreProductIdKey: String = "order_store_product_id"
    private let kProductsQuantityKey: String = "quantity"
    private let kProductsProductNameKey: String = "product_name"
    private let kProductsProductPriceKey: String = "product_price"
    private let kProductsOfferPercentageKey: String = "offer_percentage"
    private let kProductsProductIdKey: String = "product_id"
    private let kProductsProductDescriptionKey: String = "product_description"
    private let kProductsUserProductIdKey: String = "user_product_id"
    private let kProductsAddonsKey: String = "addons"
    private let kProductsProductOfferIdKey: String = "product_offer_id"
    private let kProductsExtraFeesKey: String = "extra_fees"
    private let kProductsProductImageKey: String = "product_image"
    
    // MARK: Properties
    public var productOption: [ProductOption]?
    public var optionId: Int?
    public var orderStoreProductId: Int?
    public var quantity: Int?
    public var productName: String?
    public var productPrice: Int?
    public var offerPercentage: Int?
    public var productId: Int?
    public var productDescription: String?
    public var userProductId: Int?
    public var addons: [Addons]?
    public var productOfferId: Int?
    public var extraFees: Int?
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
        if let items = json[kProductsProductOptionKey].array { productOption = items.map { ProductOption(json: $0) } }
        optionId = json[kProductsOptionIdKey].int
        orderStoreProductId = json[kProductsOrderStoreProductIdKey].int
        quantity = json[kProductsQuantityKey].int
        productName = json[kProductsProductNameKey].string
        productPrice = json[kProductsProductPriceKey].int
        offerPercentage = json[kProductsOfferPercentageKey].int
        productId = json[kProductsProductIdKey].int
        productDescription = json[kProductsProductDescriptionKey].string
        userProductId = json[kProductsUserProductIdKey].int
        if let items = json[kProductsAddonsKey].array { addons = items.map { Addons(json: $0) } }
        productOfferId = json[kProductsProductOfferIdKey].int
        extraFees = json[kProductsExtraFeesKey].int
        productImage = json[kProductsProductImageKey].string
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = productOption { dictionary[kProductsProductOptionKey] = value.map { $0.dictionaryRepresentation() } }
        if let value = optionId { dictionary[kProductsOptionIdKey] = value }
        if let value = orderStoreProductId { dictionary[kProductsOrderStoreProductIdKey] = value }
        if let value = quantity { dictionary[kProductsQuantityKey] = value }
        if let value = productName { dictionary[kProductsProductNameKey] = value }
        if let value = productPrice { dictionary[kProductsProductPriceKey] = value }
        if let value = offerPercentage { dictionary[kProductsOfferPercentageKey] = value }
        if let value = productId { dictionary[kProductsProductIdKey] = value }
        if let value = productDescription { dictionary[kProductsProductDescriptionKey] = value }
        if let value = userProductId { dictionary[kProductsUserProductIdKey] = value }
        if let value = addons { dictionary[kProductsAddonsKey] = value.map { $0.dictionaryRepresentation() } }
        if let value = productOfferId { dictionary[kProductsProductOfferIdKey] = value }
        if let value = extraFees { dictionary[kProductsExtraFeesKey] = value }
        if let value = productImage { dictionary[kProductsProductImageKey] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.productOption = aDecoder.decodeObject(forKey: kProductsProductOptionKey) as? [ProductOption]
        self.optionId = aDecoder.decodeObject(forKey: kProductsOptionIdKey) as? Int
        self.orderStoreProductId = aDecoder.decodeObject(forKey: kProductsOrderStoreProductIdKey) as? Int
        self.quantity = aDecoder.decodeObject(forKey: kProductsQuantityKey) as? Int
        self.productName = aDecoder.decodeObject(forKey: kProductsProductNameKey) as? String
        self.productPrice = aDecoder.decodeObject(forKey: kProductsProductPriceKey) as? Int
        self.offerPercentage = aDecoder.decodeObject(forKey: kProductsOfferPercentageKey) as? Int
        self.productId = aDecoder.decodeObject(forKey: kProductsProductIdKey) as? Int
        self.productDescription = aDecoder.decodeObject(forKey: kProductsProductDescriptionKey) as? String
        self.userProductId = aDecoder.decodeObject(forKey: kProductsUserProductIdKey) as? Int
        self.addons = aDecoder.decodeObject(forKey: kProductsAddonsKey) as? [Addons]
        self.productOfferId = aDecoder.decodeObject(forKey: kProductsProductOfferIdKey) as? Int
        self.extraFees = aDecoder.decodeObject(forKey: kProductsExtraFeesKey) as? Int
        self.productImage = aDecoder.decodeObject(forKey: kProductsProductImageKey) as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(productOption, forKey: kProductsProductOptionKey)
        aCoder.encode(optionId, forKey: kProductsOptionIdKey)
        aCoder.encode(orderStoreProductId, forKey: kProductsOrderStoreProductIdKey)
        aCoder.encode(quantity, forKey: kProductsQuantityKey)
        aCoder.encode(productName, forKey: kProductsProductNameKey)
        aCoder.encode(productPrice, forKey: kProductsProductPriceKey)
        aCoder.encode(offerPercentage, forKey: kProductsOfferPercentageKey)
        aCoder.encode(productId, forKey: kProductsProductIdKey)
        aCoder.encode(productDescription, forKey: kProductsProductDescriptionKey)
        aCoder.encode(userProductId, forKey: kProductsUserProductIdKey)
        aCoder.encode(addons, forKey: kProductsAddonsKey)
        aCoder.encode(productOfferId, forKey: kProductsProductOfferIdKey)
        aCoder.encode(extraFees, forKey: kProductsExtraFeesKey)
        aCoder.encode(productImage, forKey: kProductsProductImageKey)
    }
    
}
