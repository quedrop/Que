//
//  BankDetails.swift
//
//  Created by C100-105 on 15/04/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class BankDetails: NSObject, NSCoding, JSONable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kBankDetailsOtherDetailKey: String = "other_detail"
    private let kBankDetailsAccountTypeKey: String = "account_type"
    private let kBankDetailsBankNameKey: String = "bank_name"
    private let kBankDetailsBankLogoKey: String = "bank_logo"
    private let kBankDetailsIsPrimaryKey: String = "is_primary"
    private let kBankDetailsIfscCodeKey: String = "ifsc_code"
    private let kBankDetailsBankDetailIdKey: String = "bank_detail_id"
    private let kBankDetailsBankIdKey: String = "bank_id"
    private let kBankDetailsAccountNumberKey: String = "account_number"
    
    // MARK: Properties
    public var otherDetail: String?
    public var accountType: String?
    public var bankName: String?
    public var bankLogo: String?
    public var isPrimary: Int?
    public var ifscCode: String?
    public var bankDetailId: Int?
    public var bankId: Int?
    public var accountNumber: String?
    
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
        otherDetail = json[kBankDetailsOtherDetailKey].string
        accountType = json[kBankDetailsAccountTypeKey].string
        bankName = json[kBankDetailsBankNameKey].string
        bankLogo = json[kBankDetailsBankLogoKey].string
        isPrimary = json[kBankDetailsIsPrimaryKey].int
        ifscCode = json[kBankDetailsIfscCodeKey].string
        bankDetailId = json[kBankDetailsBankDetailIdKey].int
        bankId = json[kBankDetailsBankIdKey].int
        accountNumber = json[kBankDetailsAccountNumberKey].string
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = otherDetail { dictionary[kBankDetailsOtherDetailKey] = value }
        if let value = accountType { dictionary[kBankDetailsAccountTypeKey] = value }
        if let value = bankName { dictionary[kBankDetailsBankNameKey] = value }
        if let value = bankLogo { dictionary[kBankDetailsBankLogoKey] = value }
        if let value = isPrimary { dictionary[kBankDetailsIsPrimaryKey] = value }
        if let value = ifscCode { dictionary[kBankDetailsIfscCodeKey] = value }
        if let value = bankDetailId { dictionary[kBankDetailsBankDetailIdKey] = value }
        if let value = bankId { dictionary[kBankDetailsBankIdKey] = value }
        if let value = accountNumber { dictionary[kBankDetailsAccountNumberKey] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.otherDetail = aDecoder.decodeObject(forKey: kBankDetailsOtherDetailKey) as? String
        self.accountType = aDecoder.decodeObject(forKey: kBankDetailsAccountTypeKey) as? String
        self.bankName = aDecoder.decodeObject(forKey: kBankDetailsBankNameKey) as? String
        self.bankLogo = aDecoder.decodeObject(forKey: kBankDetailsBankLogoKey) as? String
        self.isPrimary = aDecoder.decodeObject(forKey: kBankDetailsIsPrimaryKey) as? Int
        self.ifscCode = aDecoder.decodeObject(forKey: kBankDetailsIfscCodeKey) as? String
        self.bankDetailId = aDecoder.decodeObject(forKey: kBankDetailsBankDetailIdKey) as? Int
        self.bankId = aDecoder.decodeObject(forKey: kBankDetailsBankIdKey) as? Int
        self.accountNumber = aDecoder.decodeObject(forKey: kBankDetailsAccountNumberKey) as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(otherDetail, forKey: kBankDetailsOtherDetailKey)
        aCoder.encode(accountType, forKey: kBankDetailsAccountTypeKey)
        aCoder.encode(bankName, forKey: kBankDetailsBankNameKey)
        aCoder.encode(bankLogo, forKey: kBankDetailsBankLogoKey)
        aCoder.encode(isPrimary, forKey: kBankDetailsIsPrimaryKey)
        aCoder.encode(ifscCode, forKey: kBankDetailsIfscCodeKey)
        aCoder.encode(bankDetailId, forKey: kBankDetailsBankDetailIdKey)
        aCoder.encode(bankId, forKey: kBankDetailsBankIdKey)
        aCoder.encode(accountNumber, forKey: kBankDetailsAccountNumberKey)
    }
    
}
