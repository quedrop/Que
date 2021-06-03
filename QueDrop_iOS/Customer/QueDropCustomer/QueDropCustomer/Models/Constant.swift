//
//  Constant.swift
//  QueDrop
//
//  Created by C100-104 on 27/12/19.
//  Copyright © 2019 C100-104. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

var kUserDetailsUdf: String {
    return "UserDetail" + "_" + UserType.rawValue
}

var kUserTypeUdf: String {
    return "LastLoginUserType"
}

enum UserRoleType: String {
    case none
    case Customer
    case Supplier
}

enum weekDay : String{
   case mo = "Mon"
   case tu = "Tue"
   case we = "Wed"
   case th = "Thu"
   case fr = "Fri"
   case sa = "Sat"
   case su = "Sun"
}

var isGuest : Bool {
    get {
        if let user = USER_OBJ, let isGuestUser = user.isGuest {
            return isGuestUser == 1
        }
        return true
    }
}

var UserType: UserRoleType {
    get {
        if let udf = UserDefaults.standard.string(forKey: kUserTypeUdf),
            let type = UserRoleType(rawValue: udf) {
            return type
        }
        return .none
    }
}

var USER_ID: Int {
    get {
        if let user = USER_OBJ {
            if isGuest {
                return user.guestUserId.asInt()
            } else {
                return user.userId.asInt()
            }
        }
        return 0
    }
}

var USER_OBJ: User? {
    get {
        let user = UserDefaults.standard.getCustom(forKey: kUserDetailsUdf) as? User
        return user
    }
}

func saveUserTypeUserDefaults(type: UserRoleType) {
     
    
    if let isPhoneVerified = USER_OBJ?.isPhoneVerified, type == .Supplier, (isPhoneVerified == 0) {
        UserDefaults.standard.removeCustomObject(forKey: kUserDetailsUdf)
    }
    UserDefaults.standard.set(type.rawValue, forKey: kUserTypeUdf)
}

func saveUserInUserDefaults(user: User) {
    UserDefaults.standard.setCustom(user, forKey: kUserDetailsUdf)
    if !isGuest {
        APP_DELEGATE.socketIOHandler?.connectWithSocket()
    }
}

enum ENUM_DeliveryOption : String {
    case Standard = "Standard"
    case Express = "Express"
}

enum SignUpFields : Int{
	case name = 0
	case email
	case password
	case confirmPassword
	case referralCode
	case termAndConditions
}

enum tabBarIndex : Int {
	case home = 0
	//case notification
	case order
	//case favourite
    case exploreSearch
	case profile
}
enum navigationType {
    case login
    case register
    case TypeSelection
    case switchAccount
}
enum NotificationType
{
	case orderStatusUpdate 
	case orderAccepted
	case orderRejected
	case driverLocationUpdated
    case Test
}

enum ShadowLoction: String {
    case bottom
    case top
}
var DefaultColor = UIColor(red: 6/255, green: 77/255, blue: 89/255, alpha: 1.0)
//let APP_DELEGATE = UIApplication.shared.connectedScenes as! SceneDelegate

// App Delegate Obj
let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate

//MARK:- Delegate Obj
//var delegate : NavigationDrawerDelegate!
var isNetworkConnected = true
var clickDetact : String = ""
var ACCESS_KEY = "nousername"
var SECRET_KEY = "Is1YE9nQYMbOFzjtV77K/3MdKMqwt8NQVGc+aRyoeRU="
var DEVICE_TOKEN = "123456"
var FCM_TOKEN = ""
var TIME_ZONE = ""
let DEVICE_TYPE = 2
let IS_TEST_DATA = "1"
var plcedOrderDetails : [Order] = []
var BADGE_COUNT = 0
//Encryption Key
let ENC_KEY = ")H@McQfTjWnZr4u7x!A%C*F-JaNdRgUk" // length == 32
let ENC_IV = "MbQeThWmZq4t7w!z" // length == 16
var LOCATION_AVAILABLE : Bool{
    get{
        switch CLLocationManager.authorizationStatus() {
           case .notDetermined,.denied, .restricted:
              return false
           case .authorizedAlways, .authorizedWhenInUse:
            return true
        @unknown default:
            return false
        }
    }
}

//USER

var COUNTRY_CODE = NSLocale.current.regionCode ?? ""
var CURRENCY_CODE = NSLocale.current.currencyCode ?? ""
enum Currency_Type : String
{
	case Rupees = "₹"
	case Doller = "$"
	case Euro = "€"
}
var Currency = Currency_Type.Doller.rawValue

var Addresses : [Address] = []
var defaultAddress : Address? {
	didSet{
		if defaultAddress != nil
		{
			UserDefaults.standard.setCustom(defaultAddress!, forKey: kDefaultLocation)
		}
	}
}
var currScreen : screens? = .login
let AcceptOrderWaitingTime = 180
//Cart Term Notes
var cartTermNotes  : [CartTermNotes] = []
//Selected Const Var
var CurrentServiceCategoryId = 0

//Repeatation optons
struct RepeatationOptions{
	var id : Int?
	var name : String?
}
//AdvancedOrderDetails
struct AdvanceOrderDetails {
	var recurringTypeId : Int = 0
	var recurredOn : String  = ""
	var recurringTime : String  = ""
	var label : String  = ""
	var repatUntilDate : String  = ""
	var multiDates : [Date] = []
	var untilDate : Date = Date()
	var selectedDayIndex : [Int] = []
}
var structAdvancedOrderDeatils = AdvanceOrderDetails()
var structRepeateOption = RepeatationOptions()
var arrStructRepeateOptions : [RepeatationOptions] = []
enum enum_repeate_options: String {
	case once = "once"
	case everyday = "everyday"
	case weekly = "weekly"
	case monthly = "monthly"
}

//CART
var cartItems = 0
var structCustomerTempCart = CustomerTempCart()
var structCartAry = CustomCart()
//var structCustomerFinalCart = CustomerFinalCart()
var IsItemDiscard = false
var newItemAddedFromStore = false
//Keys
let GoogleMapKey = "AIzaSyCfFo3hkgd1zDyNG2FC0FsbYws1srIhHak"
let GoogleSignInKey = "781167981669-igdj0u3roaqlcka231dpt1gunpptj5fe.apps.googleusercontent.com"
let kUserType = "user_type"
let kFcmToken = "fcm_token"
let kDeviceToken = "device_token"
let kDefaultLocation = "default_location"
let kItemCategories = "item_Categories"
let uuId = UUID().uuidString
var isLoginOrVerifyForOrder = false
var isTermAndConditionTapped = false
var FIREBASEID_OF_CURRENTUSER = ""
let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height
let screenSize = UIScreen.main.bounds.size
var flag : String  = ""
var isMapPresented = false

//MARK: - CHECK FOR DEVICE
let IS_IPAD = UI_USER_INTERFACE_IDIOM() != .phone

//MARK: - SCREEN WIDTH FOR ORIGINAL FONTS
let SCREEN_WIDTH_FOR_ORIGINAL_FONT = IS_IPAD ? 768 : 375 as CGFloat
let SCREEN_HEIGHT_FOR_ORIGINAL_FONT = IS_IPAD ? 1024 : 667 as CGFloat

let kCHECK_INTERNET_CONNECTION   =  "Check your internet connection"
let kPROBLEM_FROM_SERVER         =  "Problem Receiving Data From Server"
//Firebase User
//var fireauthResult : AuthDataResult? = nil
//let BlurrView = BlurrViewVC.getBlurrView()
let ERROR17012 =  "An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address."

//MARK: - FONT NAMES
let fFONT_REGULAR   =   "Montserrat-Regular"
let fFONT_BOLD      =   "Montserrat-Bold"
let fFONT_SEMIBOLD  =   "Montserrat-SemiBold"
let fFONT_BLACK     =   "Montserrat-Black"
let fFONT_LIGHT     =   "Montserrat-Light"
let fFONT_EXTRABOLD =   "Montserrat-ExtraBold"
let fFONT_MEDIUM    =   "Montserrat-Medium"

//COLORS
let GreenColor = UIColor(red: 24/255, green: 81/255, blue: 202/255, alpha: 1.0)
let GreenCGColor = UIColor(red: 24/255, green: 81/255, blue: 22/255, alpha: 1.0).cgColor
let strokeColor = UIColor(red: 35/255, green: 138/255, blue: 254/255, alpha: 1.0)
let THEME_COLOR = UIColor(red: 24/255, green: 81/255, blue: 202/255, alpha: 1.0)
let LIGHT_THEME = UIColor(red: 205/255, green: 221/255, blue: 224/255, alpha: 0.9)
let LINK_COLOR = GreenColor//UIColor(red: 47/255, green: 184/255, blue: 235/255, alpha: 1.0)
let RedColor = UIColor(red: 255/255, green: 30/255, blue: 47/255, alpha: 1.0)
let VIEW_BG_COLOR = UIColor(red: 242/255, green: 249/255, blue: 255/255, alpha: 1.0)

//GRADIENT COLOR
let THEME_COLOR_1 = UIColor(red: 86/255, green: 44/255, blue: 174/255, alpha: 1.0)
let THEME_COLOR_2 = UIColor(red: 28/255, green: 119/255, blue: 242/255, alpha: 1.0)
let GRADIENT_ARRAY = [THEME_COLOR_1.cgColor, THEME_COLOR_2.cgColor]

//MARK:- STORYBOARD
let MainStoryboard = UIStoryboard(name: "Main", bundle: nil)
let LoginStoryboard = UIStoryboard(name: "Login", bundle: nil)
let SupplierStoryboard = UIStoryboard(name: "SupplierView", bundle: nil)
let CustomerStoryboard = UIStoryboard(name: "Customer", bundle: nil)
let CustomerOrdersStoryboard = UIStoryboard(name: "CustomerOrder", bundle: nil)
let CustomerCartStoryboard = UIStoryboard(name: "CustomerCart", bundle: nil)
let CustomerProductsStoryboard = UIStoryboard(name: "CustomerProducts", bundle: nil)

//MARK:- VARIABLES FOR NOTIFICATION CLICK NAVIGATION
var IS_FROM_PUSH_NOTIFICATION : Bool = false
var PUSH_USER_INFO = [String : Any]()
var IS_APP_OPEN_FROM_NOTIFICATION_LAUNCH : Bool = true
var IS_FROM_LOCAL_NOTIFICATION : Bool = false

let ncNOTIFICATION_WEEKLY_PAYMENT = "NotificationWeeklyPayment"
let ncNOTIFICATION_PRODUCT_VERIFICATION = "NotificationProductVerification"
let ncNOTIFICATION_STORE_VERIFICATION = "NotificationStoreVerification"

let QUE_AVTAR = UIImage(named: "que_avtar")
let USER_AVTAR = UIImage(named: "user_avatar")
let BANNER_AVTAR = UIImage(named: "banner_avtar")
let CATEGORY_AVTAR = UIImage(named: "category_avtar")
let GRADIENT_IMAGE = UIImage(named: "gradient_bg")

//BRAINTTREE

let BRAINTREE_MERCHANT_ID = "jf8yv9rqtwpbjgxw"
let BRAINTREE_PUBLIC_KEY = "fd6ykxy3q9dcp8sy"
let BRAINTREE_TOKENTISE_KEY = "sandbox_9qs33bwz_jf8yv9rqtwpbjgxw"

//INTERSWITCH PAYMENT
let INITIATE_PAYMENT = "\(DICTINARY)/PaymentConfirmation.php"
let PAYMENT_REDIRECT_PAGE = "PaymentRedirect.php"
let PAYMENT_SUCCESS_PAGE = "\(DICTINARY)/PaymentSuccess.php"
