package com.quedrop.customer.model

import java.io.Serializable

//data class NotificationModel(
//    var user_notification_id: Int,
//    var notification_type_id: Int,
//    var notification_desc: String,
//    var notification_datetime: String,
//    var notification_type: String
//):Serializable

data class NotificationModel(
    var notification_id: Int,
    var notification_type: Int,
    var notification: String,
    var notification_datetime: String,
    var data_id: Int
):Serializable
