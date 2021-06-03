package com.quedrop.driver.service.request

import com.google.gson.annotations.SerializedName

data class ForgotPasswordRequest(
    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("email")
    val email: String
)