//
//  ApplePaySecret.swift
//
//  Created by C100-174 on 01/08/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class ApplePaySecret: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let transactionId = "transaction_id"
    static let orderId = "order_id"
    static let userId = "user_id"
  }

  // MARK: Properties
  public var transactionId: String?
  public var orderId: Int?
  public var userId: Int?

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
    transactionId = json[SerializationKeys.transactionId].string
    orderId = json[SerializationKeys.orderId].int
    userId = json[SerializationKeys.userId].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = transactionId { dictionary[SerializationKeys.transactionId] = value }
    if let value = orderId { dictionary[SerializationKeys.orderId] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.transactionId = aDecoder.decodeObject(forKey: SerializationKeys.transactionId) as? String
    self.orderId = aDecoder.decodeObject(forKey: SerializationKeys.orderId) as? Int
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(transactionId, forKey: SerializationKeys.transactionId)
    aCoder.encode(orderId, forKey: SerializationKeys.orderId)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
  }

}
