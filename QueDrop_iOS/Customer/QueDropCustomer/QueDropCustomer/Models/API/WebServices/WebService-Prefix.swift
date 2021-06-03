//
//  GoferDeliveryCuustomer
//
//  Created by C100-107 on 27/01/20.
//  Copyright © 2019 C100-104. All rights reserved.
//

import Foundation

//Service Type
let GET = "GET"
let POST = "POST"
let MEDIA = "MEDIA"
let MESSAGE = "Please try again later."

let isLive = true
let IS_TESTDATA = 1

//http://34.204.81.189/quedrop/API/QueDropService.php

let LOCAL_SERVER_URL = "http://clientapp.narola.online/"
let LIVE_SERVER_URL = "http://34.204.81.189/"

let SERVER_URL = isLive ?  LIVE_SERVER_URL : LOCAL_SERVER_URL
let DICTINARY = isLive ? "\(SERVER_URL)quedrop/API" : "\(SERVER_URL)pg/QueDrop/API"
//SOCKET IO Path
let LOCAL_SOCKET_SERVER_PATH = "http://clientapp.narola.online:8081"
let LIVE_SOCKET_SERVER_PATH = "http://34.204.81.189:30080/"
let SOCKET_SERVER_PATH = isLive ? LIVE_SOCKET_SERVER_PATH : LOCAL_SOCKET_SERVER_PATH
let SoketChangeStatus = "status_update"

// Term & Condition and Privecy Policy
let URL_privecyPolicy = "\(DICTINARY)/PrivacyPolicy.pdf"
let URL_termAndCondition = "\(DICTINARY)/terms-and-conditions.html"
//let URL_termAndCondition = "\(DICTINARY)/Files/GDPL-Customer.pdf"

//Web Service Path
let WEBSERVICE_PATH = "\(DICTINARY)/QueDropService.php?Service="


//Media Path
let MEDIA_URL = "\(DICTINARY)/Uploads/"

//Image Storage path
let URL_USER_IMAGES = "\(MEDIA_URL)Users/"
let URL_CATEGORY_IMAGES = "\(MEDIA_URL)ServiceCategories/"
let URL_DRIVER_DETAILS_IMAGES = "\(MEDIA_URL)DriverDetails/"
let URL_STORE_CATEGORY_IMAGES = "\(MEDIA_URL)StoreCategory/"
let URL_STORE_SLIDER_IMAGES = "\(MEDIA_URL)StoresS/"
let URL_STORE_LOGO_IMAGES = "\(MEDIA_URL)Logo/"
let URL_PRODUCT_IMAGES = "\(MEDIA_URL)Products/"
let URL_ORDER_RECEIPT_IMAGES = "\(MEDIA_URL)OrderReceipt/"



var headers = [
	"Content-Type"  : "application/json",
	"cache-control" : "no-cache",
	"Postman-Token" : "a523c3ab-c7ac-4087-b764-31e93f3fc050",
    "Accept"        : "application/json",
	"userAgent"		: "iOS",
    "is_testdata" : "\(IS_TESTDATA)"
]


//MARK:- Service Name

//CUstomer
let APIGuestLogin = "\(WEBSERVICE_PATH)GuestRegister"


//Location
let API_LOGIN = "\(WEBSERVICE_PATH)Login"
let API_ = "\(WEBSERVICE_PATH)Login"
let API_SIGNUP  = "\(WEBSERVICE_PATH)Register"
let API_SENDOTP = "\(WEBSERVICE_PATH)SendOTP"
let API_VERIFYOTP = "\(WEBSERVICE_PATH)VerifyOTP"
let API_UPDATE_DRIVER_IDENTITY  = "\(WEBSERVICE_PATH)UpdateDriverIdentityDetail"
let API_FORGOT_PASSWORD  = "\(WEBSERVICE_PATH)ForgotPassword"
let API_SOCIAL_REGISTER  = "\(WEBSERVICE_PATH)SocialRegister"

let APIRefreshToken = "\(WEBSERVICE_PATH)RefreshToken"
let APIAddAddress = "\(WEBSERVICE_PATH)AddAddress"
let APIGetCustomerAddresses = "\(WEBSERVICE_PATH)GetCustomerAddresses"
let APIDeleteAddress = "\(WEBSERVICE_PATH)DeleteAddress"
let APIEditAddress = "\(WEBSERVICE_PATH)EditAddress"
let APIGetAllServiceCategory = "\(WEBSERVICE_PATH)GetAllServiceCategory"
let APISearchStoreByName = "\(WEBSERVICE_PATH)SearchStoreByName"
let APIGetFavouriteStore = "\(WEBSERVICE_PATH)GetFavouriteStores"
let APIGetOfferList = "\(WEBSERVICE_PATH)GetOfferList"
let APIGetStoreDetails = "\(WEBSERVICE_PATH)GetStoreDetails"
let APIMarkStoreAsFavouriteUnFavourite = "\(WEBSERVICE_PATH)MarkStoreAsFavouriteUnFavourite"
let APIGetStoreCategoryWithProduct = "\(WEBSERVICE_PATH)GetStoreCategoryWithProduct"
let APIGetProductDetail = "\(WEBSERVICE_PATH)GetProductDetail"
let APIAddItemToCart = "\(WEBSERVICE_PATH)AddItemToCart"
let APIAddUserStoreProduct = "\(WEBSERVICE_PATH)AddUserStoreProduct"
let APIAddUserStore = "\(WEBSERVICE_PATH)AddUserStore"
let APIGetUserCart = "\(WEBSERVICE_PATH)GetUserCart"
let APIPlaceOrder = "\(WEBSERVICE_PATH)PlaceOrder"
let APIRescheduleOrder = "\(WEBSERVICE_PATH)RescheduleOrder"
let APIDeleteCartItem = "\(WEBSERVICE_PATH)DeleteCartItem"
let APIUpdateCartQuantity = "\(WEBSERVICE_PATH)UpdateCartQuantity"
let APIDeleteProductFromCartItem = "\(WEBSERVICE_PATH)DeleteProductFromCartItem"
let APICustomiseCartItem = "\(WEBSERVICE_PATH)CustomiseCartItem"
let APILogout = "\(WEBSERVICE_PATH)Logout"
let APIGetUserAddedStoreProductsFromCart = "\(WEBSERVICE_PATH)GetUserAddedStoreProductsFromCart"
let APIGetRecurringTypes = "\(WEBSERVICE_PATH)GetRecurringTypes"
let APIGetCartTermsNote = "\(WEBSERVICE_PATH)GetCartTermsNote"
let APIGetAllCoupuns = "\(WEBSERVICE_PATH)GetAllCoupuns"
let APIApplyCouponCode = "\(WEBSERVICE_PATH)ApplyCouponCode"
let APIGetCustomerOrders = "\(WEBSERVICE_PATH)GetCustomerOrders"
let APIGetSingleOrderDetail = "\(WEBSERVICE_PATH)GetSingleOrderDetail"
let APIGetConfirmOrderDetail = "\(WEBSERVICE_PATH)GetConfirmOrderDetail"
let API_GIVE_REVIEW = "\(WEBSERVICE_PATH)GiveRateReview"
let APIGetRatingReview = "\(WEBSERVICE_PATH)GetRatingReview"
let API_CHECK_REFERRAL_CODE_VALIDITY = "\(WEBSERVICE_PATH)CheckForValidReferralCode"
let API_APPLE_PAY_SECRET = "\(WEBSERVICE_PATH)ApplePayCharge"
let API_SUBMIT_ORDER_QUERY = "\(WEBSERVICE_PATH)SubmitOrderQuery"
let API_EXPLORE_SEARCH = "\(WEBSERVICE_PATH)ExploreSearch"

//MARK:- SOKET API

let APISocketJoin_Socket = "join_socket"
let APISocketIdentifyStatusChnage = "status_change"
let APISocketPlaceOrder = "placeOrder"
let APISocketCompleteOrder = "complete_order"
let APISocketOrderRequest = "order_request"
let APISocketOrderAcceptResult = "order_accepted"
let APISocketOrderRequestTimeout = "order_request_timeout"
let APISocketOrderStatusChanged = "order_status_changed"
let APISocketOrderAccepted = "order_accepted"
let APISocketCancelOrder = "order_accepted"
let APISocketDriverLocationChanged = "driver_location_changed"
let APISocketStartDriverLocationUpdate = "start_driver_location_update"
let APISocketStopDriverLocationUpdate = "stop_driver_location_update"
let APISocketFetchMessages = "fetch_messages"
let APISOCKETSendNewMessage  = "send_new_message"
let APISOCKETGetNewMessage = "get_new_message"
let APISOCKETGetCartItemCount = "get_cart_items_count"
let  APISOCKETGetUserDetails = "get_user_details"
let APISOCKETDisconnectManually = "disconnect_manually"
let APISOCKETGetUpdatedEstimatedTime = "get_updated_estimated_time"
let  APISOCKETGetAvailableDrivers = "get_driver_list"
let APISocketStoreVerificationACK = "store_verification_ack"

