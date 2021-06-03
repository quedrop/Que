//
//  HomeEarning.swift
//
//  Created by C100-174 on 27/05/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class HomeEarning: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let todayTotalEarning = "today_total_earning"
    static let orderDetails = "orders"
    static let lastOrderDate = "last_order_date"
    static let todayTotalOrder = "today_total_order"
    static let lastOrderTotalEarning = "last_order_total_earning"
  }

  // MARK: Properties
  public var todayTotalEarning: Float?
  public var orderDetails: [OrderDetail]?
  public var lastOrderDate: String?
  public var todayTotalOrder: Int?
  public var lastOrderTotalEarning: Float?

  // MARK: SwiftyJSON Initializers
  /// Initiates the instance based on the object.
  ///
  /// - parameter object: The object of either Dictionary or Array kind that was passed.
  /// - returns: An initialized instance of the class.
  public convenience init(object: Any) {
    self.init(json: JSON(object))
  }

  /// Initiates the instance based on the JSON that was passed.
  ///
  /// - parameter json: JSON object from SwiftyJSON.
  public required init(json: JSON) {
    todayTotalEarning = json[SerializationKeys.todayTotalEarning].float
    if let items = json[SerializationKeys.orderDetails].array { orderDetails = items.map { OrderDetail(json: $0) } }
    lastOrderDate = json[SerializationKeys.lastOrderDate].string
    todayTotalOrder = json[SerializationKeys.todayTotalOrder].int
    lastOrderTotalEarning = json[SerializationKeys.lastOrderTotalEarning].float
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = todayTotalEarning { dictionary[SerializationKeys.todayTotalEarning] = value }
    if let value = orderDetails { dictionary[SerializationKeys.orderDetails] = value.map { $0.dictionaryRepresentation() } }
    if let value = lastOrderDate { dictionary[SerializationKeys.lastOrderDate] = value }
    if let value = todayTotalOrder { dictionary[SerializationKeys.todayTotalOrder] = value }
    if let value = lastOrderTotalEarning { dictionary[SerializationKeys.lastOrderTotalEarning] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.todayTotalEarning = aDecoder.decodeObject(forKey: SerializationKeys.todayTotalEarning) as? Float
    self.orderDetails = aDecoder.decodeObject(forKey: SerializationKeys.orderDetails) as? [OrderDetail]
    self.lastOrderDate = aDecoder.decodeObject(forKey: SerializationKeys.lastOrderDate) as? String
    self.todayTotalOrder = aDecoder.decodeObject(forKey: SerializationKeys.todayTotalOrder) as? Int
    self.lastOrderTotalEarning = aDecoder.decodeObject(forKey: SerializationKeys.lastOrderTotalEarning) as? Float
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(todayTotalEarning, forKey: SerializationKeys.todayTotalEarning)
    aCoder.encode(orderDetails, forKey: SerializationKeys.orderDetails)
    aCoder.encode(lastOrderDate, forKey: SerializationKeys.lastOrderDate)
    aCoder.encode(todayTotalOrder, forKey: SerializationKeys.todayTotalOrder)
    aCoder.encode(lastOrderTotalEarning, forKey: SerializationKeys.lastOrderTotalEarning)
  }

}
