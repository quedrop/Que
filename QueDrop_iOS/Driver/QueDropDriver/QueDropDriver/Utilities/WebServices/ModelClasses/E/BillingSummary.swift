//
//  BillingSummary.swift
//
//  Created by C100-174 on 26/05/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class BillingSummary: NSObject, NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let totalShoppingEarning = "total_shopping_earning"
    static let totalAmount = "total_amount"
    static let totalDeliveryEarning = "total_delivery_earning"
    static let isPaymentDone = "is_payment_done"
    static let totalTipEarning = "total_tip_earning"
    static let totalReferralEarning = "total_referral_earning"
  }

  // MARK: Properties
  public var totalShoppingEarning: Float?
  public var totalAmount: Float?
  public var totalDeliveryEarning: Float?
  public var isPaymentDone: Float?
  public var totalTipEarning: Float?
  public var totalReferralEarning: Float?
    
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
    totalShoppingEarning = json[SerializationKeys.totalShoppingEarning].float
    totalAmount = json[SerializationKeys.totalAmount].float
    totalDeliveryEarning = json[SerializationKeys.totalDeliveryEarning].float
    isPaymentDone = json[SerializationKeys.isPaymentDone].float
    totalTipEarning = json[SerializationKeys.totalTipEarning].float
    totalReferralEarning = json[SerializationKeys.totalReferralEarning].float
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = totalShoppingEarning { dictionary[SerializationKeys.totalShoppingEarning] = value }
    if let value = totalAmount { dictionary[SerializationKeys.totalAmount] = value }
    if let value = totalDeliveryEarning { dictionary[SerializationKeys.totalDeliveryEarning] = value }
    if let value = isPaymentDone { dictionary[SerializationKeys.isPaymentDone] = value }
    if let value = totalTipEarning { dictionary[SerializationKeys.totalTipEarning] = value }
    if let value = totalReferralEarning { dictionary[SerializationKeys.totalReferralEarning] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.totalShoppingEarning = aDecoder.decodeObject(forKey: SerializationKeys.totalShoppingEarning) as? Float
    self.totalAmount = aDecoder.decodeObject(forKey: SerializationKeys.totalAmount) as? Float
    self.totalDeliveryEarning = aDecoder.decodeObject(forKey: SerializationKeys.totalDeliveryEarning) as? Float
    self.isPaymentDone = aDecoder.decodeObject(forKey: SerializationKeys.isPaymentDone) as? Float
    self.totalTipEarning = aDecoder.decodeObject(forKey: SerializationKeys.totalTipEarning) as? Float
    self.totalReferralEarning = aDecoder.decodeObject(forKey: SerializationKeys.totalReferralEarning) as? Float
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(totalShoppingEarning, forKey: SerializationKeys.totalShoppingEarning)
    aCoder.encode(totalAmount, forKey: SerializationKeys.totalAmount)
    aCoder.encode(totalDeliveryEarning, forKey: SerializationKeys.totalDeliveryEarning)
    aCoder.encode(isPaymentDone, forKey: SerializationKeys.isPaymentDone)
    aCoder.encode(totalTipEarning, forKey: SerializationKeys.totalTipEarning)
    aCoder.encode(totalReferralEarning, forKey: SerializationKeys.totalReferralEarning)
  }

}
