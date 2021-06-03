package com.quedrop.driver.service.request

import com.google.gson.annotations.SerializedName

data class SingleOrderRequest(
    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("order_id")
    val orderId: Int
)

data class RemoveOrderReceiptRequest(
    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("store_id")
    val store_id: Int,
    @SerializedName("user_store_id")
    val user_store_id: Int,
    @SerializedName("order_id")
    val order_id: Int,
    @SerializedName("user_id")
    val user_id: Int
)