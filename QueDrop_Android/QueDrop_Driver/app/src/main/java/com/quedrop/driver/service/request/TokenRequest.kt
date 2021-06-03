package com.quedrop.driver.service.request

import com.google.gson.annotations.SerializedName

data class TokenRequest(@SerializedName("access_key") val access_key : String)