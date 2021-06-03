package com.quedrop.driver.service.request

import com.google.gson.annotations.SerializedName
import okhttp3.MultipartBody
import okhttp3.RequestBody

data class RegisterRequest(
    @SerializedName("secret_key")
    val secret_key: RequestBody,
    @SerializedName("access_key")
    val access_key: RequestBody,
    @SerializedName("user_image")
    val user_image: MultipartBody.Part,
    @SerializedName("firstname")
    val firstname: RequestBody,
    @SerializedName("lastname")
    val lastname: RequestBody,
    @SerializedName("password")
    val password: RequestBody,
    @SerializedName("login_as")
    val login_as: RequestBody,
    @SerializedName("referral_code")
    val referralCode: RequestBody,
    @SerializedName("email")
    val email: RequestBody,
    @SerializedName("device_type")
    val device_type: RequestBody,
    @SerializedName("device_token")
    val device_token: RequestBody,
    @SerializedName("timezone")
    val timezone: RequestBody,
    @SerializedName("latitude")
    val latitude: RequestBody,
    @SerializedName("longitude")
    val longitude: RequestBody,
    @SerializedName("address")
    val address: RequestBody
)