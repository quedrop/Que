package com.quedrop.customer.network

import com.quedrop.customer.model.*
import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName

data class ResponseWrapper(
    var guest_user: GuestUser,
    var addresses: ArrayList<Address>,
    var getCustomerAddress: ArrayList<Address>,
    var editAddress: ArrayList<Address>,
    var deleteAddress: Unit,
    var service_categories: ArrayList<Categories>,
    var stores: ArrayList<NearByStores>,
    var store_offer: ArrayList<StoreOfferList>,
    var product_offer: ArrayList<ProfuctOfferList>,
    var order_offer: ArrayList<OrderOffer>,
    var fresh_produce_categories: ArrayList<FreshProduceCategories>,
    var favouriteStore: Unit,

    @SerializedName("store_detail")
    var store_detail: GetStoreDetails,
    var categories: ArrayList<StoreCategoryProduct>,
    var other_detail: OtherDetails,
    var product_info: ProductAddOns,
    var addItem: Unit,

    var user_store: AddUserStore,
    var cart_items: ArrayList<UserCart>,
    var amount_details: AmountDetails,
    var deleteCartItem: Unit,
    var deleteProductFromCart: Unit,
    var updateCartQuantity: Unit,
    var cartCustomise: Unit,
    var user: User,
    @SerializedName("is_user_available")
    @Expose
    var isUserAvailable: Int? = null,

    var otpMessage: Unit,
    var otpVerifyMessage: Unit,
    var driver_ids: String,
    var order_id: String,
    var recurring_order_id: String,
    var server_time: String,
    var user_products: UserProductResponse,
    var current_order: ArrayList<GetCurrentOrderResponse>,
    var past_order: ArrayList<GetCurrentOrderResponse>,
    var recurring_types: ArrayList<GetRecurringTypeResponse>,
    var cart_term_notes: ArrayList<NotesResponse>,
    var coupons: ArrayList<GetCouponCodeResponse>,
    var order_details: GetSingleOrderDetailsResponse,
    var order_billing_details: GetConfirmOrderDetails,
    var rateReviewMessage: Unit,
    var submitOrderQuery: Unit,
    var changePasswordMessage: Unit,
    var reviews: ArrayList<RateReviewResponse>,
    var apple_pay_secret: GooglePayResponse,

    //Explore
    var explore_stores: MutableList<StoreSingleDetails>,
    var products: MutableList<SupplierProduct>

)





