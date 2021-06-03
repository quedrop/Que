package com.quedrop.driver.service.request

import com.google.gson.annotations.SerializedName

data class GiveRateRequest(
    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("to_user_id")
    val toUserId: Int,
    @SerializedName("from_user_id")
    val fromUserId: Int,
    @SerializedName("rating")
    val rating: Float,
    @SerializedName("review")
    val review: String,
    @SerializedName("order_id")
    val orderId: Int
)