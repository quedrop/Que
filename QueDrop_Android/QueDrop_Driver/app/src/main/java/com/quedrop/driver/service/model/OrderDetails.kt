package com.quedrop.driver.service.model


import android.os.Parcel
import android.os.Parcelable
import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName


class OrderDetails {
    @SerializedName("order_details")
    val orderDetail: OrderDetail? = null
    @SerializedName("status")
    @Expose
    val status: Boolean? = null
    @SerializedName("message")
    @Expose
    val message: String? = null
}

class OrderDetail() : Parcelable {
    @SerializedName("order_id")
    val orderId: String? = ""

    @SerializedName("is_advance_order")
    val isAdvanceOrder: String? = ""

    @SerializedName("advance_order_datetime")
    val advanceOrderDatetime: String? = null

    @SerializedName("order_status")
    val orderStatus: String? = null

    @SerializedName("order_amount")
    val orderAmount: Double? = null

    @SerializedName("order_date")
    val orderDate: String? = null

    @SerializedName("request_date")
    val requestDate: String? = null

    @SerializedName("delivery_charge")
    val deliveryCharge: Int? = null

    @SerializedName("service_charge")
    val serviceCharge: Int? = null

    @SerializedName("order_total_amount")
    val orderTotalAmount: Double? = null

    @SerializedName("order_type")
    val orderType: String? = null

    @SerializedName("user_id")
    val userId: Int? = null

    @SerializedName("driver_note")
    val driverNote: String? = null

    @SerializedName("delivery_latitude")
    val deliveryLatitude: String? = null

    @SerializedName("delivery_longitude")
    val deliveryLongitude: String? = null

    @SerializedName("delivery_address")
    val deliveryAddress: String? = null

    @SerializedName("rating")
    val rating: Float? = null

    @SerializedName("customer_detail")
    val customerDetail: CustomerDetail? = null

    @SerializedName("stores")
    val storeDetail: MutableList<StoreDetail>? = null

    @SerializedName("billing_detail")
    val billingDetail: BillingDetail? = null


    constructor(parcel: Parcel) : this() {
    }

    override fun writeToParcel(parcel: Parcel, flags: Int) {

    }

    override fun describeContents(): Int {
        return 0
    }

    companion object CREATOR : Parcelable.Creator<OrderDetail> {
        override fun createFromParcel(parcel: Parcel): OrderDetail {
            return OrderDetail(parcel)
        }

        override fun newArray(size: Int): Array<OrderDetail?> {
            return arrayOfNulls(size)
        }
    }
}


class CustomerDetail {
    @SerializedName("user_id")
    val userId: String? = null

    @SerializedName("first_name")
    val firstName: String? = null

    @SerializedName("last_name")
    val lastName: String? = null

    @SerializedName("user_name")
    val userName: String? = null

    @SerializedName("email")
    val email: String? = null

    @SerializedName("user_image")
    val userImage: String? = null

    @SerializedName("country_code")
    val countryCode: Int? = null

    @SerializedName("phone_number")
    val phoneNumber: String? = null

    @SerializedName("rating")
    val rating: String = ""

    @SerializedName("latitude")
    val latitude: String? = null

    @SerializedName("longitude")
    val longitude: String? = null

    @SerializedName("address")
    val address: String? = null
}


class StoreDetail {
    @SerializedName("order_store_id")
    val orderStoreId: Int? = null

    @SerializedName("order_id")
    val orderId: Int? = null

    @SerializedName("store_id")
    val storeId: Int? = null

    @SerializedName("user_store_id")
    val userStoreId: Int? = null

    @SerializedName("is_active")
    val isActive: Int? = null


    @SerializedName("order_amount")
    val orderAmount: Double? = null

    @SerializedName("admin_offer_id")

    val adminOfferId: Int? = null
    @SerializedName("offer_percentage")

    val offerPercentage: Int? = null
    @SerializedName("order_receipt")

    val orderReceipt: String? = null
    @SerializedName("is_testdata")

    val isTestdata: Int? = null
    @SerializedName("is_delete")

    val isDelete: Int? = null
    @SerializedName("created_at")

    val createdAt: String? = null
    @SerializedName("updated_at")
    val updatedAt: String? = null

    @SerializedName("store_name")
    val storeName: String? = null

    @SerializedName("store_address")
    val storeAddress: String? = null

    @SerializedName("latitude")
    val latitude: String? = null

    @SerializedName("longitude")
    val longitude: String? = null

    @SerializedName("store_logo")
    val storeLogo: String? = null

    @SerializedName("can_provide_service")
    val canProvideService: Int? = null

    @SerializedName("products")
    val products: List<Product>? = null

}

class Product {
    @SerializedName("product_id")
    val productId: Int? = null

    @SerializedName("order_store_product_id")
    val orderStoreProductId: Int? = null

    @SerializedName("user_product_id")
    val userProductId: Int? = null

    @SerializedName("quantity")
    val quantity: Int? = null

    @SerializedName("product_name")
    val productName: String? = null

    @SerializedName("product_image")
    val productImage: String? = null

    @SerializedName("product_description")
    val productDescription: String? = null

    @SerializedName("extra_fees")
    val extraFees: Int? = null

    @SerializedName("product_offer_id")
    val productOfferId: Int? = null

    @SerializedName("offer_percentage")
    val offerPercentage: Int? = null

    @SerializedName("option_id")
    val optionId: Int? = null

    @SerializedName("product_price")
    val productPrice: Int? = null

    @SerializedName("addons")
    @Expose
    private val addons: List<Addon>? = null
}

class BillingDetail {

    @SerializedName("is_manual_store_available")
    val isManualStoreAvailable: Int? = 0

    @SerializedName("registered_stores")
    val registeredStore: ArrayList<RegistedStore>? = null

    @SerializedName("manual_stores")
    val manualStore: ArrayList<RegistedStore>? = null

    @SerializedName("is_order_discount")
    val isOrderDiscount: String? = ""

    @SerializedName("order_discount")
    val orderDiscount: Float? = null

    @SerializedName("is_coupon_discount")
    val isCouponDiscount: String? = ""

    @SerializedName("coupon_discount")
    val couponDiscount: Float? = null

    @SerializedName("delivery_charge")
    val deliveryCharge: Float? = null

    @SerializedName("service_charge")
    val serviceCharge: Float? = null

    @SerializedName("shopping_fee")
    val shoppingFee: Float? = null

    @SerializedName("total_pay")
    val totalPay: Float? = null

}

class RegistedStore() {
    @SerializedName("store_name")
    val storeName: String? = ""

    @SerializedName("is_store_offer")
    val isStoreOffer: String? = ""

    @SerializedName("store_amount")
    val storeAmount: Float? = null

    @SerializedName("store_discount")
    val storeDiscount: Float? = null

    @SerializedName("store_final_amount")
    val storeFinalAmount: Float? = null


}


class Addon {
    @SerializedName("addon_name")
    @Expose
    private val addonName: String? = null
    @SerializedName("addon_id")
    @Expose
    private val addonId: Int? = null
    @SerializedName("addon_price")
    @Expose
    private val addonPrice: Int? = null
}