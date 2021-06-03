//
//  Constant.swift
//  QueDropDeliveryCustomer
//
//  Created by C100-104 on 27/12/19.
//  Copyright © 2019 C100-104. All rights reserved.
//

import Foundation
import UIKit


enum SignUpFields : Int{
	case name = 0
	case email
	case password
	case confirmPassword
	case referralCode
	case termAndConditions
}

enum DriverDetailsFields : Int{
    case photo = 0
    case vehicleType
    case licence
    case registrationProof
    case numberPlate
}

enum VehicleType : String {
    case Car
    case Bike
    case Cycle
}

enum Currency_Type : String
{
    case Rupees = "₹"
    case Doller = "$"
    case Euro = "€"
}

enum OrderStatus : String {
    case Placed = "Placed"
    case Accepted = "Accepted"
    case Preparing = "Preparing"
    case Dispatch = "Dispatch"
    case Delivered = "Delivered"
    case Cancelled = "Cancelled"
}

enum ShadowLoction: String {
    case bottom
    case top
}

enum CMS_TYPE: Int {
    case TermsCondition = 1
    case PrivacyPolicy
    case FAQ
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
   
enum DELIVERY_OPTION : String {
    case Standard = "Standard"
    case Express = "Express"
}

//MARK: - CHECK FOR DEVICE
let IS_IPAD = UI_USER_INTERFACE_IDIOM() != .phone

//MARK: - SCREEN BOUNDS
let SCREEN_WIDTH = UIScreen.main.bounds.size.width as CGFloat
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height as CGFloat
let SCREEN_SIZE = UIScreen.main.bounds.size

//MARK: - SCREEN WIDTH FOR ORIGINAL FONTS
let SCREEN_WIDTH_FOR_ORIGINAL_FONT = IS_IPAD ? 768 : 375 as CGFloat
let SCREEN_HEIGHT_FOR_ORIGINAL_FONT = IS_IPAD ? 1024 : 667 as CGFloat

//MARK: - GET APPDELEGATE
let APP_DELEGATE = UIApplication.shared.delegate as? AppDelegate

//MARK: - SOME COMMON THINGS
let kCHECK_INTERNET_CONNECTION   =  "Check your internet connection"
let kPROBLEM_FROM_SERVER         =  "Problem Receiving Data From Server"
let kDRIVER_REQUEST_TIME = 60.0

var USERTYPE = 3 // Driver

//MARK:- VARIABLES
var isNetworkConnected = true
var clickDetact : String = ""
var ACCESS_KEY = "nousername"
var SECRET_KEY = "Is1YE9nQYMbOFzjtV77K/3MdKMqwt8NQVGc+aRyoeRU="
var DEVICE_TOKEN = "123456"
var FCM_TOKEN = ""
var TIME_ZONE = TimeZone.current.identifier
let DEVICE_TYPE = 2
let IS_TEST_DATA = "1"
var IS_GPS_ON   = false
var isGuest : Bool = true
var Currency = Currency_Type.Doller.rawValue

//MARK:- CONSTANTS
var LOGIN_AS = "Driver"

//MARK: - USER
var USER_ID = 0
var USER_OBJ : User?

//MARK:- KEYS
let GOOGLE_MAP_KEY = "AIzaSyCfFo3hkgd1zDyNG2FC0FsbYws1srIhHak"
let GoogleSignInKey = "781167981669-dnhnj5e64i78q47pg03d20m6fftbe1sg.apps.googleusercontent.com"

//MARK:- USER DEFAULT RELATED
let kIsUserLoggedIn = "IsUserLoggedIn"
let kUserType = "user_type"
let kUserDetails = "UserDetails"
let kUserId = "id"
let kCurrentOrderRequestId = "CurrentOrderRequestId"
let kOrderRequestQueue = "OrderRequestQueue"
let kIsRememberMeSelected = "IsRememberMe"
let kEmailId = "EmailId"
let kPassword = "Paasword"
let kFcmToken = "FcmToken"

//MARK: - DRIVERS LOCATION
var CURRENT_LATITUDE = 0.0
var CURRENT_LONGITUDE = 0.0

//MARK: - FONT NAMES
let fFONT_REGULAR   =   "Montserrat-Regular"
let fFONT_BOLD      =   "Montserrat-Bold"
let fFONT_SEMIBOLD  =   "Montserrat-SemiBold"
let fFONT_BLACK     =   "Montserrat-Black"
let fFONT_LIGHT     =   "Montserrat-Light"
let fFONT_EXTRABOLD =   "Montserrat-ExtraBold"
let fFONT_MEDIUM    =   "Montserrat-Medium"

//MARK: - COLORS
let GreenColor = UIColor(red: 24/255, green: 81/255, blue: 202/255, alpha: 1.0)
let GreenCGColor = UIColor(red: 24/255, green: 81/255, blue: 22/255, alpha: 1.0).cgColor
let strokeColor = UIColor(red: 24/255, green: 81/255, blue: 202/255, alpha: 1.0)
let THEME_COLOR = UIColor(red: 24/255, green: 81/255, blue: 202/255, alpha: 1.0)
let LINK_COLOR = UIColor(red: 47/255, green: 184/255, blue: 235/255, alpha: 1.0)
let VIEW_BACKGROUND_COLOR = UIColor(red: 242/255, green: 249/255, blue: 255/255, alpha: 1.0)
let SKYBLUE_COLOR = UIColor(red: 0/255, green: 155/255, blue: 243/255, alpha: 1.0)
let GREEN_COLOR = UIColor(red: 0/255, green: 214/255, blue: 103/255, alpha: 1.0)
let RED_COLOR = UIColor(red: 255/255, green: 30/255, blue: 47/255, alpha: 1.0)
let LIGHT_THEME = UIColor(red: 205/255, green: 221/255, blue: 224/255, alpha: 0.9)
let ORANGE_COLOR = UIColor(red: 255/255, green: 161/255, blue: 89/255, alpha: 1.0)

//GRADIENT COLOR
let THEME_COLOR_1 = UIColor(red: 86/255, green: 44/255, blue: 174/255, alpha: 1.0)
let THEME_COLOR_2 = UIColor(red: 28/255, green: 119/255, blue: 242/255, alpha: 1.0)
let GRADIENT_ARRAY = [THEME_COLOR_1.cgColor, THEME_COLOR_2.cgColor]

//MARK:- STORYBOARD
let MainStoryboard = UIStoryboard(name: "Main", bundle: nil)
let LoginStoryboard = UIStoryboard(name: "Login", bundle: nil)
let HomeStoryboard = UIStoryboard(name: "Home", bundle: nil)

//MARK:- TABS INDEX
let tTAB_HOME = 0
let tTAB_NOTIFICATION = 1
let tTAB_ORDER = 2
let tTAB_EARNING = 4
let tTAB_PROFILE = 3

//MARK:- NOTIFICATION CENTER NOTIFICATION NAMES
let ncNOTIFICATION_LOCATION_UPDATE = "LocationUpdateNotification"
let ncNOTIFICATION_SOCKET_DRIVER_STATUS = "SocketDriverLocationNotification"
let ncNOTIFICATION_SOCKET_CHANGE_DRIVER_STATUS = "SocketDriverWorkingStatusChangeNotification"
let ncNOTIFICATION_NEW_ORDER_REQUEST = "SocketNewOrderRequestNotification"
let ncNOTIFICATION_ORDER_REJECT_FROM_HOME_SCREEN = "SocketOrderRejectFromHomeNotification"
let ncNOTIFICATION_ORDER_ACCEPTED_RESULT = "SocketOrderAcceptedResultNotification"
let ncNOTIFICATION_ORDER_REQUEST_TIMEOUT = "SocketOrderRequestTimeout"
let ncNOTIFICATION_ORDER_DELIVERED = "SocketOrderDelivered"
let ncNOTIFICATION_ORDER_REQUEST_FROM_PUSH = "NotificationOrderRequestFromPush"
let ncNOTIFICATION_MANUAL_PAYMENT = "NotificationManualPayment"
let ncNOTIFICATION_WEEKLY_PAYMENT = "NotificationWeeklyPayment"
let ncNOTIFICATION_CLEAR_REQUEST = "NotificationClearRequest"

//MARK:- VARIABLES FOR NOTIFICATION CLICK NAVIGATION
var IS_FROM_PUSH_NOTIFICATION : Bool = false
var PUSH_USER_INFO = [String : Any]()
var IS_APP_OPEN_FROM_NOTIFICATION_LAUNCH : Bool = true
var IS_FROM_LOCAL_NOTIFICATION : Bool = false

let QUE_AVTAR = UIImage(named: "que_avtar")
let USER_AVTAR = UIImage(named: "avtar")
let GRADIENT_IMAGE = UIImage(named: "gradient_bg")
