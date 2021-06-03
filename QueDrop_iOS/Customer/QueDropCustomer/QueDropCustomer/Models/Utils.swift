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
		return APP_DELEGATE
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
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 4
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
    
    //MARK: - LOGOUT AND CLEAN UP
    func doLogOut() {
        /*let userDefaults = UserDefaults.standard
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if(key == sFCM_TOKEN || key == sIS_ONBOARD_SEEN || key == cMEAL_MASTER_DATE || key == cIS_BASKET_TOOLTIP_SHOWN || key == cIS_CART_TOOLTIP_SHOWN || key == cIS_PICKPOPUP_SEEN){}
            else {
                userDefaults.removeObject(forKey: key)
            }
        }
        userDefaults.synchronize()
        
        APPDELEGATE!.arrSelectedRecipeForBasket = [[String : Any]]() //FOR STORING SELECTED RECIPE FOR INGREDIENT LIST IN CART TAB
        APPDELEGATE!.mealPlanGroupForBasket = String() //FOR MANAGING ABOVE ONE
        APPDELEGATE!.isForSameRecipes = Bool()
        
        APPDELEGATE?.tabScoff = CustomTabbar()
        
        let view = SelectMethodVC.init(nibName: "SelectMethodVC", bundle: nil)
        APPDELEGATE?.navigationVC = UINavigationController.init(rootViewController: view)
        APPDELEGATE?.navigationVC.navigationBar.isHidden = true
        APPDELEGATE?.window?.rootViewController = APPDELEGATE?.navigationVC
        APPDELEGATE?.window?.makeKeyAndVisible()*/
        
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
    func tintedWithLinearGradientColors(colorsArr: [CGColor], img : UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        context.translateBy(x: 0, y: img.size.height)
        context.scaleBy(x: 1, y: -1)
        
        context.setBlendMode(.normal)
        let rect = CGRect.init(x: 0, y: 0, width: img.size.width, height: img.size.height)
        
        // Create gradient
        let colors = colorsArr as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [1.0, 0.0])
        
        // Apply gradient
        context.clip(to: rect, mask: img.cgImage!)
        context.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: img.size.height), options: .drawsAfterEndLocation)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return gradientImage!
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
        return (screenWidth * size)/SCREEN_WIDTH_FOR_ORIGINAL_FONT
    }
    
    func calculateFontForHeight(size : CGFloat) -> CGFloat {
        return (screenHeight * size)/SCREEN_HEIGHT_FOR_ORIGINAL_FONT
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
    var code = strCode
    if code == "0"
    {
        code = "1"
    }
    let arr = getAllCountriesDialCode()
    let result = arr.filter { $0["dial_code"] as! String == "+"+code}[0]
    return result
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
    
func setupFloatingTextField(textField : JVFloatLabeledTextField) {
    textField.textColor = .darkGray
    textField.floatingLabelTextColor = THEME_COLOR
    textField.floatingLabelActiveTextColor = THEME_COLOR
    textField.floatingLabelFont = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 14.0))
}

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

