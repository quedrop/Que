package com.quedrop.customer.model

import android.os.Parcelable
import kotlinx.android.parcel.Parcelize

data class AddGuestRegister(

    var secret_key:String,
    var access_key:String,
    var name:String,
    var uuid:String,
    var device_type:String,
    var device_token:String,
    var latitude:String,
    var longitude:String,
    var address:String
)

data class GuestUser(
    var guest_user_id:Int,
    var is_guest:Int
)

data class GetUserProfileDetailRequest(
    var secret_key:String,
    var access_key:String,
    var user_id:Int
)

data class User(
    var user_id : Int,
    var first_name : String,
    var last_name : String,
    var user_name : String,
    var email : String,
    var password :String,
    var user_image :String,
    var login_as:String,
    var login_type:String,
    var social_key:String,
    var country_code:String,
    var phone_number:String,
    var is_phone_verified:String,
    var is_driver_verified:String,
    var refferal_code:String,
    var offset:String,
    var device_token:String,
    var latitude:String,
    var longitude:String,
    var address:String,
    var active_status :Int,
    var guid:String,
    var driver_status:String,
    var is_guest:Int,
    var rating:String,
    var store_id:Int
)

@Parcelize
data class ReceiverUser(
    val userId: Int,
    val userName: String? = null,
    val userImagePath: String? = null,
    val orderStatus: String? = null,
    val orderId: Int? = null
) : Parcelable