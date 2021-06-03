package com.quedrop.driver.service.model

import com.google.gson.annotations.SerializedName


class FutureOrderDatesResponse {

    @SerializedName("status")
    val status: Boolean? = null

    @SerializedName("message")
    val message: String? = null

    @SerializedName("data")
    val orderDate: OrderDate? = null
}


class OrderDate {
    @SerializedName("future_order_dates")
    val futureOrderDates: List<FutureOrderDate>? = null

}

class FutureOrderDate {
    @SerializedName("future_order_date")
    val futureOrderDate: String? = null
}

data class GenieResponse<T>(
    val data: Map<String, T>? = null,
    val status: Boolean,
    val message: String
)


