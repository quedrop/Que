package com.quedrop.driver.service.model

import com.google.gson.annotations.SerializedName


class NotificationResponse {

    @SerializedName("status")
    val status: Boolean? = null

    @SerializedName("message")
    val message: String? = null

    @SerializedName("data")
    val notificationData: NotificationData? = null
}

class NotificationData {
    @SerializedName("notifications")
    val notifications: MutableList<Notifications>? = null
}


class Notifications {

    @SerializedName("notification_id")
    val notificationId: Int? = null

    @SerializedName("notification_type")
    val notificationType: Int? = null

    @SerializedName("notification")
    val notification: String? = null

    @SerializedName("notification_datetime")
    val notificationDatetime: String? = null

    @SerializedName("data_id")
    val dataId: Int? = null

}
