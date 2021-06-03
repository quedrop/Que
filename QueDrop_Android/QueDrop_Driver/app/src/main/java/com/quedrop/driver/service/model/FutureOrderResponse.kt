package com.quedrop.driver.service.model

import com.google.gson.annotations.SerializedName


class FutureOrderResponse {
    @SerializedName("status")

    val status: Boolean? = null
    @SerializedName("message")

    val message: String? = null

    @SerializedName("data")
    val futureOrderData: FutureOrderData? = null

}

class FutureOrderData {
    @SerializedName("future_orders")
    val futureOrders: List<FutureOrder>? = null
}

class FutureOrder {

    @SerializedName("recurring_order_id")

    val recurringOrderId: Int? = null
    @SerializedName("user_id")

    val userId: Int? = null
    @SerializedName("delivery_latitude")

    val deliveryLatitude: String? = null
    @SerializedName("delivery_longitude")

    val deliveryLongitude: String? = null
    @SerializedName("delivery_address")

    val deliveryAddress: String? = null
    @SerializedName("driver_note")

    val driverNote: String? = null

    @SerializedName("recurring_time")
    val recurringTime: String? = null

    @SerializedName("delivery_time")
    val deliveryTime: Int? = null

    @SerializedName("recurring_type_id")
    val recurringTypeId: Int? = null

    @SerializedName("recurred_on")
    val recurredOn: String? = null

    @SerializedName("delivery_charge")
    val deliveryCharge: Int? = null

    @SerializedName("service_charge")
    val serviceCharge: Int? = null

    @SerializedName("label")
    val label: String? = null

    @SerializedName("repeat_until_date")
    val repeatUntilDate: String? = null

    @SerializedName("order_total_amount")
    val orderTotalAmount: Double? = null

    @SerializedName("stores")
    val stores: List<StoreDetail>? = null

    @SerializedName("customer_detail")

    val customerDetail: CustomerDetail? = null
}