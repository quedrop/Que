package com.quedrop.driver.service.request

import com.google.gson.annotations.SerializedName

data class NotificationListRequest(
    @SerializedName("secret_key")
    val secret_key: String,
    @SerializedName("access_key")
    val access_key: String,
    @SerializedName("user_id")
    val userId: Int,
    @SerializedName("page_num")
    val pageNum: Int
)