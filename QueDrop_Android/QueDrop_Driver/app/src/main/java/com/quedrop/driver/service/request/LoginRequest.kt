package com.quedrop.driver.service.request

import com.google.gson.annotations.SerializedName

data class LoginRequest(
    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("password")
    val password: String,
    @SerializedName("email")
    val email: String,
    @SerializedName("device_type")
    val device_type: Int,
    @SerializedName("login_as")
    val loginAs: String,
    @SerializedName("device_token")
    val device_token: String,
    @SerializedName("timezone")
    val timezone: String
)