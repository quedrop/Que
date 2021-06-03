package com.quedrop.customer.model

import java.io.Serializable

data class AddStoreDetails(
    var secret_key: String,
    var access_key: String,
    var store_id: Int,
    var user_id: Int
)

data class GetStoreDetails(
    var store_id: Int,
    var service_category_id: Int,
    var user_id: Int,
    var store_name: String,
    var store_address: String,
    var latitude: String,
    var longitude: String,
    var store_logo: String,
    var can_provide_service: String,
    var is_active: String,
    var store_rating: String,
    var is_favourite: Boolean,
    var slider_images: ArrayList<SliderImages>,
    var food_category: ArrayList<FoodCategory>,
    var schedule: ArrayList<Schedule>
)

data class SliderImages(
    var slider_image_id: Int,
    var slider_image: String
)

data class FoodCategory(
    var store_category_id: Int,
    var store_category_title: String,
    var store_category_image: String,
    var is_active: String,
    var fresh_produce_category_id: Int
)

data class FreshProduceCategory(
    var store_category_id: Int,
    var store_category_title: String,
    var store_category_image: String,
    var is_active: String,
    var fresh_produce_category_id: Int
)

data class FreshProduce(
    var fresh_category_id: Int,
    var fresh_produce_title: String,
    var fresh_produce_image: String
): Serializable

data class Schedule(
    var schedule_id: Int,
    var opening_time: String,
    var closing_time: String,
    var weekday: String,
    var is_closed: Int

)

data class SetFavourite(
    var secret_key: String,
    var access_key: String,
    var store_id: Int,
    var user_id: Int,
    var is_favourite: String
)

data class GetFavourite(
    var secret_key: String,
    var access_key: String,
    var store_id: Int,
    var user_id: Int,
    var is_favourite: String
)

data class FavoriteStoresRequest(
    var secret_key: String,
    var access_key: String,
    var user_id: Int
)

data class GetFavouriteStores(
    var store_id: Int,
    var store_name: String,
    var store_address: String,
    var store_logo: String,
    var latitude: String,
    var longitude: String,
    var can_provide_service: String
)