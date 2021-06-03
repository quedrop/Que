//
//  LaunchVC.swift
//  QueDrop
//
//  Created by C100-104 on 22/01/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import AVKit
import CoreLocation
import Alamofire

class LaunchVC: BaseViewController {
    //MARK:- CONSTANTS
    
    //MARK:- VARIABLES
    var player: AVPlayer?
    let locStatus = CLLocationManager.authorizationStatus()

    //MARK:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        loadVideo()
    }
    
    
    //MARK:- LOAD LAUNCH VIDEO
    private func loadVideo() {
        //this line is important to prevent background music stop
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        } catch { }
        
        let path = Bundle.main.path(forResource: "launch_video", ofType:"mp4")
        
        player = AVPlayer(url: URL(fileURLWithPath: path ?? ""))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = .resizeAspectFill
      //  playerLayer.zPosition = -1
        
        self.view.layer.addSublayer(playerLayer)
        
        player?.seek(to: CMTime.zero)
        player?.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        var temp = 0
        switch locStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            IS_GPS_ON = true
            temp = 1
            break
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            break
        @unknown default:
            break
        }
        
        if temp == 1 {
            APP_DELEGATE?.startUpdatingLocation()
            if(!getIsUserLoggedIn()){
                let vc = LoginStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                if (USER_OBJ?.isPhoneVerified == 0) {
                    let vc = LoginStoryboard.instantiateViewController(withIdentifier: "MobileVerificationVC") as! MobileVerificationVC
                    vc.isFromLaunch = true
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if (USER_OBJ?.isIdentityDetailUploaded == 0) {
                    let vc = LoginStoryboard.instantiateViewController(withIdentifier: "UpdateDriverIdentityDetailVC") as!  UpdateDriverIdentityDetailVC
                    vc.isFromLaunch = true
                    navigationController?.pushViewController(vc, animated: true)
                }else {
                    navigateToHome()
                    checkForNotificationNavigation()
                }
                
            }
        } else {
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeScreen") as! GPSSelectionVC
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    func checkForNotificationNavigation() {
        if IS_FROM_PUSH_NOTIFICATION {
            IS_FROM_PUSH_NOTIFICATION = false
            
            if PUSH_USER_INFO.count > 0 {
                //JOIN DRIVER WITH SOCKET
                let dict:NSMutableDictionary = NSMutableDictionary()
                dict.setValue(USER_OBJ?.userId, forKey: "user_id")
                APP_DELEGATE!.socketIOHandler?.joinSocketWithData(data: dict)
                
                guard let notification_type = Enum_NotificationType(rawValue: Int(PUSH_USER_INFO["notification_type"] as! String)!) else {
                    return
                }

                //let notification_type = Enum_NotificationType(rawValue: Int(PUSH_USER_INFO["notification_type"] as! String)!)
                let nav = APP_DELEGATE?.window?.rootViewController as! UINavigationController
                
                switch notification_type {
                case .chat:
                    let vc = HomeStoryboard.instantiateViewController(withIdentifier: "DriverChatVC") as! DriverChatVC
                    vc.receiver_id = Int(PUSH_USER_INFO["sender_id"] as! String)!
                    vc.receiver_name = ""
                    vc.receiver_profile = ""
                    vc.orderId = Int(PUSH_USER_INFO["order_id"] as! String)!
                    vc.orderStatus = PUSH_USER_INFO["order_status"] .asString()
                    vc.isFromNotification = true
                    nav.pushViewController(vc, animated: true)
                    break
                case .Driver_verification:
                    if USER_OBJ?.userId == Int(PUSH_USER_INFO["user_id"] as! String)! {
                        updateUserObjectForDriverVerification(is_verified: Int(PUSH_USER_INFO["is_driver_verified"] as! String)!)
                    }
                    break
                case .Order_Request:
               //      postNotification(withName: ncNOTIFICATION_ORDER_REQUEST_FROM_PUSH, userInfo: ["push_info" : PUSH_USER_INFO])
//                    let orderVC = HomeStoryboard.instantiateViewController(withIdentifier: "OrderRequestDetailVC") as! OrderRequestDetailVC
//                    orderVC.orderId = PUSH_USER_INFO["order_id"] as! Int
//                    orderVC.isFromNotification = true
                    
                    if isNetworkConnected {
                        switch APP_DELEGATE!.socketIOHandler?.socket?.status{
                            case .connected?:
                                if (APP_DELEGATE!.socketIOHandler!.isJoinSocket){
                                   // APP_DELEGATE!.socketIOHandler?.fetchOrderDetails(orderId: Int(PUSH_USER_INFO["order_id"] as! String)!, completion: { (objOrder) in
                                                                                
                                        var dic = [String:Any]()
                                        dic["order_id"] = Int(PUSH_USER_INFO["order_id"] as! String)!
                                        dic["customer_id"] = Int(PUSH_USER_INFO["customer_id"] as! String)!
                                        dic["order_drivers"] = PUSH_USER_INFO["order_drivers"] as! String
                                        dic["order_details"] = [String:Any]() //objOrder.toDict()
                                        
                                        APP_DELEGATE?.socketIOHandler?.joinOrderRoom(orderId: Int(PUSH_USER_INFO["order_id"] as! String)!)
                                        
                                        addOrderRequestToQueue(dic: dic)
                                        if getCurrentOrderRequest() == 0 {
                                            setCurrentOrderReequest(orderId: Int(PUSH_USER_INFO["order_id"] as! String)!)
                                            postNotification(withName: ncNOTIFICATION_ORDER_REQUEST_FROM_PUSH, userInfo: ["push_info" : PUSH_USER_INFO])
                                        }
                                        //nav.pushViewController(orderVC, animated: true)
                                        
                                        let orderVC = HomeStoryboard.instantiateViewController(withIdentifier: "OrderRequestDetailVC") as! OrderRequestDetailVC
                                        orderVC.orderId = Int(PUSH_USER_INFO["order_id"] as! String)!
                                        orderVC.isFromNotification = true
                                        nav.pushViewController(orderVC, animated: true)
                                  //  })
                                }
                                break
                            default:
                               print("Socket Not Connected")
                        }
                    } else {
                        //ShowToast(message: kCHECK_INTERNET_CONNECTION)
                    }
                    
                    
                    break
                case .order_delivered:
                    let orderVC = HomeStoryboard.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
                    orderVC.orderId = Int(PUSH_USER_INFO["order_id"] as! String)!
                    orderVC.isFromPast = true
                    nav.pushViewController(orderVC, animated: true)
                case .Rating:
                    let vc = HomeStoryboard.instantiateViewController(withIdentifier: "ReviewRatingListVC") as! ReviewRatingListVC
                    nav.pushViewController(vc, animated: true)
                break
                case .driverWeeklyPayment:
                    if let tabvc = nav.viewControllers[0] as? CustomTabbarVC {
                        APP_DELEGATE?.FromHomeEarning = true
                        tabvc.selectedIndex = tTAB_EARNING
                    }
                    postNotification(withName: ncNOTIFICATION_WEEKLY_PAYMENT, userInfo: PUSH_USER_INFO)
                     break
                case .manualStorePayment:
                   if let tabvc = nav.viewControllers[0] as? CustomTabbarVC {
                       APP_DELEGATE?.FromHomeEarning = false
                       tabvc.selectedIndex = tTAB_EARNING
                   }
                   postNotification(withName: ncNOTIFICATION_MANUAL_PAYMENT, userInfo: PUSH_USER_INFO)
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
}
