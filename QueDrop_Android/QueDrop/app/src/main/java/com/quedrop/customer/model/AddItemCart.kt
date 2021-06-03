package com.quedrop.customer.model

data class AddItemCart(
    var secret_key: String,
    var access_key: String,
    var user_id: Int,
    var store_id: Int,
    var user_store_id: Int,
    var product_id: Int,
    var user_product_id: Int,
    var quantity: String,
    var addons: MutableList<AddOns>,
    var option_id: Int,
    var guest_user_id: Int
)

data class CustomiseCart(
    var secret_key: String,
    var access_key: String,
    var cart_product_id: Int,
    var addons: MutableList<AddOns>,
    var option_id: Int,
    var latitude: String,
    var longitude: String,
    var coupon_code: String,
    var user_id: Int,
    var guest_user_id: Int,
    var delivery_option:String
)

data class GetRecurringRequest(
    var secret_key: String,
    var access_key: String
)

data class GetRecurringTypeResponse(
    var recurring_type_id: Int,
    var recurring_type: String
)

data class GetCouponRequest(
    var secret_key: String,
    var access_key: String,
    var user_id: Int
)

data class GetCouponCodeResponse(
    var admin_offer_id: Int,
    var offer_description: String,
    var coupon_code: String,
    var offer_range: String,
    var discount_percentage: String,
    var offer_on: String,
    var offer_type: String,
    var store_id: Int,
    var start_date: String,
    var expiration_date: String
)

data class ApplyCouponCodeRequest(
    var secret_key: String,
    var access_key: String,
    var user_id: Int,
    var latitude: String,
    var longitude: String,
    var coupon_code: String,
    var total_items_price: String,
    var guest_user_id: Int
)
