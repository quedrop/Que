package com.quedrop.customer.model

data class AddCustomerAddress(
    var user_id : Int ,
    var guest_user_id:Int,
    var secret_key :String ,
    var access_key :String
)

data class Address(
    var address_id:Int,
    var address_title:String,
    var address:String,
    var latitude:String,
    var longitude:String,
    var additional_info:String,
    var address_type:String,
    var unit_number:String,
    var is_default_address:String,
    var user_id:Int,
    var guest_user_id:Int

)


data class AddAddress(

    var secret_key :String ,
    var access_key :String ,
    var user_id :Int ,
    var address_name :String ,
    var latitude :String ,
    var longitude :String ,
    var additional_info :String ,
    var address_type :String ,
    var address :String,
    var unit_number:String,
    var guest_user_id:Int
)

data class EditAddress(

    var secret_key:String,
    var access_key:String,
    var address_id:Int,
    var user_id:Int,
    var address_name:String,
    var latitude:String,
    var longitude:String,
    var additional_info:String,
    var address_type:String,
    var address:String,
    var is_default:Int,
    var unit_number:String,
    var guest_user_id:Int
)

data class DeleteAddress(
    var user_id : Int ,
    var address_id : Int,
    var secret_key :String ,
    var access_key :String,
    var guest_user_id:Int
)
