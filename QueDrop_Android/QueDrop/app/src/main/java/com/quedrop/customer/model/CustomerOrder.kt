package com.quedrop.customer.model

import java.io.Serializable

data class CurrentOrderRequest(
    var secret_key: String,
    var access_key: String,
    var user_id: Int,
    var is_for_current: String
)

data class GetCurrentOrderResponse(
    var order_id: Int,
    var is_advanced_order: String,
    var advance_order_datetime: String,
    var order_status: String,
    var order_amount: String,
    var order_date: String,
    var updated_server_time: String,
    var delivery_charge: String,
    var service_charge: String,
    var order_total_amount: String,
    var rating: String,
    var timer_value: Long,
    var server_time: String,
    var delivery_option: String,
    var stores: ArrayList<StoreDetailsOrder>
)

data class StoreDetailsOrder(

    var store_id: Int,
    var store_name: String,
    var store_address: String,
    var latitude: String,
    var longitude: String,
    var store_logo: String,
    var can_provide_service: String,
    var is_active: String,
    var user_store_id: Int,
    var products: ArrayList<ProductDetailsOrder>
)

data class ProductDetailsOrder(

    var product_id: Int,
    var order_store_product_id: String,
    var user_product_id: String,
    var quantity: String,
    var product_name: String,
    var product_image: String,
    var product_description: String,
    var extra_fees: String,
    var product_offer_id: String,
    var offer_percentage: String,
    var option_id: Int,
    var product_option: ArrayList<ProductOption>,
    var product_price: String,
    var addons: ArrayList<AddOns>
)

data class SingleOrderDetails(
    var secret_key: String,
    var access_key: String,
    var user_id: Int,
    var order_id: Int
)

data class GetSingleOrderDetailsResponse(
    var order_id: Int,
    var is_advanced_order: String,
    var advance_order_datetime: String,
    var order_status: String,
    var order_amount: String,
    var order_date: String,
    var delivery_charge: String,
    var service_charge: String,
    var order_total_amount: String,
    var order_type: String,
    var user_id: Int,
    var driver_note: String,
    var delivery_latitude: String,
    var delivery_longitude: String,
    var delivery_address: String,
    var timer_value: Int,
    var stores: ArrayList<StoreSingleDetails>,
    var driver_detail: DriverDetails,
    var customer_detail: CustomerDetails,
    var billing_detail: BillingDetails,
    var updated_server_time: String,
    var delivery_option: String
)

//ZPPP added fresh_produce_category_id
data class StoreSingleDetails(
    var store_id: Int,
    var can_provide_service: String,
    var store_name: String,
    var store_address: String,
    var latitude: String,
    var longitude: String,
    var store_logo: String,
    var user_store_id: String,
    var is_active: String,
    var order_amount: String,
    var admin_offer_id: String,
    var offer_percentage: String,
    var order_receipt: String,
    var fresh_produce_category_id: Int,
    var products: ArrayList<ProductDetailsOrder>

)

data class DriverDetails(
    var user_id: Int,
    var first_name: String,
    var last_name: String,
    var email: String,
    var user_image: String,
    var latitude: String = "0.0",
    var longitude: String = "0.0",
    var address: String,
    var country_code: String,
    var phone_number: String,
    var rating: String
) : Serializable

data class CustomerDetails(
    var user_id: Int,
    var first_name: String,
    var last_name: String,
    var email: String,
    var user_image: String,
    var latitude: String,
    var longitude: String,
    var address: String,
    var country_code: String,
    var phone_number: String,
    var rating: String
) : Serializable


data class BillingDetails(
    var is_manual_store_available: String,
    var registered_stores: ArrayList<RegisteredStore>,
    var manual_stores: ArrayList<ManualStore>,
    var is_order_discount: String,
    var order_discount: String,
    var is_coupon_discount: String,
    var coupon_discount: String,
    var delivery_charge: String,
    var service_charge: String,
    var shopping_fee: String,
    var total_pay: String
)


data class GetConfirmOrderDetails(
    var store_receipts: ArrayList<String>,
    var driver_detail: DriverDetails,
    var customer_detail: CustomerDetails,
    var billing_detail: BillingDetails
)

data class RegisteredStore(
    var store_name: String,
    var is_store_offer: String,
    var store_amount: String,
    var store_discount: String,
    var store_final_amount: String
)

data class ManualStore(
    var store_name: String,
    var is_store_offer: String,
    var store_amount: String,
    var store_discount: String,
    var store_final_amount: String
)

data class GetRateReview(
    var secret_key: String,
    var access_key: String,
    var to_user_id: Int,
    var from_user_id: Int,
    var rating: String,
    var review: String,
    var order_id: Int
)

data class GetCustomerSupprt(
    var secret_key: String,
    var access_key: String,
    var order_id: Int,
    var query: String
)

data class RescheduleOrder(
    var secret_key: String,
    var access_key: String,
    var order_id: Int
)

data class GooglePayRequest(
    var secret_key: String,
    var access_key: String,
    var user_id: Int,
    var order_id: Int,
    var amount: Float,
    var payment_method_nonce: String,
    var client_device_data: String,
    var postal_code: String? = ""
)

data class ExploreSearchRequest(
    var secret_key: String,
    var access_key: String,
    var searchText: String
)