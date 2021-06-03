package com.quedrop.customer.base.extentions

import android.content.Context
import android.content.res.Resources
import android.graphics.drawable.Drawable
import android.text.TextUtils
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.quedrop.customer.R
import com.quedrop.customer.utils.URLConstant
import java.text.SimpleDateFormat
import java.util.*


fun Calendar.getDateInFormatOf(format: String): String {
    return SimpleDateFormat(format, Locale.getDefault()).format(this.time)
}

fun String.getCalenderDate(inputFormat: String): Calendar {
    val date = SimpleDateFormat(inputFormat, Locale.getDefault()).parse(this)
    val calendar = Calendar.getInstance()
    date?.let { calendar.time = date }
    return calendar
}

fun String.convertDate(inputFormat: String, outputFormat: String): String {
    var dateString = ""
    val date = SimpleDateFormat(inputFormat, Locale.getDefault()).parse(this)
    date?.let { dateString = SimpleDateFormat(outputFormat, Locale.getDefault()).format(date) }
    return dateString
}

fun String.validateAsEmail(): Boolean {
    if (TextUtils.isEmpty(this)) return false
    return android.util.Patterns.EMAIL_ADDRESS.matcher(this).matches()
}

fun Context.pickColor(resourceId: Int): Int {
    return ContextCompat.getColor(this, resourceId)
}

fun Context.pickColorString(resourceId: Int): String {
    val colorInt = ContextCompat.getColor(this, resourceId)
    return java.lang.String.format("#%06X", 0xFFFFFF and colorInt)

}

fun Context.showToast(message: String = "") {
    Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
}

fun Context.showToastLong(message: String) {
    Toast.makeText(this, message, Toast.LENGTH_LONG).show()
}

val Int.dp: Int
    get() = (this * Resources.getSystem().displayMetrics.density + 0.5f).toInt()

//inline fun <reified T : Activity> Context.openActivity(noinline extra: Intent.() -> Unit) {
//    val intent = Intent(this, T::class.java)
//    intent.extra()
//    startActivity(intent)
//}
//
//inline fun <reified T : Activity> Fragment.openActivityForResult(
//    requestCode: Int = -1,
//    options: Bundle? = null,
//    noinline extra: Intent.() -> Unit) {
//
//    val intent = Intent(this.activity, T::class.java)
//    intent.extra()
//    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
//        startActivityForResult(intent, requestCode, options)
//    } else {
//        startActivityForResult(intent, requestCode)
//    }
//}

fun Context.getDrawableResource(resourceId: Int): Drawable? =
    ContextCompat.getDrawable(this, resourceId)

//========================= App Specific =======================================

fun Context.getCategoryImage(imageName: String): String {
    return URLConstant.urlStoreCategories+ imageName
}

fun Context.getProductImage(imageName: String): String {
    return URLConstant.urlProduct + imageName
}

fun Context.getBankLogo(imageName: String): String {
    return URLConstant.urlBankLogo + imageName
}

fun Context.getUser(imageName: String): String {
    return URLConstant.urlProduct+ imageName
}

fun Context.getStoreLogo(imageName: String): String {
    return URLConstant.nearByStoreUrl + imageName
}

fun Context.getStoreSlideImage(imageName: String): String {
    return URLConstant.urlStoreSliderImages + imageName
}