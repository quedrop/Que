package com.quedrop.customer.model

import com.google.gson.annotations.SerializedName

data class LoginRequest(
    var secret_key:String,
    var access_key:String,
    var password:String,
    var email:String,
    var device_type:Int,
    var device_token:String,
    var timezone:String,
    var guest_user_id:Int,
    var login_as:String
)

data class ForgotPasswordRequest(
    var email:String,
    var secret_key:String,
    var access_key:String
)

data class CheckForValidReferralCodeRequest(
    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("login_as")
    val login_as: String,
    @SerializedName("referral_code")
    val referral_code: String
)