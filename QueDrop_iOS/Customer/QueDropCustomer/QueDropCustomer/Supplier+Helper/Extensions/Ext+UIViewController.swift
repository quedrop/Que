//
//  Ext+UIViewController.swift
//  Assignment10
//
//  Created by C100-105 on 04/02/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func ReinitializeApp() {
        BADGE_COUNT = 0
      APP_DELEGATE.socketIOHandler?.disconenctSocketManually(id: USER_ID)
        UserDefaults.standard.removeCustomObject(forKey: kUserDetailsUdf)
        UserDefaults.standard.removeObject(forKey: kUserTypeUdf)
        defaultAddress = nil
        structCustomerTempCart = CustomerTempCart()
        cartItems = 0
        storeDetailsObj = nil
        navigateToHome()
    }
    
    func navigateToHome(from : navigationType) {
        
        switch from {
        case .login:
            if UserType == .Supplier {
                if USER_OBJ?.isPhoneVerified ?? 0 == 0 {
                    let vc = LoginStoryboard.instantiateViewController(withIdentifier: "MobileVerificationVC") as! MobileVerificationVC
                    self.navigationController?.navigationBar.isHidden = true
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if USER_OBJ?.storeId ?? 0 == 0 {
                    let vc = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierStoreDetailsVC") as! SupplierStoreDetailsVC
                    vc.isAddStore = true
                    self.navigationController?.navigationBar.isHidden = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else{
                    let navVc = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierTabBarNavigation") as! UINavigationController
                    navVc.navigationBar.isHidden = true
                    APP_DELEGATE.window?.rootViewController = navVc
                }
            } else {
                let navVc = CustomerStoryboard.instantiateViewController(withIdentifier: "CustomerTabBarNavigation") as! UINavigationController
                navVc.navigationBar.isHidden = true
                if let AddressObj = UserDefaults.standard.getCustom(forKey: kDefaultLocation) as? Address {
                    defaultAddress = AddressObj
                    
                } else {
                    let nextViewController = CustomerStoryboard.instantiateViewController(withIdentifier: "CustomerLocationVC") as! CustomerLocationVC
                    navVc.pushViewController(nextViewController, animated: true)
                    return
                }
                navVc.navigationBar.isHidden = true
                APP_DELEGATE.window?.rootViewController = navVc
            }
            
            break
        case .register:
            let vc = LoginStoryboard.instantiateViewController(withIdentifier: "MobileVerificationVC") as! MobileVerificationVC
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .TypeSelection:
            if UserType == .Supplier && USER_OBJ != nil && USER_OBJ?.userId != 0 {
                if USER_OBJ?.isPhoneVerified ?? 0 == 0 {
                    let vc = LoginStoryboard.instantiateViewController(withIdentifier: "MobileVerificationVC") as! MobileVerificationVC
                    self.navigationController?.navigationBar.isHidden = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if USER_OBJ?.storeId ?? 0 == 0 {
                    let vc = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierStoreDetailsVC") as! SupplierStoreDetailsVC
                    vc.isAddStore = true
                    self.navigationController?.navigationBar.isHidden = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else{
                    let navVc = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierTabBarNavigation") as! UINavigationController
                    navVc.navigationBar.isHidden = true
                    APP_DELEGATE.window?.rootViewController = navVc
                    checkForNotificationNavigation()
                }
            } else if UserType == .Customer {
                let navVc = CustomerStoryboard.instantiateViewController(withIdentifier: "CustomerTabBarNavigation") as! UINavigationController
                navVc.navigationBar.isHidden = true
                if let AddressObj = UserDefaults.standard.getCustom(forKey: kDefaultLocation) as? Address {
                    defaultAddress = AddressObj
                    
                } else {
                    let nextViewController = CustomerStoryboard.instantiateViewController(withIdentifier: "CustomerLocationVC") as! CustomerLocationVC
                    navVc.pushViewController(nextViewController, animated: true)
                    // return
                }
                navVc.navigationBar.isHidden = true
                APP_DELEGATE.window?.rootViewController = navVc
                checkForNotificationNavigation()
            }
            else
            {
                let nextViewController = CustomerStoryboard.instantiateViewController(withIdentifier: "CustomerLocationVC") as! CustomerLocationVC
                self.navigationController?.pushViewController(nextViewController, animated: true)
                /*var navVc = MainStoryboard.instantiateViewController(withIdentifier: "TypeSelectionNav") as! UINavigationController
                 navVc.navigationBar.isHidden = true
                 APP_DELEGATE.window?.rootViewController = navVc*/
            }
            break
        case .switchAccount:
            break
        }
    }
    
    func checkForNotificationNavigation() {
        if IS_FROM_PUSH_NOTIFICATION {
            IS_FROM_PUSH_NOTIFICATION = false
            
            if PUSH_USER_INFO.count > 0 {
                //JOIN DRIVER WITH SOCKET
                let dict:NSMutableDictionary = NSMutableDictionary()
                dict.setValue(USER_OBJ?.userId, forKey: "user_id")
                APP_DELEGATE.socketIOHandler?.joinSocketWithData(data: dict)
                
                guard let notification_type = Enum_NotificationType(rawValue: Int(PUSH_USER_INFO["notification_type"] as! String)!) else {
                    return
                }
                
                //IF USER TYPE IS VICE VERSA FOR INCOMMING NOTIFICATION WE NEED TO SETUP ROOT ACCORDING TO THAT
                if notification_type == .Order_Request || notification_type == .productVerification || notification_type == .storeVerification || notification_type == .supplierWeeklyPayment{
                    if UserType == .Customer {
                        APP_DELEGATE.socketIOHandler?.disconenctSocketManually(id: USER_ID)
                        saveUserTypeUserDefaults(type: .Supplier)
                        navigateToHome(from: .login)
                    }
                } else {
                    if UserType == .Supplier {
                        APP_DELEGATE.socketIOHandler?.disconenctSocketManually(id: USER_ID)
                        saveUserTypeUserDefaults(type: .Customer)
                        navigateToHome(from: .login)
                    }
                }
               
                
                let nav = APP_DELEGATE.window?.rootViewController as! UINavigationController
                
                switch notification_type {
                case .chat:
                    
                    if(USER_OBJ != nil && USER_OBJ?.userId != 0 && UserType == .Customer) {
                        let vc = CustomerOrdersStoryboard.instantiateViewController(withIdentifier: "CustomerChatVC") as! CustomerChatVC
                        vc.receiver_id = Int(PUSH_USER_INFO["sender_id"] as! String)!
                        vc.receiver_name = ""
                        vc.receiver_profile = ""
                        vc.orderId = Int(PUSH_USER_INFO["order_id"] as! String)!
                        vc.orderStatus = PUSH_USER_INFO["order_status"] .asString()
                        vc.isFromNotification = true
                        nav.pushViewController(vc, animated: true)
                    }
                    break
                case .Order_Accept,
                     .order_dispatch,
                     .order_delivered,
                     .Order_receipt :
                    if(USER_OBJ != nil && USER_OBJ?.userId != 0 && UserType == .Customer) {
                        let orderVC = CustomerOrdersStoryboard.instantiateViewController(withIdentifier: "OrderDetailsVC") as! OrderDetailsVC
                        orderVC.setOrderId(Int(PUSH_USER_INFO["order_id"] as! String)!)
                        nav.pushViewController(orderVC, animated: true)
                    }
                    break
                case .Rating:
                    if(USER_OBJ != nil && USER_OBJ?.userId != 0 && UserType == .Supplier) {
                        let orderVC = CustomerStoryboard.instantiateViewController(withIdentifier: "ReviewAndRatingVC") as! ReviewAndRatingVC
                        nav.pushViewController(orderVC, animated: true)
                    }
                    break
                case .Order_Request:
                    if(USER_OBJ != nil && USER_OBJ?.userId != 0 && UserType == .Supplier) {
                        let orderVC = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierOrderDetailsVC") as! SupplierOrderDetailsVC
                        orderVC.isNeedToGetOrderDetails = true
                        let order = SupplierOrder(json: .null)
                        order.orderId = Int(PUSH_USER_INFO["order_id"] as! String)!
                        orderVC.order = order
                        nav.pushViewController(orderVC, animated: true)
                    }
                    break
                case .supplierWeeklyPayment:
                    if let tabvc = nav.viewControllers[0] as? SupplierTabBarController {
                        tabvc.selectedIndex = 2
                    }
                    postNotification(withName: ncNOTIFICATION_WEEKLY_PAYMENT, userInfo: PUSH_USER_INFO)
                    break
                
                case .productVerification, .storeVerification:
                    let navVc = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierTabBarNavigation") as! UINavigationController
                    navVc.navigationBar.isHidden = true
                    APP_DELEGATE.window?.rootViewController = navVc
                    break
                default:
                    break
                }
                
                
            }
            
        } else if IS_FROM_LOCAL_NOTIFICATION {
            IS_FROM_LOCAL_NOTIFICATION = false
            
        }
        PUSH_USER_INFO = [String:Any]()
    }
    
    func navigateToHome() {
        var navVc = CustomerStoryboard.instantiateViewController(withIdentifier: "CustomerLocationNav") as! UINavigationController
        
        if let user = USER_OBJ {
            if !isGuest && user.isPhoneVerified ?? 0 == 0 {
                let vc = LoginStoryboard.instantiateViewController(withIdentifier: "MobileVerificationVC") as! MobileVerificationVC
                navVc.pushViewController(vc, animated: true)
            } else {
                
                if UserType == .Supplier {
                    navVc = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierTabBarNavigation") as! UINavigationController
                } else {
                    navVc = CustomerStoryboard.instantiateViewController(withIdentifier: "CustomerTabBarNavigation") as! UINavigationController
                    
                    if let AddressObj = UserDefaults.standard.getCustom(forKey: kDefaultLocation) as? Address {
                        defaultAddress = AddressObj
                        
                    } else {
                        let nextViewController = CustomerStoryboard.instantiateViewController(withIdentifier: "CustomerLocationVC") as! CustomerLocationVC
                        navVc.pushViewController(nextViewController, animated: true)
                        //  return
                    }
                }
            }
        }
        
        navVc.navigationBar.isHidden = true
        APP_DELEGATE.window?.rootViewController = navVc
    }
    
    func showCustomAlert(
        title: String,
        message: String,
        noAction: UIAlertAction,
        yesAction: UIAlertAction? = nil) {
        
        let alertView = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        alertView.addAction(noAction)
        
        if let yesAction = yesAction {
            alertView.addAction(yesAction)
        }
        
        present(alertView, animated: true, completion: nil)
    }
    
    func showOkAlert(title: String = "", message: String, completion: (() -> ())? = nil) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            completion?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showOkAlert(_ message: String, completion: Callback? = nil) -> Void {
        showOkAlert(title: "", message: message, completion: completion)
    }
    
    func showDismissAlert(
        title: String,
        message: String,
        alertShowTime time: DispatchTime = DispatchTime.now() + 3,
        completion: Callback? = nil) {
        
        var isDismissed = false
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .cancel,
                handler: { action in
                    isDismissed = true
                    completion?()
            })
        )
        
        self.present(
            alert,
            animated: true,
            completion: {
                DispatchQueue.main.asyncAfter(deadline: time) {
                    if !isDismissed {
                        alert.dismiss(animated: true, completion: completion)
                    }
                }
        })
    }
    
}

extension UIAlertAction {
    
    static var defaultNoAction: UIAlertAction {
        return UIAlertAction(title: "No", style: .destructive, handler: nil)
    }
    
    static var defaultCancelAction: UIAlertAction {
        return UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    }
    
    static var defaultOkAction: UIAlertAction {
        return UIAlertAction(title: "Ok", style: .default, handler: nil)
    }
    
}
