package com.quedrop.customer.model

import android.net.Uri

data class UserAddProduct(
    var is_user_added_store:String,
    var store_id:Int,
    var user_store_id:Int,
    var user_id:Int,
    var product_name:String,
    var product_description:String,
    var secret_key:String,
    var access_key:String,
    var product_image:String
)

data class AddOrder(

    var product_name:String,
    var qty:String,
    var image_name:String,
    var image_path:String,
    var image_uri:Uri,
    var user_product_id:Int,
    var product_Flag:Boolean = false

)

data class Products(

    var product_name:String,
    var product_qty:String,
    var image_name:String

)