package com.quedrop.driver.service.model

import com.google.gson.annotations.Expose

import com.google.gson.annotations.SerializedName




class TokenResponse {
    @SerializedName("tempToken")
    @Expose
     val tempToken: String? = null
    @SerializedName("status")
    @Expose
     val status: Boolean? = null
    @SerializedName("message")
    @Expose
     val message: String? = null

}