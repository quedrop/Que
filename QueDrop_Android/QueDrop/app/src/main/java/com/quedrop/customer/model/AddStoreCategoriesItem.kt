package com.quedrop.customer.model

data class AddStoreCategoriesItem(
    var secret_key: String,
    var access_key: String,
    var store_id: Int,
    var user_id: Int,
    var guest_user_id: Int,
    var is_fresh_produced: Int
)

data class StoreCategoryProduct(
    var store_category_id: Int,
    var store_category_title: String,
    var store_category_image: String,
    var is_active: String,
    var products: ArrayList<ProductDetails>,
    var fresh_produce_category_id: Int
)

data class OtherDetails(
    var total_items: String,
    var total_price: String
)

data class ProductDetails(
    var product_id: Int,
    var store_category_id: Int,
    var product_name: String,
    var product_image: String,
    var product_price: String,
    var product_description: String,
    var need_extra_fees: String,
    var extra_fees: String,
    var is_active: String,
    var is_product_selected: String,
    var header: Boolean = false,
    var has_addons: String,
    var product_option: ArrayList<ProductOption>,
    var store_category_title: String,
    var store_category_image: String
)