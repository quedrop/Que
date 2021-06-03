package com.quedrop.customer.model

import okhttp3.MultipartBody
import okhttp3.RequestBody

data class TokenRequest(
    var access_key: String
)


data class Register(
    var secret_key: RequestBody,
    var access_key: RequestBody,
    var user_image: MultipartBody.Part,
    var guest_user_id: RequestBody,
    var firstname: RequestBody,
    var lastname: RequestBody,
    var password: RequestBody,
    var login_as: RequestBody,
    var referral_code: RequestBody,
    var email: RequestBody,
    var device_type: RequestBody,
    var device_token: RequestBody,
    var timezone: RequestBody,
    var latitude: RequestBody,
    var longitude: RequestBody,
    var address: RequestBody
)

data class SendOTPRequest(
    var country_code: String,
    var phone_number: String,
    var secret_key: String,
    var access_key: String,
    var user_id:Int,
    var guest_user_id: Int
)

data class VerifyOTPRequest(

    var country_code: String,
    var phone_number: String,
    var secret_key: String,
    var access_key: String,
    var otp_code: String,
    var user_id: Int,
    var guest_user_id:Int

)

data class SocialRegisterRequest(
    var device_token:String,
    var firstname:String,
    var login_as:String,
    var device_type:Int,
    var email:String,
    var user_image:String,
    var login_type:String,
    var socialKey:String,
    var latitude:String,
    var lastname:String,
    var address:String,
    var longitude:String,
    var secret_key:String,
    var timezone:String,
    var access_key:String
)

data class LogOutRequest(
    var secret_key:String,
    var access_key:String,
    var user_id:Int,
    var device_token:String,
    var device_type:Int,
    var user_type:String
)

data class ChangePasswordRequest(
    var secret_key:String,
    var access_key:String,
    var user_id:Int,
    var old_password:String,
    var new_password:String
)

data class RateReviewDriverRequest(
    var secret_key:String,
    var access_key:String,
    var user_id:Int
)

data class RateReviewResponse(
    var user_id:Int,
    var review_id:Int,
    var review:String,
    var rating:Float,
    var first_name:String,
    var last_name:String,
    var user_image:String,
    var user_name:String,
    var order_id:Int,
    var created_at:String
)

data class GooglePayResponse(
    var transaction_id:String,
    var user_id:Int,
    var order_id:Int

)