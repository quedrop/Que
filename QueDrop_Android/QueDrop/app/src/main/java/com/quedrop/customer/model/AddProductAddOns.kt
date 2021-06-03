package com.quedrop.customer.model

data class AddProductAddOns(
    var secret_key:String,
    var access_key:String,
    var product_id:Int
)



data class ProductAddOns(
    var product_id:Int,
    var store_category_id:Int,
    var product_name:String,
    var product_image:String,
    var product_price:String,
    var product_description:String,
    var need_extra_fees:String,
    var extra_fees:String,
    var is_active:String,
    var addons:ArrayList<AddOns>,
    var product_option:ArrayList<ProductOption>
)

data class AddOns(
    var addon_id:Int,
    var addon_name:String,
    var addon_price:String
)



