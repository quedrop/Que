//
//  Utils.swift
//  SwiftProjectStructure
//
//  Created by EbitM02 on 19/06/18.
//  Copyright © 2018 Krishna. All rights reserved.
//

import UIKit
import CoreTelephony
import SwiftyJSON
import CoreLocation
import JVFloatLabeledTextField

    // MARK: - KPToast
    func ShowToast(message : String) {
        KPToast.backgroundStyle(.dark)
        KPToast.messageTextColor(UIColor.white)
        let myFont = UIFont(name: fFONT_REGULAR, size: 16)
        KPToast.messageFont(myFont!)
        KPToast.show(withMessage: message)
    }
    
    // MARK: - Common
    /*func connected() -> Bool {
        let reachability = Reachability.forInternetConnection()
        let status : NetworkStatus = reachability!.currentReachabilityStatus()
        if status == .NotReachable{
            return false
        }else{
            return true
        }
    }*/
    
    func makeCircular(view : UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
        view.layer.masksToBounds = true
    }
    
    func getAppDelegate() -> Any? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    func drawBorder(view: UIView?, color borderColor: UIColor?, width: Float, radius: Float) {
        view?.layer.borderColor = borderColor?.cgColor
        view?.layer.borderWidth = CGFloat(width)
        view?.layer.cornerRadius = CGFloat(radius)
        view?.layer.masksToBounds = true
    }
    
    func drawBorder1(view: UIView?, color borderColor: UIColor?, width: Float, radius: Float) {
        view?.layer.borderColor = borderColor?.cgColor
        view?.layer.borderWidth = CGFloat(width)
        view?.layer.cornerRadius = CGFloat(radius)
        // view?.layer.masksToBounds = true
    }
    
    func drawShadow(view : UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.5
    }
    
    func roundingCorners(_ view: UIView?, byRoundingCorners Corners: UIRectCorner, size Points: CGSize) {
        let maskPath = UIBezierPath(roundedRect: view?.bounds ?? CGRect.zero, byRoundingCorners: Corners, cornerRadii: Points)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view?.bounds ?? CGRect.zero
        maskLayer.path = maskPath.cgPath
        view?.layer.mask = maskLayer
        view?.layer.masksToBounds = true
    }

    //MARK: - SESSION RELATED
    func setIsUserLoggedIn(is_login: Bool){
        UserDefaults.standard.set(is_login, forKey: kIsUserLoggedIn)
    }
    func getIsUserLoggedIn() -> Bool {
        if((UserDefaults.standard.dictionaryRepresentation()).keys.contains(kIsUserLoggedIn)){
            return UserDefaults.standard.value(forKey: kIsUserLoggedIn) as! Bool
        } else{
            return false
        }
    }
    
    func setUserDetailObject(userDetail : User){
        UserDefaults.standard.setCustom(userDetail, forKey: kUserDetails)
    }
    func getUserDetailObject() -> User {
        if((UserDefaults.standard.dictionaryRepresentation()).keys.contains(kUserDetails)){
            return UserDefaults.standard.getCustom(forKey: kUserDetails) as! User
        } else{
            return User(object: NSDictionary())
        }
        
    }
    
    func setUserId(userId : Int) {
        UserDefaults.standard.set(userId, forKey: kUserId)
    }
    func getUserId() -> Int {
        return UserDefaults.standard.value(forKey: kUserId) as! Int
    }
    
    func setIsRememberMe(is_remember: Bool){
       UserDefaults.standard.set(is_remember, forKey: kIsRememberMeSelected)
    }
    func getIsRememberMe() -> Bool {
       if((UserDefaults.standard.dictionaryRepresentation()).keys.contains(kIsRememberMeSelected)){
           return UserDefaults.standard.value(forKey: kIsRememberMeSelected) as! Bool
       } else{
           return false
       }
    }

    func setEmail(strEmail : String) {
        UserDefaults.standard.set(strEmail, forKey: kEmailId)
    }
    func getEmail() -> String {
        return UserDefaults.standard.value(forKey: kEmailId) as! String
    }
    
    func setFCMToken(strToken : String) {
        UserDefaults.standard.set(strToken, forKey: kFcmToken)
    }
    func getFCMToken() -> String {
        if((UserDefaults.standard.dictionaryRepresentation()).keys.contains(kFcmToken)){
            return UserDefaults.standard.value(forKey: kFcmToken) as! String
        }else {
            return ""
        }
    }

    func setPassword(strPassword : String) {
        UserDefaults.standard.set(strPassword, forKey: kPassword)
    }
    func getPassword() -> String {
        return UserDefaults.standard.value(forKey: kPassword) as! String
    }

    func setUserType() {
        UserDefaults.standard.set(USERTYPE, forKey: kUserType)
    }
    func getUserType() -> String {
        return UserDefaults.standard.value(forKey: kUserType) as! String
    }
    
    func setCurrentOrderReequest(orderId : Int) {
        UserDefaults.standard.set(orderId, forKey: kCurrentOrderRequestId)
    }
    func getCurrentOrderRequest() -> Int {
        if((UserDefaults.standard.dictionaryRepresentation()).keys.contains(kCurrentOrderRequestId)){
            return UserDefaults.standard.value(forKey: kCurrentOrderRequestId) as! Int
        }else {
            return 0
        }
    }
    func removeCurrentOrderRequest(orderId : Int){
        UserDefaults.standard.removeObject(forKey: kCurrentOrderRequestId)
    }

    func addOrderRequestToQueue(dic : [String:Any]) {
        var arr = getOrderRequestQueue()
        if arr.contains(where: {$0["order_id"] as! Int == dic["order_id"] as! Int}) {}
        else {
            arr.append(dic)
        }
        UserDefaults.standard.set(arr, forKey: kOrderRequestQueue)
    }
    func getOrderRequestQueue() -> [[String:Any]] {
        if((UserDefaults.standard.dictionaryRepresentation()).keys.contains(kOrderRequestQueue)){
            return UserDefaults.standard.value(forKey: kOrderRequestQueue) as! [[String:Any]]
        }
        return [[String:Any]]()
    }
    func removeOrderFromRequestQueue(orderId : Int) {
        var arr = getOrderRequestQueue()
        if arr.count > 0 {
            arr = arr.filter {$0["order_id"] as! Int != orderId}
            UserDefaults.standard.set(arr, forKey: kOrderRequestQueue)
        }
    }
    func removeAllOrderFromRequestQueue() {
        UserDefaults.standard.removeObject(forKey: kOrderRequestQueue)
    }
    func getSingleOrderRequestQueue(orderId : Int) -> [String:Any]{
        let arr = getOrderRequestQueue()
        if arr.count > 0 {
            let d = arr.filter{$0["order_id"] as! Int == orderId}[0]
            return d
        }
        return [String : Any]()
    }
    //MARK: - LOGOUT AND CLEAN UP
    func doLogOut() {
        let userDefaults = UserDefaults.standard
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if(key == FCM_TOKEN || key == kIsRememberMeSelected || key == kEmailId || key == kPassword || key == kFcmToken){}
            else {
                userDefaults.removeObject(forKey: key)
            }
        }
        userDefaults.synchronize()
        let vc = LoginStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        APP_DELEGATE?.window?.rootViewController = nav
        
    }
    
    //MARK: - SET IMAGE TINT COLOR
    func setImageViewTintColor(img : UIImageView, color: UIColor) -> UIImage {
        img.image =  img.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        img.tintColor = color
        return (img.image ?? nil)!
    }
    
    func setImageTintColor(image: UIImage?, color: UIColor?) -> UIImage? {
        if (image?.size.height ?? 0.0) > 0 && (image?.size.width ?? 0.0) > 0 {
            var newImage: UIImage? = image?.withRenderingMode(.alwaysTemplate)
            UIGraphicsBeginImageContextWithOptions(image?.size ?? CGSize.zero, _: false, _: newImage?.scale ?? 0.0)
            color?.set()
            newImage?.draw(in: CGRect(x: 0, y: 0, width: image?.size.width ?? 0.0, height: newImage?.size.height ?? 0.0))
            newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        } else {
            return image
        }
    }

    //MARK: - CHANGE PLACEHOLDER COLOR
    func changePlaceholderColor(_ txtField: UITextField?, placecolor color: UIColor?) {
        let strplaceholderText = txtField?.placeholder
        var str: NSAttributedString? = nil
        if let color = color {
            str = NSAttributedString(string: strplaceholderText ?? "", attributes: [
                NSAttributedString.Key.foregroundColor: color
                ])
        }
        txtField?.attributedPlaceholder = str
    }
    
    //MARK: - DESIGNING FUNCTIONS
    func calculateFontForWidth(size : CGFloat) -> CGFloat {
        return (SCREEN_WIDTH * size)/SCREEN_WIDTH_FOR_ORIGINAL_FONT
    }
    
    func calculateFontForHeight(size : CGFloat) -> CGFloat {
        return (SCREEN_HEIGHT * size)/SCREEN_HEIGHT_FOR_ORIGINAL_FONT
    }
    
    func scaleFont(byWidth control: UIView?) {
        if (control is UILabel) {
            (control as? UILabel)?.adjustsFontSizeToFitWidth = true
            (control as? UILabel)?.minimumScaleFactor = 0.5
            (control as? UILabel)?.baselineAdjustment = .alignCenters
            (control as? UILabel)?.lineBreakMode = .byClipping
        } else if (control is UIButton) {
            (control as? UIButton)?.titleLabel?.adjustsFontSizeToFitWidth = true
            (control as? UIButton)?.titleLabel?.minimumScaleFactor = 0.5
            (control as? UIButton)?.titleLabel?.baselineAdjustment = .alignCenters
            (control as? UIButton)?.titleLabel?.lineBreakMode = .byClipping
        } else if (control is UITextField) {
            (control as? UITextField)?.adjustsFontSizeToFitWidth = true
            (control as? UITextField)?.minimumFontSize = 0.5
        }
    }
    
    
    //MARK: - REMOVE WHITE SPACE CHARACTERS FROM STRING
    func removeWhiteSpaceCharacter(fromText str : String) -> String {
        var str = str
        str = str.trimmingCharacters(in: CharacterSet.whitespaces)
        str = str.trimmingCharacters(in: CharacterSet.newlines)
        str = str.trimmingCharacters(in: CharacterSet.whitespaces)
        return str
    }
    
    //MARK: - EMAIL PASSWORK VALIDATION
    func validateEmail(email str : String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+]+@[A-Za-z0-9.]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: str)
    }
    
    func validatePassword(pwd str : String) -> Bool {
        let pwdRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[A-Za-z\\d@$!%*?&]{7,}$" //"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[0-9])[A-Za-z\\d0-9]{7,}"
        let pwdTest = NSPredicate(format: "SELF MATCHES %@", pwdRegex)
        return pwdTest.evaluate(with: str)
    }
    
    //MARK: - ANIMATION
    func doScaleAnimation(sender : UIView, scale : CGFloat, duration : CGFloat, completion:@escaping (Bool) -> ()){
        UIView.animate(withDuration: TimeInterval(duration), animations: {
            sender.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: { _ in
            UIView.animate(withDuration: TimeInterval(duration), animations: {
                sender.transform = CGAffineTransform.identity
            }, completion: { _ in
                 completion(true)
            })
        })
    }
    
    //MARK: SHOW ALERT CONTROLLER WITH HANDLER
    func showAlertController(title : String, message : String, completion:@escaping (Bool) -> ()){
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .destructive, handler: { (action) in
            completion(true)
        }))
        let nav = APP_DELEGATE?.window?.rootViewController as! UINavigationController
        nav.present(alert, animated: true, completion: nil)
        //APPDELEGATE?.navigationVC.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - GET CURRENT COUNTRY CODE
    func checkForCellularAvailability () -> Bool{
        var addrs: UnsafeMutablePointer<ifaddrs>?
        var cursor: UnsafeMutablePointer<ifaddrs>?
        
        defer { freeifaddrs(addrs) }
        
        guard getifaddrs(&addrs) == 0 else { return false }
        cursor = addrs
        
        while cursor != nil {
            guard
                let utf8String = cursor?.pointee.ifa_name,
                let name = NSString(utf8String: utf8String),
                name == "pdp_ip0"
                else {
                    cursor = cursor?.pointee.ifa_next
                    continue
            }
            return true
        }
        return false
    }

    func getCountryCode() -> String {
        var strCountryCode = ""
        if(checkForCellularAvailability()){
            let networkInfo: CTTelephonyNetworkInfo = CTTelephonyNetworkInfo()
            let ar = networkInfo.subscriberCellularProvider
            if ar != nil {
                if  let mcc = ar!.isoCountryCode {
                    //print("\(mcc)")
                    return mcc
                }
            }
        }else{
            let currentLocale = NSLocale.current as NSLocale
            strCountryCode = currentLocale.object(forKey: .countryCode) as! String
            return strCountryCode
        }
        return "US"
    }
    
    func getCountryDialCode(strCode : String) -> [String : Any] {
        let arr = getAllCountriesDialCode()
        let result = arr.filter { $0["code"] as! String == strCode.uppercased()}[0]
        return result
    }
    
    func getAllCountriesDialCode() -> [[String : Any]]{
        if let url = Bundle.main.url(forResource: "countries", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let arr = json as! [[String : Any]]
                return arr
            } catch {
                print("Error!! Unable to parse")
            }
        }
        return [[String : Any]]()
    }
    func getCountry(fromDialingCode strCode: String) -> [String : Any] {
        let arr = getAllCountriesDialCode()
        let result = arr.filter { $0["dial_code"] as! String == "+"+strCode}[0]
        return result
    }

//MARK:- SEND NOTIFICATION CENTER NOTIFICATION
func postNotification(withName notificationName: String, userInfo : [AnyHashable : Any]) {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationName), object: nil, userInfo: userInfo)
}

//MARK: - GENERATE LOCAL NOTIFICATION
func generateLocalNotification(title : String, body: String, identifier : String) {
    // 1
    let content = UNMutableNotificationContent()
    content.title = title
    //content.subtitle = "from ioscreator.com"
    content.body = body
    content.sound = .default
//    // 2
//    let imageName = "applelogo"
//    guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
//
//    let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
//
//    content.attachments = [attachment]
    
    // 3
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    // 4
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}
func generateChatLocalNotification(title : String, body: String, userInfo : [String:Any],identifier : String) {
    // 1
    let content = UNMutableNotificationContent()
    content.title = title
    //content.subtitle = "from ioscreator.com"
    content.body = body
    content.userInfo = userInfo
    content.sound = .default
//    // 2
//    let imageName = "applelogo"
//    guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
//
//    let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
//
//    content.attachments = [attachment]
    
    // 3
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    // 4
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}


//MARK:- UPDAT EUSER OBJECT
func updateUserObjectForDriverVerification(is_verified : Int) {
    USER_OBJ?.isDriverVerified = is_verified
    UserDefaults.standard.removeCustomObject(forKey: kUserDetails)
    setUserDetailObject(userDetail: USER_OBJ!)
}
func updateUserObjectForDriverIdentity(is_uploaded : Int) {
    USER_OBJ?.isIdentityDetailUploaded = is_uploaded
    UserDefaults.standard.removeCustomObject(forKey: kUserDetails)
    setUserDetailObject(userDetail: USER_OBJ!)
}


//MARK:- ADD DASHED BOARDER
func addDashedBorder(withColor : UIColor, view : UIView) {
    let shapeLayer:CAShapeLayer = CAShapeLayer()
    let frameSize = view.frame.size
    let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)

    shapeLayer.bounds = shapeRect
    shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = withColor.cgColor
    shapeLayer.lineWidth = 0.8
    shapeLayer.lineJoin = CAShapeLayerLineJoin.round
    shapeLayer.lineDashPattern = [2,2]
    shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
    
    view.layer.addSublayer(shapeLayer)
}
		
func addDashedCircle(withColor : UIColor, view : UIView) {
    let circleLayer = CAShapeLayer()
    circleLayer.path = UIBezierPath(ovalIn: view.bounds).cgPath
    circleLayer.lineWidth = 0.5
    circleLayer.strokeColor =  withColor.cgColor//border of circle
    circleLayer.fillColor = UIColor.clear.cgColor//inside the circle
    circleLayer.lineJoin = .round
    circleLayer.lineDashPattern = [2,2]
    view.layer.addSublayer(circleLayer)
}

//MARK:- CONVERT SERVER DATE TO LOCAL
func serverToLocal(date:String) -> Date? {
   
    let dateFormatter = DateFormatter()
    //let tempLocale = dateFormatter.locale // save locale temporarily
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    let date1 = dateFormatter.date(from: date)!
    /*dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.locale = tempLocale // reset the locale
    let dateString = dateFormatter.string(from: date1)
    
    print("EXACT_DATE : \(dateString)")*/
    
    
    /*let dateStr = date
       let df = DateFormatter()
       df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
       
       var dt = df.date(from:dateStr)!
       dt = dt.UTCtoLocal().toDate()!
    
    return dt8*/
 return date1
}

func getSecondsBetweenDates(date1 : Date, date2 : Date) -> TimeInterval{
   // let seconds = date1.timeIntervalSince(date2)
   // return kDRIVER_REQUEST_TIME - seconds
    
    
    let difference = Calendar.current.dateComponents([.second], from: date2, to: date1)
    let seconds = difference.second ?? 0
    print(seconds)
    return kDRIVER_REQUEST_TIME - Double(seconds)
}

//MARK:- CALCULATE DSITANCE BETWEEN TWO POINTS
func getDistance(lat1:Double, lon1:Double, lat2:Double, lon2:Double) -> String {
    
    let coordinate₀ = CLLocation(latitude: lat1, longitude: lon1)
    let coordinate₁ = CLLocation(latitude: lat2, longitude: lon2)
    
    let distanceInMeters = coordinate₀.distance(from: coordinate₁)
    
    
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

//MARK:- CALCULATE DSITANCE BETWEEN TWO POINTS
func getAppoxTime(lat1:Double, lon1:Double, lat2:Double, lon2:Double) -> String {
    
    let coordinate₀ = CLLocation(latitude: lat1, longitude: lon1)
    let coordinate₁ = CLLocation(latitude: lat2, longitude: lon2)
    let distanceInMeters = coordinate₀.distance(from: coordinate₁)

    let time = distanceInMeters / 400
    
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .short

    let formattedString = formatter.string(from: TimeInterval(time * 60))!
    print(formattedString)
    
    return formattedString
    /*formatter.unitsStyle = .full
    print(formatter.string(from: TimeInterval(time * 60))!)
    
    formatter.unitsStyle = .abbreviated
    print(formatter.string(from: TimeInterval(time * 60))!)
    
    formatter.unitsStyle = .spellOut
    print(formatter.string(from: TimeInterval(time * 60))!)
    
    formatter.unitsStyle = .positional
    print(formatter.string(from: TimeInterval(time * 60))!)
    
    if time > 50 && time < 60 {
        print("around 1 hour(\(time.rounded(toPlaces: 0))minutes)")
        return "around 1 hrs (\(time.rounded(toPlaces: 0)) mins)"
    }
    else if time >= 60 {
        print("Hours : ",(Double(time/60).rounded(toPlaces: 1).rounded(toPlaces: 0)))
        return "\(Int(Double(time/60).rounded(toPlaces: 1).rounded(toPlaces: 0))) Hrs"
    }
    else {
        print("Minit : ",time.rounded(toPlaces: 0))
        return "\(Int(time.rounded(toPlaces: 0))) mins"
    }*/
    
    
}

func isValidUrl(url: String) -> Bool {
    let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
    let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
    let result = urlTest.evaluate(with: url)
    return result
}

func getWeekDates(from date : Date) -> [Date]
{
    let day = DateFormatter(format: "EEE").string(from: date)
    print("Day : ",day )
    var newDate = date
    switch day {
    case weekDay.mo.rawValue:
        newDate = Calendar.current.date(byAdding: .day, value: -5, to: date)!
        break
    case weekDay.tu.rawValue:
        newDate = Calendar.current.date(byAdding: .day, value: -6, to: date)!
        break
    case weekDay.we.rawValue:
        newDate = Calendar.current.date(byAdding: .day, value: 0, to: date)!
        break
    case weekDay.th.rawValue:
        newDate = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        break
    case weekDay.fr.rawValue:
        newDate = Calendar.current.date(byAdding: .day, value: -2, to: date)!
        break
    case weekDay.sa.rawValue:
        newDate = Calendar.current.date(byAdding: .day, value: -3, to: date)!
        break
    case weekDay.su.rawValue:
        newDate = Calendar.current.date(byAdding: .day, value: -4, to: date)!
        break
    default:
        break
    }
    //selectWeek(From: newDate)
    var weekDates : [Date] = []
    for index in 0...6
    {
       weekDates.append(Calendar.current.date(byAdding: .day, value: index, to: newDate)!)
    }
    return weekDates
}


extension UIView {
    func addShadow(location: ShadowLoction, color: UIColor = .gray
        , opacity: Float = 0.1, radius: CGFloat = 3.0) {
        switch location {
        case .bottom:
             addShadow(offset: CGSize(width: 0, height: 6), color: color, opacity: opacity, radius: radius)
        case .top:
            addShadow(offset: CGSize(width: 0, height: -6), color: color, opacity: opacity, radius: radius)
        }
    }
    func addShadow(offset: CGSize, color: UIColor = .gray, opacity: Float = 0.1, radius: CGFloat = 3.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    func addShadow(shadowColor: UIColor, offSet: CGSize, opacity: Float, shadowRadius: CGFloat, cornerRadius: CGFloat, corners: UIRectCorner, fillColor: UIColor = .white) {
           
           let shadowLayer = CAShapeLayer()
           let size = CGSize(width: cornerRadius, height: cornerRadius)
           let cgPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size).cgPath //1
           shadowLayer.path = cgPath //2
           shadowLayer.fillColor = fillColor.cgColor //3
           shadowLayer.shadowColor = shadowColor.cgColor //4
           shadowLayer.shadowPath = cgPath
           shadowLayer.shadowOffset = offSet //5
           shadowLayer.shadowOpacity = opacity
           shadowLayer.shadowRadius = shadowRadius
           self.layer.addSublayer(shadowLayer)
       }
}

func setupFloatingTextField(textField : JVFloatLabeledTextField) {
    textField.textColor = .darkGray
    textField.floatingLabelTextColor = THEME_COLOR
    textField.floatingLabelActiveTextColor = THEME_COLOR
    textField.floatingLabelFont = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 14.0))
}
