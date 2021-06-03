package com.quedrop.driver.service.request
import com.google.gson.annotations.SerializedName

data class FutureOrderRequest(
    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("user_id")
    val userId: String,
    @SerializedName("order_date")
    val orderDate: String,
    @SerializedName("is_customer")
    val isCustomer: Int
)