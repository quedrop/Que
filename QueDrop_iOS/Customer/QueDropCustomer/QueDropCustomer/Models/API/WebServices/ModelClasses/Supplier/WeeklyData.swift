//
//  WeeklyData.swift
//
//  Created by C100-174 on 26/05/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class WeeklyData: NSObject, NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let orderDate = "order_date"
    static let orderDateWeekday = "order_date_weekday"
    static let totalAmount = "total_amount"
  }

  // MARK: Properties
  public var orderDate: String?
  public var orderDateWeekday: String?
  public var totalAmount: Float?

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
    orderDate = json[SerializationKeys.orderDate].string
    orderDateWeekday = json[SerializationKeys.orderDateWeekday].string
    totalAmount = json[SerializationKeys.totalAmount].float
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = orderDate { dictionary[SerializationKeys.orderDate] = value }
    if let value = orderDateWeekday { dictionary[SerializationKeys.orderDateWeekday] = value }
    if let value = totalAmount { dictionary[SerializationKeys.totalAmount] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.orderDate = aDecoder.decodeObject(forKey: SerializationKeys.orderDate) as? String
    self.orderDateWeekday = aDecoder.decodeObject(forKey: SerializationKeys.orderDateWeekday) as? String
    self.totalAmount = aDecoder.decodeObject(forKey: SerializationKeys.totalAmount) as? Float
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(orderDate, forKey: SerializationKeys.orderDate)
    aCoder.encode(orderDateWeekday, forKey: SerializationKeys.orderDateWeekday)
    aCoder.encode(totalAmount, forKey: SerializationKeys.totalAmount)
  }

}
