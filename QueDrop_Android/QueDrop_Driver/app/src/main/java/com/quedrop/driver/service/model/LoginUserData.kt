package com.quedrop.driver.service.model

import android.os.Parcelable
import androidx.annotation.Keep
import com.google.gson.annotations.Expose

import com.google.gson.annotations.SerializedName
import kotlinx.android.parcel.Parcelize


@Keep
class LoginResponse {
    @SerializedName("userToken")
    @Expose
    var userToken: String? = null

    @SerializedName("status")
    @Expose
    var status: Boolean? = null

    @SerializedName("message")
    @Expose
    var message: String? = null

    @SerializedName("data")
    @Expose
    var data: MainData? = null
}

@Keep
class MainData {

    @SerializedName("user")
    @Expose
    var user: User? = null

    @SerializedName("is_user_available")
    @Expose
    var isUserAvailable: Int? = null
}

@Keep
class User {
    @SerializedName("user_id")
    @Expose
    var userId: Int? = null

    @SerializedName("first_name")
    @Expose
    var firstName: String? = null

    @SerializedName("last_name")
    @Expose
    var lastName: String? = null

    @SerializedName("user_name")
    @Expose
    var userName: String? = null

    @SerializedName("email")
    @Expose
    var email: String? = null

    @SerializedName("password")
    @Expose
    var password: String? = null

    @SerializedName("user_image")
    @Expose
    var userImage: String? = null

    @SerializedName("login_as")
    @Expose
    var loginAs: String? = null

    @SerializedName("login_type")
    @Expose
    var loginType: String? = null

    @SerializedName("social_key")
    @Expose
    var socialKey: Any? = null

    @SerializedName("country_code")
    @Expose
    var countryCode: Int? = null

    @SerializedName("phone_number")
    @Expose
    var phoneNumber: String? = null

    @SerializedName("is_phone_verified")
    @Expose
    var isPhoneVerified: Int? = null

    @SerializedName("is_driver_verified")
    @Expose
    var isDriverVerified: Int? = null

    @SerializedName("refferal_code")
    @Expose
    var refferalCode: String? = null

    @SerializedName("offset")
    @Expose
    var offset: String? = null

    @SerializedName("device_token")
    @Expose
    var deviceToken: String? = null

    @SerializedName("latitude")
    @Expose
    var latitude: String = ""

    @SerializedName("longitude")
    @Expose
    var longitude: String = ""

    @SerializedName("address")
    @Expose
    var address: String? = null

    @SerializedName("active_status")
    @Expose
    var activeStatus: Int? = null

    @SerializedName("guid")
    @Expose
    var guid: String? = null

    @SerializedName("driver_status")
    @Expose
    var driverStatus: Int? = null

    @SerializedName("is_guest")
    @Expose
    var isGuest: Int? = null

    @SerializedName("google_key")
    @Expose
    var googleKey: String? = null

    @SerializedName("rating")
    @Expose
    var rating: String? = null

    @SerializedName("is_identity_detail_uploaded")
    @Expose
    var isIdentityDetailUploaded: Int? = null

}

@Parcelize
data class ReceiverUser(
    val userId: Int,
    val userName: String? = null,
    val userImagePath: String? = null,
    val orderStatus: String? = null,
    val orderId: Int? = null
) : Parcelable