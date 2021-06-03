package com.quedrop.customer.model

import java.io.Serializable

//zp change 06/10
data class SupplierProduct(
    var product_id: String,
    var store_category_id: String,
    var product_name: String,
    var product_image: String,
    var product_price: String,
    var product_description: String,
    var need_extra_fees: String,
    var extra_fees: String,
    var is_active: Int,
    var addons: ArrayList<SupplierAddOn>,
    var product_option: ArrayList<SupplierProductOptions>,
    var store_id: Int,
    var fresh_produce_category_id: Int
):Serializable

data class SupplierAddOn(
    var addon_id: String,
    var addon_name: String,
    var addon_price: String
):Serializable

data class SupplierProductOptions(
    var option_id: String,
    var option_name: String,
    var price: String,
    var is_default: Int
):Serializable

data class SupplierProductOffer(
    var product_offer_id:Int,
    var store_id:Int,
    var store_category_id:Int,
    var product_id:Int,
    var offer_percentage:String,
    var offer_code:String,
    var start_date:String,
    var start_time:String,
    var expiration_date:String,
    var expiration_time:String,
    var additional_info:String,
    var is_active:Int,
    var product_name:String,
    var product_image:String,
    var store_name:String,
    var latitude:String,
    var longitude:String,
    var store_category_title:String
):Serializable
