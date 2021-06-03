package com.quedrop.customer.model

data class AddNearByStores(
    var secret_key: String,
    var access_key: String,
    var service_category_id: Int,
    var latitude: String,
    var longitude: String
)

data class NearByStores(
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
    var schedule: ArrayList<Schedule>,
    var fresh_produce_category_id: Int
)

data class SearchStoreByName(
    var secret_key: String,
    var access_key: String,
    var searchText: String,
    var service_category_id: Int,
    var fresh_produce_category_id: Int
)
