//
//  API_SupplierNotification.swift
//  QueDrop
//
//  Created by C100-105 on 07/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SwiftyJSON
import IHProgressHUD
import Alamofire

class API_SupplierNotification {
    
    static let shared = API_SupplierNotification()
   
    func getSupplierNotifications(
        responseData: @escaping SucessCallbackList<SupplierNotifications>,
        errorData: @escaping ErrorCallback) {
        
        let param: NSMutableDictionary = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "user_id" : USER_ID
        ]
        
        IHProgressHUD.show()
        APIHelper.shared.postJsonRequest(url: APIGetNotifications, parameter: param as! Parameters, headers: headers, completion: { iscompleted, status, response in
            IHProgressHUD.dismiss()
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                
                if let data = response["data"] as? NSDictionary,
                    let dict = data["notifications"] {
                    isDone = true
                    let notifications = JSON(dict).to(type: SupplierNotifications.self) as! [SupplierNotifications]
                    responseData(notifications, false)
                    
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
