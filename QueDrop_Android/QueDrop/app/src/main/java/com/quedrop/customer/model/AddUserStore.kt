package com.quedrop.customer.model

import java.io.Serializable

data class AddUserStore(

    var user_store_id:Int,
    var user_id:Int,
    var store_name:String,
    var store_address:String,
    var latitude:String,
    var longitude:String,
    var store_description:String,
    var store_logo:String,
    var slider_images:SliderImages1,
    var food_category:FoodCategory1,
    var schedule:Schedule1,
    var store_rating:String,
    var is_active:String,
    var can_provide_service:String,
    var service_category_id:Int,
    var is_favourite:String
):Serializable

data class SliderImages1(
    var slider_image_id: Int,
    var slider_image: String
):Serializable

data class FoodCategory1(
    var store_category_id: Int,
    var store_category_title: String,
    var store_category_image: String,
    var is_active: String
):Serializable

data class Schedule1(
    var schedule_id: Int,
    var opening_time: String,
    var closing_time: String,
    var weekday: String
):Serializable