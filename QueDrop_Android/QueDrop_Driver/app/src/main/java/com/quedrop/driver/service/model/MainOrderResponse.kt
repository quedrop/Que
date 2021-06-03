package com.quedrop.driver.service.model

import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName

data class MainOrderResponse(
    @SerializedName("status") val status: Boolean,
    @SerializedName("message") val message: String? = "",
    @SerializedName("data") val data: Data
)

data class Data(

    @SerializedName("last_order_total_earning")
    @Expose
    val last_order_total_earning: Double,
    @SerializedName("today_total_earning")
    @Expose
    val today_total_earning: Double,
    @SerializedName("today_total_order")
    @Expose
    val today_total_order: Int,
    @SerializedName("last_order_date")
    @Expose
    val last_order_date: String? = "",

    @SerializedName("orders")
    @Expose
    val orders: MutableList<Orders>,
    @SerializedName("order_details")
    @Expose
    val singleOrders: Orders,
    @SerializedName("future_orders")
    @Expose
    val futureOrders: Orders,
    @SerializedName("billing_summary")
    @Expose
    val billingSummary: BillingSummary,
    @SerializedName("weekly_data")
    @Expose
    val weeklyData: MutableList<WeeklyData>,
    @SerializedName("reviews")
    @Expose
    val reviews: List<RateAndReviews>? = null,
    @SerializedName("future_order_dates")
    @Expose
    val futureOrderDates: MutableList<FutureOrderDates>? = null
)


data class Orders(
    @SerializedName("order_id") val orderId: Int,
    @SerializedName("is_advanced_order") val isAdvancedOrder: Int,
    @SerializedName("advance_order_datetime") val advanceOrderDatetime: String? = "",
    @SerializedName("order_status") val orderStatus: String? = "",
    @SerializedName("order_amount") val orderAmount: Double,
    @SerializedName("order_date") val orderDate: String? = "",
    @SerializedName("delivery_charge") val deliveryCharge: Double,
    @SerializedName("service_charge") val serviceCharge: Double,
    @SerializedName("order_total_amount") val orderTotalAmount: Double,
    @SerializedName("order_type") val orderType: String? = "",
    @SerializedName("driver_note") val driverNote: String? = "",
    @SerializedName("delivery_latitude") val deliveryLatitude: String = "",
    @SerializedName("delivery_longitude") val deliveryLongitude: String = "",
    @SerializedName("delivery_address") val deliveryAddress: String? = "",
    @SerializedName("rating") val rating: Double,
    @SerializedName("tip") val tip: Int,
    @SerializedName("shopping_fee") val shoppingFee: Double,
    @SerializedName("stores") val stores: MutableList<Stores>,
    @SerializedName("customer_detail") val customerDetail: Customer_detail,
    @SerializedName("request_date") val requestDate: String? = "",
    @SerializedName("billing_detail") val billingDetail: BillingData? = null,
    @SerializedName("is_payment_done") val isPaymentDone: String? = "",
    @SerializedName("delivery_option") val deliveryOption: String? = "",
    //recurring order

    @SerializedName("recurring_order_id") val recurringOrderId: Int,
    @SerializedName("delivery_time") val deliveryTime: Int,
    @SerializedName("recurring_time") val recurringTime: String? = "",
    @SerializedName("recurred_on") val recurredOn: String? = "",
    @SerializedName("recurring_type") val recurringType: String?,
    @SerializedName("repeat_until_date") val repeatUntilDate: String? = "",
    @SerializedName("recurring_order_entries") val recurringOrderEntries: MutableList<RecurringOrderEntries>
)

data class Products(

    @SerializedName("product_id") val productId: Int,
    @SerializedName("order_store_product_id") val orderStoreProductId: Int,
    @SerializedName("user_product_id") val userProductId: Int,
    @SerializedName("quantity") val quantity: Int,
    @SerializedName("product_name") val productName: String? = "",
    @SerializedName("product_image") val productImage: String? = "",
    @SerializedName("product_description") val productDescription: String? = "",
    @SerializedName("extra_fees") val extraFees: Double,
    @SerializedName("product_offer_id") val productOfferId: Int,
    @SerializedName("offer_percentage") val offerPercentage: Double,
    @SerializedName("option_id") val optionId: Int,
    @SerializedName("product_option") val productOption: MutableList<ProductOption>,
    @SerializedName("product_price") val productPrice: Double

    // @SerializedName("addons") val addons: MutableList<_root_ide_package_.kotlin.String?="=">
)

data class ProductOption(
    @SerializedName("option_id") var optionId: Int,
    @SerializedName("option_name") var optionName: String? = "",
    @SerializedName("price") var price: Double,
    @SerializedName("is_default") var isDefault: Int
)

data class Stores(

    @SerializedName("store_id") val storeId: Int,
    @SerializedName("can_provide_service") val canProvideService: Int,
    @SerializedName("store_name") val storeName: String? = "",
    @SerializedName("store_address") val storeAddress: String? = "",
    @SerializedName("latitude") val latitude: String = "0.0",
    @SerializedName("longitude") val longitude: String = "0.0",
    @SerializedName("store_logo") val storeLogo: String? = "",
    @SerializedName("user_store_id") val userStoreId: Int,
    @SerializedName("is_active") val isActive: Int,
    @SerializedName("order_amount") val orderAmount: Double,
    @SerializedName("admin_offer_id") val adminOfferId: Int,
    @SerializedName("offer_percentage") val offerPercentage: Double,
    @SerializedName("order_receipt") val orderReceipt: String? = "",
    @SerializedName("order_store_id") val orderStoreId: Int,
    @SerializedName("products") val products: MutableList<Products>
)

data class BillingData(

    @SerializedName("is_manual_store_available") val isManualStoreAvailable: Int? = 0,
    @SerializedName("registered_stores") val registeredStore: ArrayList<RegistedStore>? = null,
    @SerializedName("manual_stores") val manualStore: ArrayList<RegistedStore>? = null,
    @SerializedName("is_order_discount") val isOrderDiscount: String? = "",
    @SerializedName("order_discount") val orderDiscount: Float? = null,
    @SerializedName("is_coupon_discount") val isCouponDiscount: String? = "",
    @SerializedName("coupon_discount") val couponDiscount: Float? = null,
    @SerializedName("delivery_charge") val deliveryCharge: Float? = null,
    @SerializedName("service_charge") val serviceCharge: Float? = null,
    @SerializedName("shopping_fee") val shoppingFee: Float? = null,
    @SerializedName("total_pay") val totalPay: Float? = null,
    @SerializedName("tip") val tip: Float? = null,
    @SerializedName("driver_total_earn") val driverTotalEarn: Float? = null,
    @SerializedName("shopping_fee_driver") val shoppingFeeDriver: Float? = null
)

data class WeeklyData(

    @SerializedName("order_date") val orderDate: String? = "",
    @SerializedName("order_date_weekday") val orderDateWeekday: String? = "",
    @SerializedName("total_amount") val totalAmount: Double
)

data class BillingSummary(

    @SerializedName("is_payment_done") val isPaymentDone: Int,
    @SerializedName("total_delivery_earning") val totalDeliveryEarning: Double,
    @SerializedName("total_tip_earning") val totalTipEarning: Double,
    @SerializedName("total_shopping_earning") val totalShoppingEarning: Double,
    @SerializedName("total_amount") val totalAmount: Double,
    @SerializedName("total_referral_earning") val totalReferralEarning: Double
)

data class Customer_detail(

    @SerializedName("user_id") val userId: Int,
    @SerializedName("first_name") val firstName: String? = "",
    @SerializedName("last_name") val lastName: String? = "",
    @SerializedName("email") val email: String? = "",
    @SerializedName("user_image") val userImage: String? = "",
    @SerializedName("latitude") val latitude: Double,
    @SerializedName("longitude") val longitude: Double,
    @SerializedName("address") val address: String? = "",
    @SerializedName("country_code") val countryCode: Int,
    @SerializedName("phone_number") val phoneNumber: String? = "",
    @SerializedName("rating") val rating: Double
)

data class RateAndReviews(
    @SerializedName("user_id") var user_id: Int? = null,
    @SerializedName("review_id") var review_id: Int? = null,
    @SerializedName("review") var review: String? = "",
    @SerializedName("rating") var rating: Float? = null,
    @SerializedName("first_name") var first_name: String? = "",
    @SerializedName("last_name") var last_name: String? = "",
    @SerializedName("user_image") var user_image: String? = "",
    @SerializedName("user_name") var user_name: String? = "",
    @SerializedName("order_id") var order_id: Int? = null,
    @SerializedName("created_at") var created_at: String? = ""
)

data class RecurringOrderEntries(
    @SerializedName("recurring_entry_id") var recurring_entry_id: Int? = null,
    @SerializedName("order_place_datetime") var order_place_datetime: String? = "",
    @SerializedName("order_delivery_datetime") var order_delivery_datetime: String? = "",
    @SerializedName("driver_id") var driver_id: Int? = 0,
    @SerializedName("recurring_type") var recurring_type: String? = "",
    @SerializedName("recurring_time") var recurring_time: String? = "",
    @SerializedName("rejected_drivers") var rejected_drivers: String? = "",
    @SerializedName("is_accepted") var is_accepted: Int? = 0
)

data class FutureOrderDates(
    @SerializedName("future_order_date") var futureOrderDates: String? = ""
)
