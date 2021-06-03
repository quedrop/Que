//
//  API_SupplierOrder.swift
//  QueDrop
//
//  Created by C100-105 on 03/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SwiftyJSON
import IHProgressHUD
import Alamofire

class API_SupplierOrder {
    
    static let shared = API_SupplierOrder()

    func getSupplierOrders(
        orderType: Enum_OrderType,
        offset: Int,
        responseData: @escaping SucessCallbackList<SupplierOrder>,
        errorData: @escaping ErrorCallback) {
        
        let param: NSMutableDictionary = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "store_id" : (USER_OBJ?.storeId).asInt(),
            "user_id": USER_ID,
            "is_for_current": orderType.rawValue,
            "page_num": offset
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIGetSupplierOrders, parameter: param as! Parameters, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                
                if let data = response["data"] as? NSDictionary,
                    let dict = data["supplier_order"] {
                    isDone = true
                    let orders = JSON(dict).to(type: SupplierOrder.self) as! [SupplierOrder]
                    var loadMore = false
                    if let load_more = response["load_more"] as? Bool {
                        loadMore = load_more
                    }
                    responseData(orders, loadMore)
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
    
    func getSingleSupplierOrder(
        orderId: Int,
        responseData: @escaping SucessCallback<SupplierOrder>,
        errorData: @escaping ErrorCallback) {
        
        let param: NSMutableDictionary = [
            "secret_key": SECRET_KEY,
            "access_key": ACCESS_KEY,
            "user_id": USER_ID,
            "order_id":orderId,
            "store_id" : (USER_OBJ?.storeId).asInt()
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIGetSingleSupplierOrderDetail, parameter: param as! Parameters, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                
                if let data = response["data"] as? NSDictionary,
                    let dict = data["order_detail"] {
                    isDone = true
                    let order = JSON(dict).to(type: SupplierOrder.self) as! SupplierOrder
                    
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
    
}
