//
//  API_SupplierOffer.swift
//  QueDrop
//
//  Created by C100-105 on 06/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SwiftyJSON
import IHProgressHUD
import Alamofire

class API_SupplierOffer {
    
    static let shared = API_SupplierOffer()
    
    func validateOfferDetails(isAdd: Bool, detail: Struct_OfferDetails) -> (Bool, String) {
        var isValid = false
        var message = ""
        
        if detail.category == nil {
            message = "Please select category"
            
        } else if detail.product == nil {
            message = "Please select product"
            
        } else if detail.percentage <= 0 {
            message = "Please enter percentage"
            
        } else if detail.startTime == nil {
            message = "Please select offer start time"
            
        } else if detail.endTime == nil {
            message = "Please select offer expiration time"
            
        } else if let start = detail.startTime, let end = detail.endTime {
            if start == end {
                message = "Offer start and expiration time must not be same."
            } else if start > end {
                message = "Please select offer expiration time less then start time"
            } else {
                isValid = true
            }
        }
        
        return (isValid, message)
    }
    
    func callAddEditOfferApi(
        isAdd: Bool,
        productOfferId: Int,
        offerDetails detail: Struct_OfferDetails,
        responseData: @escaping SucessCallback<SupplierOffer>,
        errorData: @escaping ErrorCallback) {
        
        let isValid = validateOfferDetails(isAdd: isAdd, detail: detail)
        
        if !isValid.0 {
            errorData(false, isValid.1)
            return
        }
        
        var startDate = ""
        if let time = detail.startTime?.toString(format: "yyyy-MM-dd") {
            startDate = time
        }
        
        var startTime = ""
        if let time = detail.startTime?.toString(format: "HH:mm:ss") {
            startTime = time
        }
        
        var endDate = ""
        if let time = detail.endTime?.toString(format: "yyyy-MM-dd") {
            endDate = time
        }
        
        var endTime = ""
        if let time = detail.endTime?.toString(format: "HH:mm:ss") {
            endTime = time
        }
        
        let param: NSMutableDictionary = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "store_id" : (USER_OBJ?.storeId).asInt(),
            "store_category_id": (detail.category?.storeCategoryId).asInt(),
            "product_id": (detail.product?.productId).asInt(),
            "offer_percentage": detail.percentage,
            "offer_code": detail.code,
            "start_date": startDate,
            "start_time": startTime,
            "expiration_date": endDate,
            "expiration_time": endTime,
            "additional_info": detail.additionalInfo,
            "is_active": detail.isActive ? 1 : 0
        ]
        
        if !isAdd {
            param["product_offer_id"] = productOfferId
        }
        
        let url = isAdd ? APIAddProductOffer : APIEditProductOffer
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(
            url: url,
            parameter: param as! Parameters,
            headers: headers,
            completion: { iscompleted, status, response in
                IHProgressHUD.dismiss()
                
                var messageStr = ""
                var isDone = false
                
                if iscompleted {
                    if let data = response["data"] as? NSDictionary,
                        let dict = data["offer"] {
                        isDone = true
                        let offer = JSON(dict).to(type: SupplierOffer.self) as! SupplierOffer
                        responseData(offer)
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
    
    func callDeleteCategoryApi(
        productOfferId: Int,
        responseData: @escaping (_ isDone: Bool, _ message: String) -> Void) {
        
        
        let param: NSMutableDictionary = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "product_offer_id" : productOfferId
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIDeleteProductOffer, parameter: param as! Parameters, headers: headers, completion: { iscompleted, status, response in
            IHProgressHUD.dismiss()
            
            var messageStr = ""
            var isDone = false
            if iscompleted {
                
                isDone = response["status"] as! Bool
                if let msg = response["message"] as? String {
                    messageStr = msg
                }
                
            } else if status == "ConnectionLost" {
                messageStr = "Please check your internet connection.."
            } else {
                messageStr = "Something went wrong.\n Please try after some time. "
            }
            responseData(isDone, messageStr)
        })
    }
    
    func getSupplierOffers(
        responseData: @escaping SucessCallbackList<SupplierOffer>,
        errorData: @escaping ErrorCallback) {
        
        let param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "store_id" : (USER_OBJ?.storeId).asInt(),
            "user_id" : USER_ID
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIGetAllProductOffers, parameter: param, headers: headers, completion: { iscompleted, status, response in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                
                if let data = response["data"] as? NSDictionary,
                    let dict = data["offers"] {
                    isDone = true
                    let offers = JSON(dict).to(type: SupplierOffer.self) as! [SupplierOffer]
                    responseData(offers, false)
                    
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
}
