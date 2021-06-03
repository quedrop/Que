//
//  OrderBillingDetails.swift
//
//  Created by C100-104 on 07/04/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class OrderBillingDetails: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kOrderBillingDetailsDriverDetailKey: String = "driver_detail"
  private let kOrderBillingDetailsStoreReceiptsKey: String = "store_receipts"
  private let kOrderBillingDetailsCustomerDetailKey: String = "customer_detail"
  private let kOrderBillingDetailsBillingDetailKey: String = "billing_detail"

  // MARK: Properties
  public var driverDetail: DriverDetail?
  public var storeReceipts: [String]?
  public var customerDetail: CustomerDetail?
  public var billingDetail: BillingDetail?

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
    driverDetail = DriverDetail(json: json[kOrderBillingDetailsDriverDetailKey])
    if let items = json[kOrderBillingDetailsStoreReceiptsKey].array { storeReceipts = items.map { $0.stringValue } }
    customerDetail = CustomerDetail(json: json[kOrderBillingDetailsCustomerDetailKey])
    billingDetail = BillingDetail(json: json[kOrderBillingDetailsBillingDetailKey])
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = driverDetail { dictionary[kOrderBillingDetailsDriverDetailKey] = value.dictionaryRepresentation() }
    if let value = storeReceipts { dictionary[kOrderBillingDetailsStoreReceiptsKey] = value }
    if let value = customerDetail { dictionary[kOrderBillingDetailsCustomerDetailKey] = value.dictionaryRepresentation() }
    if let value = billingDetail { dictionary[kOrderBillingDetailsBillingDetailKey] = value.dictionaryRepresentation() }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.driverDetail = aDecoder.decodeObject(forKey: kOrderBillingDetailsDriverDetailKey) as? DriverDetail
    self.storeReceipts = aDecoder.decodeObject(forKey: kOrderBillingDetailsStoreReceiptsKey) as? [String]
    self.customerDetail = aDecoder.decodeObject(forKey: kOrderBillingDetailsCustomerDetailKey) as? CustomerDetail
    self.billingDetail = aDecoder.decodeObject(forKey: kOrderBillingDetailsBillingDetailKey) as? BillingDetail
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(driverDetail, forKey: kOrderBillingDetailsDriverDetailKey)
    aCoder.encode(storeReceipts, forKey: kOrderBillingDetailsStoreReceiptsKey)
    aCoder.encode(customerDetail, forKey: kOrderBillingDetailsCustomerDetailKey)
    aCoder.encode(billingDetail, forKey: kOrderBillingDetailsBillingDetailKey)
  }

}
