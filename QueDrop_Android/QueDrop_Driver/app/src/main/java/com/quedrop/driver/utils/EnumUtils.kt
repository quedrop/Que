package com.quedrop.driver.utils

enum class EnumUtils(val stringVal: String) {


    ACCEPTED("Accepted"),
    PLACED("Placed"),
    DISPATCH("Dispatch"),
    DELIVERED("Delivered"),
    CANCELLED("Cancelled")


}

enum class TabEnums(val staringVal: String, val posVal: Int) {
    DASHBOARD("DashBoard", 0),
    NOTIFICATION("Notification", 1),
    ORDER("Order", 2),
    FAVOURITE("Favourite", 3),
    PROFILE("Profile", 4),
}

enum class ENUMNotificationType(val posVal: Int) {

    ORDER_REQUEST(1),//R
    ORDER_ACCEPT(2),
    ORDER_REJECT(3), //D
    ORDER_REQUEST_TIMEOUT(4),
    RECURRING_ORDER_PLACED(5),//D
    RATING(6),//rthumb
    NEAR_BY_PLACE(7),//location
    DRIVER_VERIFICATION(8),
    ORDER_RECEIPT(9),//D
    ORDER_DISPATCH(10),//D
    ORDER_DELIVERED(11),//D //heart
    ORDER_CANCELLED(12),//D
    CHAT(13),
    NOTIFICATION_DRIVER_WEEKLY_PAYMENT(14),
    NOTIFICATION_SUPPLIER_WEEKLY_PAYMENT(15),
    NOTIFICATION_MANUAL_STORE_PAYMENT(16),
    UNKNOWN_TYPE(17)
}