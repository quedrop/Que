//
//  API_SupplierProfile.swift
//  QueDrop
//
//  Created by C100-105 on 08/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SwiftyJSON
import IHProgressHUD
import Alamofire

class API_SupplierProfile {
    
    static let shared = API_SupplierProfile()
    
    func logOutUser(responseData: @escaping (_ isDone: Bool, _ message: String) -> Void) {
        
        let param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "user_id" : USER_ID,
            "device_token" : DEVICE_TOKEN,
            "device_type" : DEVICE_TYPE
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APILogout, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            
            var message = ""
            var isDone = false
            if iscompleted {
                
                isDone = response["status"] as! Bool
                if let msg = response["message"] as? String {
                    message = msg
                }
                
            } else if status == "ConnectionLost" {
                message = "Please check your internet connection.."
            } else {
                message = "Something went wrong.\n Please try after some time. "
            }
            responseData(isDone, message)
        })
    }
    
    func getStoreDetail(
        responseData: @escaping SucessCallback<StoreDetail>,
        errorData: @escaping ErrorCallback) {
        
        let param: Parameters = [
            "secret_key": SECRET_KEY,
            "access_key": ACCESS_KEY,
            "store_id": (USER_OBJ?.storeId).asInt()
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIGetStoreDetails, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                
                if let data = response["data"] as? NSDictionary,
                    let dict = data["store_detail"] {
                    isDone = true
                    let order = JSON(dict).to(type: StoreDetail.self) as! StoreDetail
                    
                    responseData(order)
                }
                messageStr = response["message"] as! String
            } else if status == "ConnectionLost" {
                messageStr = "Please check your internet connection.."
            } else {
                messageStr = "Something went wrong.\n Please try after some time. "
            }
            errorData(isDone, messageStr)
            
        })
    }
    
    func validateProfileDetails(detail: Struct_EditProfileDetails) -> (Bool, String) {
        var isValid = false
        var msg = ""
        
        if detail.fname.isEmpty {
            msg = "Please enter firstname"
            
        } else if detail.username.isEmpty {
            msg = "Please enter username"
            
        } else if detail.phone.isEmpty {
            msg = "Please enter phone number"
            
        } else if let code = detail.country["dial_code"] as? String?, code == nil {
            msg = "Please select country code"
            
        } else {
            isValid = true
        }
        
        return (isValid, msg)
    }
    
    func callEditProfileApi(
        userDetails detail: Struct_EditProfileDetails,
        responseData: @escaping SucessCallback<User>,
        errorData: @escaping ErrorCallback) {
        
        let valid = validateProfileDetails(detail: detail)
        if !valid.0 {
            errorData(false, valid.1)
            return
        }
        
        let param: NSMutableDictionary = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "user_id" : (USER_OBJ?.userId).asInt(),
            "user_name" : detail.username,
            "login_as" : UserType.rawValue,
            "first_name" : detail.fname,
            "last_name" : detail.lname,
            "phone_number" : detail.phone
        ]
        
        if let code = detail.country["dial_code"] as? String {
            param["country_code"] = code
        }
        if let email = USER_OBJ?.email{
            if email.isEmpty && !(detail.email.isEmpty)
            {
                param["email"] = detail.email
            }
        }
        if let image = detail.image {
            param["user_image"] = image
        }
        
        IHProgressHUD.show()
        APIHelper.shared.postMultipartJSONRequest(endpointurl: APIEditProfile, parameters: param, responseData: { (response, error, message) in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if let response = response {
                if let data = response["data"] as? NSDictionary,
                    let dict = data["users"] {
                    isDone = true
                    let user = JSON(dict).to(type: User.self) as! User
                    UserDefaults.standard.setCustom(user, forKey: kUserDetailsUdf)
                    responseData(user)
                    
                }
                messageStr = response["message"] as! String
            } else {
                messageStr = message.asString()
            }
            errorData(isDone, messageStr)
        })
    }
    
    func callChangePasswordAPI(
        detail: Struct_ChangePassword,
        responseData: @escaping ErrorCallback) {
        
        let param: Parameters = [
            "secret_key": SECRET_KEY,
            "access_key": ACCESS_KEY,
            "user_id": USER_ID,
            "old_password": detail.oldPassword,
            "new_password": detail.newPassword
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIChangePassword, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                isDone = true
                messageStr = response["message"] as! String
            } else if status == "ConnectionLost" {
                messageStr = "Please check your internet connection.."
            } else {
                messageStr = "Something went wrong.\n Please try after some time. "
            }
            responseData(isDone, messageStr)
            
        })
    }
    
    func validateStoreDetails(detail: Struct_StoreDetails) -> (Bool, String) {
        var isValid = false
        var msg = ""
        
        if detail.name.isEmpty {
            msg = "Please enter store name"

        } else if detail.address.isEmpty {
            msg = "Please enter store address"

        } else if detail.loc_lat.isEmpty || detail.loc_long.isEmpty {
            msg = "Please select proper address location"
            
        } else {
            
            isValid = true
        }
        
        return (isValid, msg)
    }
    
    func callEditStoreDetailsApi(
        storeDetails detail: Struct_StoreDetails,
        responseData: @escaping SucessCallback<StoreDetail>,
        errorData: @escaping ErrorCallback) {
        
        let valid = validateStoreDetails(detail: detail)
        if !valid.0 {
            errorData(false, valid.1)
            return
        }
        
        let param: NSMutableDictionary = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "user_id" : USER_ID,
            "store_id" : (USER_OBJ?.storeId).asInt(),
            "store_name" : detail.name,
            "store_address" : detail.address,
            "latitude" : detail.loc_lat,
            "longitude" : detail.loc_long,
            "delete_slider_image_ids" : detail.removeImageIds.removeBraces(),
            "slider_image[]" : detail.images,
            "store_schedule" : detail.getScheduleStr(),
            "service_category_id" : detail.serviceCategoryId
        ]
        
        if let image = detail.logoImage {
            param["store_logo"] = image
        }
        
        IHProgressHUD.show()
        APIHelper.shared.postMultipartJSONRequest(endpointurl: APIEditStoreDetails, parameters: param, responseData: { (response, error, message) in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if let response = response {
                if let data = response["data"] as? NSDictionary,
                    let dict = data["store_detail"] {
                    isDone = true
                    let store = JSON(dict).to(type: StoreDetail.self) as! StoreDetail
                    storeDetailsObj = store
                    responseData(store)
                    
                }
                messageStr = response["message"] as! String
            } else {
                messageStr = message.asString()
            }
            errorData(isDone, messageStr)
        })
    }
    
    func validateCreateStoreDetails(detail: Struct_StoreDetails) -> (Bool, String) {
        var isValid = false
        var msg = ""
        
        if detail.logoImage == nil {
            msg = "Please attach store logo"
        }else if detail.name.isEmpty {
            msg = "Please enter store name"

        } else if detail.address.isEmpty {
            msg = "Please enter store address"

        } else if detail.loc_lat.isEmpty || detail.loc_long.isEmpty {
            msg = "Please select proper address location"
            
        } else {
            isValid = true
        }
        
        return (isValid, msg)
    }
    
    func callCreateStoreDetailsApi(
        storeDetails detail: Struct_StoreDetails,
        responseData: @escaping SucessCallback<StoreDetail>,
        errorData: @escaping ErrorCallback) {
        
        let valid = validateCreateStoreDetails(detail: detail)
        if !valid.0 {
            errorData(false, valid.1)
            return
        }
        
        let param: NSMutableDictionary = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "user_id" : USER_ID,
            "store_name" : detail.name,
            "store_address" : detail.address,
            "latitude" : detail.loc_lat,
            "longitude" : detail.loc_long,
            "slider_image[]" : detail.images,
            "store_schedule" : detail.getScheduleStr(),
            "service_category_id" : detail.serviceCategoryId
        ]
        
        if let image = detail.logoImage {
            param["store_logo"] = image
        }
        
        IHProgressHUD.show()
        APIHelper.shared.postMultipartJSONRequest(endpointurl: API_CREATE_STORE, parameters: param, responseData: { (response, error, message) in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if let response = response {
                if let data = response["data"] as? NSDictionary,
                    let dict = data["store_detail"] {
                    isDone = true
                    let store = JSON(dict).to(type: StoreDetail.self) as! StoreDetail
                    storeDetailsObj = store
                    
                    let userObj : User = UserDefaults.standard.getCustom(forKey: kUserDetailsUdf) as! User
                    userObj.storeId = storeDetailsObj?.storeId
                    UserDefaults.standard.removeObject(forKey: kUserDetailsUdf)
                    UserDefaults.standard.setCustom(userObj, forKey: kUserDetailsUdf)
                    
                    responseData(store)
                    
                }
                messageStr = response["message"] as! String
            } else {
                messageStr = message.asString()
            }
            errorData(isDone, messageStr)
        })
    }
    
    
    func validatePaymentDetails(detail: Struct_SupplierBankDetails) -> (Bool, String) {
        var isValid = false
        var msg = ""
        
        if detail.bank == nil {
            msg = "Please select bank"

        } else if detail.accountNumber.isEmpty {
            msg = "Please enter account number"

        } else if detail.ifscCode.isEmpty {
            msg = "Please enter IFSC Code"
            
        } else {
            isValid = true
        }
        
        return (isValid, msg)
    }
    
    func callAddEditPaymentDetailsApi(
        isAdd: Bool,
        bankDetailId: Int,
        bankDetails detail: Struct_SupplierBankDetails,
        responseData: @escaping SucessCallback<SupplierBankDetails>,
        errorData: @escaping ErrorCallback) {
        
        let valid = validatePaymentDetails(detail: detail)
        if !valid.0 {
            errorData(false, valid.1)
            return
        }
        
        let param: NSMutableDictionary = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "user_id" : USER_ID,
            "bank_id" : (detail.bank?.bankId).asInt(),
            "account_number" : detail.accountNumber,
            "account_type" : detail.accountType.rawValue,
            "ifsc_number" : detail.ifscCode,
            "other_detail" : detail.otherDetails,
            "is_primary" : detail.isParimary ? 1 : 0
        ]
        
        if !isAdd {
            param["bank_detail_id"] = bankDetailId
        }
        
        let url = isAdd ? APIAddBankDetail : APIEditBankDetail
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: url, parameter: param as! Parameters, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                
                if let data = response["data"] as? NSDictionary,
                    let dict = data["bank_details"] {
                    
                    isDone = true
                    let bankDetail = JSON(dict).to(type: SupplierBankDetails.self) as! SupplierBankDetails
                    
                    responseData(bankDetail)
                }
                messageStr = response["message"] as! String
            } else if status == "ConnectionLost" {
                messageStr = "Please check your internet connection.."
            } else {
                messageStr = "Something went wrong.\n Please try after some time. "
            }
            errorData(isDone, messageStr)
            
        })
    }
    
    func callDeletePaymentApi(
        paymentId: Int,
        responseData: @escaping (_ isDone: Bool, _ message: String) -> Void) {
        
        let param: NSMutableDictionary = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "bank_detail_id" : paymentId,
            "user_id" : USER_ID
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIDeleteBankDetail, parameter: param as! Parameters, headers: headers, completion: { iscompleted, status, response in
            IHProgressHUD.dismiss()
            
            var message = ""
            var isDone = false
            if iscompleted {
                
                isDone = response["status"] as! Bool
                if let msg = response["message"] as? String {
                    message = msg
                }
                
            } else if status == "ConnectionLost" {
                message = "Please check your internet connection.."
            } else {
                message = "Something went wrong.\n Please try after some time. "
            }
            responseData(isDone, message)
        })
    }
    
    func getSupplierPayments(
        responseData: @escaping SucessCallbackList<SupplierBankDetails>,
        errorData: @escaping ErrorCallback) {
        
        let param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "user_id" : USER_ID
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIGetBankDetails, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                
                if let data = response["data"] as? NSDictionary,
                    let dict = data["bank_details"] {
                    
                    isDone = true
                    let bank_details = JSON(dict).to(type: SupplierBankDetails.self) as! [SupplierBankDetails]
                    var loadMore = false
                    if let load_more = response["load_more"] as? Bool {
                        loadMore = load_more
                    }
                    responseData(bank_details, loadMore)
                    
                }
                messageStr = response["message"] as! String
                
            } else if status == "ConnectionLost" {
                messageStr = "Please check your internet connection.."
            } else {
                messageStr = "Something went wrong.\n Please try after some time. "
            }
            errorData(isDone, messageStr)
            
        })
    }
    
    func getBankList(
        responseData: @escaping SucessCallbackList<SupplierBanks>,
        errorData: @escaping ErrorCallback) {
        
        let param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIGetBankNameList, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                
                if let data = response["data"] as? NSDictionary,
                    let dict = data["banks"] {
                    
                    isDone = true
                    let banks = JSON(dict).to(type: SupplierBanks.self) as! [SupplierBanks]
                    var loadMore = false
                    if let load_more = response["load_more"] as? Bool {
                        loadMore = load_more
                    }
                    responseData(banks, loadMore)
                    
                }
                messageStr = response["message"] as! String
                
            } else if status == "ConnectionLost" {
                messageStr = "Please check your internet connection.."
            } else {
                messageStr = "Something went wrong.\n Please try after some time. "
            }
            errorData(isDone, messageStr)
            
        })
    }
    
    func getServiceCategories(
        responseData: @escaping SucessCallbackList<ServiceCategories>,
        errorData: @escaping ErrorCallback) {
        
        let param: Parameters = [
            "secret_key": SECRET_KEY,
            "access_key": ACCESS_KEY
        ]
        
        //IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIGetAllServiceCategory, parameter: param, headers: headers, completion: { iscompleted,status,response in
            //IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                
                if let data = response["data"] as? NSDictionary,
                    let categoryArray = data["service_categories"] as? NSArray{
                    isDone = true
                    let arr = JSON(categoryArray).to(type: ServiceCategories.self) as! [ServiceCategories]
                    responseData(arr, false)
                }
                
            } else if status == "ConnectionLost" {
                messageStr = "Please check your internet connection.."
            } else {
                messageStr = "Something went wrong.\n Please try after some time. "
            }
            errorData(isDone, messageStr)
            
        })
    }
}
