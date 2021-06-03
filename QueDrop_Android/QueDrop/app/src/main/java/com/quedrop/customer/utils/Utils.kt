package com.quedrop.customer.utils

import android.app.Activity
import android.app.DatePickerDialog
import android.app.Dialog
import android.app.TimePickerDialog
import android.content.Context
import android.location.Geocoder
import android.net.Uri
import android.provider.MediaStore
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.TextView
import com.android.volley.Request
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.google.android.gms.maps.model.LatLng
import com.quedrop.customer.R
import org.json.JSONException
import org.json.JSONObject
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.TimeUnit


object Utils {

    var seceretKey: String = ""
    var accessKey: String = ""
    var guestId: Int = 0
    var userId: Int = 0
    var is_default: Int = 1
    var deviceToken: String = ""
//    var isGuest: String = ""


    var selectAddress: String = ""
    var textAddress: String = ""
    var selectAddressTitle: String = ""
    var selectAddressType: String = ""
    var keyLatitude: String = "0.0"
    var keyLongitude: String = "0.0"

    var isPlaceOrderBoolean = false
    var isCallOnceMap: Boolean = false
    var flagCartCustomise: Boolean = false
    var keyStoreId: Int = 0

    val countryCodeList = arrayOf("+91", "+44", "+1")
    val countryFlagList = arrayOf(R.drawable.ic_home, R.drawable.ic_home, R.drawable.ic_home)

    const val CURRENCY = "$"


    fun fetchRouteTime(
        context: Context,
        sourceLatitude: Double,
        sourceLongitude: Double,
        destinationLatitude: Double,
        destinationLongitude: Double,
        textMain: TextView
    ) {
        val path: MutableList<List<LatLng>> = ArrayList()
        val urlDirections =
            context.resources.getString(R.string.urlDirection) + "origin=" + sourceLatitude + "," + sourceLongitude +
                    "&destination=" + destinationLatitude + "," + destinationLongitude +
                    "&key=" + context.resources.getString(
                R.string.mapApiKey
            )
        val directionsRequest = object : StringRequest(
            Request.Method.GET,
            urlDirections,
            com.android.volley.Response.Listener<String> { response ->

                try {
                    val jsonResponse = JSONObject(response)
                    // Get routes
                    val routes = jsonResponse.getJSONArray("routes")
                    val legs = routes.getJSONObject(0).getJSONArray("legs")
                    val steps = legs.getJSONObject(0).getJSONArray("steps")
                    var jDistance = (legs.get(0) as JSONObject).getJSONObject("distance")
                    val jDuration = (legs.get(0) as JSONObject).getJSONObject("duration")
                    val time = jDuration.getString("text")

                    textMain.text = time
                } catch (e: JSONException) {

                }

            },
            com.android.volley.Response.ErrorListener { _ ->
            }) {}

        val requestQueue = Volley.newRequestQueue(context)
        requestQueue.add(directionsRequest)
    }

    fun fetchRouteDistance(
        context: Context,
        sourceLatitude: Double,
        sourceLongitude: Double,
        destinationLatitude: Double,
        destinationLongitude: Double,
        textMain: TextView
    ) {
        val path: MutableList<List<LatLng>> = ArrayList()
        val urlDirections =
            context.resources.getString(R.string.urlDirection) + "origin=" + sourceLatitude + "," + sourceLongitude +
                    "&destination=" + destinationLatitude + "," + destinationLongitude +
                    "&key=" + context.resources.getString(
                R.string.mapApiKey
            )
        val directionsRequest = object : StringRequest(
            Request.Method.GET,
            urlDirections,
            com.android.volley.Response.Listener<String> { response ->
                try {
                    val jsonResponse = JSONObject(response)


                    // Get routes
                    val routes = jsonResponse.getJSONArray("routes")
                    val legs = routes.getJSONObject(0).getJSONArray("legs")
                    val steps = legs.getJSONObject(0).getJSONArray("steps")
                    val jDistance = (legs.get(0) as JSONObject).getJSONObject("distance")
                    val jDuration = (legs.get(0) as JSONObject).getJSONObject("duration")
                    val distance = jDistance.getString("text")

                    textMain.text = distance
                } catch (e: JSONException) {

                }

            },
            com.android.volley.Response.ErrorListener { _ ->
            }) {}

        val requestQueue = Volley.newRequestQueue(context)
        requestQueue.add(directionsRequest)
    }

    fun getCurrentDay(): String {

        val value: Calendar = Calendar.getInstance()
        return value.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.LONG, Locale.getDefault())
    }

    fun getCurrentTime(): String {

        return SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(Date())
    }

    fun getCurrentDate(): String {

        return SimpleDateFormat("dd-MM-yyyy", Locale.getDefault()).format(Date())
    }

    fun getConvertDate(inputDateString: String): String {
        val originalFormat = SimpleDateFormat("yyyy-MM-dd hh:mm:ss")
        val targetFormat = SimpleDateFormat("dd MMMM yyyy")
        val date = originalFormat.parse(inputDateString)
        return targetFormat.format(date)
    }

    fun convertTime(time: String): String {
        val sdf = SimpleDateFormat("hh:mm:ss")
        val sdfs = SimpleDateFormat("hh:mm a")
        val dt: Date

        dt = sdf.parse(time)!!
        println("Time Display: " + sdfs.format(dt))
        return sdfs.format(dt)

    }

    fun checkTimeStatus(
        openingTime: String,
        closingTime: String,
        currentTime: String
    ): Boolean {
        try {
            val string1 = openingTime
            val time1 = SimpleDateFormat("hh:mm a").parse(string1)
            val calendar1 = Calendar.getInstance()
            calendar1.time = time1
            val x = calendar1.time


            val string2 = closingTime
            val time2 = SimpleDateFormat("hh:mm a").parse(string2)
            val calendar2 = Calendar.getInstance()
            calendar2.time = time2
            val y = calendar2.time


            val someRandomTime = currentTime
            val d = SimpleDateFormat("hh:mm a").parse(someRandomTime)
            val calendar3 = Calendar.getInstance()
            calendar3.time = d


            val z = calendar3.time
            return !(z.before(x) && z.after(y))
        } catch (e: ParseException) {
            e.printStackTrace()
            return false
        }


    }

    fun isKeyboardShown(context: Context?, view: View?): Boolean {
        if (context == null || view == null) {
            return false
        }
        val imm = context
            .getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        return imm.hideSoftInputFromWindow(view.getWindowToken(), 0)
    }


    fun getRealPathFromURI(context: Context, mContentUri: Uri): String? {
        var path: String? = null
        val proj = arrayOf(MediaStore.MediaColumns.DATA)
        val cursor = context.contentResolver.query(mContentUri, proj, null, null, null)
        if (cursor?.moveToFirst()!!) {
            val column_index = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA)
            path = cursor.getString(column_index)
        }
        cursor.close()
        return path
    }

    fun showDate(year: Int, month: Int, day: Int, textView: TextView) {
        textView.text = StringBuilder().append(day).append("/")
            .append(month).append("/").append(year)
    }

    fun showTime(mHour: Int, mMinute: Int, textView: TextView) {

        var AM_PM: String = ""
        var mHourMain: Int = mHour
        if (mHour < 12) {
            AM_PM = "AM"
            if (mHour == 0) {
                mHourMain = 12
            } else {

                mHourMain = mHour
            }
        } else {
            AM_PM = "PM"
            if (mHour == 12) {
                mHourMain = 12
            } else {

                mHourMain -= 12
            }


        }
        textView.text = StringBuilder().append(mHourMain).append(":")
            .append(mMinute).append(" ").append(AM_PM)
    }

    fun datePicker(
        activity: Activity,
        year: Int,
        month: Int,
        day: Int,
        textView: TextView
    ): Dialog? {

        var myDateListener =
            DatePickerDialog.OnDateSetListener { arg0, arg1, arg2, arg3 ->
                //                showDate(arg1, arg2 + 1, arg3, textView)
            }
        var datePickerDialog = DatePickerDialog(
            activity,
            myDateListener, year, month, day
        )

        var now = System.currentTimeMillis() - 1000
        datePickerDialog.datePicker.minDate = now
//        datePickerDialog.datePicker.maxDate = now+(1000*60*60*24*)


        return datePickerDialog
    }

    fun TimePicker(activity: Activity, mHour: Int, mMinute: Int, textView: TextView): Dialog? {

        var myTimeListener =
            TimePickerDialog.OnTimeSetListener { arg0, arg1, arg2 ->
                showTime(arg1, arg2, textView)
            }

        return TimePickerDialog(
            activity,
            myTimeListener, mHour, mMinute, false
        )
    }


    fun convertDeliveryTime(context: Context, seconds: String, textView: TextView) {
        if (seconds.isNotEmpty()) {
            var secondLong = seconds.toLong()
            val day = TimeUnit.SECONDS.toDays(secondLong).toInt()
            val hours = TimeUnit.SECONDS.toHours(secondLong) - day * 24
            val minute =
                TimeUnit.SECONDS.toMinutes(secondLong) - TimeUnit.SECONDS.toHours(secondLong) * 60

            textView.text =
                hours.toString() + " " + context.resources.getString(R.string.hours) + " " + minute.toString() + " " + context.resources.getString(
                    R.string.min
                )
        }

    }

    fun getCompleteAddressString(context: Context, LATITUDE: Double, LONGITUDE: Double): String {
        var strAdd = ""
        val geocoder = Geocoder(context, Locale.getDefault())
        try {
            val addresses = geocoder.getFromLocation(LATITUDE, LONGITUDE, 1)
            if (addresses != null) {
                val returnedAddress = addresses[0]
                val strReturnedAddress = StringBuilder("")

                for (i in 0..returnedAddress.maxAddressLineIndex) {
                    strReturnedAddress.append(returnedAddress.getAddressLine(i)).append("\n")
                }
                strAdd = strReturnedAddress.toString()

            } else {

            }
        } catch (e: Exception) {
            e.printStackTrace()

        }

        return strAdd
    }

    fun getCompleteAddressName(context: Context, LATITUDE: Double, LONGITUDE: Double): String {
        var strAdd = ""
        val geocoder = Geocoder(context, Locale.getDefault())
        try {
            val addresses = geocoder.getFromLocation(LATITUDE, LONGITUDE, 1)
            if (addresses != null) {

                val address = addresses[0].getAddressLine(0)
                val city = addresses[0].locality
                val state = addresses[0].adminArea
                val country = addresses[0].countryName
                val postalCode = addresses[0].postalCode

                val knownName = addresses[0].featureName

                val returnedAddress = addresses[0]
                val strReturnedAddress = StringBuilder("")

                for (i in 0..returnedAddress.maxAddressLineIndex) {
                    strReturnedAddress.append(returnedAddress.getAddressLine(i)).append("\n")
                }
                strAdd = knownName.toString()

            } else {

            }
        } catch (e: Exception) {
            e.printStackTrace()

        }

        return strAdd
    }


    fun getTimeZone(): String {
        val cal = Calendar.getInstance()
        return cal.timeZone.id
    }


    fun msToString(ms: Long?): String {
        ms?.let {
            val totalSecs = ms / 1000
            val hours = totalSecs / 3600
            val mins = totalSecs / 60 % 60
            val secs = totalSecs % 60
            val minsString = if (mins == 0L)
                "00"
            else
                if (mins < 10)
                    "0$mins"
                else
                    "" + mins
            val secsString = if ((secs == 0L))
                "00"
            else
                (if ((secs < 10))
                    "0$secs"
                else
                    "" + secs)
            if (hours > 0)
                return (hours).toString() + ":" + minsString + ":" + secsString
            else return if (mins > 0)
                (mins).toString() + ":" + secsString
            else
                "00:$secsString"
        }
        return ""
    }

    fun msToString1(millisUntilFinished: Long?): String {
        millisUntilFinished?.let {

            val seconds: Long = millisUntilFinished / 1000
            val minutes = seconds / 60
            val hours = minutes / 60
            // val days = hours / 24
            val time = String.format("%1$02d:%2$02d:%3$02d", hours % 24, minutes % 60, seconds % 60)

            if (hours > 0)
                return String.format("%1$02d:%2$02d:%3$02d", hours % 24, minutes % 60, seconds % 60)
//            else return if (mins > 0)
//                (mins).toString() + ":" + secsString
            else
                return String.format("%1$02d:%2$02d", minutes % 60, seconds % 60)
            //   "00:$secsString"
        }
        return ""
    }

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

    private const val serverDateFormat = "yyyy-MM-dd HH:mm:ss"


    fun convertServerDateToUserTimeZone(serverDate: String?): String? {
        val ourdate: String
        ourdate = try {
            val formatter = SimpleDateFormat(serverDateFormat)
            formatter.timeZone = TimeZone.getTimeZone("UTC")
            val value: Date = formatter.parse(serverDate)
            val timeZone: TimeZone = TimeZone.getDefault()
//            val dateFormatter =
//                SimpleDateFormat(serverDateFormat) //this format changeable
            formatter.timeZone = timeZone
            formatter.format(value)

        } catch (e: Exception) {
            "0000-00-00 00:00:00"
        }
        println("******* OurDate $ourdate");
        return ourdate
    }

    object Supplier {

        var supplierAccessKey = ""
        var supplierUserId = 0
        var supplierStoreID = 0
        var supplierStoredCreated: Boolean = false
    }

}