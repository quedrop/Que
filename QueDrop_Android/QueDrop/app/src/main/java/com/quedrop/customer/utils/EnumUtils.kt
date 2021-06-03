package com.quedrop.customer.utils

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

    ORDER_REQUEST(1),
    ORDER_ACCEPT(2),
    ORDER_REJECT(3),
    ORDER_REQUEST_TIMEOUT(4),
    RECURRING_ORDER_PLACED(5),
    RATING(6),
    NEAR_BY_PLACE(7),
    DRIVER_VERIFICATION(8),
    ORDER_RECEIPT(9),
    ORDER_DISPATCH(10),
    ORDER_DELIVERED(11),
    ORDER_CANCELLED(12),
    CHAT(13),
    NOTIFICATION_DRIVER_WEEKLY_PAYMENT(14),
    NOTIFICATION_SUPPLIER_WEEKLY_PAYMENT(15),
    NOTIFICATION_MANUAL_STORE_PAYMENT(16),
    NOTIFICATION_SUPPLIER_STORE_VERIFICATION(19),
    UNKNOWN_TYPE(17)

}

enum class EnumHomeOfferCategoriesList(val posVal: Int) {
    PAYMENT_OFFER_LIST(0),
    PRODUCT_OFFER_LIST(1),
    RESTAURANT_LIST(2),
    FRESH_PRODUCE_LIST(3),
    ALL_CATEGORIES_LIST(4)
}

enum class EnumExploreCategoriesList(val posVal: Int) {
    STORE_LIST(0),
    PRODUCT_LIST(1)
}


enum class EnumOfferUtils(val stringVal: String) {
    FreeDelivery("FreeDelivery"),
    FreeServiceCharge("FreeServiceCharge"),
    Delivery("Delivery"),
    ServiceCharge("ServiceCharge"),
    Discount("Discount")
}
