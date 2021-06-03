package com.quedrop.customer.model

data class AddUserCart(
    var secret_key: String,
    var access_key: String,
    var user_id: Int,
    var latitude: String,
    var longitude: String,
    var coupon_code: String,
    var guest_user_id: Int,
    var delivery_option:String
)

data class UserCart(
    var cart_id: Int,
    var store_details: StoreDetails,
    var products: MutableList<Product>
)

data class StoreDetails(
    var store_id: Int,
    var store_name: String,
    var store_address: String,
    var latitude: String,
    var longitude: String,
    var store_logo: String,
    var can_provide_service: String,
    var is_active: String,
    var user_store_id: Int,
    var store_offer: StoreOffer,
    var schedule: ArrayList<Schedule>,
    var store_total_amount: String
)



data class StoreOffer(
    var admin_offer_id: Int,
    var offer_description: String,
    var coupon_code: String,
    var offer_range: String,
    var discount_percentage: String,
    var offer_on: String,
    var offer_type: String,
    var store_id: Int,
    var start_date: String,
    var expiration_date: String,
    var is_active: String
)

data class ProductOffer(
    var product_offer_id: Int,
    var offer_percentage: String,
    var offer_code: String,
    var start_date: String,
    var start_time: String,
    var expiration_date: String,
    var expiration_time: String,
    var additional_info: String,
    var is_active: String
)

data class ProductOption(
    var option_id: Int,
    var option_name: String,
    var price: String,
    var is_default: String
)

data class AmountDetails(

    var delivery_charge: String,
    var service_charge: String,
    var total_delivery_time: String,
    var total_items_price: String,
    var order_discount_value: String,
    var shopping_fee: String,
    var coupon_applied_on_delivery: String,
    var coupon_applied_on_service_charge: String,
    var is_coupon_applied: String,
    var coupon_discount_price: String,
    var grand_total: String
)


data class DeleteCartItem(
    var secret_key: String,
    var access_key: String,
    var cart_id: Int,
    var user_id: Int,
    var latitude: String,
    var longitude: String,
    var coupon_code: String,
    var guest_user_id: Int,
    var delivery_option:String
)

data class UpdateCartQuantity(
    var secret_key: String,
    var access_key: String,
    var quantity: String,
    var user_id: Int,
    var cart_product_id: Int,
    var latitude: String,
    var longitude: String,
    var coupon_code: String,
    var guest_user_id: Int,
    var delivery_option:String
)

data class DeleteProductFromCartItem(
    var secret_key: String,
    var access_key: String,
    var cart_id: Int,
    var user_id: Int,
    var cart_product_id: Int,
    var latitude: String,
    var longitude: String,
    var coupon_code: String,
    var guest_user_id: Int,
    var delivery_option:String
)

data class Product(
    var product_id: Int,
    var cart_product_id: Int,
    var user_product_id: Int,
    var quantity: String,
    var product_name: String,
    var product_image: String,
    var product_description: String,
    var need_extra_fees: String,
    var extra_fees: String,
    var addons: MutableList<AddOns>,
    var offer: ProductOffer,
    var product_original_price: String,
    var product_final_price: String,
    var option_id: Int,
    var product_option: MutableList<ProductOption>,
    var has_addons:String

)

data class AddUserProductFromCartRequest(
    var secret_key: String,
    var access_key: String,
    var user_id: Int,
    var user_store_id: Int,
    var store_id: Int
)

data class UserProductResponse(
    var store_id: Int,
    var store_name: String,
    var store_address: String,
    var latitude: String,
    var longitude: String,
    var store_logo: String,
    var can_provide_service: String,
    var is_active: String,
    var user_store_id: String,
    var store_offer: StoreOffer,
    var products: MutableList<UserAddedProducts>

)


data class UserAddedProducts(
    var product_id: String,
    var cart_product_id: Int,
    var user_product_id: Int,
    var quantity: String,
    var product_name: String,
    var product_image: String,
    var product_description: String,
    var need_extra_fees: String,
    var extra_fees: String,
    var addons: MutableList<AddOns>,
    var offer: ProductOffer,
    var product_original_price: String,
    var product_final_price: String,
    var option_id: Int,
    var product_option: MutableList<ProductOption>
)