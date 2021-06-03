//
//  AppDelegate.swift
//  QueDropDriver
//
//  Created by C100-174 on 27/02/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import GoogleMaps
import GooglePlaces
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    //MARK:- VARIABLES
    var window: UIWindow?
    var locationManager = CLLocationManager();
    var socketIOHandler:SocketIOHandler?
    var socketHandlersAdded =  false
    var FromHomeEarning = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        let remoteNotif = launchOptions?[.remoteNotification] as? NSDictionary
        let keyExists = remoteNotif?["aps"] != nil
        if /*remoteNotif != nil*/keyExists {
           // let notifName = remoteNotif?["aps"] as! String
            //print("Notification: \(notifName )")
            IS_APP_OPEN_FROM_NOTIFICATION_LAUNCH = true
        }
        else {
            IS_APP_OPEN_FROM_NOTIFICATION_LAUNCH = false
            print("Not remote")
        }
        //REMOVE ALL NOTIFICATION FROM NOTIFICATION TRAY
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        //CHECK IF USER IS LOGGED IN OR NOT
        if getIsUserLoggedIn() {
            USER_OBJ = getUserDetailObject()
            USER_ID = USER_OBJ?.userId ?? 0
        }
        //GOOGLE SIGNIN KEY
        GIDSignIn.sharedInstance().clientID = GoogleSignInKey
        
        //GOOGLE MAP KEY
        GMSServices.provideAPIKey(GOOGLE_MAP_KEY)
        GMSServices.provideAPIKey(GOOGLE_MAP_KEY)
        
        //INITIALIZE SOCKETIOHANDLER
        socketIOHandler=SocketIOHandler()
        
        //REGISTER FOR PUSH NOTIFICATION
        registerForPushNotifications(application)
        
        //FIREBASE CONFIGURATION
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        return true
    }
    
    func registerForPushNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        if socketIOHandler != nil{
            socketIOHandler?.background()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        IS_APP_OPEN_FROM_NOTIFICATION_LAUNCH = false
        var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0);
        bgTask = application.beginBackgroundTask(withName:"MyBackgroundTask", expirationHandler: {() -> Void in
            print("The task has started")
            application.endBackgroundTask(bgTask)
            bgTask = UIBackgroundTaskIdentifier.invalid
        })
        if socketIOHandler != nil{
           socketIOHandler?.background()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if socketIOHandler != nil{
            socketIOHandler?.foreground()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        //UPDATE TIMEZONE
        TIME_ZONE = TimeZone.current.identifier
        if socketIOHandler != nil{
           socketIOHandler?.foreground()
       }
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if socketIOHandler != nil{
            socketIOHandler?.ChangeDriverWorkingStatus(isOnline: false)
            socketIOHandler?.clearRequestQueue()
            removeCurrentOrderRequest(orderId: 0)
            socketIOHandler?.background()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
            DEVICE_TOKEN = token
            print("Device Token: \(DEVICE_TOKEN)")
        
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)")
    }
   //MARK:- SOCIAL LOGIN
   func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        let fbOpenUrl = ApplicationDelegate.shared.application(app, open: url, options: options)
        let googleOpenUrl = GIDSignIn.sharedInstance().handle(url)
        
      return fbOpenUrl || googleOpenUrl
    }
    
    //MARK:- START LOCATION UPDATION
    func startUpdatingLocation()  {
        if IS_GPS_ON {
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            } else {
                ShowToast(message: "Please turn location service on from your device's setting");
            }
        } else {
            ShowToast(message: "Please turn location service on from your device's setting");
        }
    }
    
    //MARK:- CLLOCATIONMANAGER DELEGATE METHOD
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        if(getIsUserLoggedIn() && locValue.latitude != CURRENT_LATITUDE && locValue.longitude != CURRENT_LONGITUDE) {
            CURRENT_LATITUDE = locValue.latitude
            CURRENT_LONGITUDE = locValue.longitude
            NotificationCenter.default.post(name: NSNotification.Name(ncNOTIFICATION_LOCATION_UPDATE), object: nil, userInfo: nil)
            //UPDATE LOCATION VIA SOCKET
            socketDriverLocationUpdate()
        }
        CURRENT_LATITUDE = locValue.latitude
        CURRENT_LONGITUDE = locValue.longitude
        
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func socketDriverLocationUpdate()  {
        switch socketIOHandler?.socket?.status{
            case .connected?:
                if (socketIOHandler!.isJoinSocket){
                    socketIOHandler?.updateDriverLocation()
                }
                break
            default:
               print("Socket Not Connected")
        }
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate,MessagingDelegate{
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        FCM_TOKEN = fcmToken
        setFCMToken(strToken: fcmToken)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Firebase Noti \(notification)")
        //let dataDict:[String: String] = ["token": FCM_TOKEN]
        //NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        completionHandler([.alert,.badge,.sound])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Firebase Noti \(userInfo)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Firebase Noti \(response)")
        let userInfo = response.notification.request.content.userInfo
        
        if !IS_APP_OPEN_FROM_NOTIFICATION_LAUNCH {
            if response.notification.request.identifier == "ChatNotification" {
                if let dic = userInfo as? [String : Any] {
                    navigationToChat(dic: dic)
               }
            } else if response.notification.request.identifier == "OrderDelieverNotification" {
                if let dic = userInfo as? [String : Any] {
                    navigateToOrderDetail(dic: dic)
                }
            } else if response.notification.request.identifier == "Notification.driver_verifiy" {
                
            } else if response.notification.request.identifier == "ManualStorePaymentNotification"{
                if let dic = userInfo as? [String : Any] {
                    navigationForPayment(dic: dic, isForWeekly: false)
                }
            } else if response.notification.request.identifier == "WeeklyPaymentNotification"{
                if let dic = userInfo as? [String : Any] {
                    navigationForPayment(dic: dic, isForWeekly: true)
                }
            } else {
                if let dic = userInfo as? [String : Any] {
                    guard let notification_type = Enum_NotificationType(rawValue: Int(dic["notification_type"] as! String)!) else {
                        return
                    }
        
                    switch notification_type {
                    case .chat:
                        navigationToChat(dic: dic)
                        break
                    case .Driver_verification:
                        if USER_OBJ?.userId == Int(dic["user_id"] as! String)! {
                            updateUserObjectForDriverVerification(is_verified: Int(dic["is_driver_verified"] as! String)!)
                        }
                        break
                    case .Order_Request:
                        navigateToOrderRequestDetail(dic: dic)
                        break
                    case .order_delivered:
                        navigateToOrderDetail(dic: dic)
                        break
                    case .Rating:
                        navigateToRating(dic: dic)
                        break
                    case .manualStorePayment:
                        navigationForPayment(dic: dic, isForWeekly: true)
                        break
                        
                    case .driverWeeklyPayment:
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
            if visibleViewCtrl.isKind(of: DriverChatVC.self) {
                if let chatvc = visibleViewCtrl as? DriverChatVC {
                    
                    if chatvc.orderId == orderId  && chatvc.sender_id == USER_OBJ?.userId  && chatvc.receiver_id == receiverId {
                        needNavigation = false
                    } else {
                        needNavigation = true
                    }
                }
            } else {
                needNavigation = true
            }
        }
        
        if needNavigation && getIsUserLoggedIn(){
            let navigationController = UIApplication.shared.windows[0].rootViewController as! UINavigationController
            let vcs = navigationController.viewControllers
            if (vcs.count > 0){
                let launch = vcs[0]
                if launch.isKind(of: LaunchVC.self){
                    var d = dic
                    d["notification_type"] = "\(Enum_NotificationType.chat.rawValue)"
                    navigationToLaunch(dic: d)
                } else {
                    let vc = HomeStoryboard.instantiateViewController(withIdentifier: "DriverChatVC") as! DriverChatVC
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
        if(getIsUserLoggedIn()) {
            let navigationController = UIApplication.shared.windows[0].rootViewController as! UINavigationController
            let orderVC = HomeStoryboard.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
            orderVC.orderId = Int(dic["order_id"] as! String)!
            orderVC.isFromPast = true
            navigationController.pushViewController(orderVC, animated: true)
        }
    }
    
    func navigateToRating(dic : [String : Any]) {
        if(USER_OBJ != nil && USER_OBJ?.userId != 0) {
            var needNavigation : Bool = false
            if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
                if visibleViewCtrl.isKind(of: ReviewRatingListVC.self) {
                    needNavigation = false
                } else {
                    needNavigation = true
                }
            }
            
            if needNavigation {
                let navigationController = UIApplication.shared.windows[0].rootViewController as! UINavigationController
                 let orderVC = HomeStoryboard.instantiateViewController(withIdentifier: "ReviewRatingListVC") as! ReviewRatingListVC
                navigationController.pushViewController(orderVC, animated: true)
            }
        }
    }
    
    func navigationToLaunch(dic : [String : Any]) {
        IS_APP_OPEN_FROM_NOTIFICATION_LAUNCH = false
        IS_FROM_PUSH_NOTIFICATION = true
        PUSH_USER_INFO = dic
    }
    
    func navigateToOrderRequestDetail(dic : [String : Any]) {
        if(getIsUserLoggedIn()) {
            let navigationController = UIApplication.shared.windows[0].rootViewController as! UINavigationController
            if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
                /*if visibleViewCtrl.isKind(of: HomeVC.self) {
                } else {*/
                    visibleViewCtrl.tabBarController?.selectedIndex = tTAB_HOME
                    navigationController.popToViewController(ofClass: HomeVC.self)
                
                    let orderVC = HomeStoryboard.instantiateViewController(withIdentifier: "OrderRequestDetailVC") as! OrderRequestDetailVC
                    orderVC.orderId = Int(dic["order_id"] as! String)!
                    orderVC.isFromNotification = true
                    navigationController.pushViewController(orderVC, animated: true)
                
                //}
            }
        }
        
        
    }
    
    func navigationForPayment(dic : [String : Any], isForWeekly : Bool) {
        let navigationController = UIApplication.shared.windows[0].rootViewController as! UINavigationController
       
           /* if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
                if visibleViewCtrl.isKind(of: EarningVC.self) {
                } else {*/
                    if let tabvc = navigationController.viewControllers[0] as? CustomTabbarVC {
                        if isForWeekly {
                            APP_DELEGATE?.FromHomeEarning = true
                        } else {
                            APP_DELEGATE?.FromHomeEarning = false
                        }
                        tabvc.selectedIndex = tTAB_EARNING
                    }
                    
               // }
           // }
            if isForWeekly {
                postNotification(withName: ncNOTIFICATION_WEEKLY_PAYMENT, userInfo: dic)
            }else {
                postNotification(withName: ncNOTIFICATION_MANUAL_PAYMENT, userInfo: dic)
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
