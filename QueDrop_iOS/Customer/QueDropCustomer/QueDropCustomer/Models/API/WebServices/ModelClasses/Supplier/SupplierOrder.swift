//
//  SupplierOrder.swift
//
//  Created by C100-105 on 03/04/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class SupplierOrder: NSObject, NSCoding, JSONable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kSupplierOrderOrderAmountKey: String = "order_amount"
    private let kSupplierOrderOrderIdKey: String = "order_id"
    private let kSupplierOrderProductsKey: String = "products"
    private let kSupplierOrderDriverIdKey: String = "driver_id"
    private let kSupplierOrderOrderStoreIdKey: String = "order_store_id"
    private let kSupplierOrderOrderDateKey: String = "order_date"
    private let kSupplierOrderCustomerIdKey: String = "customer_id"
    private let kSupplierOrderUserStoreIdKey: String = "user_store_id"
    private let kSupplierOrderLatitudeKey: String = "latitude"
    private let kSupplierOrderOrderStatusKey: String = "order_status"
    private let kSupplierOrderCustomerDetailKey: String = "customer_detail"
    private let kSupplierOrderCreatedAtKey: String = "created_at"
    private let kSupplierOrderDistanceKey: String = "distance"
    private let kSupplierOrderDriverDetailKey: String = "driver_detail"
    private let kSupplierOrderLongitudeKey: String = "longitude"
    
    // MARK: Properties
    public var orderAmount: Float?
    public var orderId: Int?
    public var products: [SupplierProducts]?
    public var driverId: Int?
    public var orderStoreId: Int?
    public var orderDate: String?
    public var customerId: Int?
    public var userStoreId: Int?
    public var latitude: String?
    public var orderStatus: String?
    public var customerDetail: CustomerDetail?
    public var createdAt: String?
    public var distance: String?
    public var driverDetail: DriverDetail?
    public var longitude: String?
    
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
        orderAmount = json[kSupplierOrderOrderAmountKey].float
        orderId = json[kSupplierOrderOrderIdKey].int
        if let items = json[kSupplierOrderProductsKey].array { products = items.map { SupplierProducts(json: $0) } }
        driverId = json[kSupplierOrderDriverIdKey].int
        orderStoreId = json[kSupplierOrderOrderStoreIdKey].int
        orderDate = json[kSupplierOrderOrderDateKey].string
        customerId = json[kSupplierOrderCustomerIdKey].int
        userStoreId = json[kSupplierOrderUserStoreIdKey].int
        latitude = json[kSupplierOrderLatitudeKey].string
        orderStatus = json[kSupplierOrderOrderStatusKey].string
        customerDetail = CustomerDetail(json: json[kSupplierOrderCustomerDetailKey])
        createdAt = json[kSupplierOrderCreatedAtKey].string
        distance = json[kSupplierOrderDistanceKey].string
        driverDetail = DriverDetail(json: json[kSupplierOrderDriverDetailKey])
        longitude = json[kSupplierOrderLongitudeKey].string
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = orderAmount { dictionary[kSupplierOrderOrderAmountKey] = value }
        if let value = orderId { dictionary[kSupplierOrderOrderIdKey] = value }
        if let value = products { dictionary[kSupplierOrderProductsKey] = value.map { $0.dictionaryRepresentation() } }
        if let value = driverId { dictionary[kSupplierOrderDriverIdKey] = value }
        if let value = orderStoreId { dictionary[kSupplierOrderOrderStoreIdKey] = value }
        if let value = orderDate { dictionary[kSupplierOrderOrderDateKey] = value }
        if let value = customerId { dictionary[kSupplierOrderCustomerIdKey] = value }
        if let value = userStoreId { dictionary[kSupplierOrderUserStoreIdKey] = value }
        if let value = latitude { dictionary[kSupplierOrderLatitudeKey] = value }
        if let value = orderStatus { dictionary[kSupplierOrderOrderStatusKey] = value }
        if let value = customerDetail { dictionary[kSupplierOrderCustomerDetailKey] = value.dictionaryRepresentation() }
        if let value = createdAt { dictionary[kSupplierOrderCreatedAtKey] = value }
        if let value = distance { dictionary[kSupplierOrderDistanceKey] = value }
        if let value = driverDetail { dictionary[kSupplierOrderDriverDetailKey] = value.dictionaryRepresentation() }
        if let value = longitude { dictionary[kSupplierOrderLongitudeKey] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.orderAmount = aDecoder.decodeObject(forKey: kSupplierOrderOrderAmountKey) as? Float
        self.orderId = aDecoder.decodeObject(forKey: kSupplierOrderOrderIdKey) as? Int
        self.products = aDecoder.decodeObject(forKey: kSupplierOrderProductsKey) as? [SupplierProducts]
        self.driverId = aDecoder.decodeObject(forKey: kSupplierOrderDriverIdKey) as? Int
        self.orderStoreId = aDecoder.decodeObject(forKey: kSupplierOrderOrderStoreIdKey) as? Int
        self.orderDate = aDecoder.decodeObject(forKey: kSupplierOrderOrderDateKey) as? String
        self.customerId = aDecoder.decodeObject(forKey: kSupplierOrderCustomerIdKey) as? Int
        self.userStoreId = aDecoder.decodeObject(forKey: kSupplierOrderUserStoreIdKey) as? Int
        self.latitude = aDecoder.decodeObject(forKey: kSupplierOrderLatitudeKey) as? String
        self.orderStatus = aDecoder.decodeObject(forKey: kSupplierOrderOrderStatusKey) as? String
        self.customerDetail = aDecoder.decodeObject(forKey: kSupplierOrderCustomerDetailKey) as? CustomerDetail
        self.createdAt = aDecoder.decodeObject(forKey: kSupplierOrderCreatedAtKey) as? String
        self.distance = aDecoder.decodeObject(forKey: kSupplierOrderDistanceKey) as? String
        self.driverDetail = aDecoder.decodeObject(forKey: kSupplierOrderDriverDetailKey) as? DriverDetail
        self.longitude = aDecoder.decodeObject(forKey: kSupplierOrderLongitudeKey) as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(orderAmount, forKey: kSupplierOrderOrderAmountKey)
        aCoder.encode(orderId, forKey: kSupplierOrderOrderIdKey)
        aCoder.encode(products, forKey: kSupplierOrderProductsKey)
        aCoder.encode(driverId, forKey: kSupplierOrderDriverIdKey)
        aCoder.encode(orderStoreId, forKey: kSupplierOrderOrderStoreIdKey)
        aCoder.encode(orderDate, forKey: kSupplierOrderOrderDateKey)
        aCoder.encode(customerId, forKey: kSupplierOrderCustomerIdKey)
        aCoder.encode(userStoreId, forKey: kSupplierOrderUserStoreIdKey)
        aCoder.encode(latitude, forKey: kSupplierOrderLatitudeKey)
        aCoder.encode(orderStatus, forKey: kSupplierOrderOrderStatusKey)
        aCoder.encode(customerDetail, forKey: kSupplierOrderCustomerDetailKey)
        aCoder.encode(createdAt, forKey: kSupplierOrderCreatedAtKey)
        aCoder.encode(distance, forKey: kSupplierOrderDistanceKey)
        aCoder.encode(driverDetail, forKey: kSupplierOrderDriverDetailKey)
        aCoder.encode(longitude, forKey: kSupplierOrderLongitudeKey)
    }
    
}
