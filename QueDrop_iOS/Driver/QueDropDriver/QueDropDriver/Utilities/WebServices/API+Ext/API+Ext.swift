//
//  API+Ext.swift
//  QueDropDeliveryCustomer
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
            "email": emailId,
            "login_as" : LOGIN_AS,
            "device_type": DEVICE_TYPE,
            "device_token": getFCMToken(),
            "timezone" : TIME_ZONE
        ]
        APIHelper.shared.postJsonRequest(url: API_LOGIN, parameter: param, headers: headers ) { (isCompleted, status, response) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if isCompleted {
                if !(response["status"] as! Bool) {
                    ShowToast(message: response["message"] as! String)
                }
                else {
                    APP_DELEGATE?.startUpdatingLocation()
                    print(response["data"] as Any)
                    let data = response["data"] as! NSDictionary
                    let userDict = data["user"] as! NSDictionary
                    let user: User = User(json: JSON(userDict))
                    USER_OBJ = user
                    USER_ID = user.userId ?? 0
                    setUserDetailObject(userDetail: USER_OBJ!)
                    setUserId(userId: USER_ID)
                    setUserType()
                    setIsUserLoggedIn(is_login: true)
                    
                    if self.isRememberMe {
                        setIsRememberMe(is_remember: true)
                        setEmail(strEmail: self.emailId)
                        setPassword(strPassword: self.password)
                    } else {
                        setIsRememberMe(is_remember: false)
                        setEmail(strEmail: "")
                        setPassword(strPassword: "")
                    }
                    
                    //Navigate to Phone Number Verification Screen
                    if USER_OBJ?.isPhoneVerified ?? 0 == 0
                    {
                        self.navigateToMobileVerification()
                    }else if  USER_OBJ?.isIdentityDetailUploaded ?? 0 == 0
                    {
                        self.navigateToDriverIdentityDetail()
                    }
                    else
                    {
                        self.navigateToHome()
                    }
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
            "login_as": LOGIN_AS,
            "socialKey": userSocialId,
            "email": email,
            "device_type": DEVICE_TYPE,
            "device_token": getFCMToken(),
            "timezone" : TIME_ZONE,
            "latitude" : CURRENT_LATITUDE,
            "longitude" : CURRENT_LONGITUDE,
            "address" :  "",
            "is_for_validation" : "1"
        ]
        APIHelper.shared.postJsonRequest(url: API_SOCIAL_REGISTER, parameter: param, headers: headers) { (isCompleted, status, response) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if isCompleted {
                if !(response["status"] as! Bool) {
                    ShowToast(message: response["message"] as! String)
                }
                else {
                    print(response["data"] as Any)
                    let data = response["data"] as! NSDictionary
                    let isUserAvailable = data["is_user_available"] as! Bool
                    print("availbility Status : ",isUserAvailable)
                    if isUserAvailable
                    {
                        let userDict = data["user"] as! NSDictionary
                        let user: User = User(json: JSON(userDict))
                        USER_OBJ = user
                        USER_ID = user.userId ?? 0
                        isGuest = false
                        setUserDetailObject(userDetail: USER_OBJ!)
                        setUserId(userId: USER_ID)
                        setUserType()
                        setIsUserLoggedIn(is_login: true)
                        //Navigate to Phone Number Verification Screen
                        if USER_OBJ?.isPhoneVerified ?? 0 == 0
                        {
                            self.navigateToMobileVerification()
                        }else if  USER_OBJ?.isIdentityDetailUploaded ?? 0 == 0
                        {
                            self.navigateToDriverIdentityDetail()
                        }
                        else
                        {
                            self.navigateToHome()
                        }
                        
                    }
                    else
                    {
                        let vc = LoginStoryboard.instantiateViewController(withIdentifier: "AdditionalDetailsVC") as! AdditionalDetailsVC
                        vc.SetDetails(loginType: loginType, userSocialId: userSocialId, firstName: firstName, lastName: lastName, email: email, profilePic_url: profilePic_url)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
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
            "login_as": LOGIN_AS,
            "socialKey": userSocialId,
            "email": email,
            "device_type": DEVICE_TYPE,
            "device_token": getFCMToken(),
            "timezone" : TIME_ZONE,
            "latitude" : CURRENT_LATITUDE,
            "longitude" : CURRENT_LONGITUDE,
            "address" :  "",
            "referral_code" : rCode,
            "user_image" : profilePic_url,
            "is_for_validation" : "0"
        ]
        APIHelper.shared.postJsonRequest(url: API_SOCIAL_REGISTER, parameter: param, headers: headers) { (isCompleted, status, response) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if isCompleted {
                if !(response["status"] as! Bool) {
                    ShowToast(message: response["message"] as! String)
                }
                else {
                    print(response["data"] as Any)
                    let data = response["data"] as! NSDictionary
                    let userDict = data["user"] as! NSDictionary
                    let user: User = User(json: JSON(userDict))
                    USER_OBJ = user
                    USER_ID = user.userId ?? 0
                    isGuest = false
                    setUserDetailObject(userDetail: USER_OBJ!)
                    setUserId(userId: USER_ID)
                    setUserType()
                    setIsUserLoggedIn(is_login: true)
                    
                    //Navigate to Phone Number Verification Screen
                    if USER_OBJ?.isPhoneVerified ?? 0 == 0
                    {
                        self.navigateToMobileVerification()
                    }else if  USER_OBJ?.isIdentityDetailUploaded ?? 0 == 0
                    {
                        self.navigateToDriverIdentityDetail()
                    }
                    else
                    {
                        self.navigateToHome()
                    }
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

extension ForgotPasswordVC{
    func forgotPassword() {
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "device_type": DEVICE_TYPE,
            "device_token": getFCMToken(),
            "timezone" : TIME_ZONE,
            "email" : txtEmail.text ?? ""
        ]
        APIHelper.shared.postJsonRequest(url: API_FORGOT_PASSWORD, parameter: param, headers: headers) { (isCompleted, status, response) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if isCompleted {
                if !(response["status"] as! Bool) {
                    ShowToast(message: response["message"] as! String)
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
extension SignUpVC {
    
    func doRegistration(fname : String, lname : String, password : String, referral_code : String, email : String)  {
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        var param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "firstname" : fname,
            "lastname" : lname,
            "password": password,
            "login_as" : LOGIN_AS,
            "referral_code": referral_code,
            "email": email,
            "device_type": "\(DEVICE_TYPE)",
            "device_token": getFCMToken(),
            "timezone" : TimeZone.current.identifier,
            "latitude" : "\(CURRENT_LATITUDE)",
            "longitude" : "\(CURRENT_LONGITUDE)",
            "address" : ""
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
                    let data = response!["data"] as! NSDictionary
                       let userDict = data["user"] as! NSDictionary
                       let user: User = User(json: JSON(userDict))
                       USER_OBJ = user
                       USER_ID = user.userId ?? 0
                       setUserDetailObject(userDetail: USER_OBJ!)
                       setUserId(userId: USER_ID)
                       setUserType()
                       setIsUserLoggedIn(is_login: true)
                       //Navigate to Phone Number Verification Screen
                       self.navigateToMobileVerification()
                   }
               }
           } else {
               //responseData(false, error, message)
               ShowToast(message: response?["message"] as? String ?? "")
           }
        }
        
       /* APIHelper.shared.postJsonRequest(url: API_SIGNUP, parameter: param, headers: headers) { (isCompleted, status, response) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if isCompleted {
                if !(response["status"] as! Bool) {
                    ShowToast(message: response["message"] as! String)
                }
                else {
                    print(response["data"] as Any)
                    let data = response["data"] as! NSDictionary
                    let userDict = data["user"] as! NSDictionary
                    let user: User = User(json: JSON(userDict))
                    USER_OBJ = user
                    USER_ID = user.userId ?? 0
                    setUserDetailObject(userDetail: USER_OBJ!)
                    setUserId(userId: USER_ID)
                    setUserType()
                    setIsUserLoggedIn(is_login: true)
                    //Navigate to Phone Number Verification Screen
                    self.navigateToMobileVerification()
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
        } */
    }
    
    func checkReferralCodeValidity(referralCode : String)  {
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let param: Parameters = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "login_as" : LOGIN_AS,
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
            "phone_number" : mobileNumber,
            "user_id" : USER_OBJ?.userId ?? 0
        ]
        
        APIHelper.shared.postJsonRequest(url: API_SENDOTP, parameter: param, headers: headers) { (isCompleted, status, response) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if isCompleted {
                if !(response["status"] as! Bool) {
                    ShowToast(message: response["message"] as! String)
                }
                else {
                    //Navigate to Code Verification Screen
                    self.navigateToCodeVerification()
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
    
    func callLogoutAPI() {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : USER_OBJ?.userId ?? 0,
                                 "device_token" : getFCMToken(),
                                 "device_type" : DEVICE_TYPE
        ]
        APIHelper.shared.postJsonRequest(url: API_LOGOUT, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as! String)
                }
                else
                {
                    // ShowToast(message: response["message"] as! String)
                    APP_DELEGATE?.socketIOHandler?.disconenctSocketManually()
                    doLogOut()
                    
                }
            }
            else
            {
                if status == "ConnectionLost"
                {
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                }
                else
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
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
            "user_id" : USER_ID
        ]
        
        APIHelper.shared.postJsonRequest(url: API_VERIFYOTP, parameter: param, headers: headers) { (isCompleted, status, response) in
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if isCompleted {
                if !(response["status"] as! Bool) {
                    ShowToast(message: response["message"] as! String)
                }
                else {
                    //Navigate to Code Verification Screen
                    
                    /*if getIsUserLoggedIn() {
                     USER_OBJ = getUserDetailObject()
                     USER_ID = USER_OBJ?.userId ?? 0
                     USER_OBJ?.isPhoneVerified = 1
                     USER_OBJ?.phoneNumber = mobileNumber
                     USER_OBJ?.countryCode = Int(strCountryCode)
                     setUserDetailObject(userDetail: USER_OBJ!)
                     setUserId(userId: USER_ID)
                     }*/
                    let data = response["data"] as! NSDictionary
                    print(response["data"] as Any)
                    let userDict = data["user"] as! NSDictionary
                    let user: User = User(json: JSON(userDict))
                    USER_OBJ = user
                    USER_ID = user.userId ?? 0
                    setUserDetailObject(userDetail: USER_OBJ!)
                    setUserId(userId: USER_ID)
                    setUserType()
                    setIsUserLoggedIn(is_login: true)
                    
                    if !self.isNavigateFromEditProfile {
                        if USER_OBJ?.isIdentityDetailUploaded ?? 0 == 0 {
                            self.navigateToDriverIdentityScreen()
                        } else {
                            self.navigateToHome()
                        }
                    }else {
                        //NAVIGATE TO PROFILE VC
                        for controller in self.navigationController!.viewControllers as Array {
                            if controller.isKind(of: ProfileVC.self) {
                                self.navigationController!.popToViewController(controller, animated: true)
                                break
                            }
                        }
                    }
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
extension UpdateDriverIdentityDetailVC {
    func updateDriverIdentityDetails() {
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let param: NSMutableDictionary =  [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "vehicle_type" : selectedVehicleType,
            "user_id" : "\(USER_ID)"
        ]
        
        if let imgDriverPhoto = imgPhoto {
            param["driver_photo"] = imgDriverPhoto
        }
        if let imgLicence = imgLicence {
            param["licence_photo"] = imgLicence
        }
        if let imgPlate = imgNumP {
            param["number_plate"] = imgPlate
        }
        if let imgReg = imgReg {
            param["registration_proof"] = imgReg
        }
        
        
        APIHelper.shared.postMultipartJSONRequest(endpointurl: API_UPDATE_DRIVER_IDENTITY, parameters: param) { (response, error, message) in
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if response != nil
            {
                if !(response?["status"] as! Bool) {
                    ShowToast(message: response?["message"] as! String)
                }
                else{
                    if let data = response?["data"] as? NSDictionary {
                        if self.isFromProfile {
                            ShowToast(message: response?["message"] as! String)
                        } else {
                            self.navigateToHome()
                        }
                        var dic = [String : Any]()
                        dic["driver_status"] = false
                        postNotification(withName: ncNOTIFICATION_SOCKET_DRIVER_STATUS, userInfo: ["data" : dic] as [String:Any])
                        updateUserObjectForDriverVerification(is_verified: 0)
                        updateUserObjectForDriverIdentity(is_uploaded: 1)
                    }
                }
            } else {
                //responseData(false, error, message)
                ShowToast(message: response?["message"] as? String ?? "")
            }
        }
    }
    
    func callLogoutAPI() {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : USER_OBJ?.userId ?? 0,
                                 "device_token" : getFCMToken(),
                                 "device_type" : DEVICE_TYPE
        ]
        APIHelper.shared.postJsonRequest(url: API_LOGOUT, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as! String)
                }
                else
                {
                    // ShowToast(message: response["message"] as! String)
                    APP_DELEGATE?.socketIOHandler?.disconenctSocketManually()
                    doLogOut()
                }
            }
            else
            {
                if status == "ConnectionLost"
                {
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                }
                else
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
}

extension HomeVC {
    func FetchPolylineForRoute(to_lat : String , to_long : String) {
        
        let session = URLSession.shared
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(CURRENT_LATITUDE ),\(CURRENT_LONGITUDE )&destination=\(to_lat),\(to_long)&sensor=false&mode=driving&key=\(GOOGLE_MAP_KEY)")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            let jsonResponse : [String:Any]?
            if let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
            {
                jsonResponse = jsonResult
            }else{
                print("error in JSONSerialization")
                return
            }
            
            guard let routes = jsonResponse!["routes"] as? [Any] else {
                return
            }
            
            if routes.count > 0 {
                guard let route = routes[0] as? [String: Any] else {
                    return
                }
                
                guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
                    return
                }
                
                guard let polyLineString = overview_polyline["points"] as? String else {
                    return
                }
                
                //CALL THIS METHOD TO DRAW ROUTE ON MAP
                DispatchQueue.main.async {
                    self.drawPathOnMap(witPolyline: polyLineString)
                }
            } else {
                return
            }
            
        })
        task.resume()
    }
    
    func getHomeEarningData()
    {
        //GetCustomerOrders
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "selected_date" : "\(DateFormatter(format: "yyyy-MM-dd").string(from: Date()))",
            "user_id":USER_ID
        ]
        APIHelper.shared.postJsonRequest(url: API_GET_HOME_EARNING, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    self.lblNoData.isHidden = false
                    self.collectionPager.isHidden = true
                    self.pageControl.isHidden = true
                    self.homeEarning = nil
                }
                else
                {
                    self.lblNoData.isHidden = true
                    self.collectionPager.isHidden = false
                    self.pageControl.isHidden = false
                    if let data = response["data"] as? NSDictionary
                    {
                        self.homeEarning = HomeEarning(json: JSON(data))
                    }
                }
                self.collectionPager.reloadData()
                self.pageControl.currentPage = 0
            }
            else
            {
                if status == "ConnectionLost"
                {
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                }
                else
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
}

extension OrderRequestDetailVC {
    func FetchPolylineForRoute(to_lat : String , to_long : String) {
        
        let session = URLSession.shared
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(CURRENT_LATITUDE ),\(CURRENT_LONGITUDE )&destination=\(to_lat),\(to_long)&sensor=false&mode=driving&key=\(GOOGLE_MAP_KEY)")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            let jsonResponse : [String:Any]?
            if let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
            {
                jsonResponse = jsonResult
            }else{
                print("error in JSONSerialization")
                return
            }
            
            guard let routes = jsonResponse!["routes"] as? [Any] else {
                return
            }
            
            if routes.count > 0 {
                guard let route = routes[0] as? [String: Any] else {
                    return
                }
                
                guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
                    return
                }
                
                guard let polyLineString = overview_polyline["points"] as? String else {
                    return
                }
                
                //CALL THIS METHOD TO DRAW ROUTE ON MAP
                DispatchQueue.main.async {
                    self.drawPathOnMap(witPolyline: polyLineString)
                }
            } else {
                return
            }
            
        })
        task.resume()
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
        APIHelper.shared.postJsonRequest(url: API_GET_DRIVER_ORDERS, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    self.lblNoData.isHidden = false
                    self.tableView.isHidden = true
                    self.arrCurrentOrder = [OrderDetail]()
                    self.setUpDetails()
                }
                else
                {
                    self.lblNoData.isHidden = true
                    self.tableView.isHidden = false
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
                                let currentOrderObj: OrderDetail = OrderDetail(json: JSON(currentOrder))
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

extension PastOrderVC {
    func getPastOrder()
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "is_for_current" : 2,
                                 "user_id":USER_ID
        ]
        APIHelper.shared.postJsonRequest(url: API_GET_DRIVER_ORDERS, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    self.lblNoData.isHidden = false
                    self.tableView.isHidden = true
                    self.arrPastOrder = [OrderDetail]()
                    self.setUpDetails()
                }
                else
                {
                    self.lblNoData.isHidden = true
                    self.tableView.isHidden = false
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
                                let currentOrderObj: OrderDetail = OrderDetail(json: JSON(currentOrder))
                                self.arrPastOrder.append(currentOrderObj)
                            }
                            print("Past Order Array :",self.arrPastOrder)
                        }
                    }
                    self.setUpDetails()
                }
                //self.ReinitializeApp()
                self.tableView.reloadData()
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

extension OrderDetailVC {
    func FetchPolylineForRoute(to_lat : String , to_long : String) {
        
        let session = URLSession.shared
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(CURRENT_LATITUDE ),\(CURRENT_LONGITUDE )&destination=\(to_lat),\(to_long)&sensor=false&mode=driving&key=\(GOOGLE_MAP_KEY)")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            let jsonResponse : [String:Any]?
            if let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
            {
                jsonResponse = jsonResult
            }else{
                print("error in JSONSerialization")
                return
            }
            
            guard let routes = jsonResponse!["routes"] as? [Any] else {
                return
            }
            
            if routes.count > 0 {
                guard let route = routes[0] as? [String: Any] else {
                    return
                }
                
                guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
                    return
                }
                
                guard let polyLineString = overview_polyline["points"] as? String else {
                    return
                }
                
                //CALL THIS METHOD TO DRAW ROUTE ON MAP
                DispatchQueue.main.async {
                    self.drawPathOnMap(witPolyline: polyLineString)
                }
            } else {
                return
            }
            
            
        })
        task.resume()
    }
    
    
    func uploadOrderStoreReceipt(orderId : Int, orderStoreId : Int, imgReceipt : UIImage, amount : String) {
        IHProgressHUD.show()
        let param: NSMutableDictionary =  [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "order_id" : "\(orderId)",
            "user_id" : "\(USER_ID)",
            "order_store_id" : "\(orderStoreId)",
            "receipt" : imgReceipt,
            "bill_amount" : amount
        ]
        
        APIHelper.shared.postMultipartJSONRequest(endpointurl: API_UPLOAD_ORDER_RECIEPT, parameters: param) { (response, error, message) in
            IHProgressHUD.dismiss()
            if response != nil
            {
                if (response!["status"] as! Bool){
                    self.getOrderDetail()
                }
                ShowToast(message: response?["message"] as! String)
                
            } else {
                //responseData(false, error, message)
                ShowToast(message: response?["message"] as? String ?? "")
            }
        }
    }
    
    func removeStoreReceipt(storeId : Int, userStoreId : Int, orderId : Int) {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "is_for_current" : 2,
                                 "user_id":USER_ID,
                                 "store_id" : storeId,
                                 "user_store_id" : userStoreId,
                                 "order_id" : orderId,
                                 "bill_amount" : 0
        ]
        APIHelper.shared.postJsonRequest(url: API_REMOVE_ORDER_RECEIPT, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    self.showAlert(title: "Alert", message: response["message"] as! String)
                }
                else
                {
                    self.getOrderDetail()
                    ShowToast(message: response["message"] as! String)
                }
            }
            else
            {
                if status == "ConnectionLost"
                {
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                }
                else
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
    
    func getSingleOrderDetail(orderId : Int)
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "order_id" : orderId
        ]
        APIHelper.shared.postJsonRequest(url: API_GET_SINGLE_ORDER_DETAIL, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    self.showAlert(title: "Alert", message: response["message"] as! String)
                }
                else
                {
                    if let data = response["data"] as? NSDictionary
                    {
                        if let dicOrder = data["order_details"] as? NSDictionary
                        {
                            let objOrder: OrderDetail = OrderDetail(json: JSON(dicOrder))
                            self.orderDetails = objOrder
                            // self.tblView.reloadData()
                            self.loadOrderData()
                        }
                    }
                }
            }
            else
            {
                if status == "ConnectionLost"
                {
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                }
                else
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
}

extension DeliveryRouteVC {
    func FetchPolylineForRoute(to_lat : String , to_long : String, from_lat : String, from_long : String) {
        
        let session = URLSession.shared
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(from_lat ),\(from_long )&destination=\(to_lat),\(to_long)&sensor=false&mode=driving&key=\(GOOGLE_MAP_KEY)")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            let jsonResponse : [String:Any]?
            if let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
            {
                jsonResponse = jsonResult
            }else{
                print("error in JSONSerialization")
                return
            }
            
            guard let routes = jsonResponse!["routes"] as? [Any] else {
                return
            }
            
            if routes.count > 0 {
                guard let route = routes[0] as? [String: Any] else {
                    return
                }
                
                guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
                    return
                }
                
                guard let polyLineString = overview_polyline["points"] as? String else {
                    return
                }
                
                //CALL THIS METHOD TO DRAW ROUTE ON MAP
                DispatchQueue.main.async {
                    self.drawPathOnMap(witPolyline: polyLineString)
                }
            } else {
                return
            }
            
            
        })
        task.resume()
    }
}

extension GiveReviewVC {
    func giveReview(toUserId : Int, fromUserId : Int, rating : Float, review : String, orderId : Int) {
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
                    ShowToast(message: response["message"] as! String)
                }
                else
                {
                    ShowToast(message: response["message"] as! String)
                    self.dismisssVC()
                }
            }
            else
            {
                if status == "ConnectionLost"
                {
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                }
                else
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
}

extension EditProfileVC {
    func updateProfileData( userdetail : Struct_EditProfileDetails) {
        IHProgressHUD.show()
        
        let param: NSMutableDictionary = [
            "secret_key" : SECRET_KEY,
            "access_key" : ACCESS_KEY,
            "user_id" : "\(USER_ID)",
            "user_name" : userdetail.username,
            "login_as" : LOGIN_AS,
            "first_name" : userdetail.fname,
            "last_name" : userdetail.lname,
            "phone_number" : userdetail.phone
        ]
        
        if let code = userdetail.country["dial_code"] as? String {
            param["country_code"] = code
        }
        
        if let image = userdetail.image {
            param["user_image"] = image
        }
        
        APIHelper.shared.postMultipartJSONRequest(endpointurl: API_EDIT_PROFILE, parameters: param) { (response, error, message) in
            IHProgressHUD.dismiss()
            if response != nil
            {
                if !(response?["status"] as! Bool) {
                    ShowToast(message: response?["message"] as! String)
                }
                else{
                    if let data = response?["data"] as? NSDictionary {
                        if let dict = data["users"] {
                            let user = JSON(dict).to(type: User.self) as! User
                            USER_OBJ = user
                            USER_ID = user.userId ?? 0
                            setUserDetailObject(userDetail: USER_OBJ!)
                            setUserId(userId: USER_ID)
                            
                            /*let isPhoneVerified = user.isPhoneVerified.asInt() == 1
                             if !isPhoneVerified {
                             let vc = LoginStoryboard.instantiateViewController(withIdentifier: "MobileVerificationVC") as! MobileVerificationVC
                             vc.isNavigateFromEditProfile = true
                             self.navigationController?.pushViewController(vc, animated: true)
                             } else {*/
                            self.loadProfileData()
                            self.navigationController?.popViewController(animated: true)
                            //}
                        }
                    }
                }
                
            } else {
                //responseData(false, error, message)
                ShowToast(message: response?["message"] as? String ?? "")
            }
        }
    }
}

extension ChangePasswordVC {
    func doChangePwd(newPwd : String, oldPwd : String) {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : USER_OBJ?.userId ?? 0,
                                 "old_password" : oldPwd,
                                 "new_password" : newPwd
        ]
        APIHelper.shared.postJsonRequest(url: API_CHANGE_PASSWORD, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as! String)
                }
                else
                {
                    ShowToast(message: response["message"] as! String)
                    self.password.oldPassword = ""
                    self.password.newPassword = ""
                    self.password.confirmPassword = ""
                    self.tblView.reloadData()
                }
            }
            else
            {
                if status == "ConnectionLost"
                {
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                }
                else
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
}

extension SettingsVC {
    func callLogoutAPI() {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : USER_OBJ?.userId ?? 0,
                                 "device_token" : getFCMToken(),
                                 "device_type" : DEVICE_TYPE
        ]
        APIHelper.shared.postJsonRequest(url: API_LOGOUT, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as! String)
                }
                else
                {
                    //ShowToast(message: response["message"] as! String)
                    APP_DELEGATE?.socketIOHandler?.disconenctSocketManually()
                    doLogOut()
                }
            }
            else
            {
                if status == "ConnectionLost"
                {
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                }
                else
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
}

extension ReviewRatingListVC {
    func getRatingsAndReview( _ userId : Int)
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id":userId
        ]
        APIHelper.shared.postJsonRequest(url: API_GET_REVIEW_RATING, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                if self.arrReview.count != 0
                {
                    self.arrReview.removeAll()
                }
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as! String)
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
                
                if self.arrReview.count > 0 {
                    self.tblView.reloadData()
                    self.tblView.isHidden = false
                    self.lblNoData.isHidden = true
                } else{
                    self.tblView.isHidden = true
                    self.lblNoData.isHidden = false
                }
                
                
            }
            else
            {
                if status != "ConnectionLost"
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
}

extension ViewDriverIdentityDetailsVC {
    func getIdentityDetails()
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id": USER_OBJ?.userId ?? 0
        ]
        APIHelper.shared.postJsonRequest(url: API_GET_DRIVER_IDENTITY, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as! String)
                }
                else
                {
                    
                    if let data = response["data"] as? NSDictionary
                    {
                        if let detail = data["driver_detail"] as? NSDictionary
                        {
                            self.driverDetails = DriverDetail(json: JSON(detail))
                            self.tblView.reloadData()
                        }
                    }
                    
                }
                
            }
            else
            {
                if status != "ConnectionLost"
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
}

extension ManagePaymentMethodVC{
    func getBankDetails() {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id": USER_OBJ?.userId ?? 0
        ]
        APIHelper.shared.postJsonRequest(url: API_GET_BANK_DETAILS, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as! String)
                }
                else
                {
                    
                    if let data = response["data"] as? NSDictionary,
                        let dict = data["bank_details"] {
                        self.arrOfPaymentType.removeAll()
                        self.arrOfPaymentType = JSON(dict).to(type: BankDetails.self) as! [BankDetails]
                        self.tableView.reloadData()
                        
                    }
                    
                }
                
            }
            else
            {
                if status != "ConnectionLost"
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
    
    func deleteBankDetails(bankDetailId : Int) {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id": USER_OBJ?.userId ?? 0,
                                 "bank_detail_id":bankDetailId
        ]
        APIHelper.shared.postJsonRequest(url: API_DELETE_BANK_DETAIL, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as! String)
                }
                else
                {
                    self.arrOfPaymentType = self.arrOfPaymentType.filter { return !($0.bankDetailId == bankDetailId) }
                    self.tableView.reloadData()
                    ShowToast(message: response["message"] as! String)
                }
                
            }
            else
            {
                if status != "ConnectionLost"
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
    
}


extension AddPaymentMethodVC{
    func getBankNameList() {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY
        ]
        APIHelper.shared.postJsonRequest(url: API_GET_BANK_NAME_LIST, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as! String)
                }
                else
                {
                    
                    if let data = response["data"] as? NSDictionary,
                        let dict = data["banks"] {
                        self.arrOfBanks.removeAll()
                        self.arrOfBanks = JSON(dict).to(type: Banks.self) as! [Banks]
                        self.bindBankToObj()
                        
                    }
                    
                }
                
            }
            else
            {
                if status != "ConnectionLost"
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
    
    
    func addEditBankDetail(isAdd : Bool, bankDetailId : Int, detail : Struct_SupplierBankDetails) {
        IHProgressHUD.show()
        var param: Parameters = ["secret_key" : SECRET_KEY,
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
        
        let url = isAdd ? API_ADD_BANK_DETAIL : API_EDIT_BANK_DETAILS
        
        APIHelper.shared.postJsonRequest(url: url, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as! String)
                }
                else
                {
                    
                    if let data = response["data"] as? NSDictionary,
                        let dict = data["bank_details"] {
                        let bankDetail = JSON(dict).to(type: BankDetails.self) as! BankDetails
                        self.callbackForLatestDetails?(bankDetail)
                        self.tableView.reloadData()
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                }
            }
            else
            {
                if status != "ConnectionLost"
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
}

extension NotificationVC{
    func getNotificationList() {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id" : USER_OBJ?.userId ?? 0,
                                 "page_num" : pageNumOffset
        ]
        APIHelper.shared.postJsonRequest(url: API_GET_NOTIFICATIONS, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    ShowToast(message: response["message"] as! String)
                }
                else
                {
                    
                    if let data = response["data"] as? NSDictionary,
                        let dict = data["notifications"] {
                        let notifications = JSON(dict).to(type: SupplierNotifications.self) as! [SupplierNotifications]
                        
                        if self.pageNumOffset == 1 {
                            self.arrOfNotification.removeAll()
                        }
                        self.arrOfNotification.append(contentsOf: notifications)
                        
                        
                        self.tableView.reloadData()
                    }
                    if let load_more = response["load_more"] as? Bool {
                        self.isLoadMore = load_more
                        if load_more {
                            self.pageNumOffset += 1
                        } 
                    }
                    
                }
                
            }
            else
            {
                if status != "ConnectionLost"
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
    
}

extension WeeklyEarningVC {
    func getWeeklyEarning(strStartDate : String, strEndDate : String)
    {
        //GetCustomerOrders
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "week_start_date" : strStartDate,
                                 "week_end_date" : strEndDate,
                                 "user_id":USER_ID
        ]
        APIHelper.shared.postJsonRequest(url: API_GET_WEEKLY_EARNING, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    self.lblNoData.isHidden = false
                    //self.tableView.isHidden = true
                    self.arrOrders = [OrderDetail]()
                    self.arrWeeklyData = [WeeklyData]()
                    
                    self.setUpTableDetails()
                }
                else
                {
                    self.lblNoData.isHidden = true
                    self.tableView.isHidden = false
                    if let data = response["data"] as? NSDictionary
                    {
                        if let currentOrders = data["orders"] as? NSArray{
                            if self.arrOrders.count != 0{
                                self.arrOrders.removeAll()
                            }
                            for currentOrder in currentOrders{
                                let currentOrderObj: OrderDetail = OrderDetail(json: JSON(currentOrder))
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
                    self.setUpTableDetails()
                }
                //self.ReinitializeApp()
                self.tableView.reloadData()
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

extension ManualStoreEarningVC {
    func getManualStoreEarning(selectedDate : String)
    {
        //GetCustomerOrders
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "selected_date" : selectedDate,
                                 "user_id":USER_ID
        ]
        APIHelper.shared.postJsonRequest(url: API_GET_MANUAL_EARNING, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    self.lblNoData.isHidden = false
                    //self.tableView.isHidden = true
                    self.arrOrders = [OrderDetail]()
                    
                    self.setUpTableDetails()
                }
                else
                {
                    self.lblNoData.isHidden = true
                    self.tableView.isHidden = false
                    if let data = response["data"] as? NSDictionary
                    {
                        if let currentOrders = data["orders"] as? NSArray{
                            if self.arrOrders.count != 0{
                                self.arrOrders.removeAll()
                            }
                            for currentOrder in currentOrders{
                                let currentOrderObj: OrderDetail = OrderDetail(json: JSON(currentOrder))
                                self.arrOrders.append(currentOrderObj)
                            }
                            print("Current Order Array :",self.arrOrders)
                        }
                    }
                    self.setUpTableDetails()
                }
                self.tableView.reloadData()
            }
            else
            {
                if status == "ConnectionLost"
                {
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                }
                else
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
}

extension FutureOrderVC{
    func getFutureOrderDates() {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id": USER_OBJ?.userId ?? 0,
                                 "is_for_customer" : 0
        ]
        APIHelper.shared.postJsonRequest(url: API_GET_FUTURE_ORDER_DATES, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool){
                    ShowToast(message: response["message"] as! String)
                }
                else
                {
                    
                    if let data = response["data"] as? NSDictionary,
                        let dict = data["future_order_dates"] {
                        self.arrFutureDates = JSON(dict).to(type: FutureOrderDates.self) as! [FutureOrderDates]
                        //RELOAD CALENDAR HERE
                       
                    }
                    
                }
                
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                }else {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
    
    func getFutureOrders(date : String) {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id": USER_OBJ?.userId ?? 0,
                                 "is_for_customer" : 0,
                                 "order_date" : date
                                 
                                 
        ]
        APIHelper.shared.postJsonRequest(url: API_GET_FUTURE_ORDERS, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    self.lblNoData.isHidden = false
                    //self.tblOrder.isHidden = true
                    self.arrOrders = [FutureOrders]()
                    //self.setUpDetails()
                }
                else
                {
                    self.lblNoData.isHidden = true
                    //self.tblOrder.isHidden = false
                    
                    if let data = response["data"] as? NSDictionary,
                        let dict = data["future_orders"] {
                        self.arrOrders = JSON(dict).to(type: FutureOrders.self) as! [FutureOrders]
                        //RELOAD CALENDAR HERE
                            
                    }
                    self.setUpDetails()
                }
                self.tblOrder.reloadData()
            }
            else
            {
                if status == "ConnectionLost"{
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                }else {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
    
}

extension FutureOrderDetailVC {
    func FetchPolylineForRoute(to_lat : String , to_long : String) {
        
        let session = URLSession.shared
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(CURRENT_LATITUDE ),\(CURRENT_LONGITUDE )&destination=\(to_lat),\(to_long)&sensor=false&mode=driving&key=\(GOOGLE_MAP_KEY)")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            let jsonResponse : [String:Any]?
            if let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
            {
                jsonResponse = jsonResult
            }else{
                print("error in JSONSerialization")
                return
            }
            
            guard let routes = jsonResponse!["routes"] as? [Any] else {
                return
            }
            
            if routes.count > 0 {
                guard let route = routes[0] as? [String: Any] else {
                    return
                }
                
                guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
                    return
                }
                
                guard let polyLineString = overview_polyline["points"] as? String else {
                    return
                }
                
                //CALL THIS METHOD TO DRAW ROUTE ON MAP
                DispatchQueue.main.async {
                    self.drawPathOnMap(witPolyline: polyLineString)
                }
            } else {
                return
            }
            
            
        })
        task.resume()
    }
    
    func getSingleFutureOrderDetail(orderId : Int)
    {
        IHProgressHUD.show()
        let param: Parameters = ["secret_key" : SECRET_KEY,
                                 "access_key" : ACCESS_KEY,
                                 "user_id":USER_OBJ?.userId ?? 0,
                                 "recurring_order_id":orderId,
                                 "timezone" : TIME_ZONE,
                                 "is_full_detail" : 1,
                                 "is_for_customer" : 0
        ]
        APIHelper.shared.postJsonRequest(url: API_GET_SINGLE_FUTURE_ORDER_DETAIL, parameter: param, headers: headers, completion: { iscompleted,status,response in
            IHProgressHUD.dismiss()
            if iscompleted
            {
                
                if !(response["status"] as! Bool)
                {
                    self.showAlert(title: "Alert", message: response["message"] as! String)
                }
                else
                {
                    if let data = response["data"] as? NSDictionary
                    {
                        if let dicOrder = data["future_orders"] as? NSDictionary
                        {
                            let objOrder: FutureOrders = FutureOrders(json: JSON(dicOrder))
                            self.orderDetails = objOrder
                            // self.tblView.reloadData()
                            self.loadOrderData()
                        }
                    }
                }
            }
            else
            {
                if status == "ConnectionLost"
                {
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                }
                else
                {
                    ShowToast(message: "Something went wrong.\n Please try after some time. ")
                }
            }
        })
    }
}
