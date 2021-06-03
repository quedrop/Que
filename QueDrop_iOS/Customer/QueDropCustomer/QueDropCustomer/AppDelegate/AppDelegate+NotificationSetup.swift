//
//  AppDelegate+NotificationSetup.swift
//  ChatDemo
//
//  Created by C100-105 on 22/05/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import UserNotificationsUI
import FirebaseMessaging

//MARK: - Notification Delegate & Other Methods
extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        DEVICE_TOKEN = token
        print("Device Token: \(DEVICE_TOKEN)")
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote push notification")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        //print("didReceiveRemoteNotification: \(userInfo)")
        
        var isDisplayNotification = true
        
        //        if let apsObj = userInfo["aps"] as? NSDictionary,
        //            let actionId = apsObj["category"] as? String {
        
        //            if let enumNoti = Enum_NotificationType(rawValue: actionId) {
        //                isDisplayNotification = true
        //            }
        //        }
        
        if isDisplayNotification {
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
        
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        FCM_TOKEN = fcmToken
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        var isDisplayNotification = true
        let userInfo = notification.request.content.userInfo
        print("willPresent: \(userInfo)")
        
        
        print("Firebase Noti \(notification)")
        let dataDict:[String: String] = ["token": FCM_TOKEN]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        let _ = notification.request.content.userInfo
        //print(userInfo)
        
        if isDisplayNotification {
            completionHandler([.alert, .badge, .sound])
        }
    }
    
    /*func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
     
     let userInfo = response.notification.request.content.userInfo
     var isDisplayNotification = true
     
     print("didReceive: \(userInfo)")
     
     if let apsObj = userInfo["aps"] as? NSDictionary,
     let actionId = apsObj["category"] as? Int {
     
     if let enumNoti = Enum_NotificationType(rawValue: actionId) {
     switch enumNoti {
     case .Driver_verification:
     break
     
     case .Rating:
     break
     
     case .Near_By_Place:
     break
     
     case .Order_Request,
     .Order_Accept,
     .Order_Reject,
     .Order_Request_Timeout,
     .Recurring_Order_Placed,
     .Order_receipt,
     .order_dispatch,
     .order_delivered,
     .order_cancelled:
     
     break
     
     case .chat:
     <#code#>
     case .unKnownType:
     isDisplayNotification = true
     break
     
     }
     }
     }
     
     if isDisplayNotification {
     completionHandler()
     }
     }*/
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Firebase Noti \(response)")
        let userInfo = response.notification.request.content.userInfo
        // let navigationController = UIApplication.shared.windows[0].rootViewController as! UINavigationController
                
        if !IS_APP_OPEN_FROM_NOTIFICATION_LAUNCH {
                        
            if response.notification.request.identifier == "ChatNotification" {
                if let dic = userInfo as? [String : Any] {
                    navigationToChat(dic: dic)
                }
            } else if response.notification.request.identifier == "OrderStatus" {
                if let dic = userInfo as? [String : Any] {
                    navigateToOrderDetail(dic: dic)
                }
            }  else if response.notification.request.identifier == "WeeklyPaymentNotification"{
                if let dic = userInfo as? [String : Any] {
                    navigationForPayment(dic: dic, isForWeekly: true)
                }
            } else if response.notification.request.identifier == "StoreVerificationNotification"{
                
            } else {
                if let dic = userInfo as? [String : Any] {
                    guard let notification_type = Enum_NotificationType(rawValue: Int(dic["notification_type"] as! String)!) else {
                        return
                    }
                    
                    //IF USER TYPE IS VICE VERSA FOR INCOMMING NOTIFICATION WE NEED TO SETUP ROOT ACCORDING TO THAT
                    if notification_type == .Order_Request || notification_type == .productVerification || notification_type == .storeVerification || notification_type == .supplierWeeklyPayment {
                        if UserType == .Customer {
                            APP_DELEGATE.socketIOHandler?.disconenctSocketManually(id: USER_ID)
                            saveUserTypeUserDefaults(type: .Supplier)
                            interChangeUserTypeNavigationIfNeeded()
                        }
                    } else {
                        if UserType == .Supplier {
                            APP_DELEGATE.socketIOHandler?.disconenctSocketManually(id: USER_ID)
                            saveUserTypeUserDefaults(type: .Customer)
                            interChangeUserTypeNavigationIfNeeded()
                        }
                    }
                    
                    switch notification_type {
                    case .chat:
                        navigationToChat(dic: dic)
                        break
                        
                    case .Order_Accept,
                         .order_dispatch,
                         .order_delivered,
                         .Order_receipt :
                        navigateToOrderDetail(dic: dic)
                        break
                    case .Rating:
                        navigateToRating(dic: dic)
                        break
                    case .Order_Request:
                        navigateToSupplierOrderDetail(dic: dic)
                        break
                    case .supplierWeeklyPayment:
                        navigationForPayment(dic: dic, isForWeekly: true)
                        break
                    default:
                        break
                    }
                }
            }
        } else {
            navigationToLaunch(dic: (userInfo as? [String : Any])!)
        }
        
        
        completionHandler()
        
    }
    
    func navigationToChat(dic : [String:Any]) {
        
      //  let keyExists = dic["notification_type"] != nil
        var orderId = 0
        var receiverId = 0
        //if keyExists {
            orderId = Int(dic["order_id"] as! String )!
            receiverId = Int(dic["sender_id"] as! String)!
       /* } else {
            orderId = dic["order_id"] .asInt()
            receiverId = dic["sender_id"] .asInt()
        }*/
        var needNavigation : Bool = false
        if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
            if visibleViewCtrl.isKind(of: CustomerChatVC.self) {
                if let chatvc = visibleViewCtrl as? CustomerChatVC {
                    
                    if chatvc.orderId == orderId  && chatvc.sender_id == USER_OBJ?.userId  && chatvc.receiver_id == receiverId {
                        needNavigation = false
                    } else {
                        needNavigation = true
                    }
                }
            } else {
                needNavigation = true
            }
        } else {
            needNavigation = true
        }
        
        if needNavigation && USER_OBJ != nil && USER_OBJ?.userId != 0  && UserType == .Customer{
            let navigationController = UIApplication.shared.windows[0].rootViewController as! UINavigationController
            let vcs = navigationController.viewControllers
            if (vcs.count > 0){
                let launch = vcs[0]
                if launch.isKind(of: LaunchVC.self){
                    var d = dic
                    d["notification_type"] = "\(Enum_NotificationType.chat.rawValue)"
                    navigationToLaunch(dic: d)
                } else {
                    let vc = CustomerOrdersStoryboard.instantiateViewController(withIdentifier: "CustomerChatVC") as! CustomerChatVC
                    vc.receiver_id = receiverId
                    vc.receiver_name = ""
                    vc.receiver_profile = ""
                    vc.orderId = orderId
                    vc.orderStatus = dic["order_status"] .asString()
                    vc.isFromNotification = true
                    navigationController.pushViewController(vc, animated: true)
                }
            }
        }
        
    }
    
    func navigateToOrderDetail(dic : [String:Any])  {
        if(USER_OBJ != nil && USER_OBJ?.userId != 0  && UserType == .Customer) {
            var needNavigation : Bool = false
            if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
                if visibleViewCtrl.isKind(of: OrderDetailsVC.self) {
                    if let vc = visibleViewCtrl as? OrderDetailsVC {
                        if vc.orderId == Int(dic["order_id"] as! String)! {
                            needNavigation = false
                        } else {
                            needNavigation = true
                        }
                    }
                } else {
                    needNavigation = true
                }
            } else {
                needNavigation = true
            }
            
            if needNavigation {
                let navigationController = UIApplication.shared.windows[0].rootViewController as! UINavigationController
                let orderVC = CustomerOrdersStoryboard.instantiateViewController(withIdentifier: "OrderDetailsVC") as! OrderDetailsVC
                orderVC.setOrderId(Int(dic["order_id"] as! String)!)
                navigationController.pushViewController(orderVC, animated: true)
            }
        }
    }
    
   func navigateToSupplierOrderDetail(dic : [String:Any])  {
        if(USER_OBJ != nil && USER_OBJ?.userId != 0  && UserType == .Supplier) {
            var needNavigation : Bool = false
            if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
                if visibleViewCtrl.isKind(of: SupplierOrderDetailsVC.self) {
                    if let vc = visibleViewCtrl as? SupplierOrderDetailsVC {
                        if vc.order.orderId == Int(dic["order_id"] as! String)! {
                            needNavigation = false
                        } else {
                            needNavigation = true
                        }
                    }
                } else {
                    needNavigation = true
                }
            } else {
                needNavigation = true
            }
            
            if needNavigation {
                let navigationController = UIApplication.shared.windows[0].rootViewController as! UINavigationController
                 let orderVC = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierOrderDetailsVC") as! SupplierOrderDetailsVC
                 orderVC.isNeedToGetOrderDetails = true
                let order = SupplierOrder(json: .null)
                order.orderId = Int(dic["order_id"] as! String)!
                orderVC.order = order
                navigationController.pushViewController(orderVC, animated: true)
            }
        }
    }
    
    func navigateToRating(dic : [String : Any]) {
        if(USER_OBJ != nil && USER_OBJ?.userId != 0  && UserType == .Customer) {
            var needNavigation : Bool = false
            if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
                if visibleViewCtrl.isKind(of: ReviewAndRatingVC.self) {
                    needNavigation = false
                } else {
                    needNavigation = true
                }
            } else {
                needNavigation = true
            }
            
            if needNavigation {
                let navigationController = UIApplication.shared.windows[0].rootViewController as! UINavigationController
                 let orderVC = CustomerStoryboard.instantiateViewController(withIdentifier: "ReviewAndRatingVC") as! ReviewAndRatingVC
                navigationController.pushViewController(orderVC, animated: true)
            }
        }
    }
    func navigationToLaunch(dic : [String : Any]) {
        IS_APP_OPEN_FROM_NOTIFICATION_LAUNCH = false
        IS_FROM_PUSH_NOTIFICATION = true
        PUSH_USER_INFO = dic
    }
    
    func interChangeUserTypeNavigationIfNeeded() {
        let navigationController = UIApplication.shared.windows[0].rootViewController as! UINavigationController
        if UserType == .Supplier {
            if USER_OBJ?.isPhoneVerified ?? 0 == 0 {
                let vc = LoginStoryboard.instantiateViewController(withIdentifier: "MobileVerificationVC") as! MobileVerificationVC
                navigationController.navigationBar.isHidden = true
                navigationController.pushViewController(vc, animated: true)
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
    }
    
    func navigationForPayment(dic : [String : Any], isForWeekly : Bool) {
        let navigationController = UIApplication.shared.windows[0].rootViewController as! UINavigationController
       
                    if let tabvc = navigationController.viewControllers[0] as? SupplierTabBarController {
                        
                        tabvc.selectedIndex = 2
                    }
                    
                postNotification(withName: ncNOTIFICATION_WEEKLY_PAYMENT, userInfo: dic)
        
       
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                //print("Permission granted: \(granted)")
                guard granted else { return }
                
                self?.addCategoriesForNotification()
                
                self?.getNotificationSettings()
        }
    }
    
    func addCategoriesForNotification() {
        
    }
    
    func getNotificationSettings() {
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            //print("Notification settings: \(settings.authorizationStatus)")
            
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    
}
public extension UIWindow {
    var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}
