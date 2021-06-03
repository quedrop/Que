package com.quedrop.customer.model

data class OfferList(
    var secret_key: String,
    var access_key: String
)

data class StoreOfferList(
    var admin_offer_id: String,
    var offer_description: String,
    var coupon_code: String,
    var discount_price: String,
    var discount_percentage: String,
    var offer_type: String,
    var store_id: Int,
    var start_date: String,
    var expiration_date: String,
    var store_logo: String,
    var store_name: String,
    var latitude: String,
    var longitude: String,
    var store_rating: String

)

data class ProfuctOfferList(
    var product_offer_id: Int,
    var store_id: Int,
    var store_category_id: Int,
    var product_id: Int,
    var offer_percentage: String,
    var offer_code: String,
    var start_date: String,
    var start_time: String,
    var expiration_date: String,
    var expiration_time: String,
    var additional_info: String,
    var is_active: String,
    var product_name: String,
    var product_image: String,
    var store_name: String,
    var latitude: String,
    var longitude: String,
    var store_category_title: String
)

data class OrderOffer(
    var admin_offer_id: Int,
    var offer_description: String,
    var coupon_code: String,
    var offer_range: Int,
    var discount_percentage: Int,
    var offer_on: String,
    var offer_type: String,
    var start_date: String,
    var expiration_date: String,
    var discount_amount: Int
)

data class FreshProduceCategories(
    var fresh_category_id: Int,
    var fresh_produce_title: String,
    var fresh_produce_image: String
)

