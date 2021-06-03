package com.quedrop.customer.network

import com.google.gson.annotations.Expose

data class TokenResponse(

    @Expose
    val tempToken: String? = null,
    @Expose
    val status: Boolean? = null,
    @Expose
    val message: String? = null
)

data class LoginResponse(
    @Expose
    var userToken: String? = null,
    @Expose
    var status: Boolean? = null,
    @Expose
    var message: String? = null,
    @Expose
    var data: ResponseWrapper? = null
)


