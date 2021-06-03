//
//  Cart.swift
//
//  Created by C100-104 on 25/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON


public class Cart: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kCartCartItemsKey: String = "cart_items"
  private let kCartAmountDetailsKey: String = "amount_details"

  // MARK: Properties
  public var cartItems: [CartItems]?
  public var amountDetails: AmountDetails?

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
    if let items = json[kCartCartItemsKey].array { cartItems = items.map { CartItems(json: $0) } }
    amountDetails = AmountDetails(json: json[kCartAmountDetailsKey])
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = cartItems { dictionary[kCartCartItemsKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = amountDetails { dictionary[kCartAmountDetailsKey] = value.dictionaryRepresentation() }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.cartItems = aDecoder.decodeObject(forKey: kCartCartItemsKey) as? [CartItems]
    self.amountDetails = aDecoder.decodeObject(forKey: kCartAmountDetailsKey) as? AmountDetails
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(cartItems, forKey: kCartCartItemsKey)
    aCoder.encode(amountDetails, forKey: kCartAmountDetailsKey)
  }

}
