package com.quedrop.customer.model

import java.io.Serializable

data class SupplierStoreDetail(
    var store_id: Int,
    var service_category_id: Int,
    var user_id: Int,
    var store_name: String,
    var store_address: String,
    var latitude: String,
    var longitude: String,
    var store_logo: String,
    var can_provide_service: Int,
    var is_active: Int,
    var store_rating: String,
    var is_favourite: Boolean,
    var slider_images: ArrayList<StoreImages>,
    var schedule: ArrayList<StoreSchedule>,
    var food_category: ArrayList<StoreFoodCategory>,
    var service_category_name:String = ""
) : Serializable

data class StoreImages(
    var slider_image_id: Int,
    var slider_image: String
) : Serializable

data class StoreSchedule(
    var schedule_id: Int,
    var opening_time: String,
    var closing_time: String,
    var weekday: String,
    var is_closed: Int

):Serializable

data class StoreFoodCategory(
    var store_category_id: Int,
    var store_category_title: String,
    var store_category_image: String,
    var is_active: String
):Serializable