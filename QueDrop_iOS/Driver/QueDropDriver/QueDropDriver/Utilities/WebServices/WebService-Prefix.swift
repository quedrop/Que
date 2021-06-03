//
//  QueDropDeliveryCuustomer
//
//  Created by C100-107 on 27/01/20.
//  Copyright © 2019 C100-104. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

//Service Type
let GET = "GET"
let POST = "POST"
let MEDIA = "MEDIA"
let MESSAGE = "Please try again later."

let IS_TESTDATA = 1
let IS_LIVE = 1

let WEB_DOMAIN = IS_LIVE == 1 ? "http://34.204.81.189/" : "http://clientapp.narola.online/"
//
let SERVER_URL = IS_LIVE == 1 ?  "\(WEB_DOMAIN)quedrop/API/" : "\(WEB_DOMAIN)pg/QueDropApp/API/"
let MEDIA_URL = "\(SERVER_URL)Uploads/"
//Web Service Path
let WEBSERVICE_PATH = "\(SERVER_URL)/QueDropService.php?Service="

//Image Storage path
let URL_USER_IMAGES = "\(MEDIA_URL)Users/"
let URL_CATEGORY_IMAGES = "\(MEDIA_URL)ServiceCategories/"
let URL_DRIVER_DETAILS_IMAGES = "\(MEDIA_URL)DriverDetails/"
let URL_STORE_CATEGORY_IMAGES = "\(MEDIA_URL)StoreCategory/"
let URL_STORE_SLIDER_IMAGES = "\(MEDIA_URL)StoresS/"
let URL_STORE_LOGO_IMAGES = "\(MEDIA_URL)Logo/"
let URL_PRODUCT_IMAGES = "\(MEDIA_URL)Products/"
let URL_ORDER_RECEIPT_IMAGES = "\(MEDIA_URL)OrderReceipt/"
let URL_BANKS_LOGO = "\(MEDIA_URL)BankLogo/"

var headers = [
	"Content-Type"    : "application/json",
	"cache-control"   : "no-cache",
	"Postman-Token"   : "a523c3ab-c7ac-4087-b764-31e93f3fc050",
    "Accept"           : "application/json",
    "userAgent"		: "iOS",
    "is_testdata"     : "\(IS_TESTDATA)"
    ]


//MARK:- Service Name

//CUstomer
let APIGuestLogin = "\(WEBSERVICE_PATH)GuestRegister"

//Location

let APIRefreshToken = "\(WEBSERVICE_PATH)RefreshToken"
let API_LOGIN = "\(WEBSERVICE_PATH)Login"
let API_SIGNUP  = "\(WEBSERVICE_PATH)Register"
let API_SENDOTP = "\(WEBSERVICE_PATH)SendOTP"
let API_VERIFYOTP = "\(WEBSERVICE_PATH)VerifyOTP"
let API_UPDATE_DRIVER_IDENTITY  = "\(WEBSERVICE_PATH)UpdateDriverIdentityDetail"
let API_FORGOT_PASSWORD  = "\(WEBSERVICE_PATH)ForgotPassword"
let API_SOCIAL_REGISTER  = "\(WEBSERVICE_PATH)SocialRegister"
let API_GET_DRIVER_ORDERS = "\(WEBSERVICE_PATH)GetDriverOrders"
let API_UPLOAD_ORDER_RECIEPT = "\(WEBSERVICE_PATH)UploadOrderReceipt"
let API_REMOVE_ORDER_RECEIPT =  "\(WEBSERVICE_PATH)RemoveOrderReceipt"
let API_GET_SINGLE_ORDER_DETAIL = "\(WEBSERVICE_PATH)GetSingleOrderDetail"
let API_GIVE_REVIEW = "\(WEBSERVICE_PATH)GiveRateReview"
let API_EDIT_PROFILE = "\(WEBSERVICE_PATH)EditProfile"
let API_CHANGE_PASSWORD = "\(WEBSERVICE_PATH)ChangePassword"
let API_LOGOUT = "\(WEBSERVICE_PATH)Logout"
let API_GET_REVIEW_RATING = "\(WEBSERVICE_PATH)GetRatingReview"
let API_GET_DRIVER_IDENTITY = "\(WEBSERVICE_PATH)GetDriverIdentityDetail"
let API_GET_BANK_DETAILS = "\(WEBSERVICE_PATH)GetBankDetails"
let API_ADD_BANK_DETAIL = "\(WEBSERVICE_PATH)AddBankDetail"
let API_EDIT_BANK_DETAILS = "\(WEBSERVICE_PATH)EditBankDetail"
let API_DELETE_BANK_DETAIL = "\(WEBSERVICE_PATH)DeleteBankDetail"
let API_GET_BANK_NAME_LIST = "\(WEBSERVICE_PATH)GetBankNameList"
let API_GET_NOTIFICATIONS = "\(WEBSERVICE_PATH)GetNotifications"
let API_GET_WEEKLY_EARNING = "\(WEBSERVICE_PATH)GetDriverWeekleyPaymentDetail"
let API_GET_MANUAL_EARNING = "\(WEBSERVICE_PATH)ManualStorePaymentDetail"
let API_GET_HOME_EARNING = "\(WEBSERVICE_PATH)GetEarningDataForHome"
let API_CHECK_REFERRAL_CODE_VALIDITY = "\(WEBSERVICE_PATH)CheckForValidReferralCode"
let API_GET_FUTURE_ORDER_DATES = "\(WEBSERVICE_PATH)GetFutureOrderDates"
let API_GET_FUTURE_ORDERS = "\(WEBSERVICE_PATH)GetFutureOrders"
let API_GET_SINGLE_FUTURE_ORDER_DETAIL = "\(WEBSERVICE_PATH)GetSingleFutureOrderDetail"
//MARK:- FOR SOCKET
let SOCKET_SERVER_PATH = IS_LIVE == 1 ? "http://34.204.81.189:30080/" : "http://clientapp.narola.online:8081"

let APISocketJoin_Socket = "join_socket"
let APISocketChangeDriverStatus = "changeDriverWorkingStatus"
let APISocketGetDriverStatus = "getDriverWorkingStatus"
let APISocketOrderRequest = "order_request"
let APISocketAcceptRejectOrder = "AcceptRejectOrder"
let APISocketOrderAcceptResult = "order_accepted"
let APISocketJoinOrderRoom = "JoinOrderRoom"
let APISocketOrderRequestTimeout = "order_request_timeout"
let APISocketLeaveOrderRoom = "LeaveOrderRoom"
let APISocketDriverVerificationChanged = "driver_verification_change"
let APISocketUpdateDriverLocation   = "updateDriverLocation"
let APISocketGetOrderDetail = "getOrderDetail"
let APISocketUpdateOrderStatus = "update_order_status"
let APISocketOrderDeliveredAck = "order_delivered_acknowledge"
let APISocketFetchMessages = "fetch_messages"
let APISOCKETSendNewMessage  = "send_new_message"
let APISOCKETGetNewMessage = "get_new_message"
let APISOCKETGetUserDetails = "get_user_details"
let APISOCKETDisconnectManually = "disconnect_manually"
let APISocketManualStorePayment = "manual_store_payment_acknowledge"
let APISocketWeeklyPayment = "driver_weekly_payment_acknowledge"
let APISocketAcceptRejectRecurringOrder = "accept_reject_recurring_order"

//TERMS CONDITION AND PRIVACY POLICY
//let URL_TERMS_CONDITION = IS_LIVE == 1 ? "\(SERVER_URL)terms-and-conditions.html" : "\(SERVER_URL)terms-and-conditions.html"
let URL_TERMS_CONDITION = "\(SERVER_URL)terms-and-conditions.html" 

let URL_PRIVACY_POLICY = IS_LIVE == 1 ? "\(SERVER_URL)PrivacyPolicy.pdf" : "\(SERVER_URL)PrivacyPolicy.pdf"
