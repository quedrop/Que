package com.quedrop.driver.service.request

import com.google.gson.annotations.SerializedName

data class SocialRegisterRequest  (
    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("firstname")
    val firstname: String,
    @SerializedName("lastname")
    val lastname: String,
    @SerializedName("login_type")
    val loginType: Int,
    @SerializedName("login_as")
    val login_as: Int,
    @SerializedName("socialKey")
    val socialKey: String,
    @SerializedName("email")
    val email: String,
    @SerializedName("device_type")
    val device_type: Int,
    @SerializedName("device_token")
    val device_token: String,
    @SerializedName("timezone")
    val timezone: String,
    @SerializedName("latitude")
    val latitude: String,
    @SerializedName("longitude")
    val longitude: String,
    @SerializedName("address")
    val address: String,
    @SerializedName("user_image")
    val userImage: String,
    @SerializedName("referral_code")
    val referralCode: String,
    @SerializedName("is_for_validation")
    val isForValidation: Int
)