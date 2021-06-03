//
//  BaseViewController.swift
//  QueDeliveryCustomer
//
//  Created by C100-104 on 18/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import CoreLocation
import Reachability

class BaseViewController: UIViewController , UIGestureRecognizerDelegate {
    //MARK:- CONSTANTS
    
    //MARK:- VARIABLES
    let reachability = try! Reachability()
    var isViewLoadFirstTime = true
    var listMessage = "Loading"
    var pullToRefreshDelegate: PullToRefreshDelegate?
    var refreshControl = UIRefreshControl()
    
    //MARK:- VC LIFE CYCLE METHOD
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        checkRechabiliy()
    }
    
    //MARK: - Swipe gesture handle
    func setupPullRefresh(tblView: UITableView, delegate: PullToRefreshDelegate, isHideLoader: Bool = false) {
        pullToRefreshDelegate = delegate
        tblView.isUserInteractionEnabled = true
        refreshControl.addTarget(self, action: #selector(self.pullToRefreshHandler), for: .valueChanged)
        
        if isHideLoader {
            refreshControl.tintColor = .clear
            refreshControl.backgroundColor = .clear
            //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        }
        
        tblView.refreshControl = refreshControl
    }
    
    func setupPullRefresh(collView: UICollectionView, delegate: PullToRefreshDelegate, isHideLoader: Bool = false) {
        pullToRefreshDelegate = delegate
        collView.isUserInteractionEnabled = true
        refreshControl.addTarget(self, action: #selector(self.pullToRefreshHandler), for: .valueChanged)
        
        if isHideLoader {
            refreshControl.tintColor = .clear
            refreshControl.backgroundColor = .clear
        }
        
        collView.refreshControl = refreshControl
    }
    
    @objc private func pullToRefreshHandler() {
        refreshControl.endRefreshing()
        pullToRefreshDelegate?.pullrefreshCallback()
    }
    //MARK: - CALCULATE DISTANCE BETWEEN TWO LOCATION
    func distance(lat1:Double, lon1:Double , in_time : Bool ) -> String {
        /*let lat2 = Double(defaultAddress?.latitude ?? "0.0") ?? 0.0
        let lon2 = Double(defaultAddress?.longitude ?? "0.0") ?? 0.0
        let coordinate₀ = CLLocation(latitude: lat1, longitude: lon1)
        let coordinate₁ = CLLocation(latitude: lat2, longitude: lon2)

        let distanceInMeters = coordinate₀.distance(from: coordinate₁)
        if in_time
        {
            let time = distanceInMeters / 400
            if time > 50 && time < 60
            {
                print("around 1 hour(\(time.rounded(toPlaces: 0))minits)")
                return "around 1 hour(\(time.rounded(toPlaces: 0))minits)"
            }
            else if time >= 60
            {
                print("Hours : ",(Double(time/60).rounded(toPlaces: 1).rounded(toPlaces: 0)))
                return "\(Int(Double(time/60).rounded(toPlaces: 1).rounded(toPlaces: 0))) Hrs"
            }
            else
            {
                print("Minit : ",time.rounded(toPlaces: 0))
                return "\(Int(time.rounded(toPlaces: 0))) min"
            }
        }
        else
        {
            let distanceInKM = distanceInMeters / 1000
            if distanceInMeters >= 1000
            {
                return "\(distanceInKM.rounded(toPlaces: 2)) km"
            }
            else
            {
                return "\(distanceInMeters.rounded(toPlaces: 2)) meters"
            }
        }
        */
        return ""
    }
    
    func isTabbarHidden(_ isHidden:Bool) {
        self.tabBarController?.tabBar.isHidden = isHidden
    }
    //MARK:-Navigation FUNCS
    func navigateToMobileVerification() {
           let vc = LoginStoryboard.instantiateViewController(withIdentifier: "MobileVerificationVC") as! MobileVerificationVC
           self.navigationController?.pushViewController(vc, animated: true)
       }
    func navigateToHome() {
        let navVc = HomeStoryboard.instantiateViewController(withIdentifier: "CustomerTabBarNavigation") as! UINavigationController
                    navVc.navigationBar.isHidden = true
        APP_DELEGATE!.window?.rootViewController = navVc
    }
    func navigateToDriverIdentityDetail() {
        let vc = LoginStoryboard.instantiateViewController(withIdentifier: "UpdateDriverIdentityDetailVC") as!  UpdateDriverIdentityDetailVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Date Function
     public func randomString(length: Int) -> String {
            
            let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let len = UInt32(letters.length)
            var randomString = ""
            for _ in 0 ..< length {
                let rand = arc4random_uniform(len)
                var nextChar = letters.character(at: Int(rand))
                randomString += NSString(characters: &nextChar, length: 1) as String
            }
            return randomString
        }
        
        func toString(format: String) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
             dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            let currentDate = Date()
             dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            return dateFormatter.string(from: currentDate)
        }
        
        func localToUTC(format:String) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            let dt = dateFormatter.date(from: self.toString(format: format))
            dateFormatter.dateFormat = format
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            
            return dateFormatter.string(from: dt!)
        }
        
        func UTCToLocal(format:String) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            
            let dt = dateFormatter.date(from: self.toString(format: format))
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = format
            
            return dateFormatter.string(from: dt!)
        }
        
        public func timeAgoSinceDate(date:Date, numericDates:Bool) -> String {
    //        return date.toString(format:"hh:mm a MMM dd")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            dateFormatter.timeZone = NSTimeZone.local
            let currentDate = date
            return dateFormatter.string(from: currentDate)
            
        }
    
    func daysBetweenDates(startDate: Date , endDate: Date) -> Int {
           let calendar = Calendar.current
           
           let components = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
           
           return components.day!
       }
    
    func getChatDateFromServer(strDate:String) -> String
       {
           let dateStr          = strDate
           let formatter        = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
           let currDate : Date = formatter.date(from: dateStr)! as Date
           
           let todayDt = NSDate()
           let todaystr = formatter.string(from: todayDt as Date)
           let todaydate : Date = formatter.date(from: todaystr)! as Date
           
           
           if (todaydate >= currDate)
           {
               let startDate:NSDate = todaydate as NSDate
               let endDate:Date = currDate as Date
               
               let int_days = daysBetweenDates(startDate: startDate as Date,endDate: endDate)
               
               if int_days == -1
               {
                  return "Yesterday"
               }
               else if int_days == 0
               {
                  return ""
               }
               else if int_days < -1
               {
                  formatter.dateFormat = "dd MMM"
                  let todaystr1 = formatter.string(from: todayDt as Date)
                  return todaystr1
               }
               else
               {
                   return ""
               }
               
               
           }
           else
           {
               return ""
           }
       }
    
    //MARK:- CHECK NETWORK REACHABILITY
    func checkRechabiliy() {
           reachability.whenReachable = { reachability in
               if reachability.connection == .wifi {
                   print("Reachable via WiFi")
                   isNetworkConnected =  true
               } else {
                   print("Reachable via Cellular")
                   isNetworkConnected =  true
               }
               APP_DELEGATE?.socketIOHandler?.foreground()
           }
           reachability.whenUnreachable = { _ in
               print("Not reachable")
               //self.showAlert(title: "Alert", message: "Please check your internet connection.")
               ShowToast(message: "Please check your internet connection.")
               isNetworkConnected = false
           }
           
           do {
               try reachability.startNotifier()
           } catch {
               print("Unable to start notifier")
           }
    }
}
