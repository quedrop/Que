package com.quedrop.driver.service.request

import com.google.gson.annotations.SerializedName

data class GetWeeklyPaymentRequest(

    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("user_id")
    val user_id: Int,
    @SerializedName("week_start_date")
    val week_start_date: String,
    @SerializedName("week_end_date")
    val week_end_date: String
)

data class GetManualStorePaymentRequest(
    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("user_id")
    val user_id: Int,
    @SerializedName("selected_date")
    val selected_date: String
)

data class CheckForValidReferralCodeRequest(
    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("login_as")
    val login_as: String,
    @SerializedName("referral_code")
    val referral_code: String
)

data class GetFutureOrderRequest(
    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("user_id")
    val user_id: Int,
    @SerializedName("order_date")
    val order_date: String,
    @SerializedName("is_for_customer")
    val is_for_customer: String
)

data class GetFutureSingleOrderRequest(
    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("user_id")
    val user_id: Int,
    @SerializedName("recurring_order_id")
    val recurring_order_id: Int,
    @SerializedName("timezone")
    val timezone: String,
    @SerializedName("is_full_detail")
    val is_full_detail: Int,
    @SerializedName("is_for_customer")
    val is_for_customer: Int
)

data class GetFutureOrderDatesRequest(

    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("user_id")
    val user_id: Int,
    @SerializedName("is_for_customer")
    val is_for_customer: Int

)
