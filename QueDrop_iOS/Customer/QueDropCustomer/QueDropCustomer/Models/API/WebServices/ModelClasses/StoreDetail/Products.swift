//
//  Products.swift
//
//  Created by C100-104 on 10/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class Products: NSObject, NSCoding, JSONable {
	 // MARK: Declaration for string constants to be used to decode and also serialize.
	  private let kProductProductIdKey: String = "product_id"
	  private let kProductIsProductSelectedKey: String = "is_product_selected"
	  private let kProductHasAddonsKey: String = "has_addons"
	  private let kProductProductDescriptionKey: String = "product_description"
	  private let kProductIsActiveKey: String = "is_active"
	  private let kProductNeedExtraFeesKey: String = "need_extra_fees"
	  private let kProductExtraFeesKey: String = "extra_fees"
	  private let kProductProductNameKey: String = "product_name"
	  private let kProductProductPriceKey: String = "product_price"
	  private let kProductProductImageKey: String = "product_image"
	  private let kProductStoreCategoryIdKey: String = "store_category_id"
      private let kProductOptionsKey: String = "product_option"
      private let kProductStoreIdKey: String = "store_id"
      private let kProductFreshProduceCategoryIdKey: String = "fresh_produce_category_id"

	  // MARK: Properties
	  public var productId: Int?
	  public var isProductSelected: Int?
	  public var hasAddons: Int?
	  public var productDescription: String?
	  public var isActive: Int?
	  public var needExtraFees: Int?
	  public var extraFees: Int?
	  public var productName: String?
	  public var productPrice: Float?
	  public var productImage: String?
	  public var storeCategoryId: Int?
      public var productOption: [ProductOption]?
      public var storeId: Int?
    public var freshProduceCategoryId: Int?
    

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
	required  public init(json: JSON) {
		productId = json[kProductProductIdKey].int
		isProductSelected = json[kProductIsProductSelectedKey].int
		hasAddons = json[kProductHasAddonsKey].int
		productDescription = json[kProductProductDescriptionKey].string
		isActive = json[kProductIsActiveKey].int
		needExtraFees = json[kProductNeedExtraFeesKey].int
		extraFees = json[kProductExtraFeesKey].int
		productName = json[kProductProductNameKey].string
		productPrice = json[kProductProductPriceKey].float
		productImage = json[kProductProductImageKey].string
		storeCategoryId = json[kProductStoreCategoryIdKey].int
		if let items = json[kProductOptionsKey].array { productOption = items.map { ProductOption(json: $0) } }
        storeId = json[kProductStoreIdKey].int
        freshProduceCategoryId = json[kProductFreshProduceCategoryIdKey].int
	  }

	  /**
	   Generates description of the object in the form of a NSDictionary.
	   - returns: A Key value pair containing all valid values in the object.
	  */
	  public func dictionaryRepresentation() -> [String: Any] {
		var dictionary: [String: Any] = [:]
		if let value = productId { dictionary[kProductProductIdKey] = value }
		if let value = isProductSelected { dictionary[kProductIsProductSelectedKey] = value }
		if let value = hasAddons { dictionary[kProductHasAddonsKey] = value }
		if let value = productDescription { dictionary[kProductProductDescriptionKey] = value }
		if let value = isActive { dictionary[kProductIsActiveKey] = value }
		if let value = needExtraFees { dictionary[kProductNeedExtraFeesKey] = value }
		if let value = extraFees { dictionary[kProductExtraFeesKey] = value }
		if let value = productName { dictionary[kProductProductNameKey] = value }
		if let value = productPrice { dictionary[kProductProductPriceKey] = value }
		if let value = productImage { dictionary[kProductProductImageKey] = value }
		if let value = storeCategoryId { dictionary[kProductStoreCategoryIdKey] = value }
		if let value = productOption { dictionary[kProductOptionsKey] = value.map { $0.dictionaryRepresentation() } }
        if let value = storeId { dictionary[kProductStoreIdKey] = value }
        if let value = freshProduceCategoryId { dictionary[kProductFreshProduceCategoryIdKey] = value }
		return dictionary
	  }

	  // MARK: NSCoding Protocol
	  required public init(coder aDecoder: NSCoder) {
		self.productId = aDecoder.decodeObject(forKey: kProductProductIdKey) as? Int
		self.isProductSelected = aDecoder.decodeObject(forKey: kProductIsProductSelectedKey) as? Int
		self.hasAddons = aDecoder.decodeObject(forKey: kProductHasAddonsKey) as? Int
		self.productDescription = aDecoder.decodeObject(forKey: kProductProductDescriptionKey) as? String
		self.isActive = aDecoder.decodeObject(forKey: kProductIsActiveKey) as? Int
		self.needExtraFees = aDecoder.decodeObject(forKey: kProductNeedExtraFeesKey) as? Int
		self.extraFees = aDecoder.decodeObject(forKey: kProductExtraFeesKey) as? Int
		self.productName = aDecoder.decodeObject(forKey: kProductProductNameKey) as? String
		self.productPrice = aDecoder.decodeObject(forKey: kProductProductPriceKey) as? Float
		self.productImage = aDecoder.decodeObject(forKey: kProductProductImageKey) as? String
		self.storeCategoryId = aDecoder.decodeObject(forKey: kProductStoreCategoryIdKey) as? Int
		self.productOption = aDecoder.decodeObject(forKey: kProductOptionsKey) as? [ProductOption]
        self.storeId = aDecoder.decodeObject(forKey: kProductStoreIdKey) as? Int
        self.freshProduceCategoryId = aDecoder.decodeObject(forKey: kProductFreshProduceCategoryIdKey) as? Int
	  }

	  public func encode(with aCoder: NSCoder) {
		aCoder.encode(productId, forKey: kProductProductIdKey)
		aCoder.encode(isProductSelected, forKey: kProductIsProductSelectedKey)
		aCoder.encode(hasAddons, forKey: kProductHasAddonsKey)
		aCoder.encode(productDescription, forKey: kProductProductDescriptionKey)
		aCoder.encode(isActive, forKey: kProductIsActiveKey)
		aCoder.encode(needExtraFees, forKey: kProductNeedExtraFeesKey)
		aCoder.encode(extraFees, forKey: kProductExtraFeesKey)
		aCoder.encode(productName, forKey: kProductProductNameKey)
		aCoder.encode(productPrice, forKey: kProductProductPriceKey)
		aCoder.encode(productImage, forKey: kProductProductImageKey)
		aCoder.encode(storeCategoryId, forKey: kProductStoreCategoryIdKey)
		aCoder.encode(productOption, forKey: kProductOptionsKey)
        aCoder.encode(storeId, forKey: kProductStoreIdKey)
        aCoder.encode(freshProduceCategoryId, forKey: kProductOptionsKey)
	  }

	}
