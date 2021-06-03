@file:Suppress("NULLABILITY_MISMATCH_BASED_ON_JAVA_ANNOTATIONS")

package com.quedrop.driver.utils

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.location.Address
import android.location.Geocoder
import android.net.Uri
import android.provider.MediaStore
import android.webkit.URLUtil
import androidx.exifinterface.media.ExifInterface
import com.devspark.appmsg.AppMsg
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import java.io.ByteArrayOutputStream
import java.text.SimpleDateFormat
import java.util.*
import java.util.regex.Matcher
import java.util.regex.Pattern


const val REQUEST_CODE_GPS = 100
const val KEY_TOKEN = "key_token"
const val KEY_USER = "key_user"
const val KEY_LATITUDE = "key_latitude"
const val KEY_LONGITUDE = "key_longitude"
const val DEVICE_TOKEN = "device_token"
const val ACCESS_KEY = "nousername"
const val DEVICE_TYPE = 1
const val KEY_LOGIN_AS = 3
const val GOOGLE_LOGIN_REQUEST_CODE = 200
const val LOGIN_TYPE_GOOGLE = 3
const val LOGIN_TYPE_FB = 2
const val KEY_EMAIL = "key_email"
const val KEY_PASSWORD = "key_password"
const val KEY_USERID = "key_user_id"
const val KEY_LOGIN_TYPE_AS = "Driver"
const val KEY_TIMEOUT = "key_timeout"
const val KEY_IS_ANY_CURRENT_ORDER = "key_is_any_current_order"
const val KEY_LAST_ORDER_ID = "key_last_order_id"
const val KEY_CURRENT_REQUEST_ID = "kCurrentOrderRequestId"
const val KEY_RQUEST_QUEUE = "kOrderRequestQueue"
const val KEY_RECEIPT = "receipt"
const val CURRENCY = "$"
const val ORDER_STATUS_ACCEPTED = "Accepted"
const val ORDER_STATUS_DISPATCH = "Dispatch"
const val KEY_EDIT_IDENTITY = "edit_identity"
const val KEY_FROM_EDIT_IDENTITY = "from_edit_identity"

const val KEY_LICENCE_PHOTO = "licence_photo"
const val KEY_DRIVER_PHOTO = "driver_photo"
const val KEY_REGISTRATION_PROOF = "registration_proof"
const val KEY_NUMBER_PLATE = "number_plate"

const val BANK_ACCOUNT_SAVING = "Saving"
const val BANK_ACCOUNT_CURRENT = "Current"
const val TYPE_CAR = "Car"
const val TYPE_BIKE = "Bike"
const val TYPE_CYCLE = "Cycle"

const val dateFormat = "yyyy-MM-dd HH:mm:ss"

//notification key constant
const val NOTI_LOGS = "notification_logs"
const val Key__Manual_payment: String = "manualstore_noti"
const val Key_Earning_payment: String = "earning_noti"

//Shared keys constant
const val EARNING_DATA = "earning_data"

const val STANDARD_DELIVERY = "Standard"
const val EXPRESS_DELIVERY = "Express"


object BroadCastConstant {
    const val BROADCAST_EVENT_CHANGE = "broadcastEventChange"
    const val BROADCAST_KEY_EVENT = "broadcastKeyEvent"
    const val BROADCAST_KEY_OBJ = "broadcastKeyObj"

}

object ImageConstant {
    const val DRIVER_DETAILS = "Uploads/DriverDetails/"
    const val PROFILE_DATA = "Uploads/Users/"
    const val SERVICE_CATEGORY = "Uploads/ServiceCategories/"
    const val STORE_CATEGORY = "Uploads/StoreCategory/"
    const val STORE_SLIDER = "Uploads/StoresS/"
    const val STORE_LOGO = "Uploads/Logo/"
    const val USER_STORE = "Uploads/Users/"
    const val USER_STORE_PRODUCT = "Uploads/Products/"
    const val USER_STORE_PRODUCT_RECEIPT = "Uploads/OrderReceipt/"
    const val USER_BANK_DETAILS = "Uploads/BankLogo/"
}

object URLConstant {

    const val PROVACY_URL = BuildConfig.BASE_URL + "privacy_policy.html"

    //    const val TEMS_AND_CONDI_URL = BuildConfig.BASE_URL + "terms-and-conditions.html"
    val TEMS_AND_CONDI_URL = BuildConfig.BASE_URL + "PrivacyPolicy.pdf"

}

fun isEmailValid(email: String?): Boolean {
    val pattern: Pattern
    val matcher: Matcher
    val EMAIL_PATTERN =
        "^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
    pattern = Pattern.compile(EMAIL_PATTERN)
    matcher = pattern.matcher(email)
    return matcher.matches()
}

fun isValidMobile(phone: String?): Boolean {
    return if (phone != null && !Pattern.matches("[a-zA-Z]+", phone)) {
        phone.length > 6 && phone.length <= 13
    } else false
}


fun getCompressedFilePath(context: Context, filePath: String): String? {
    var bmp: Bitmap? = null
    var bos: ByteArrayOutputStream? = null
    var bt: ByteArray? = null
    var encodeString: String? = null
    try {
        //bmp = BitmapFactory.decodeFile(filePath)
        bmp = getBitmap(filePath)
        bos = ByteArrayOutputStream()
        bmp.compress(Bitmap.CompressFormat.JPEG, 60, bos)
        return MediaStore.Images.Media.insertImage(context.contentResolver, bmp, "Title", null)
    } catch (e: Exception) {
        e.printStackTrace()
        return ""
    }
}


private fun getBitmap(filePath: String): Bitmap {
    val ei = ExifInterface(filePath)
    val orientation = ei.getAttributeInt(
        ExifInterface.TAG_ORIENTATION,
        ExifInterface.ORIENTATION_UNDEFINED
    )
    val bitmap = BitmapFactory.decodeFile(filePath)
    val bitmapNew = Bitmap.createScaledBitmap(bitmap, bitmap.width, bitmap.height, true)
    var rotatedBitmap: Bitmap? = null
    when (orientation) {

        ExifInterface.ORIENTATION_ROTATE_90 -> rotatedBitmap =
            rotateImageIfRequire(bitmapNew!!, 90f)

        ExifInterface.ORIENTATION_ROTATE_180 -> rotatedBitmap =
            rotateImageIfRequire(bitmapNew, 180f)

        ExifInterface.ORIENTATION_ROTATE_270 -> rotatedBitmap =
            rotateImageIfRequire(bitmapNew, 270f)

        ExifInterface.ORIENTATION_NORMAL -> rotatedBitmap = bitmapNew

        else -> rotatedBitmap = bitmapNew
    }

    return rotatedBitmap!!

}

private fun rotateImageIfRequire(source: Bitmap, angle: Float): Bitmap {
    val matrix = Matrix()
    matrix.postRotate(angle);
    return Bitmap.createBitmap(
        source, 0, 0, source.width, source.height,
        matrix, true
    )
}

fun getTimeZone(): String {
    val cal = Calendar.getInstance()
    return cal.timeZone.id
}

fun getAddress(context: Context): String {
    val addresses: List<Address>
    val geocoder = Geocoder(context, Locale.getDefault())
    addresses = geocoder.getFromLocation(
        SharedPreferenceUtils.getString(KEY_LATITUDE).toDouble(),
        SharedPreferenceUtils.getString(KEY_LONGITUDE).toDouble(),
        1
    )
    if (addresses.size > 0) {
        val city: String = addresses[0].locality
        val state: String = addresses[0].adminArea
        val country: String = addresses[0].countryName
        return "$city $state $country"
    } else {
        return ""
    }
}


//fun String.getCalenderDate(inputFormat: String): Calendar {
//    val date = SimpleDateFormat(inputFormat, Locale.getDefault()).parse(this)
//    val calendar = Calendar.getInstance()
//    date?.let { calendar.time = date }
//    return calendar
//}

//fun showToast(context: Context, mesaage: String) {
//    Toast.makeText(context, mesaage, Toast.LENGTH_SHORT).show()
//}

//fun Context.showToast(message: String = "") {
//    Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
//}


fun getRealPathFromURI(context: Context, mContentUri: Uri): String? {
    var path: String? = null
    val proj = arrayOf(MediaStore.MediaColumns.DATA)
    val cursor = context.contentResolver.query(mContentUri, proj, null, null, null)
    if (cursor?.moveToFirst()!!) {
        val column_index = cursor?.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA)
        path = cursor.getString(column_index)
    }
    cursor.close()
    return path
}


val settingOptionList = arrayListOf(
    "Change Password",
    "My Referral Code",
    "Manage Payment Method",
    "Reviews & Rating",
    "Identity Details"
)
val settingOptionIcons = arrayListOf(
    R.drawable.ic_lock,
    R.drawable.ic_a12,
    R.drawable.ic_wallet,
    R.drawable.ic_ratting_thumb,
    R.drawable.ic_sport_car
)


fun getDeviceWidth(context: Context): Int {
    val metrics = context.resources.displayMetrics
    return metrics.widthPixels

}


fun getDeviceHeight(context: Context): Int {
    val metrics = context.resources.displayMetrics
//        if (context instanceof BaseActivity) {
    //            Rect rectgle = new Rect();
    //            Window window = ((BaseActivity) context).getWindow();
    //            window.getDecorView().getWindowVisibleDisplayFrame(rectgle);
    //            int StatusBarHeight = rectgle.top;
    //            height = height - StatusBarHeight;
    //        }
    return metrics.heightPixels
}

fun isNetworkUrl(url: String): Boolean {
    return URLUtil.isNetworkUrl(url)
}


fun convertUTCDateToLocalDate(date: String): String {
    val dateStr = date
    val df = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
    df.timeZone = TimeZone.getTimeZone("UTC")
    val date = df.parse(dateStr)
    df.timeZone = TimeZone.getDefault()

    val localDate = df.format(date)

    val formatter = SimpleDateFormat("dd MMMM yyyy hh:mm a", Locale.getDefault())
    return formatter.format(df.parse(localDate))
}


fun convertUTCDateToLocalDate(date: String, format: String): String {
    val dateStr = date
    val df = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
    df.timeZone = TimeZone.getTimeZone("UTC")
    val date = df.parse(dateStr)
    df.timeZone = TimeZone.getDefault()

    val localDate = df.format(date)

    val formatter = SimpleDateFormat(format, Locale.getDefault())
    return formatter.format(df.parse(localDate))
}


fun showAlertMessage(context: Activity, message: String) {
    AppMsg.makeText(
        context,
        message,
        AppMsg.STYLE_ALERT
    ).show()
}

fun showInfoMessage(context: Activity, message: String) {
    AppMsg.makeText(
        context,
        message,
        AppMsg.STYLE_INFO
    ).show()
}

fun geFormatedDate(format: String): String {
    val c = Calendar.getInstance()
    val date = c.time
    val format1 = SimpleDateFormat("dd-MMMM-yyyy", Locale.getDefault())
    val formatedDate = format1.format(date)
    val format2 = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
    val orderDate = format2.format(date)
    return orderDate
}




