package com.quedrop.customer.model

data class PlaceOrder(
    var secret_key:String,
    var access_key:String,
    var user_id:Int,
    var delivery_latitude:String,
    var delivery_longitude:String,
    var delivery_address:String,
    var driver_note:String,
    var payment_type_id:Int,
    var coupon_code:String,
    var timezone:String,
    var is_recurring_order:String,
    var recurring_type_id:Int,
    var recurred_on:String,
    var recurring_time:String,
    var label:String,
    var repeat_until_date:String,
    var delivery_option:String
)

data class ResponsePlaceOrder(
    var driver_ids:Int,
    var order_id:Int,
    var recurring_order_id:Int
)