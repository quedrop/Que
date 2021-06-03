//
//  StructTypes.swift
//  QueDrop
//
//  Created by C100-105 on 02/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

struct Struct_AddCategoryDetails {
    var name = ""
    var image: UIImage? = nil
}

struct Struct_AddAddOnDetails {
    var id: Int?
    var name = ""
    var price: Float = 0
}

struct Struct_AddPriceOptionsDetails {
    var id: Int?
    var name = ""
    var price: Float = 0
}

struct Struct_ProductDetails {
    var name = "", descriptionText = ""
    var extraFeeTag: Bool = false
    var isActive: Bool = true
    var image: UIImage? = nil
    var addOns: [Struct_AddAddOnDetails] = []
    var priceOptions: [Struct_AddPriceOptionsDetails] = []
    
    var addOnsDeleted: [Int] = []
    var priceOptionsDeleted: [Int] = []
    
    var defaultPriceOptionIndex = 0
    
    func getPriceOptionStr() -> String {
        
        var temp: [String] = []
        var index = 0
        for option in priceOptions {
            let isDefault = defaultPriceOptionIndex == index ? "1" : "0"
            
            let data = "{"
                + "\"option_id\":\"" + option.id.asInt().description + "\","
                + "\"option_name\":\"" + option.name + "\","
                + "\"price\":\"" + option.price.description + "\","
                + "\"is_default\":\"" + isDefault + "\""
                + "}"
            temp.append(data)
            
            index += 1
        }
        return !temp.isEmpty ? "[" + temp.joined(separator: ",") + "]" : ""
    }
    
    func getAddOnStr() -> String {
        var temp: [String] = []
        for addon in addOns {
            let data = "{"
                + "\"addon_id\":\"" + addon.id.asInt().description + "\","
                + "\"addon_name\":\"" + addon.name + "\","
                + "\"addon_price\":\"" + addon.price.description + "\""
                + "}"
            temp.append(data)
        }
        return !temp.isEmpty ? "[" + temp.joined(separator: ",") + "]" : ""
    }
}


struct Struct_OfferDetails {
    
    var category: FoodCategory?
    var product: ProductInfo?
    
    var code = ""
    var percentage = 0
    
    var startTime: Date?
    var endTime: Date?
    
    var additionalInfo = ""
    var isActive = true
    
}

struct Struct_EditProfileDetails {
    var image: UIImage? = nil
    var fname = ""
    var lname = ""
    var username = ""
    var phone = ""
    var email = ""
    var country: [String: Any] = getCountryDialCode(strCode: getCountryCode())
}

struct Struct_SettingData {
    let image: UIImage
    let title: String
}

struct Struct_ChangePassword {
    var oldPassword = ""
    var newPassword = ""
    var confirmPassword = ""
    
}

struct Struct_StoreDetails {
//    private let weekDayStrArr = [
//        "Sunday",
//        "Monday",
//        "Tuesday",
//        "Wednesday",
//        "Thursday",
//        "Friday",
//        "Saturday"
//    ]
    
    var name = ""
    var address = ""
    var loc_lat = ""
    var loc_long = ""
    
    var logo = ""
    var logoImage : UIImage? = nil
    
    var removeImageIds: [Int] = []
    var images: [UIImage] = []
    
    var imagesUrls: [String] = []
    
    var schedule: [Schedule] = []
    var serviceCategory = ""
    var serviceCategoryId = 0
    
    func getScheduleStr() -> String {
        var temp: [String] = []
        for s in schedule {
            if s.scheduleId == 0 {
                let data = "{"
                    + "\"opening_time\":\"" + s.openingTime.asString() + "\","
                    + "\"closing_time\":\"" + s.closingTime.asString() + "\","
                    + "\"weekday\":\"" + s.weekday.asString() + "\","
                    + "\"is_closed\":\"" + s.isClosed.asInt().description + "\""
                    + "}"
                temp.append(data)
            } else {
                let data = "{"
                    + "\"schedule_id\":\"" + s.scheduleId.asInt().description + "\","
                    + "\"opening_time\":\"" + s.openingTime.asString() + "\","
                    + "\"closing_time\":\"" + s.closingTime.asString() + "\","
                    + "\"weekday\":\"" + s.weekday.asString() + "\","
                    + "\"is_closed\":\"" + s.isClosed.asInt().description + "\""
                    + "}"
                temp.append(data)
            }
            
        }
        return !temp.isEmpty ? "[" + temp.joined(separator: ",") + "]" : ""
    }
}

struct Struct_SupplierBankDetails {
    var bank: SupplierBanks?
    
    var accountNumber = ""
    var ifscCode = ""
    var otherDetails = ""
    
    //1- saving, 2-current
    var accountType = Enum_BankAccountType.Saving
    
    var isParimary = false
}
