//
//  AppDelegate.swift
//  QueDrop
//
//  Created by C100-104 on 26/12/19.
//  Copyright © 2019 C100-104. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import IHProgressHUD
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging
import Braintree
  
var isDevelopmentTarget = false

//@available(iOS 13.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var socketIOHandler:SocketIOHandler?
    var socketHandlersAdded = false
    var navigateToSupplierLogin : Bool = false
    var braintreeClient: BTAPIClient?
    
    let notificationCenter = UNUserNotificationCenter.current()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        isDevelopmentTarget = true
        #else
        isDevelopmentTarget = false
        #endif
        
        let remoteNotif = launchOptions?[.remoteNotification] as? NSDictionary
        let keyExists = remoteNotif?["aps"] != nil
        if /*remoteNotif != nil*/keyExists {
            IS_APP_OPEN_FROM_NOTIFICATION_LAUNCH = true
        }
        else {
            IS_APP_OPEN_FROM_NOTIFICATION_LAUNCH = false
        }
        
        //REMOVE ALL NOTIFICATION FROM NOTIFICATION TRAY
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        
        GMSServices.provideAPIKey(GoogleMapKey)
        GMSPlacesClient.provideAPIKey(GoogleMapKey)
        //window?.backgroundColor = .white
        
        
        socketIOHandler=SocketIOHandler()
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
        TIME_ZONE = localTimeZoneIdentifier
        IHProgressHUD.set(defaultMaskType: .clear)
        
        // Initialize Google sign-in
        GIDSignIn.sharedInstance().clientID = GoogleSignInKey
        
        //BRAINTREE
        braintreeClient = BTAPIClient(authorization: BRAINTREE_TOKENTISE_KEY)
        
        
        registerForPushNotifications(application)
        notificationCenter.delegate = self
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        TIME_ZONE = TimeZone.current.identifier
//        if socketIOHandler != nil{
//            socketIOHandler?.foreground()
//        }
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        IS_APP_OPEN_FROM_NOTIFICATION_LAUNCH = false
        if socketIOHandler != nil{
//            var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0);
//                  bgTask = application.beginBackgroundTask(withName:"MyBackgroundTask", expirationHandler: {() -> Void in
//                      print("The task has started")
//                      application.endBackgroundTask(bgTask)
//                      bgTask = UIBackgroundTaskIdentifier.invalid
//                  })
                  if socketIOHandler != nil{
                     socketIOHandler?.background()
                 }
           // socketIOHandler?.background()
        }
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        if socketIOHandler != nil {
            socketIOHandler?.foreground()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
//        if socketIOHandler != nil{
//            socketIOHandler?.background()
//        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
           if socketIOHandler != nil{
               socketIOHandler?.background()
           }
       }
    func scheduleNotification(notificationType: NotificationType, userInfo : [String:Any] =  ["":""]) {
        
        let content = UNMutableNotificationContent() // Содержимое уведомления
        var identifier = "Local Notification"
        switch notificationType {
        case .orderStatusUpdate:
            content.title = "Order Status "
            content.body = "Your Order Status Changed."
            content.userInfo = userInfo
            identifier = "OrderStatus"
            break
        case  .orderAccepted:
            content.title = "Order Status"
            content.body = "Your Order Accepted by Driver.."
            content.userInfo = userInfo
            identifier = "OrderStatus"
            break
        case .driverLocationUpdated:
            content.title = "Driver Location Changed"
            content.body = "Current Order Driver Location Updated"
            break
        default:
            break
        }
        //content.title = notificationType
        //content.body = "This is example how to create " + notificationType // Notifications
        if #available(iOS 12.0, *) {
            content.sound = .defaultCritical
        } else {
            content.sound = .default
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:  1, repeats: false)
        
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    func registerForPushNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            notificationCenter.delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            notificationCenter.requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        let fbOpenUrl = ApplicationDelegate.shared.application(app, open: url, options: options)
        let googleOpenUrl = GIDSignIn.sharedInstance().handle(url)
        
        return fbOpenUrl || googleOpenUrl
    }
}
