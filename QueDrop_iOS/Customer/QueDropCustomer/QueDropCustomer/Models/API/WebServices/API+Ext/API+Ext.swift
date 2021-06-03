//
//  API+Ext.swift
//  QueDrop
//
//  Created by C100-104 on 28/01/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import IHProgressHUD

extension LoginVC{
    func doLogin()
    {
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let param : Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "password": password,
            "guest_user_id" : isGuest ? USER_OBJ?.guestUserId ?? 0 : 0,
            "login_as": UserType.rawValue,
            "email": emailId,
            "device_type": DEVICE_TYPE,
            "device_token": FCM_TOKEN,
            "timezone" : TIME_ZONE
        ]
        APIHelper.shared.postJsonRequest(url: API_LOGIN, parameter: param, headers: headers) { (isCompleted, status, response) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if isCompleted {
                if !(response["status"] as! Bool) {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else {
                    print(response["data"] as Any)
                    let data = response["data"] as! NSDictionary
                    let userDict = data["user"] as! NSDictionary
                    let user: User = User(json: JSON(userDict))
                    saveUserInUserDefaults(user: user)
                    
                    UserDefaults.standard.set("\(self.isRememberMe)", forKey: self.kIsRememberMe + self.userTypeStr)
                    if self.isRememberMe {
                        UserDefaults.standard.set("\(self.emailId)", forKey: self.kEmail + self.userTypeStr)
                        UserDefaults.standard.set("\(self.password)", forKey: self.kPassword + self.userTypeStr)
                        
                    } else {
                        UserDefaults.standard.set("", forKey: self.kEmail + self.userTypeStr)
                        UserDefaults.standard.set("", forKey: self.kPassword + self.userTypeStr)
                    }
                    
                    self.navigateToHome(from: .login)
                }
            }
            else{
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        }
    }
    
    func checkAccountAvailability(loginType : String , userSocialId : String,firstName : String,lastName : String ,email : String ,profilePic_url : String)
    {
        // loginType - ('Standard', 'Facebook', 'Google')
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let param : Parameters = [
            "guest_user_id" : isGuest ? USER_OBJ?.guestUserId ?? 0 : 0,
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "login_type": loginType,
            "firstname" : firstName,
            "lastname" : lastName,
            "login_as": UserType.rawValue,
            "socialKey": userSocialId,
            "email": email,
            "device_type": DEVICE_TYPE,
            "device_token": FCM_TOKEN,
            "timezone" : TIME_ZONE,
            "latitude" : defaultAddress?.latitude ?? "",
            "longitude" : defaultAddress?.longitude ?? "",
            "address" : defaultAddress?.address ?? "",
            "is_for_validation" : "1"
        ]
        APIHelper.shared.postJsonRequest(url: API_SOCIAL_REGISTER, parameter: param, headers: headers) { (isCompleted, status, response) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if isCompleted {
                if !(response["status"] as! Bool) {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else {
                    print(response["data"] as Any)
                    let data = response["data"] as! NSDictionary
                    if let isUserAvailable = data["is_user_available"] as? Bool , isUserAvailable
                    {
                        let userDict = data["user"] as! NSDictionary
                        let user: User = User(json: JSON(userDict))
                        UserDefaults.standard.setCustom(user, forKey: kUserDetailsUdf)
                        self.navigateToHome(from: .login)
                    }
                    else
                    {
                        let vc = LoginStoryboard.instantiateViewController(withIdentifier: "AdditionalDetailsVC") as! AdditionalDetailsVC
                        vc.SetDetails(loginType: /*"Google"*/loginType, userSocialId: userSocialId, firstName: firstName, lastName: lastName, email: email, profilePic_url: profilePic_url)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            else{
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        }
    }
    
}
extension AdditionalDetailsVC {
    func doLoginWithSocialAccount(loginType : String , userSocialId : String,firstName : String,lastName : String ,email : String ,profilePic_url : String)
    {
        // loginType - ('Standard', 'Facebook', 'Google')
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let param : Parameters = [
            "guest_user_id" : isGuest ? USER_OBJ?.guestUserId ?? 0 : 0,
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "firstname" : firstName,
            "lastname" : lastName,
            "login_type": loginType,
            "login_as": UserType.rawValue,
            "socialKey": userSocialId,
            "email": email,
            "device_type": DEVICE_TYPE,
            "device_token": FCM_TOKEN,
            "timezone" : TIME_ZONE,
            "latitude" : defaultAddress?.latitude ?? "",
            "longitude" : defaultAddress?.longitude ?? "",
            "address" : defaultAddress?.address ?? "",
            "referral_code" : rCode,
            "user_image" : profilePic_url,
            "is_for_validation" : "0"
        ]
        APIHelper.shared.postJsonRequest(url: API_SOCIAL_REGISTER, parameter: param, headers: headers) { (isCompleted, status, response) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if isCompleted {
                if !(response["status"] as! Bool) {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else {
                    print(response["data"] as Any)
                    let data = response["data"] as! NSDictionary
                    let userDict = data["user"] as! NSDictionary
                    let user: User = User(json: JSON(userDict))
                    //saveUserInUserDefaults(user: user)
                    UserDefaults.standard.setCustom(user, forKey: kUserDetailsUdf)
                    self.navigateToHome(from: .register)
                }
            }
            else{
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        }
    }
}
extension ForgotPasswordVC{
    func forgotPassword() {
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "device_type": DEVICE_TYPE,
            "device_token": FCM_TOKEN,
            "timezone" : TIME_ZONE,
            "email" : txtEmail.text ?? ""
        ]
        APIHelper.shared.postJsonRequest(url: API_FORGOT_PASSWORD, parameter: param, headers: headers) { (isCompleted, status, response) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if isCompleted {
                if !(response["status"] as! Bool) {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else {
                    print(response["data"] as Any)
                    ShowToast(message: "New Password has been sent to your emaild id.")
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else{
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        }
        
    }
}
extension SignUpVC {
    
    func doRegistration(fname : String, lname : String, password : String, referral_code : String, email : String)  {
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        var param: Parameters = [
            "guest_user_id" : isGuest ? "\(USER_OBJ?.guestUserId ?? 0)" : "0",
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "firstname" : fname,
            "lastname" : lname,
            "password": password,
            "login_as" : UserType.rawValue,
            "referral_code": referral_code,
            "email": email,
            "device_type": "\(DEVICE_TYPE)",
            "device_token": FCM_TOKEN,
            "timezone" : TimeZone.current.identifier,
            "latitude" : defaultAddress?.latitude ?? "0.0",
            "longitude" : defaultAddress?.longitude ?? "0.0",
            "address" : defaultAddress?.address ?? ""
        ]
        
        if isImageSelected {
            param["user_image"] = imgUser.image
        }
        
        APIHelper.shared.postMultipartJSONRequest(endpointurl: API_SIGNUP, parameters: param as NSDictionary) { (response, error, message) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            
            if response != nil
           {
               if !(response?["status"] as! Bool) {
                   ShowToast(message: response?["message"] as! String)
               }
               else{
                   if let data = response?["data"] as? NSDictionary {
                    print(response!["data"] as Any)
                       let userDict = data["user"] as! NSDictionary
                        let user: User = User(json: JSON(userDict))
                      UserDefaults.standard.setCustom(user, forKey: kUserDetailsUdf)
                      //self.navigateToHome()
                      self.navigateToHome(from: .register)
                   }
               }
           } else {
               //responseData(false, error, message)
               ShowToast(message: response?["message"] as? String ?? "")
           }
        }
        
        /*APIHelper.shared.postJsonRequest(url: API_SIGNUP, parameter: param, headers: headers) { (isCompleted, status, response) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if isCompleted {
                if !(response["status"] as! Bool) {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else {
                    print(response["data"] as Any)
                    let data = response["data"] as! NSDictionary
                    let userDict = data["user"] as! NSDictionary
                    let user: User = User(json: JSON(userDict))
                    UserDefaults.standard.setCustom(user, forKey: kUserDetailsUdf)
                    //self.navigateToHome()
                    self.navigateToHome(from: .register)
                }
            }
            else{
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        }*/
    }
    
    func checkReferralCodeValidity(referralCode : String)  {
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "login_as" : "Customer",
            "referral_code": referralCode
        ]
        
        APIHelper.shared.postJsonRequest(url: API_CHECK_REFERRAL_CODE_VALIDITY, parameter: param, headers: headers) { (isCompleted, status, response) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if isCompleted {
                if !(response["status"] as! Bool) {
                    ShowToast(message: response["message"] as! String)
                }
                else {
                    ShowToast(message: response["message"] as! String)
                }
            }
            else{
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    if response.count == 0 {
                        ShowToast(message: "Something went wrong. Please Try Again")
                    }else {
                        ShowToast(message: response["message"] as! String)
                    }
                }
            }
        }
    }
}

extension MobileVerificationVC {
    
    func sendOTP(strCountryCode : String, mobileNumber : String) {
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "country_code" : strCountryCode,
            "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
            "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0,
            "phone_number" : mobileNumber
        ]
        
        APIHelper.shared.postJsonRequest(url: API_SENDOTP, parameter: param, headers: headers) { (isCompleted, status, response) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if isCompleted {
                if !(response["status"] as! Bool) {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else {
                    //Navigate to Code Verification Screen
                    USER_OBJ?.phoneNumber = mobileNumber
                    self.navigateToCodeVerification()
                }
            }
            else{
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        }
    }
}

extension OTPVerificationVC {
    func verifyOTP(strCountryCode : String, mobileNumber : String, strCode : String) {
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "country_code" : strCountryCode,
            "phone_number" : mobileNumber,
            "otp_code" : strCode,
            "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
            "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0
        ]
        
        APIHelper.shared.postJsonRequest(url: API_VERIFYOTP, parameter: param, headers: headers) { (isCompleted, status, response) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if isCompleted {
                if !(response["status"] as! Bool) {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else {
                    //Navigate to Home Screen
                    let data = response["data"] as! NSDictionary
                    let userDict = data["user"] as! NSDictionary
                    let user: User = User(json: JSON(userDict))
                    UserDefaults.standard.setCustom(user, forKey: kUserDetailsUdf)
                    //self.navigateToHome()
                    if currScreen != nil && (currScreen == .editProfile || currScreen == .profile)
                    {
                        currScreen = nil
                        self.popTwoViewBack()
                    }
                    else if currScreen != nil && currScreen == .cart
                    {
                        currScreen = nil
                        self.popTwoViewBack(true)
                    }
                    else
                    {
                        self.navigateToHome(from: .login)
                    }
                }
            }
            else{
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        }
    }
}

extension CustomerLocationVC
{
    func guestRegister()
    {
        
        let number = Int.random(in: 0...99999999)
        let Name : String = "Guest_\(number)"
        IHProgressHUD.show()
        
        let param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "name" : Name,
            "uuid" : uuId,
            "device_type": DEVICE_TYPE,
            "device_token": FCM_TOKEN,
            "latitude" : "\(currentLocation?.coordinate.latitude ?? 0.0)",
            "longitude" : "\(currentLocation?.coordinate.longitude ?? 0.0)",
            "address" : address]
        APIHelper.shared.postJsonRequest(url: APIGuestLogin, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    print(response["data"])
                    let data = response["data"] as! NSDictionary
                    let userDict = data["guest_user"] as! NSDictionary
                    //print(userobj)
                    let user: User = User(json: JSON(userDict))
                    user.firstName = Name
                    UserDefaults.standard.setCustom(user, forKey: kUserDetailsUdf)
                    //SocketIOManager.shared.connectSocket()
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    
    func saveAddress(name: String , unitNum : String , lat : String , lon : String , info :String ,type : Int, address : String)
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                 "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0,
                                 "address_name" : name,
                                 "unit_number" : unitNum,
                                 "latitude" : lat,
                                 "longitude" : lon,
                                 "additional_info" : info,
                                 "address_type" : "\(type)",
            "address": address]
        
        APIHelper.shared.postJsonRequest(url: APIAddAddress, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    print(response["data"])
                    let data = response["data"] as? NSDictionary
                    if data != nil
                    {
                        var addressArray = data?["addresses"] as? NSArray
                        if addressArray !=  nil
                        {
                            Addresses.removeAll()
                            for address in addressArray!
                            {
                                let add	: Address = Address(json: JSON(address))
                                Addresses.append(add)
                            }
                            
                            print("Address Array :",Addresses)
                            self.tableViewBottom.reloadData()
                        }
                    }
                    
                }
                if Addresses.count == 0
                {
                    self.constraintBottomViewHeight.constant = 200
                }
                else
                {
                    self.constraintBottomViewHeight.constant = 300
                }
                self.actionBack(self.btnBack)
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    
    func getAddresses()
    {
        IHProgressHUD.show()
        let param: Parameters = [	"secret_key" : SECRET_KEY,
                                     "access_key" : ACCESS_KEY,
                                     "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                     "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0
        ]
        
        APIHelper.shared.postJsonRequest(url: APIGetCustomerAddresses, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    //self.showAlert(title: "Alert", message: response["message"] as? String ?? "Something went wrong.")
                    Addresses.removeAll()
                }
                else
                {
                    print(response["data"])
                    let data = response["data"] as? NSDictionary
                    if data != nil
                    {
                        var addressArray = data?["addresses"] as? NSArray
                        if addressArray !=  nil
                        {
                            Addresses.removeAll()
                            for address in addressArray!
                            {
                                let add	: Address = Address(json: JSON(address))
                                Addresses.append(add)
                            }
                            print("Address Array :",Addresses)
                        }
                    }
                }
                self.tableViewBottom.reloadData()
                if Addresses.count == 0
                {
                    self.constraintBottomViewHeight.constant = 180
                }
                else
                {
                    self.constraintBottomViewHeight.constant = (screenHeight > 680) ? 300 : 250
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    
    func EditAddress(name: String ,unitNum : String, lat : String , lon : String , info :String ,type : Int, address : String)
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                 "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0,
                                 "address_id" : selectedAddressId,
                                 "address_name" : name,
                                 "unit_number" : unitNum,
                                 "latitude" : lat,
                                 "longitude" : lon,
                                 "additional_info" : info,
                                 "address_type" : type,
                                 "address": address,
                                 "is_default":"0"]
        
        APIHelper.shared.postJsonRequest(url: APIEditAddress, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    print(response["data"])
                    let data = response["data"] as? NSDictionary
                    if data != nil
                    {
                        var addressArray = data?["addresses"] as? NSArray
                        if addressArray !=  nil
                        {
                            Addresses.removeAll()
                            for address in addressArray!
                            {
                                let add	: Address = Address(json: JSON(address))
                                Addresses.append(add)
                            }
                            
                            self.tableViewBottom.reloadData()
                            print("Address Array :",Addresses)
                        }
                    }
                    //print(userobj)
                    
                    
                }
                self.actionBack(self.btnBack)
                if Addresses.count == 0
                {
                    self.constraintBottomViewHeight.constant = 180
                }
                else
                {
                    self.constraintBottomViewHeight.constant = 300
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    
    func deleteSelectedAddress()
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "address_id" : selectedAddressId,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                 "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0]
        
        APIHelper.shared.postJsonRequest(url: APIDeleteAddress, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    print(response["message"])
                    /*let data = response["data"] as? NSDictionary
                     if data != nil
                     {
                     //						var addressArray = data?["addresses"] as? NSArray
                     //						if addressArray !=  nil
                     //						{
                     //							Addresses.removeAll()
                     //							for address in addressArray!
                     //							{
                     //								let add	: Address = Address(json: JSON(address))
                     //								Addresses.append(add)
                     //							}
                     //
                     //							self.tableViewBottom.reloadData()
                     //							print("Address Array :",Addresses)
                     //						}
                     }
                     //print(userobj)*/
                    if defaultAddress?.addressId ?? 0 == self.selectedAddressId
                    {
                        self.actionGetCurrentLoaction(self.btnBack)
                    }
                    
                }
                self.getAddresses()
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
}

extension CustomerHomeVC
{
    func getCategories()
    {
        //IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY]
        
        APIHelper.shared.postJsonRequest(url: APIGetAllServiceCategory, parameter: param, headers: headers, completion: { iscompleted,status,response in
            //IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    self.dataLoaded = true
                    
                    //self.showAlert(title: "Alert", message: response["message"] as? String ?? "Something went wrong.")
                    if self.Categories.count != 0
                    {
                        self.Categories.removeAll()
                    }
                    DispatchQueue.main.async {
                        
                        self.tableView.reloadData()
                        self.tableView.scrollToTop()
                    }
                }
                else
                {
                    print(response["data"])
                    let data = response["data"] as? NSDictionary
                    if data != nil
                    {
                        if let categoryArray = data?["service_categories"] as? NSArray
                        {
                            if self.Categories.count != 0
                            {
                                self.Categories.removeAll()
                            }
                            for category in categoryArray
                            {
                                let cat	: ServiceCategories = ServiceCategories(json: JSON(category))
                                self.Categories.append(cat)
                            }
                            print("Categories Array :",self.Categories)
                        }
                    }
                }
                //let Tcell = self.tableView.cellForRow(at: IndexPath(row: self.tableViewSections.count - 1, section: 0)) as? HomeComonTVCell
                DispatchQueue.main.async {
                    /*self.tableView.reloadRows(at: [IndexPath(row: cardsType.Categoyries.rawValue, section: 0)], with: .automatic)
                     let cell = self.tableView.cellForRow(at: IndexPath(row: cardsType.Categoyries.rawValue, section: 0)) as? HomeComonTVCell
                     cell?.collectionView.reloadData()*/
                    self.dataLoaded = true
                    self.tableView.reloadData()
                    self.tableView.scrollToTop()
                }
                
                //Tcell?.collectionView.reloadData()
                //				self.tableViewBottom.reloadData()
                //				if Addresses.count == 0
                //				{
                //					self.constraintBottomViewHeight.constant = 200
                //				}
                //				else
                //				{
                //					self.constraintBottomViewHeight.constant = 300
                //				}
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    func getOffers()
    {
        //IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY]
        
        APIHelper.shared.postJsonRequest(url: APIGetOfferList, parameter: param, headers: headers, completion: { iscompleted,status,response in
            //IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    self.dataLoaded = true
                    DispatchQueue.main.async {
                        self.getCategories()
                    }
                    //self.showAlert(title: "Alert", message: response["message"] as? String ?? "Something went wrong.")
                    //self.Categories.removeAll()
                }
                else
                {
                    print(response["data"])
                    let data = response["data"] as? NSDictionary
                    if data != nil
                    {
                        if let storeOfferArray = data?["store_offer"] as? NSArray
                        {
                            if self.storeOffers.count != 0
                            {
                                self.storeOffers.removeAll()
                            }
                            for storeOffer in storeOfferArray
                            {
                                let offer	: StoreOffer = StoreOffer(json: JSON(storeOffer))
                                self.storeOffers.append(offer)
                            }
                            print("Store Offer Array :",self.storeOffers)
                        }
                        if let productOfferArray = data?["product_offer"] as? NSArray
                        {
                            self.productOffers.removeAll()
                            for productOffer in productOfferArray
                            {
                                let offer : ProductOffer = ProductOffer(json: JSON(productOffer))
                                self.productOffers.append(offer)
                            }
                            print("Product Offer Array :",self.productOffers)
                        }
                        if let orderOfferArray = data?["order_offer"] as? NSArray
                        {
                            self.orderOffers.removeAll()
                            for orderOffer in orderOfferArray
                            {
                                let offer : OrderOffer = OrderOffer(json: JSON(orderOffer))
                                self.orderOffers.append(offer)
                            }
                            print("Order Offer Array :",self.orderOffers)
                        }
                        if let freshArray = data?["fresh_produce_categories"] as? NSArray
                        {
                            self.arrFreshProduces.removeAll()
                            for objFresh in freshArray
                            {
                                let obj : FreshProduceCategories = FreshProduceCategories(json: JSON(objFresh))
                                self.arrFreshProduces.append(obj)
                            }
                            print("Fresh Produces :",self.arrFreshProduces)
                        }
                        
                    }
                }
                //let Tcell = self.tableView.cellForRow(at: IndexPath(row: self.tableViewSections.count - 1, section: 0)) as? HomeComonTVCell
                DispatchQueue.main.async {
                    /*self.tableView.reloadRows(at: [IndexPath(row: cardsType.ProductOffers.rawValue, section: 0)], with: .automatic)
                     let cell = self.tableView.cellForRow(at: IndexPath(row: cardsType.ProductOffers.rawValue, section: 0)) as? HomeComonTVCell
                     cell?.collectionView.reloadData()*/
                    self.getCategories()
                }
                /*DispatchQueue.main.async {
                 self.tableView.reloadRows(at: [IndexPath(row: cardsType.RestaurantOffers.rawValue, section: 0)], with: .automatic)
                 let cell = self.tableView.cellForRow(at: IndexPath(row: cardsType.RestaurantOffers.rawValue, section: 0)) as? HomeComonTVCell
                 cell?.collectionView.reloadData()
                 
                 }*/
                //Tcell?.collectionView.reloadData()
                //				self.tableViewBottom.reloadData()
                //				if Addresses.count == 0
                //				{
                //					self.constraintBottomViewHeight.constant = 200
                //				}
                //				else
                //				{
                //					self.constraintBottomViewHeight.constant = 300
                //				}
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    func getTermAndCondition()
    {
        //IHProgressHUD.show()
        /*if let cartTerm = UserDefaults.standard.getCustom(forKey: "cartTermNotes") as? [CartTermNotes]
        {
            cartTermNotes.removeAll()
            cartTermNotes.append(contentsOf: cartTerm)
        }
        else
        {*/
            let param: Parameters = ["secret_key" : SECRET_KEY,
                                     "access_key" : ACCESS_KEY]
            
            APIHelper.shared.postJsonRequest(url: APIGetCartTermsNote, parameter: param, headers: headers, completion: { iscompleted,status,response in
                //IHProgressHUD.dismiss()
                if iscompleted
                {
                    if !(response["status"] as! Bool)
                    {
                        self.dataLoaded = true
                        DispatchQueue.main.async {
                            self.getCategories()
                        }
                        //self.showAlert(title: "Alert", message: response["message"] as? String ?? "Something went wrong.")
                        //self.Categories.removeAll()
                    }
                    else
                    {
                        print(response["data"])
                        let data = response["data"] as? NSDictionary
                        if data != nil
                        {
                            if let cartTermNoteAry = data?["cart_term_notes"] as? NSArray
                            {
                                 cartTermNotes.removeAll()
                                for cartTermNote in cartTermNoteAry
                                {
                                    let cartTerm : CartTermNotes = CartTermNotes(json: JSON(cartTermNote))
                                   
                                    cartTermNotes.append(cartTerm)
                                }
                                //FaUserDefaults.standard.setCustom(cartTermNotes, forKey: "cartTermNotes")
                            }
                        }
                    }
                }
                else
                {
                    if status == "ConnectionLost"{
                        ShowToast(message: kCHECK_INTERNET_CONNECTION)
                    } else{
                        /*if response.count == 0 {
                         ShowToast(message: "Something went wrong. Please Try Again")
                         }else {*/
                        ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                        //}
                    }
                }
            })
        //}
    }
}

extension RestaurantsVC{
    func getStores(_ searchText : String, serviceId : Int, freshProducedId : Int)
    {
        //IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "searchText" : searchText,
                                 "service_category_id" : serviceId,
                                 "fresh_produce_category_id" : freshProducedId]
        
        APIHelper.shared.postJsonRequest(url: APISearchStoreByName, parameter: param, headers: headers, completion: { iscompleted,status,response in
            //IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    //ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //self.Categories.removeAll()
                    self.stores.removeAll()
                }
                else
                {
                    // print(response["data"])
                    let data = response["data"] as? NSDictionary
                    if data != nil
                    {
                        if let storeArray = data?["stores"] as? NSArray
                        {
                            if self.stores.count != 0
                            {
                                self.stores.removeAll()
                            }
                            for store in storeArray
                            {
                                let StoreObj : Store = Store(json: JSON(store))
                                self.stores.append(StoreObj)
                            }
                            print("Categories Array :",self.stores)
                        }
                    }
                }
                //let Tcell = self.tableView.cellForRow(at: IndexPath(row: self.tableViewSections.count - 1, section: 0)) as? HomeComonTVCell
                self.staticCount = 0
                self.tableView.reloadData()
                if self.activeView == 1 {
                    self.refreshMap()
                }
                if self.stores.count == 0
                {
                    self.lblStoreNotAvailable.isHidden = false
                    if searchText.count != 0
                    {
                        self.lblStoreNotAvailable.text = "Search result not found"
                    }
                    else
                    {
                        self.lblStoreNotAvailable.text = "No store available"
                    }
                }
                else
                {
                    self.lblStoreNotAvailable.isHidden = true
                }
                
                //Tcell?.collectionView.reloadData()
                //				self.tableViewBottom.reloadData()
                //				if Addresses.count == 0
                //				{
                //					self.constraintBottomViewHeight.constant = 200
                //				}
                //				else
                //				{
                //					self.constraintBottomViewHeight.constant = 300
                //				}
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                   // ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
}
extension StoreDetailsVC{
    func getStoreDetails(storeId : Int)
    {
        //IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                 "store_id" : storeId
        ]
        
        APIHelper.shared.postJsonRequest(url: APIGetStoreDetails, parameter: param, headers: headers, completion: { iscompleted,status,response in
            //IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    //self.showAlert(title: "Alert", message: response["message"] as? String ?? "Something went wrong.")
                    //self.shimmerView.isHidden = true
                }
                else
                {
                    
                    print(response["data"])
                    let data = response["data"] as? NSDictionary
                    if data != nil
                    {
                        let storeDetails = data?["store_detail"] as? NSDictionary
                        if storeDetails !=  nil
                        {
                            let storeDetailObj : StoreDetail = StoreDetail(json: JSON(storeDetails))
                            if storeDetailObj != nil
                            {
                                self.storeDetails = storeDetailObj
                                structCustomerTempCart.storeId = nil
                                structCustomerTempCart.store = nil
                                structCustomerTempCart.storeId = storeDetailObj.storeId ?? 0
                                structCustomerTempCart.store = storeDetailObj
                                if storeDetailObj.foodCategory?.count ?? 0 > 0
                                {
                                    self.btnSearch.isEnabled = true
                                }
                                else
                                {
                                    self.btnSearch.isEnabled = false
                                }
                                if storeDetailObj.foodCategory?.count ?? 0 == 0
                                {
                                    self.lblCategoriesNotAvailable.isHidden = false
                                }
                                else
                                {
                                    self.arrFoodCategory = (storeDetailObj.foodCategory?.filter {$0.freshProduceCategoryId == 0})!
                                    self.arrFreshProducedCategory = (storeDetailObj.foodCategory?.filter {$0.freshProduceCategoryId! > 0})!
                                    self.lblCategoriesNotAvailable.isHidden = true
                                }
                                self.collectionView.reloadData()
                                
                                self.shimmerView.isHidden = true
                                self.btnLike.isEnabled = true
                                //self.btnSearch.isEnabled = true
                            }
                            print("Store Details :",storeDetails)
                        }
                    }
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    func markAsFavourite(favouriteStatus : Int, StoreId : Int)
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "store_id" : StoreId,
                                 "user_id" : USER_ID,
                                 "is_favourite" : favouriteStatus
        ]
        
        APIHelper.shared.postJsonRequest(url: APIMarkStoreAsFavouriteUnFavourite, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if status == "success"
                {
                    self.storeDetails?.isFavourite = favouriteStatus == 1
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
}
extension AddStoreOrderVC{
    func getStoreDetails(storeId : Int)
    {
        /*
         "secret_key": "FEinhS54sNUNNll0tjqNdzLskf3SPgUISZzp1vIZXzE=",
         "access_key": "nousername",
         "user_id": 164,
         "user_store_id": 0,
         "store_id" : 10
         */
        
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                 "user_store_id" : userStoreId,
                                 "store_id" : storeId
        ]
        
        APIHelper.shared.postJsonRequest(url: APIGetUserAddedStoreProductsFromCart, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    //self.showAlert(title: "Alert", message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    print(response["data"])
                    let data = response["data"] as? NSDictionary
                    if data != nil
                    {
                        let storeDetails = data?["user_products"] as? NSDictionary
                        if storeDetails !=  nil
                        {
                            let storeDetailObj : StoreDetail = StoreDetail(json: JSON(storeDetails))
                            if storeDetailObj != nil
                            {
                                self.storeDetails = storeDetailObj
                                //self.collectionView.reloadData()
                            }
                            print("Store Details :",storeDetails)
                            if let productList = storeDetails?["products"] as? NSArray
                            {
                                //print(productList)
                                if self.arrProductList.count != 0
                                {
                                    self.arrProductList.removeAll()
                                }
                                for product in productList
                                {
                                    let productObj : CartProducts = CartProducts(json: JSON(product))
                                    self.arrProductList.append(productObj)
                                    //
                                }
                            }
                            self.manageItems()
                        }
                    }
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    func markAsFavourite(favouriteStatus : Int, StoreId : Int)
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "store_id" : StoreId,
                                 "user_id" : USER_ID,
                                 "is_favourite" : favouriteStatus
        ]
        
        APIHelper.shared.postJsonRequest(url: APIMarkStoreAsFavouriteUnFavourite, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if status == "success"
                {
                    self.storeDetails?.isFavourite = favouriteStatus == 1
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    func orderItemToStore()
    {
        IHProgressHUD.show()
        //var products : [[String : String]] = []
        var imageDict : [UIImage] = []
        
        var productString = "["
        imageDict.removeAll()
        var imageCount = 1
        var aryCount = 0
        for product in arrOrders
        {
            if aryCount == 0
            {
                productString = "\(productString){"
                aryCount += 1
            }
            else
            {
                productString = "\(productString),{"
                aryCount += 1
            }
            //let dict = ["product_name" : product.productname,"qty" : "\(product.ProductQty)","image_name" : product.productImage.accessibilityIdentifier ?? ""]
            if product.imageName == "swift_file"
            {
                productString = " \(productString) \"user_product_id\" : \(product.productId), \"product_name\" : \"\(product.productname)\" , \"qty\" : \"\(product.ProductQty)\", \"image_name\" : \"swift_file_\(imageCount).jpg\""
                imageDict.append(product.productImage ?? UIImage())
                imageCount += 1
            }
            else
            {
                productString = " \(productString)  \"user_product_id\" : \(product.productId), \"product_name\" : \"\(product.productname)\" , \"qty\" : \"\(product.ProductQty)\", \"image_name\" : \"\""
            }
            
            //products.append(dict)
            
            
            productString = "\(productString)}"
        }
        productString = "\(productString)]"
        let deletedStringArry = deletedIds.map { String($0) }
        print("Products : ",productString)
        print("Products Images : ",imageDict)
        let param: NSMutableDictionary = ["secret_key" : SECRET_KEY,
                                          "access_key" : ACCESS_KEY,
                                          "is_user_added_store" : isUserAddedStore ? "1" : "0",
                                          "store_id" : "\(self.storeId)",
            
            "user_store_id" : "\(self.userStoreId)" ,
            "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
            "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0,
            "delete_product_id" : "\(deletedStringArry.joined(separator: ","))",
            "products": productString,
            "product_image[]":imageDict,
            "version" : "v2"
        ]
        APIHelper.shared.postMultipartJSONRequest(endpointurl: APIAddUserStoreProduct, parameters: param) { (response, error, message) in
            IHProgressHUD.dismiss()
            if response != nil
            {
                if !(response?["status"] as! Bool)
                {
                    ShowToast(message: response?["message"] as! String)
                }
                else
                {
                    if !self.isNavigateToCart
                    {
                        //self.popTwoViewBack()
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    else
                    {
                        let nextViewController = CustomerCartStoryboard.instantiateViewController(withIdentifier: "CartViewVC") as! CartViewVC
                        self.navigationController?.pushViewController(nextViewController, animated: true)
                    }
                }
            } else {
                ShowToast(message:message ?? "")
            }
        }
    }
    //	"product_details" : [{"Name": "TV" , "Qty" : 2 , "image_added" : 1 },{"Name": "AC" , "Qty" : 1 , "image_added" : 0 },{"Name": "Player" , "Qty" : 3 , "image_added" : 1 }]
}
extension AddNewStoreVC
{
    func registerStore()
    {
        IHProgressHUD.show()
        let param : NSMutableDictionary = ["secret_key" : SECRET_KEY,
                                           "access_key" : ACCESS_KEY,
                                           "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                           "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0,
                                           "store_name" : structStoreDetails.storeName ?? "",
                                           "store_address" : structStoreDetails.storeAddress ?? "",
                                           "store_description": structStoreDetails.storeDiscription ?? "",
                                           "latitude": structStoreDetails.storeLat ?? "",
                                           "longitude": structStoreDetails.storeLon ?? "",
                                           "store_image": self.pickedImage.count > 0 ? self.pickedImage[0] : UIImage()
        ]
        APIHelper.shared.postMultipartJSONRequest(endpointurl: APIAddUserStore, parameters: param) { (response, error, message) in
            IHProgressHUD.dismiss()
            if response != nil
            {
                if !(response?["status"] as! Bool)
                {
                    ShowToast(message: response?["message"] as! String)
                }
                else
                {
                    
                    if let data = response?["data"] as? NSDictionary
                    {
                        if let userStore = data["user_store"] as? NSDictionary
                        {
                            let storeDetailObj : StoreDetail = StoreDetail(json: JSON(userStore))
                            if storeDetailObj != nil
                            {
                                print("Store Details :",storeDetailObj)
                                self.isStoreAdded =  true
                                self.showAlert(title: "", message: "Your store successfully registerd.", completion: {_ in
                                    let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddStoreOrderVC") as! AddStoreOrderVC
                                    nextViewController.setStoreObj(storeDetails: storeDetailObj)
                                    
                                    self.navigationController?.pushViewController(nextViewController, animated: true)
                                })
                            }
                            
                        }
                        
                        /*if let productArray = data["product_detail"] as? NSArray
                         {
                         
                         for category in categoryArray
                         {
                         let catObj : FoodCategory = FoodCategory(json: JSON(category))
                         self.StoreCategories.append(catObj)
                         }
                         print("Categories Array -:- ",self.StoreCategories)
                         }*/
                    }
                }
            } else {
                ShowToast(message: message ?? "")
            }
        }
    }
    
}
extension StoreItemsVC{
    func getStoreItems(storeId : Int)
    {
        //IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                 "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0,
                                 "store_id" : storeId,
                                 "is_fresh_produced" : isFreshProduced ? 1 : 0
        ]
        
        APIHelper.shared.postJsonRequest(url: APIGetStoreCategoryWithProduct, parameter: param, headers: headers, completion: { iscompleted,status,response in
            //IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    self.apiCalled = false
                    self.reloadData()
                    return
                    //self.showAlert(title: "Alert", message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    
                    let data = response["data"] as? NSDictionary
                    if data != nil
                    {
                        
                        if let CartDetails = data?["other_detail"] as? NSDictionary
                        {
                            self.cartDetails  = AddedProductDetails(json: JSON(CartDetails))
                        }
                        if let categoryArray = data?["categories"] as? NSArray
                        {
                            if self.StoreCategories.count != 0
                            {
                                self.StoreCategories.removeAll()
                            }
                            for category in categoryArray
                            {
                                let catObj : FoodCategory = FoodCategory(json: JSON(category))
                                self.StoreCategories.append(catObj)
                            }
                            print("Categories Array -:- ",self.StoreCategories)
                        }
                    }
                }
                self.OriginalStoreCategories.removeAll()
                self.OriginalStoreCategories.append(contentsOf: self.StoreCategories)
                //UserDefaults.standard.setCustom(self.OriginalStoreCategories, forKey: kItemCategories)
                self.apiCalled = true
                self.reloadData()
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
}
extension ItemAddOnVC{
    func getProductInfo(productId : Int)
    {
        //IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "product_id" : productId
        ]
        
        APIHelper.shared.postJsonRequest(url: APIGetProductDetail, parameter: param, headers: headers, completion: { iscompleted,status,response in
            //IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    //self.showAlert(title: "Alert", message: response["message"] as? String ?? "Something went wrong.")
                    
                }
                else
                {
                    
                    let data = response["data"] as? NSDictionary
                    if data != nil
                    {
                        if let productInfoObj = data?["product_info"] as? NSDictionary
                        {
                            self.productInfo = ProductInfo(json: JSON(productInfoObj))
                        }
                    }
                }
                self.reloadData()
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    
    func updateCartItems()
    {
        IHProgressHUD.show()
        var dictary : [[String : Int]] = []
        for addonId in structCustomerTempCart.productAddonsIds
        {
            let dict = ["addon_id" : addonId]
            dictary.append(dict)
        }
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                 "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0,
                                 "cart_product_id" : cartProduct?.cartProductId ?? 0,
                                 "addons" : dictary,
                                 "latitude" : defaultAddress?.latitude ?? "",
                                 "longitude" : defaultAddress?.longitude ?? "",
                                 "coupon_code" : "",
                                 "option_id": structCustomerTempCart.selectedOptions?.optionId ?? 0
        ]
        
        APIHelper.shared.postJsonRequest(url: APICustomiseCartItem, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    self.dismiss(animated: true, completion: {
                        if let data = response["data"] as? NSDictionary
                        {
                            self.delegate?.reloadCart(cartData: data, code: "")
                        }
                        else
                        {
                            self.delegate?.reloadCart(cartData: [:], code: "")
                        }
                    })
                    
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
}

extension ConfirmItemForCartVC{
    func addItemToCart()
    {
        //"[{\"addon_id\" : 147,\"addon_id\" : 8}]"
        
        //serviceMgr.callPOSTAPIJSONEncode(webpath: webPath1, withTag: "RestListAPI", params: params1)
        IHProgressHUD.show()
        var dictary : [[String : Int]] = []
        for addonId in structCustomerTempCart.productAddonsIds
        {
            let dict = ["addon_id" : addonId]
            dictary.append(dict)
        }
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                 "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0,
                                 "store_id" : structCustomerTempCart.storeId ?? 0,
                                 "user_store_id" : 0,
                                 "product_id" : structCustomerTempCart.productId ?? 0,
                                 "user_product_id" : 0,
                                 "quantity" : structCustomerTempCart.productQty,
                                 "addons" : dictary,
                                 "option_id": structCustomerTempCart.selectedOptions?.optionId ?? 0
        ]
        
        APIHelper.shared.postJsonRequest(url: APIAddItemToCart, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    newItemAddedFromStore = true
                    if structCustomerTempCart.product?.hasAddons ?? 0 == 1 || structCustomerTempCart.product?.productOption?.count ?? 1 > 1
                    {
                        self.popTwoViewBack()
                        
                    }
                    else
                    {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    
    func markAsFavourite(favouriteStatus : Int, StoreId : Int)
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "store_id" : StoreId,
                                 "user_id" : USER_ID,
                                 "is_favourite" : favouriteStatus
        ]
        
        APIHelper.shared.postJsonRequest(url: APIMarkStoreAsFavouriteUnFavourite, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if status == "success"
                {
                    self.storeDetails?.isFavourite = favouriteStatus == 1
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
            }
        })
    }

}
extension CartViewVC{
    func getCartDetails()
    {
        ismannualStoreAvailable = false
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                 "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0,
                                 "latitude" : defaultAddress?.latitude ?? "",
                                 "longitude" : defaultAddress?.longitude ?? "",
                                 "coupon_code" : "",
                                 "delivery_option" : selectedDeliveryOption
        ]
        
        APIHelper.shared.postJsonRequest(url: APIGetUserCart, parameter: param, headers: headers, completion: { iscompleted,status,response in
            
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    //self.showAlert(title: "Alert", message: response["message"] as? String ?? "Something went wrong.")
                    self.sectionCount = 1
                    if self.cartArray.count != 0
                    {
                        self.cartArray.removeAll()
                    }
                    self.SetUpStoreItem()
                    
                    if(response["message"] as? String ?? "Something went wrong." == "Please provide delivery address.") {
                        self.showOkAlert(message: "Please privde delivery address otherwise order total price won't be calculated.\n If your location service is disabled then turn on the location service from the device setting.")
                    }
                }
                else
                {
                    
                    let data = response["data"] as? NSDictionary
                    self.sectionCount = 6
                    
                    if data != nil
                    {
                        if let AmtDetails = data?["amount_details"] as? NSDictionary{
                            self.amountDetails = AmountDetails(json: JSON(AmtDetails))
                            self.finalAmt = self.amountDetails?.grandTotal ?? 0
                            self.deliveryTime =	self.amountDetails?.totalDeliveryTime ?? 0
                            if self.amountDetails?.couponDiscountPrice ?? 0 > 0
                            {
                                self.isCouponApplied = true
                            }
                            //self.tableView.reloadRows(at: [IndexPath(row: 0, section: enumCartSections.billDetails.rawValue)], with: .automatic)
                        }
                        if let cartAry = data?["cart_items"] as? NSArray
                        {
                            if self.cartArray.count != 0
                            {
                                self.cartArray.removeAll()
                            }
                            self.itemsCount = 0
                            self.storewithProductCount.removeAll()
                            for cart in cartAry
                            {
                                let cartObj : CartItems = CartItems(json: JSON(cart))
                                self.itemsCount +=  cartObj.products?.count ?? 0
                                var storeID = cartObj.storeDetails?.storeId ?? 0
                                if storeID == 0
                                {
                                    storeID = cartObj.storeDetails?.userStoreId ?? 0
                                }
                                
                                if cartObj.products?[0].productId ?? 0 == 0
                                {
                                    self.ismannualStoreAvailable = true
                                }
                                else if cartObj.storeDetails?.storeId ?? 0 == 0
                                {
                                    self.ismannualStoreAvailable = true
                                }
                                self.storewithProductCount[storeID] = cartObj.products?.count ?? 0
                                self.cartArray.append(cartObj)
                            }
                            print("Cart Array -:- ",self.cartArray)
                        }
                    }
                    self.SetUpStoreItem()
                }
            }
            else
            {
                self.sectionCount = 1
                if self.isItemRemovedFromCart
                {
                    self.navigationController?.popToRootViewController(animated: true)
                }
                else
                {
                    if self.cartArray.count != 0
                    {
                        self.cartArray.removeAll()
                    }
                    self.SetUpStoreItem()
                }
                
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "")
                    //}
                }
            }
        })
    }
    
    func removeStoreOrderFromCart(_ cartId : Int)
    {
        ismannualStoreAvailable = false
        isItemRemovedFromCart = true
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                 "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0,
                                 "cart_id": cartId,
                                 "latitude" : defaultAddress?.latitude ?? "",
                                 "longitude" : defaultAddress?.longitude ?? "",
                                 "coupon_code" : "",
                                 "delivery_option" : selectedDeliveryOption
        ]
        
        APIHelper.shared.postJsonRequest(url: APIDeleteCartItem, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                IHProgressHUD.dismiss()
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    self.navigationController?.popToRootViewController(animated: true)
                }
                else
                {
                    
                    let data = response["data"] as? NSDictionary
                    self.sectionCount = 0
                    
                    if data != nil
                    {
                        if let AmtDetails = data?["amount_details"] as? NSDictionary{
                            self.amountDetails = AmountDetails(json: JSON(AmtDetails))
                            self.finalAmt = self.amountDetails?.grandTotal ?? 0
                            self.deliveryTime =	self.amountDetails?.totalDeliveryTime ?? 0
                            if self.amountDetails?.couponDiscountPrice ?? 0 > 0
                            {
                                self.isCouponApplied = true
                            }
                            //self.tableView.reloadRows(at: [IndexPath(row: 0, section: enumCartSections.billDetails.rawValue)], with: .automatic)
                        }
                        if let cartAry = data?["cart_items"] as? NSArray
                        {
                            if self.cartArray.count != 0
                            {
                                self.cartArray.removeAll()
                            }
                            self.itemsCount = 0
                            self.storewithProductCount.removeAll()
                            for cart in cartAry
                            {
                                let cartObj : CartItems = CartItems(json: JSON(cart))
                                self.itemsCount +=  cartObj.products?.count ?? 0
                                var storeID = cartObj.storeDetails?.storeId ?? 0
                                if cartObj.products?[0].productId ?? 0 == 0
                                {
                                    self.ismannualStoreAvailable = true
                                }
                                else if cartObj.storeDetails?.storeId ?? 0 == 0
                                {
                                    self.ismannualStoreAvailable = true
                                }
                                if storeID == 0
                                {
                                    storeID = cartObj.storeDetails?.userStoreId ?? 0
                                }
                                self.storewithProductCount[storeID] = cartObj.products?.count ?? 0
                                self.cartArray.append(cartObj)
                            }
                            print("Cart Array -:- ",self.cartArray)
                        }
                    }
                }
                self.SetUpStoreItem()
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    func UpdateQtyOfProduct(_ quantity : Int, productId : Int)
    {
        ismannualStoreAvailable = false
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                 "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0,
                                 "quantity":quantity,
                                 "latitude" : defaultAddress?.latitude ?? "",
                                 "longitude" : defaultAddress?.longitude ?? "",
                                 "coupon_code" : "",
                                 "cart_product_id":productId,
                                 "delivery_option" : selectedDeliveryOption
        ]
        
        APIHelper.shared.postJsonRequest(url: APIUpdateCartQuantity, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                IHProgressHUD.dismiss()
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    
                    let data = response["data"] as? NSDictionary
                    self.sectionCount = 6
                    
                    if data != nil
                    {
                        if let AmtDetails = data?["amount_details"] as? NSDictionary{
                            self.amountDetails = AmountDetails(json: JSON(AmtDetails))
                            self.finalAmt = self.amountDetails?.grandTotal ?? 0
                            self.deliveryTime =	self.amountDetails?.totalDeliveryTime ?? 0
                            if self.amountDetails?.couponDiscountPrice ?? 0 > 0
                            {
                                self.isCouponApplied = true
                            }
                            //self.tableView.reloadRows(at: [IndexPath(row: 0, section: enumCartSections.billDetails.rawValue)], with: .automatic)
                        }
                        if let cartAry = data?["cart_items"] as? NSArray
                        {
                            if self.cartArray.count != 0
                            {
                                self.cartArray.removeAll()
                            }
                            self.itemsCount = 0
                            self.storewithProductCount.removeAll()
                            for cart in cartAry
                            {
                                let cartObj : CartItems = CartItems(json: JSON(cart))
                                self.itemsCount +=  cartObj.products?.count ?? 0
                                var storeID = cartObj.storeDetails?.storeId ?? 0
                                if cartObj.products?[0].productId ?? 0 == 0
                                {
                                    self.ismannualStoreAvailable = true
                                }
                                else if cartObj.storeDetails?.storeId ?? 0 == 0
                                {
                                    self.ismannualStoreAvailable = true
                                }
                                if storeID == 0
                                {
                                    storeID = cartObj.storeDetails?.userStoreId ?? 0
                                }
                                self.storewithProductCount[storeID] = cartObj.products?.count ?? 0
                                self.cartArray.append(cartObj)
                            }
                            print("Cart Array -:- ",self.cartArray)
                        }
                    }
                    self.SetUpStoreItem()
                    //self.tableView.reloadData()
                    
                }
            }
            else
            {
                IHProgressHUD.dismiss()
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    func RemoveProductFromCart(_ cartId : Int, productId : Int)
    {
        ismannualStoreAvailable = false
        isItemRemovedFromCart = true
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                 "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0,
                                 "cart_id":cartId,
                                 "latitude" : defaultAddress?.latitude ?? "",
                                 "longitude" : defaultAddress?.longitude ?? "",
                                 "coupon_code" : "",
                                 "cart_product_id":productId,
                                 "delivery_option" : selectedDeliveryOption
        ]
        
        APIHelper.shared.postJsonRequest(url: APIDeleteProductFromCartItem, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                IHProgressHUD.dismiss()
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    self.navigationController?.popToRootViewController(animated: true)
                    //self.showAlert(title: "Alert", message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    
                    let data = response["data"] as? NSDictionary
                    self.sectionCount = 6
                    
                    if data != nil
                    {
                        if let AmtDetails = data?["amount_details"] as? NSDictionary{
                            self.amountDetails = AmountDetails(json: JSON(AmtDetails))
                            self.finalAmt = self.amountDetails?.grandTotal ?? 0
                            self.deliveryTime =	self.amountDetails?.totalDeliveryTime ?? 0
                            if self.amountDetails?.couponDiscountPrice ?? 0 > 0
                            {
                                self.isCouponApplied = true
                            }
                            //self.tableView.reloadRows(at: [IndexPath(row: 0, section: enumCartSections.billDetails.rawValue)], with: .automatic)
                        }
                        if let cartAry = data?["cart_items"] as? NSArray
                        {
                            if self.cartArray.count != 0
                            {
                                self.cartArray.removeAll()
                            }
                            self.itemsCount = 0
                            self.storewithProductCount.removeAll()
                            for cart in cartAry
                            {
                                let cartObj : CartItems = CartItems(json: JSON(cart))
                                self.itemsCount +=  cartObj.products?.count ?? 0
                                var storeID = cartObj.storeDetails?.storeId ?? 0
                                if cartObj.products?[0].productId ?? 0 == 0
                                {
                                    self.ismannualStoreAvailable = true
                                }
                                if cartObj.storeDetails?.storeId ?? 0 == 0
                                {
                                    self.ismannualStoreAvailable = true
                                }
                                if storeID == 0
                                {
                                    storeID = cartObj.storeDetails?.userStoreId ?? 0
                                }
                                self.storewithProductCount[storeID] = cartObj.products?.count ?? 0
                                self.cartArray.append(cartObj)
                            }
                            print("Cart Array -:- ",self.cartArray)
                        }
                    }
                }
                self.SetUpStoreItem()
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    
    func PlaceOrder()
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                 "delivery_latitude" : defaultAddress?.latitude ?? "",
                                 "delivery_longitude" : defaultAddress?.longitude ?? "",
                                 "delivery_address" : defaultAddress?.address ?? "",
                                 "driver_note":"",
                                 "payment_type_id" : 1,
                                 "coupon_code" : self.appliedCouponCode,
                                 "timezone" : TIME_ZONE,
                                 "is_recurring_order" : isRecurringOrder,
                                 "recurring_type_id" : isRecurringOrder == 0 ? 0 : structAdvancedOrderDeatils.recurringTypeId,
                                 "recurred_on" : isRecurringOrder == 0 ? "" : structAdvancedOrderDeatils.recurredOn,
                                 "recurring_time" : isRecurringOrder == 0 ? "" : structAdvancedOrderDeatils.recurringTime,
                                 "label" : isRecurringOrder == 0 ? "" : structAdvancedOrderDeatils.label,
                                 "repear_until_date" : isRecurringOrder == 0 ? "" : structAdvancedOrderDeatils.repatUntilDate,
                                 "delivery_option" : selectedDeliveryOption
        ]
        APIHelper.shared.postJsonRequest(url: APIPlaceOrder, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    plcedOrderDetails.removeAll()
                    if let data = response["data"] as? NSDictionary
                    {
                        let orderDetails = Order(json: JSON(data))
                        //print("Order Details : ",orderDetails)
                        plcedOrderDetails.append(orderDetails)
                        switch APP_DELEGATE.socketIOHandler?.socket?.status{
                            
                        case .connected?:
                            let d = ["order_id" : plcedOrderDetails[0].orderId ?? 0, "user_id" : USER_ID, "driver_ids" : plcedOrderDetails[0].driverIds ?? ""] as [String : Any]
                            APP_DELEGATE.socketIOHandler?.PlaceOrder(dic: d)
                            break
                        default:
                            print("Socket Not Connected")
                            break;
                        }
                        BADGE_COUNT = 0
                        isTermAndConditionTapped = false
                        if let timerAlertView = self.storyboard?.instantiateViewController(withIdentifier: "TimerViewVC") as? TimerViewVC
                        {
                            timerAlertView.delegate = self
                            timerAlertView.setOrderId(orderId: plcedOrderDetails[0].orderId ?? 0, ServerTime: plcedOrderDetails[0].serverTime ?? "")
                            self.present(timerAlertView, animated: false, completion: nil)
                        }
                    }
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
}
extension CustomerSettingsVC{
    func LogOutUser()
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : USER_ID,
                                 "device_token" : FCM_TOKEN,
                                 "device_type" : DEVICE_TYPE
        ]
        
        APIHelper.shared.postJsonRequest(url: APILogout, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {   
                self.ReinitializeApp()
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
}
extension RecurringOrderVC{
    func GetRecurringTypes()
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY
        ]
        
        APIHelper.shared.postJsonRequest(url: APIGetRecurringTypes, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                arrStructRepeateOptions.removeAll()
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    if let data = response["data"] as? NSDictionary
                    {
                        if let recurringTypes = data["recurring_types"] as? NSArray
                        {
                            for recurringType in recurringTypes
                            {
                                let dict = recurringType as! NSDictionary
                                let id = dict["recurring_type_id"] as! Int
                                let name = dict["recurring_type"] as! String
                                structRepeateOption.id = id
                                structRepeateOption.name = name
                                if name.lowercased() == enum_repeate_options.once.rawValue
                                {
                                    self.selectedRecurringTypeId = id
                                }
                                arrStructRepeateOptions.append(structRepeateOption)
                                print(arrStructRepeateOptions)
                                print("Id : \(id) - Name : \(name)")
                            }
                        }
                    }
                }
                //self.ReinitializeApp()
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
}
extension ApplyCouponVC{
    func getDiscountCoupons()
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY
        ]
        APIHelper.shared.postJsonRequest(url: APIGetAllCoupuns, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    if self.coupensAry.count != 0
                    {
                        self.coupensAry.removeAll()
                    }
                    self.lblNotAvailable.isHidden = !(self.coupensAry.count == 0)
                    self.tableView.reloadData()
                    //ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    if let data = response["data"] as? NSDictionary
                    {
                        if let CoupensAry = data["coupons"] as? NSArray
                        {
                            if self.coupensAry.count != 0
                            {
                                self.coupensAry.removeAll()
                            }
                            for coupon in CoupensAry
                            {
                                let couponObj: Coupons = Coupons(json: JSON(coupon))
                                self.coupensAry.append(couponObj)
                            }
                            self.count = self.coupensAry.count
                            self.lblNotAvailable.isHidden = !(self.coupensAry.count == 0)
                            self.tableView.reloadData()
                            print("coupens Array :",self.coupensAry)
                        }
                    }
                }
                //self.ReinitializeApp()
                
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    
    
    func applyCoupon(_ amount : Float ,code : String)
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                                 "guest_user_id" : isGuest ? USER_OBJ?.guestUserId ?? 0 : 0,
                                 "latitude" : defaultAddress?.latitude ?? "",
                                 "longitude" : defaultAddress?.longitude ?? "",
                                 "coupon_code" : code,
                                 "total_items_price" : amount,
                                 "delivery_option" : selectedDeliveryOption
        ]
        
        APIHelper.shared.postJsonRequest(url: APIApplyCouponCode, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    self.dismiss(animated: true, completion: {
                        if let data = response["data"] as? NSDictionary
                        {
                            self.delegate?.reloadCart(cartData: data , code : code )
                        }
                        else
                        {
                            self.delegate?.reloadCart(cartData: [:], code: "")
                        }
                    })
                    
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
}
extension CurrentOrderVC {
    func getCurrentOrder()
    {
        //GetCustomerOrders
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "is_for_current" : 1,
                                 "user_id":USER_ID
        ]
        APIHelper.shared.postJsonRequest(url: APIGetCustomerOrders, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    // ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    if self.arrCurrentOrder.count != 0
                    {
                        self.arrCurrentOrder.removeAll()
                    }
                    self.setUpDetails()
                }
                else
                {
                    if let data = response["data"] as? NSDictionary
                    {
                        if let currentOrders = data["current_order"] as? NSArray
                        {
                            if self.arrCurrentOrder.count != 0
                            {
                                self.arrCurrentOrder.removeAll()
                            }
                            for currentOrder in currentOrders
                            {
                                let currentOrderObj: CurrentOrder = CurrentOrder(json: JSON(currentOrder))
                                self.arrCurrentOrder.append(currentOrderObj)
                            }
                            print("Current Order Array :",self.arrCurrentOrder)
                        }
                    }
                    self.setUpDetails()
                }
                //self.ReinitializeApp()
                self.tableView.reloadData()
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }            }
        })
    }
    
    func reScheduleOrder(orderId : Int)
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "order_id" : orderId
        ]
        
        APIHelper.shared.postJsonRequest(url: APIRescheduleOrder, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    
                    if let data = response["data"] as? NSDictionary
                    {
                        let orderDetails = Order(json: JSON(data))
                        //print("Order Details : ",orderDetails)
                        switch APP_DELEGATE.socketIOHandler?.socket?.status{
                        case .connected?:
                            let d = ["order_id" : orderDetails.orderId ?? 0, "user_id" : USER_ID, "driver_ids" : orderDetails.driverIds ?? ""] as [String : Any]
                            APP_DELEGATE.socketIOHandler?.PlaceOrder(dic: d)
                            break
                        default:
                            print("Socket Not Connected")
                            break;
                        }
                        //Reload Screen
                        self.getCurrentOrder()
                        //                               if let timerAlertView = self.storyboard?.instantiateViewController(withIdentifier: "TimerViewVC") as? TimerViewVC
                        //                               {
                        //                                   timerAlertView.delegate = self
                        //                                   timerAlertView.setOrderId(orderId: plcedOrderDetails[0].orderId ?? 0, ServerTime: plcedOrderDetails[0].serverTime ?? "")
                        //                                   self.present(timerAlertView, animated: false, completion: nil)
                        //                               }
                        
                    }
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    
}

extension PastOrderVC {
    func getPastOrder()
    {
        //GetCustomerOrders
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "is_for_current" : 2,
                                 "user_id":USER_ID
        ]
        APIHelper.shared.postJsonRequest(url: APIGetCustomerOrders, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    // ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    if self.arrPastOrder.count != 0
                    {
                        self.arrPastOrder.removeAll()
                    }
                    self.setUpDetails()
                }
                else
                {
                    if let data = response["data"] as? NSDictionary
                    {
                        if let currentOrders = data["past_order"] as? NSArray
                        {
                            if self.arrPastOrder.count != 0
                            {
                                self.arrPastOrder.removeAll()
                            }
                            for currentOrder in currentOrders
                            {
                                let currentOrderObj: CurrentOrder = CurrentOrder(json: JSON(currentOrder))
                                self.arrPastOrder.append(currentOrderObj)
                            }
                            print("Current Order Array :",self.arrPastOrder)
                        }
                    }
                    self.setUpDetails()
                }
                //self.ReinitializeApp()
                self.tableView.reloadData()
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
}

extension OrderDetailsVC {
    func getOrderDetails(of orderId: Int)
    {
        //GetCustomerOrders
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "order_id" : orderId,
                                 "user_id":USER_ID
        ]
        APIHelper.shared.postJsonRequest(url: APIGetSingleOrderDetail, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    self.navigationController?.popViewController(animated: true)
                }
                else
                {
                    if let data = response["data"] as? NSDictionary
                    {
                        if let order_details = data["order_details"] as? NSDictionary
                        {
                            
                            let OrderObj: OrderDetails = OrderDetails(json: JSON(order_details))
                            
                            self.orderDetails = OrderObj
                           // self.orderDetails?.orderStatus
                          //  print("Current Order Array :",self.orderDetails)
                        }
                    }
                    self.setUpDetails()
                }
                //self.ReinitializeApp()
                //	self.tableView.reloadData()
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    func reScheduleOrder(orderId : Int)
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "order_id" : orderId
        ]
        
        APIHelper.shared.postJsonRequest(url: APIRescheduleOrder, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    
                    if let data = response["data"] as? NSDictionary
                    {
                        let orderDetails = Order(json: JSON(data))
                        //print("Order Details : ",orderDetails)
                        switch APP_DELEGATE.socketIOHandler?.socket?.status{
                        case .connected?:
                            let d = ["order_id" : orderDetails.orderId ?? 0, "user_id" : USER_ID, "driver_ids" : orderDetails.driverIds ?? ""] as [String : Any]
                            APP_DELEGATE.socketIOHandler?.PlaceOrder(dic: d)
                            break
                        default:
                            print("Socket Not Connected")
                            break;
                        }
                        //Reload Screen
                        self.getOrderDetails(of: orderId)
                        //                               if let timerAlertView = self.storyboard?.instantiateViewController(withIdentifier: "TimerViewVC") as? TimerViewVC
                        //                               {
                        //                                   timerAlertView.delegate = self
                        //                                   timerAlertView.setOrderId(orderId: plcedOrderDetails[0].orderId ?? 0, ServerTime: plcedOrderDetails[0].serverTime ?? "")
                        //                                   self.present(timerAlertView, animated: false, completion: nil)
                        //                               }
                        
                    }
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
}
extension ConfirmedOrderVC{
    func getOrderDetails(of orderId : Int )
    {
        //GetCustomerOrders
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "order_id" : orderId,
                                 "user_id":USER_ID
        ]
        APIHelper.shared.postJsonRequest(url: APIGetConfirmOrderDetail, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    if let data = response["data"] as? NSDictionary
                    {
                        if let order_details = data["order_billing_details"] as? NSDictionary
                        {
                            
                            let OrderObj: OrderBillingDetails = OrderBillingDetails(json: JSON(order_details))
                            
                            self.orderBillingDetails = OrderObj
                            
                            print("Billing Detail Fetched")
                        }
                    }
                    self.setUpdetails()
                }
                //self.ReinitializeApp()
                //	self.tableView.reloadData()
            }
            else
            { if status == "ConnectionLost"{
                ShowToast(message: kCHECK_INTERNET_CONNECTION)
            } else{
                /*if response.count == 0 {
                 ShowToast(message: "Something went wrong. Please Try Again")
                 }else {*/
                ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                //}
                }
            }
        })
    }
}
extension CustomerSupportVC  {
    func getOrderDetails(of orderId: Int)
    {
        //GetCustomerOrders
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "order_id" : orderId,
                                 "user_id":USER_ID
        ]
        APIHelper.shared.postJsonRequest(url: APIGetSingleOrderDetail, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    if let data = response["data"] as? NSDictionary
                    {
                        if let order_details = data["order_details"] as? NSDictionary
                        {
                            
                            let OrderObj: OrderDetails = OrderDetails(json: JSON(order_details))
                            
                            self.orderDetails = OrderObj
                        }
                    }
                    self.setUpDetails()
                }
                //self.ReinitializeApp()
                //    self.tableView.reloadData()
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    func submitQuery(Customer query : String )
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "order_id" : orderId,
                                 "query":query
        ]
        APIHelper.shared.postJsonRequest(url: API_SUBMIT_ORDER_QUERY, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
}
extension GiveReviewVC {
    func giveReview(toUserId : Int, fromUserId : Int, rating : CGFloat, review : String, orderId : Int) {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "order_id" : orderId,
                                 "to_user_id" : toUserId,
                                 "from_user_id" : fromUserId,
                                 "rating" : rating,
                                 "review" : review
        ]
        APIHelper.shared.postJsonRequest(url: API_GIVE_REVIEW, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    self.dismisssVC()
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
}
extension ReviewAndRatingVC {
    func getRatingsAndReview( _ userId : Int)
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id":userId
        ]
        APIHelper.shared.postJsonRequest(url: APIGetRatingReview, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if self.arrReview.count != 0
                {
                    self.arrReview.removeAll()
                }
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                }
                else
                {
                    
                    if let data = response["data"] as? NSDictionary
                    {
                        if let reviews = data["reviews"] as? NSArray
                        {
                            for review in reviews{
                                let reviewObj: Reviews = Reviews(json: JSON(review))
                                self.arrReview.append(reviewObj)
                            }
                            print("Review Count : ",self.arrReview.count)
                        }
                    }
                    
                }
                self.setUpDetails()
                //self.ReinitializeApp()
                //    self.tableView.reloadData()
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
}
extension FavouriteStoreVC {
    func getFavouriteStore()
    {
        //IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : USER_ID]
        
        APIHelper.shared.postJsonRequest(url: APIGetFavouriteStore, parameter: param, headers: headers, completion: { iscompleted,status,response in
            //IHProgressHUD.dismiss()
            self.isApiCalled = true
            var msg  = "No Store Available."
            if self.stores.count != 0
            {
                self.stores.removeAll()
            }
            if iscompleted
            {
                if !(response["status"] as! Bool)
                {
                    // ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    msg = response["message"] as! String
                    //self.Categories.removeAll()
                }
                else
                {
                    // print(response["data"])
                    let data = response["data"] as? NSDictionary
                    if data != nil
                    {
                        if let storeArray = data?["stores"] as? NSArray
                        {
                            
                            for store in storeArray
                            {
                                let StoreObj : Store = Store(json: JSON(store))
                                self.stores.append(StoreObj)
                            }
                            print("Categories Array :",self.stores)
                        }
                    }
                }
                self.tableView.reloadData()
                
                if self.stores.count == 0
                {
                    self.lblDataNotAvailable.isHidden = false
                    self.lblDataNotAvailable.text = msg
                }
                else
                {
                    self.lblDataNotAvailable.isHidden = true
                }
                
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
    
    func markAsFavourite(favouriteStatus : Int, StoreId : Int , index : Int = 0)
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "store_id" : StoreId,
                                 "user_id" : USER_ID,
                                 "is_favourite" : favouriteStatus
        ]
        
        APIHelper.shared.postJsonRequest(url: APIMarkStoreAsFavouriteUnFavourite, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if status == "success"
                {
                    self.stores.remove(at: index)
                    self.tableView.reloadData()
                    if self.stores.count == 0
                    {
                        self.lblDataNotAvailable.isHidden = false
                    }
                    else
                    {
                        self.lblDataNotAvailable.isHidden = true
                    }
                }
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                } else{
                    /*if response.count == 0 {
                     ShowToast(message: "Something went wrong. Please Try Again")
                     }else {*/
                    ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                    //}
                }
            }
        })
    }
}

extension DriverLocationVC {
    
}

extension SupplierEarningsVC {
    func getWeeklyEarning(strStartDate : String, strEndDate : String)
    {
        //GetCustomerOrders
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "week_start_date" : strStartDate,
                                 "week_end_date" : strEndDate,
                                  "store_id" : (USER_OBJ?.storeId).asInt(),
                                  "user_id" : (USER_OBJ?.userId).asInt(),
        ]
        APIHelper.shared.postJsonRequest(url: API_GET_WEEKLY_EARNING, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                  //  self.lblNoData.isHidden = false
                    //self.tableView.isHidden = true
                    self.arrOrders = [SupplierOrder]()
                    self.arrWeeklyData = [WeeklyData]()
                    
                    self.setUpDetails()
                }
                else
                {
                  //  self.lblNoData.isHidden = true
                    self.tableView.isHidden = false
                    if let data = response["data"] as? NSDictionary
                    {
                        if let currentOrders = data["orders"] as? NSArray{
                            if self.arrOrders.count != 0{
                                self.arrOrders.removeAll()
                            }
                            for currentOrder in currentOrders{
                                let currentOrderObj: SupplierOrder = SupplierOrder(json: JSON(currentOrder))
                                self.arrOrders.append(currentOrderObj)
                            }
                            print("Current Order Array :",self.arrOrders)
                        }
                        
                        if let billingS = data["billing_summary"] as? NSDictionary {
                            self.billingDetails = BillingSummary(json: JSON(billingS))
                        }
                        
                        if let wDys = data["weekly_data"] as? NSArray{
                            if self.arrWeeklyData.count != 0{
                                self.arrWeeklyData.removeAll()
                            }
                            for objD in wDys{
                                let currentObj: WeeklyData = WeeklyData(json: JSON(objD))
                                self.arrWeeklyData.append(currentObj)
                            }
                        }
                    }
                    self.setUpDetails()
                }
                //self.ReinitializeApp()
                //self.tableView.reloadData()
            }
            else
            {
                if status == "ConnectionLost"
                {
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                    //self.showAlert(title: "Alert", message: kCHECK_INTERNET_CONNECTION)
                }
                else
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                   // self.showAlert(title: "Warning", message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
}

extension ExploreSearchVC {
    func exploreSearch(strText : String) {
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                     "access_key" : ACCESS_KEY,
                                     "searchText" : strText]
            
            APIHelper.shared.postJsonRequest(url: API_EXPLORE_SEARCH, parameter: param, headers: headers, completion: { iscompleted,status,response in
                //IHProgressHUD.dismiss()
                if iscompleted
                {
                    if !(response["status"] as! Bool) {
                        //ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                        //self.Categories.removeAll()
                        self.arrStores.removeAll()
                        self.arrProducts.removeAll()
                        if response["message"] as? String == "Please provide search text." {
                            self.lblNoDataFound.isHidden = true
                            self.imgPlaceholder.isHidden = false
                        } else {
                            self.lblNoDataFound.isHidden = false
                            self.imgPlaceholder.isHidden = true
                        }
                    }
                    else {
                        // print(response["data"])
                        let data = response["data"] as? NSDictionary
                        if data != nil
                        {
                            self.arrStores.removeAll()
                            self.arrProducts.removeAll()
                            if let storeArray = data?["explore_stores"] as? NSArray, storeArray.count > 0
                            {
                                self.arrStores = JSON(storeArray).to(type: Store.self) as! [Store]
                            }
                            if let productArray = data?["products"] as? NSArray, productArray.count > 0
                            {
                                self.arrProducts = JSON(productArray).to(type: Products.self) as! [Products]
                            }
                        }
                        if self.arrStores.count > 0 || self.arrProducts.count > 0 {
                            self.lblNoDataFound.isHidden = true
                            self.imgPlaceholder.isHidden = true
                        } else {
                            self.imgPlaceholder.isHidden = false
                        }
                    }
                    
                    
                    
                    self.tableView.reloadData()
                    
//                    if self.stores.count == 0
//                    {
//                        self.lblStoreNotAvailable.isHidden = false
//                        if searchText.count != 0
//                        {
//                            self.lblStoreNotAvailable.text = "Search result not found"
//                        }
//                        else
//                        {
//                            self.lblStoreNotAvailable.text = "No store available"
//                        }
//                    }
//                    else
//                    {
//                        self.lblStoreNotAvailable.isHidden = true
//                    }
                }
                else
                {
                    if status == "ConnectionLost"{
                        ShowToast(message: kCHECK_INTERNET_CONNECTION)
                    } else{
                        /*if response.count == 0 {
                         ShowToast(message: "Something went wrong. Please Try Again")
                         }else {*/
                       // ShowToast(message: response["message"] as? String ?? "Something went wrong.")
                        //}
                    }
                }
            })
        }
}
