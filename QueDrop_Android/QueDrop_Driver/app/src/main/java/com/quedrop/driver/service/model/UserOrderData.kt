package com.quedrop.driver.service.model

import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName

class UserOrderData {
    @SerializedName("status")
    @Expose
    val status: Boolean = false
    @SerializedName("message")
    @Expose
    val message: String? = null
    @SerializedName("data")
    @Expose
    val data: OrderData? = null
}

class OrderData {
    @SerializedName("current_order")
    @Expose
    val currentOrder: MutableList<Orders>? = null

    @SerializedName("past_order")
    @Expose
    val pastOrder: MutableList<Orders>? = null

    @SerializedName("future_orders")
    @Expose
    val futureOrders: MutableList<Orders>? = null
}
