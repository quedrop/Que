//
//  BaseViewController.swift
//  QueDrop
//
//  Created by C100-104 on 18/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import CoreLocation
import Reachability
 

class BaseViewController: UIViewController , UIGestureRecognizerDelegate {
    
    var reachability : Reachability?
    var locationManager_Local = CLLocationManager()
    let geocoder_Local = CLGeocoder()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.tintColor = THEME_COLOR
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        do
        {
            reachability =  try Reachability()
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
        }
        checkRechabiliy()
    }
    
    
    //MARK:- Common Functions
    
    //Calculate Distance Between two location
    func distance(lat1:Double, lon1:Double , in_time : Bool ) -> String {
        let lat2 = Double(defaultAddress?.latitude ?? "0.0") ?? 0.0
        let lon2 = Double(defaultAddress?.longitude ?? "0.0") ?? 0.0
        let coordinate₀ = CLLocation(latitude: lat1, longitude: lon1)
        let coordinate₁ = CLLocation(latitude: lat2, longitude: lon2)
        
        let distanceInMeters = coordinate₀.distance(from: coordinate₁) // result is in meters
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
                //tmproutedist = "\(distanceInKM.rounded(toPlaces: 2)) KM"
                
                return "\(distanceInKM.rounded(toPlaces: 2)) km"
            }
            else
            {
                //tmproutedist = "\(distanceInMeters.rounded(toPlaces: 2)) MTR"
                return "\(distanceInMeters.rounded(toPlaces: 2)) meters"
            }
        }
        //return "\(distanceInKM)"
        
        
    }
    
    func isTabbarHidden(_ isHidden:Bool) {
        self.tabBarController?.tabBar.isHidden = isHidden
    }
    func UpdateTabBar(index : Int)
    {
        self.tabBarController?.selectedIndex = index
    }
    
    //MARK:- Encrypt Decrypt

    func encryptMessage(message: String, encryptionKey: String = ENC_KEY) throws -> String {
            let messageData = message.data(using: .utf8)!
            let cipherData = RNCryptor.encrypt(data: messageData, withPassword: encryptionKey)
            return cipherData.base64EncodedString()
        }
    
        func decryptMessage(encryptedMessage: String, encryptionKey: String) throws -> String {
    
            let encryptedData = Data.init(base64Encoded: encryptedMessage)!
            let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: encryptionKey)
            let decryptedString = String(data: decryptedData, encoding: .utf8)!
    
            return decryptedString
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
            let currentDate = Date()
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
    //MARK:- Check Network Reachability
    func checkRechabiliy()
    {
        
        reachability?.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
                isNetworkConnected =  true
            } else {
                print("Reachable via Cellular")
                isNetworkConnected =  true
            }
        }
        reachability?.whenUnreachable = { _ in
            print("Not reachable")
            isNetworkConnected = false
            /*let alert = UIAlertController(title: "Alert", message: "Please check your internet connection.", preferredStyle: .alert)
             NotificationCenter.default.addObserver(alert, selector: Selector(("hideAlertController")), name: NSNotification.Name(rawValue: "DismissAllAlertsNotification"), object: nil)
             self.present(alert, animated: true, completion:nil)*/
            self.showAlert(title: "Alert", message: kCHECK_INTERNET_CONNECTION)
            
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    

    func popTwoViewBack(_ withPresentAnimation : Bool = false) {
        if withPresentAnimation
        {
            let transition:CATransition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromBottom
            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
            
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: false)
        }
        else
        {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }
    }

    func getCurrenLocationDetails()
    {
        
        var currentLoc: CLLocation!
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways) {
            currentLoc = locationManager_Local.location
            if currentLoc == nil
            {
                currentLoc = locationManager_Local.location
                
            }
            //		   print("Location  latitude ::",currentLoc.coordinate.latitude)
            //		   print("Loaction longitude ::",currentLoc.coordinate.longitude)
        }
        if currentLoc == nil
        {
            print("Location Not Found")
            currentLoc = locationManager_Local.location
            if currentLoc == nil
            {
                print("Location Missing")
                return
            }
        }
        // currentLoc
        //getLocationDetails()
        
        geocoder_Local.cancelGeocode()
        geocoder_Local.reverseGeocodeLocation(currentLoc) { response, error in
            if let error = error as NSError?, error.code != 10 {
                // ignore cancelGeocode errors
                // show error and remove annotation
                let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true) {
                    //self.mapView.removeAnnotation(annotation)
                }
            } else if let placemark = response?.first {
                
                let name = placemark.name
                print("Location name ::",name ?? "")
                print("Location Placemark ::",placemark)
                defaultAddress?.address = "\(placemark.address())\(placemark.postalCode ?? "")"
                defaultAddress?.addressId = 0
                defaultAddress?.addressTitle = name
                defaultAddress?.addressType = ""
                defaultAddress?.latitude = currentLoc.coordinate.latitude.description
                defaultAddress?.longitude = currentLoc.coordinate.longitude.description
            }
        }
    }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}
// AlertController subclass with method to dismiss alert controller
class AlertController: UIAlertController {
    func hideAlertController() {
        self.dismiss(animated: true, completion: nil)
    }
}
