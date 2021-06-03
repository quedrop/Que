package com.quedrop.customer.model

import java.io.Serializable

data class SupplierOrder(
    var order_store_id: Int,
    var order_id: Int,
    var created_at: String,
    var order_status: String,
    var order_amount: String,
    var driver_id: Int,
    var user_store_id: Int,
    var customer_id: Int,
    var latitude: String,
    var longitude: String,
    var distance: String,
    var driver_detail: DriverDetails,
    var customer_detail: CustomerDetails,
    var products: ArrayList<ProductOrder>
) : Serializable

data class ProductOrder(
    var product_id: Int,
    var order_store_product_id: Int,
    var user_product_id: Int,
    var quantity: Int,
    var product_name: String,
    var product_image: String,
    var product_description: String,
    var extra_fees: Int,
    var product_offer_id: Int,
    var offer_percentage: Int,
    var option_id: Int,
    var product_price: Int,
    var addons: ArrayList<SupplierAddOn>,
    var product_option: ArrayList<SupplierProductOptions>

) : Serializable

data class WeeklyData(
    val order_date: String,
    val order_date_weekday: String,
    val total_amount: Double
) : Serializable

data class BillingSummary(
    val is_payment_done: Int,
    val total_amount: Double
) : Serializable


