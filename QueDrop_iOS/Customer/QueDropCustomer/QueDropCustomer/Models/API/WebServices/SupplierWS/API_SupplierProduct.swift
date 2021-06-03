//
//  API_SupplierProduct.swift
//  QueDrop
//
//  Created by C100-105 on 02/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SwiftyJSON
import IHProgressHUD
import Alamofire

class API_SupplierProduct {
    
    static let shared = API_SupplierProduct()
    
    private func getAddEditProductParams(
        storeCategoryId: Int,
        detail: Struct_ProductDetails) -> NSMutableDictionary {
        
        let param: NSMutableDictionary = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "user_id" : (USER_OBJ?.userId).asInt(),
            "store_category_id" : storeCategoryId,
            "product_name" : detail.name,
            //"product_price" : detail.price,
            "product_description" : detail.descriptionText,
            "addons" : detail.getAddOnStr(),
            "extra_fees_tag" : detail.extraFeeTag ? 1 : 0,
            "price_options" : detail.getPriceOptionStr(),
            "is_available" : detail.isActive ? 1 : 0,
        ]
        
        if let image = detail.image {
            param["product_image"] = image
        }
        
        return param
    }
    
    func validateProductDetails(isAdd: Bool, detail: Struct_ProductDetails) -> (Bool, String) {
        var isValid = false
        var message = ""
        
        if detail.image == nil && isAdd {
            message = "Please select product image"
            
        } else if detail.name.count == 0 {
            message = "Please enter product name"
            
        } else if detail.priceOptions.count == 0 {
            message = "Please add default price"
            
        } else {
            isValid = true
            
        }
        
        if isValid && detail.priceOptions.count > 0 {
            isValid = false
            for priceOption in detail.priceOptions {
                
                if priceOption.name.isEmpty {
                    message = "Please enter appropriate name in price options"
                    break
                } else if priceOption.price < 0 {
                    message = "Please enter appropriate price in price options"
                    break
                } else {
                    isValid = true
                }
            }
        }
        
        if isValid && detail.addOns.count > 0 {
            isValid = false
            for addOn in detail.addOns {
                
                if addOn.name.isEmpty {
                    message = "Please enter appropriate name in addons"
                    break
                } else if addOn.price < 0 {
                    message = "Please enter appropriate price in addons"
                    break
                } else {
                    isValid = true
                }
            }
        }
        
        return (isValid, message)
    }
    
    func callAddEditProductApi(
        isAdd: Bool,
        productId: Int,
        storeCategoryId: Int,
        andDetail detail: Struct_ProductDetails,
        responseData: @escaping SucessCallback<ProductInfo>,
        errorData: @escaping ErrorCallback) {
        
        let isValid = validateProductDetails(isAdd: isAdd, detail: detail)
        
        if !isValid.0 {
            errorData(false, isValid.1)
            return
        }
        
        let param = getAddEditProductParams(storeCategoryId: storeCategoryId, detail: detail)
        
        if !isAdd {
            param["product_id"] = productId
            param["delete_addon_ids"] = detail.addOnsDeleted.removeBraces()
            param["delete_option_ids"] = detail.priceOptionsDeleted.removeBraces()
        }
        
        let url = isAdd ? APIAddSupplierProduct : APIEditSupplierProduct
        
        IHProgressHUD.show()
        APIHelper.shared.postMultipartJSONRequest(endpointurl: url, parameters: param, responseData: { (response, error, message) in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if let response = response {
                if let data = response["data"] as? NSDictionary,
                    let dict = data["product"] {
                    isDone = true
                    let product = JSON(dict).to(type: ProductInfo.self) as! ProductInfo
                    responseData(product)
                }
                messageStr = response["message"] as! String
            } else {
                messageStr = message.asString()
            }
            errorData(isDone, messageStr)
        })
    }
    
    func callDeleteProductApi(
        productId: Int,
        responseData: @escaping (_ isDone: Bool, _ message: String) -> Void) {
        
        let param: NSMutableDictionary = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "product_id" : productId
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIDeleteSupplierProduct, parameter: param as! Parameters, headers: headers, completion: { iscompleted, status, response in
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
    
    func getSupplierProducts(
        storeCategoryId: Int,
        search: String,
        offset: Int,
        responseData: @escaping SucessCallbackList<ProductInfo>,
        errorData: @escaping ErrorCallback) {
        
        let param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "store_category_id" : storeCategoryId,
            "searchText": search.trimmingCharacters(in: .whitespaces),
            "page_num":offset
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APISearchSupplierProduct, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                
                if let data = response["data"] as? NSDictionary,
                    let dict = data["products"] {
                    
                    isDone = true
                    let products = JSON(dict).to(type: ProductInfo.self) as! [ProductInfo]
                    var loadMore = false
                    if let load_more = response["load_more"] as? Bool {
                        loadMore = load_more
                    }
                    responseData(products, loadMore)
                    
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
    
    func getSupplierProducts(
        storeCategoryId: Int,
        responseData: @escaping SucessCallbackList<ProductInfo>,
        errorData: @escaping ErrorCallback) {
        
        let param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "store_category_id" : storeCategoryId
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIGetSupplierProduct, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                
                if let data = response["data"] as? NSDictionary,
                    let dict = data["products"] {
                    isDone = true
                    let products = JSON(dict).to(type: ProductInfo.self) as! [ProductInfo]
                    var loadMore = false
                    if let load_more = response["load_more"] as? Bool {
                        loadMore = load_more
                    }
                    responseData(products, loadMore)
                    
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
