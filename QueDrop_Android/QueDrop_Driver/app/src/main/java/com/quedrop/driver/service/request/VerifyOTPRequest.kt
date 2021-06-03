package com.quedrop.driver.service.request

import com.google.gson.annotations.SerializedName

data class VerifyOTPRequest(
    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("country_code")
    val countryCode: String,
    @SerializedName("phone_number")
    val phoneNumber: String ,
    @SerializedName("otp_code")
    val otpCode: String,
    @SerializedName("user_id")
    val userId: Int
)