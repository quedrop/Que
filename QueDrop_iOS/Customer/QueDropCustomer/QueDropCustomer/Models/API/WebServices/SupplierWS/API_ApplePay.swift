//
//  API_ApplePay.swift
//  GoferDeliveryCustomer
//
//  Created by C100-174 on 31/07/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SwiftyJSON
import IHProgressHUD
import Alamofire

class API_ApplePay {
    
    static let shared = API_ApplePay()
    
    
    func chargeApplePayForChange(
        orderId : Int,
        amount : Float,
        paymentMethodNonce : String,
        deviceData : String,
        postalCode : String,
        responseData: @escaping SucessCallback<ApplePaySecret>,
        errorData: @escaping ErrorCallback)  {
        
        let amt = String(format: "%.2f", amount)
        
        let param: NSMutableDictionary = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "order_id" : orderId,
            "user_id" : (USER_OBJ?.userId).asInt(),
            "amount" : amt,
            "payment_method_nonce" : paymentMethodNonce,
            "client_device_data" : deviceData,
            "postal_code" : postalCode
        ]
        
        APIHelper.shared.postJsonRequest(url: API_APPLE_PAY_SECRET, parameter: param as! Parameters, headers: headers, completion: { iscompleted,status,response in
            
            var isDone = false
            var messageStr = ""
            
            if iscompleted {
                isDone = response["status"] as! Bool
                
                if isDone {
                    if let data = response["data"] as? NSDictionary,
                        let dict = data["apple_pay_secret"] {
                        isDone = true
                        let orders = JSON(dict).to(type: ApplePaySecret.self) as! ApplePaySecret
                        responseData(orders)
                    }
                    //messageStr = response["message"] as! String
                } else {
                    messageStr = "Something went wrong.\n Please try after some time. "
                    errorData(isDone, messageStr)
                }
            } else if status == "ConnectionLost" {
                messageStr = "Please check your internet connection.."
                errorData(isDone, messageStr)
            } else {
                messageStr = "Something went wrong.\n Please try after some time. "
                errorData(isDone, messageStr)
            }
            
        })
        
    }
    
}
