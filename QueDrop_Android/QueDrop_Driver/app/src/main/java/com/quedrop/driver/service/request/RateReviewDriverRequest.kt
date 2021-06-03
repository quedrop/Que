package com.quedrop.driver.service.request

import com.google.gson.annotations.SerializedName

class RateReviewDriverRequest(

    @SerializedName("secret_key")
    var secret_key: String,

    @SerializedName("access_key")
    var access_key: String,

    @SerializedName("user_id")
    var user_id: Int
)