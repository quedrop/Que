//
//  API_SupplierCategory.swift
//  QueDrop
//
//  Created by C100-105 on 02/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SwiftyJSON
import IHProgressHUD
import Alamofire

class API_SupplierCategory {
    
    static let shared = API_SupplierCategory()
    
    func callAddEditCategoryApi(
        isAdd: Bool,
        categoeyId: Int,
        categoryDetails detail: Struct_AddCategoryDetails,
        responseData: @escaping SucessCallback<FoodCategory>,
        errorData: @escaping ErrorCallback) {
        
        let param: NSMutableDictionary = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "store_id" : (USER_OBJ?.storeId).asInt(),
            "user_id" : (USER_OBJ?.userId).asInt(),
            "category_name" : detail.name
        ]
        
        if let image = detail.image {
            param["category_image"] = image
        }
        
        if !isAdd {
            param["store_category_id"] = categoeyId
        }
        
        let url = isAdd ? APIAddSupplierCategory : APIEditSupplierCategory
        
        IHProgressHUD.show()
        APIHelper.shared.postMultipartJSONRequest(endpointurl: url, parameters: param, responseData: { (response, error, message) in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if let response = response {
                if let data = response["data"] as? NSDictionary,
                    let dict = data["category"] {
                    isDone = true
                    let category = JSON(dict).to(type: FoodCategory.self) as! FoodCategory
                    responseData(category)
                    
                }
                messageStr = response["message"] as! String
            } else {
                messageStr = message.asString()
            }
            errorData(isDone, messageStr)
        })
    }
    
    func callDeleteCategoryApi(
        categoryId: Int,
        responseData: @escaping (_ isDone: Bool, _ message: String) -> Void) {
        
        
        let param: NSMutableDictionary = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "store_id" : (USER_OBJ?.storeId).asInt(),
            "store_category_id" : categoryId
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIDeleteSupplierCategory, parameter: param as! Parameters, headers: headers, completion: { iscompleted, status, response in
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
    
    func getSupplierCategories(
        responseData: @escaping SucessCallbackList<FoodCategory>,
        errorData: @escaping ErrorCallback) {
        
        let param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "store_id" : (USER_OBJ?.storeId).asInt(),
            "user_id" : USER_ID
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIGetSupplierCategories, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                
                if let data = response["data"] as? NSDictionary,
                    let dict = data["categories"] as? NSArray, dict.count > 0 {
                    isDone = true
                    let categories = JSON(dict).to(type: FoodCategory.self) as! [FoodCategory]
                    responseData(categories, false)
                    
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
    
    func getSupplierFreshProduceCategories(
        responseData: @escaping SucessCallbackList<FoodCategory>,
        errorData: @escaping ErrorCallback) {
        
        let param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "store_id" : (USER_OBJ?.storeId).asInt(),
            "user_id" : USER_ID
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIGetSupplierFreshProduceCategories, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                
                if let data = response["data"] as? NSDictionary,
                    let dict = data["categories"] as? NSArray, dict.count > 0 {
                    isDone = true
                    let categories = JSON(dict).to(type: FoodCategory.self) as! [FoodCategory]
                    responseData(categories, false)
                    
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
    
    func getFreshProducedCategories(
           responseData: @escaping SucessCallbackList<FreshProduceCategories>,
           errorData: @escaping ErrorCallback) {
           
           let param: Parameters = [
               "secret_key" : SECRET_KEY,
               "access_key" : ACCESS_KEY,
               "store_id" : (USER_OBJ?.storeId).asInt(),
               "user_id" : USER_ID
           ]
           
           IHProgressHUD.show()
           APIHelper.shared.postJsonRequest(url: APIGetFreshProducedCategory, parameter: param, headers: headers, completion: { iscompleted,status,response in
               IHProgressHUD.dismiss()
               
               var isDone = false
               var messageStr = ""
               
               if iscompleted {
                   
                   if let data = response["data"] as? NSDictionary,
                       let dict = data["fresh_produce_categories"] as? NSArray, dict.count > 0 {
                       isDone = true
                       let categories = JSON(dict).to(type: FreshProduceCategories.self) as! [FreshProduceCategories]
                       responseData(categories, false)
                       
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
    
    func callAddFreshProducedCategory(
        categoryId: Int,
        responseData: @escaping SucessCallbackList<FoodCategory>,
        errorData: @escaping ErrorCallback) {
        
         let param: NSMutableDictionary = [
                   "secret_key" : SECRET_KEY,
                   "access_key" : ACCESS_KEY,
                   "store_id" : (USER_OBJ?.storeId).asInt(),
                   "user_id" : USER_ID,
                   "fresh_produce_category_id" : categoryId
               ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIAddFreshProducedCategory, parameter: param as! Parameters, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                
                if let data = response["data"] as? NSDictionary,
                    let dict = data["categories"] as? NSArray, dict.count > 0 {
                    isDone = true
                    let categories = JSON(dict).to(type: FoodCategory.self) as! [FoodCategory]
                    responseData(categories, false)
                    
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
