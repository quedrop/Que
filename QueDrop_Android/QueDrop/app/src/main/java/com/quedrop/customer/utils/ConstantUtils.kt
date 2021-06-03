package com.quedrop.customer.utils

import com.quedrop.customer.network.ApiUtils

class ConstantUtils {

    companion object {

        val ZERO = 0
        val ONE = 1
        val TWO = 2
        val THREE = 3
        val FOUR = 4
        val FIVE = 5
        val MULTIPLE_PERMISSIONS = 10
        val PERMISSION_READ_STATE = 11
        val PERMISSION_READ_EXTERNAL_STORAGE = 12
        val PERMISSION_CAMERA = 13
        val PERMISSION_RECEIVE_SMS = 14
        val REQUEST_CODE_GPS = 100
        val REQUEST_CODE_ADDRESS = 101
        val REQUEST_CODE_EDITADDRESS = 102
        val REQUEST_CODE_ADDITEM = 103
        val REQUEST_CODE_ADDADDONS = 104
        val REQUEST_CODE_CUSTOMIZE = 105
        val REQUEST_CART_CUSTOMISE = 106
        var REQUEST_PICK_IMAGE = 200
        var REQUEST_CAMERA = 201
        var REQUEST_PLACE_ADD = 202
        var REQUEST_TV_PLACE_ADD = 203
        var REQUEST_RECURRING = 204
        var GOOGLE_LOGIN_REQUEST_CODE = 205
        var LOGIN_CART_REQUEST_CODE = 206
        var LOGIN_ENTER_PHONE_REQUEST_CODE = 207
        var LOGIN_REGISTER_REQUEST_CODE = 208
        var LOGIN_SOCIAL_REQUEST_CODE = 209
        var REGISTER_ENTER_PHONE_REQUEST_CODE = 210
        var ENTER_PHONE_VERIFY_REQUEST_CODE = 211
        var LOGIN_FORGOT_PASS_REQUEST_CODE = 212
        var EMAIL_PHONE_NUMBER_REQUEST_CODE = 213
        var ADD_STORE_REQUEST_CODE = 214
        var FAV_LOGIN_REQUEST_CODE = 215
        var ADD_PRODUCT_REQUEST_CODE = 216
        var ADD_LOGIN_PRODUCT_REQUEST_CODE = 217
        var REQUEST_COUPON_CART = 218
        var REQUEST_LOGIN_COUPON = 219
        var REQUEST_LOGIN_ORDER = 220
        var REQUEST_CART_FOOD_CATEGORY = 221
        var LOGIN_PROFILE = 222
        var PROFILE_MANAGE_CODE = 223
        var ORDER_MANAGE_CODE = 224
        val REQUEST_CODE_SEARCH_ADDRESS = 225
        val VALUE_1000 = 1000
        val VALUE_15 = 15f
        val VALUE_11 = 11f

        const val DEVICE_TYPE = 1
        val KEY_LOGIN_AS = "Customer"
        val KEY_LOGIN_AS_SUPPLIER = "Supplier"

        val USER_TYPE_C = "Customer"
        val USER_TYPE_S = "Supplier"

        const val LOGIN_TYPE_GOOGLE = 3
        const val LOGIN_TYPE_FB = 2
        const val KEY_EMAIL = "key_email"
        const val KEY_PASSWORD = "key_password"

        const val USER_TYPE_CUSTOMER = 0
        const val USER_TYPE_SUPPLIER = 1

        const val BANK_ACCOUNT_SAVING = "Saving"
        const val BANK_ACCOUNT_CURRENT = "Current"


        const val NOTICES = "Notification_testing"

        const val STANDARD_DELIVERY = "Standard"
        const val EXPRESS_DELIVERY = "Express"
        const val KEY_DELIVERY_TYPE = "delivery_type"

    }
}

object URLConstant {
    // http://34.204.81.189/quedrop/API/PrivacyPolicy.pdf

    val PRIVACY_URL = ApiUtils.BASE_URL + "PrivacyPolicy.pdf"
    val TEMS_AND_CONDI_URL = ApiUtils.BASE_URL + "terms-and-conditions.html"

    //    val TEMS_AND_CONDI_URL = ApiUtils.BASE_URL + "PrivacyPolicy.pdf"
    val serviceCategoryUrl = ApiUtils.BASE_URL + "Uploads/ServiceCategories/"
    val nearByStoreUrl = ApiUtils.BASE_URL + "Uploads/Logo/"
    val urlProduct = ApiUtils.BASE_URL + "Uploads/Products/"
    val urlStoreCategories = ApiUtils.BASE_URL + "Uploads/StoreCategory/"
    val urlStoreSliderImages = ApiUtils.BASE_URL + "Uploads/StoresS/"
    val urlDriverDetails = ApiUtils.BASE_URL + "Uploads/DriverDetails/"
    val urlOrderReceipt = ApiUtils.BASE_URL + "Uploads/OrderReceipt/"
    val urlUser = ApiUtils.BASE_URL + "Uploads/Users/"
    val urlBankLogo = ApiUtils.BASE_URL + "Uploads/BankLogo/"
}


object BroadCastConstant {
    const val BROADCAST_EVENT_CHANGE = "broadcastEventChange"
    const val BROADCAST_KEY_EVENT = "broadcastKeyEvent"
    const val BROADCAST_KEY_OBJ = "broadcastKeyObj"

}

object UserTypes {
    const val CUSTOMER = 0
    const val SUPPLIER = 1
}
