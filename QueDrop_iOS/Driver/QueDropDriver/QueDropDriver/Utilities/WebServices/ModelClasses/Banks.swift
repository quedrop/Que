//
//  Banks.swift
//
//  Created by C100-105 on 15/04/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class Banks: NSObject, NSCoding, JSONable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kBanksBankIdKey: String = "bank_id"
    private let kBanksBankNameKey: String = "bank_name"
    private let kBanksBankLogoKey: String = "bank_logo"
    
    // MARK: Properties
    public var bankId: Int?
    public var bankName: String?
    public var bankLogo: String?
    
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
        bankId = json[kBanksBankIdKey].int
        bankName = json[kBanksBankNameKey].string
        bankLogo = json[kBanksBankLogoKey].string
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = bankId { dictionary[kBanksBankIdKey] = value }
        if let value = bankName { dictionary[kBanksBankNameKey] = value }
        if let value = bankLogo { dictionary[kBanksBankLogoKey] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.bankId = aDecoder.decodeObject(forKey: kBanksBankIdKey) as? Int
        self.bankName = aDecoder.decodeObject(forKey: kBanksBankNameKey) as? String
        self.bankLogo = aDecoder.decodeObject(forKey: kBanksBankLogoKey) as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(bankId, forKey: kBanksBankIdKey)
        aCoder.encode(bankName, forKey: kBanksBankNameKey)
        aCoder.encode(bankLogo, forKey: kBanksBankLogoKey)
    }
    
}
