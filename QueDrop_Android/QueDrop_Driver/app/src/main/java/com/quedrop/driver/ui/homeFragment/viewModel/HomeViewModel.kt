package com.quedrop.driver.ui.homeFragment.viewModel

import android.os.Build
import android.os.Handler
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.lifecycle.MutableLiveData
import com.quedrop.driver.viewModel.BaseViewModel
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.service.ApiService
import com.quedrop.driver.service.model.GoogleMapDirection
import com.google.android.gms.maps.model.LatLng
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.HashMap


class HomeViewModel(private val apiService: ApiService) : BaseViewModel() {
    val mapDirectionData: MutableLiveData<GoogleMapDirection> = MutableLiveData()
    private var orderEndTime = ""
    private var endTime = 0
    val countDownResponse: MutableLiveData<String> = MutableLiveData()
    val currentOrderViewShow: MutableLiveData<Boolean> = MutableLiveData()

    fun getMapRoute(
        origin: String,
        destination: String,
        mapKey: String,
        wayPointsList: ArrayList<LatLng>
    ) {
        val viaPoint = StringBuilder()
        val data = HashMap<String, String>()
        data["origin"] = origin
        data["destination"] = destination
        for (points in wayPointsList) {
            viaPoint.append(
                points.latitude.toString().plus(",").plus(points.longitude.toString()).plus(
                    "|"
                )
            )
        }
        data["waypoints"] = viaPoint.toString()
        data["mode"] = "walk"
        data["key"] = mapKey

        apiService.getMapRoute(data)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ mapData ->
                mapDirectionData.value = mapData
            }, {

            }).autoDispose(compositeDisposable)

    }

//    val handler = Handler()
//    private var runnable = object : Runnable {
//        @RequiresApi(Build.VERSION_CODES.O)
//        override fun run() {
//            try {
//                handler.postDelayed(this, 1000)
//                if (endTime > 0) {
//                    val minutes = (endTime / 60)
//                    val seconds = endTime - minutes * 60
//
//                    var minuteStr = ""
//                    minuteStr = when {
//                        minutes.toString().length == 1 -> "0$minutes"
//                        else -> minutes.toString()
//                    }
//                    var secStr = ""
//                    secStr = when {
//                        seconds.toString().length == 1 -> "0$seconds"
//                        else -> seconds.toString()
//                    }
//                    countDownResponse.value = "$minuteStr:$secStr"
//                    endTime--
//
//                } else {
//                    endTime = 0
//                    countDownResponse.value = "00:00"
//                    handler.removeCallbacks(this)
//
//                }
//            } catch (e: Exception) {
//                e.printStackTrace()
//            }
//        }
//    }
//
//    fun startCountDown(orderDate: String) {
//        orderEndTime = orderDate
//        countRemainingTime()
//        //   handler.postDelayed(runnable, 0)
//    }
//
//    private fun countRemainingTime() {
//
//
//        val formatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
//        formatter.timeZone = TimeZone.getTimeZone("GMT")
//
//        val endDate = formatter.parse(
//            orderEndTime.replace(
//                "Z$".toRegex(),
//                "+0000"
//            )
//        )!!
//
//
//
//        //formatter.timeZone = TimeZone.getDefault()  // IMP !!!
//
//        //val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.getDefault())
//        val outputFormat = SimpleDateFormat("dd-MM-yyyy hh:mm:ss a", Locale.getDefault())
//        //inputFormat.timeZone = TimeZone.getTimeZone("America/New_York")
//        outputFormat.timeZone = TimeZone.getTimeZone("GMT+5.30")
//        //val date = inputFormat.parse(orderEndTime)
//        val formattedDate = outputFormat.format(endDate)
//        println(formattedDate) // prints 10-04-2018*/
//
//        Log.e("JSOrderDate", formattedDate.toString())
//
//        val currentDate = Date()
////
//        Log.e("OrderDate", endDate.toString())
//        Log.e("CurrentDate", currentDate.toString())
//
//        //val timeDate = endDate.time
//        //val timeEndDate = currentDate.time
//
//
//        //val startDateTime = Calendar.getInstance()
//        //val endDateTime = Calendar.getInstance()
//
//        //startDateTime.timeInMillis = timeDate
//        //endDateTime.timeInMillis = timeEndDate
//
//        val milliseconds1 = currentDate.time
//        val milliseconds2 = endDate.time
//
//
//
//        Log.e("currentMillis","==>"+System.currentTimeMillis())
//        Log.e("milliseconds1","==>"+milliseconds1/1000L)
//        Log.e("milliseconds2","==>"+milliseconds2/1000L)
//
//        var diff = milliseconds2 - milliseconds1
//
//        Log.e("diff","==>"+diff)
//        diff = TimeUnit.MILLISECONDS.toSeconds(diff)
//
//        //endTime = TimeUnit.to
//        endTime = 120 - diff.toInt()
//
//        Log.e("EndTime","==>"+endTime+" "+diff)
//
//        if (endTime > 0) {
//            currentOrderViewShow.postValue(true)
//        }
////        For testing remove above if loop and uncomment below line
////        currentOrderViewShow.postValue(true)
//        handler.postDelayed(runnable, 0)
//    }
//
//    fun stopCountDown() {
//        handler.removeCallbacks(runnable)
//    }


    val handler = Handler()
    private var runnable = object : Runnable {
        @RequiresApi(Build.VERSION_CODES.O)
        override fun run() {
            try {
                handler.postDelayed(this, 1000)
                if (endTime > 0) {
                    val minutes = (endTime / 60)
                    val seconds = endTime - minutes * 60

                    var minuteStr = ""
                    minuteStr = when {
                        minutes.toString().length == 1 -> "0$minutes"
                        else -> minutes.toString()
                    }
                    var secStr = ""
                    secStr = when {
                        seconds.toString().length == 1 -> "0$seconds"
                        else -> seconds.toString()
                    }
                    countDownResponse.value = "$minuteStr:$secStr"
                    endTime--

                } else {
                    endTime = 0
                    countDownResponse.value = "00:00"
                    handler.removeCallbacks(this)

                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    fun startCountDown(orderDate: String) {
        orderEndTime = orderDate
        countRemainingTime()
// handler.postDelayed(runnable, 0)
    }

    private fun countRemainingTime() {

        val formatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        val endDate = formatter.parse(
            orderEndTime.replace(
                "Z$".toRegex(),
                "+0000"
            )
        )!!
        val currentDate = Calendar.getInstance().time

        Log.e("Time","OrderDate=>"+ endDate.toString())
        Log.e("Time","CurrentDate=>"+ currentDate.toString())

        val timeDate = endDate.time
        val timeEndDate = currentDate.time


        val startDateTime = Calendar.getInstance()
        val endDateTime = Calendar.getInstance()

        startDateTime.timeInMillis = timeDate
        endDateTime.timeInMillis = timeEndDate

        val milliseconds1 = startDateTime.timeInMillis
        val milliseconds2 = endDateTime.timeInMillis
        var diff = milliseconds2 - milliseconds1
        diff /= 1000
        endTime = 60 - diff.toInt()

        Log.e("Time","Difference=>"+diff.toString())
        Log.e("Time","EndTime=>"+ endTime.toString())

        if (endTime > 0) {
            currentOrderViewShow.postValue(true)
        }
// For testing remove above if loop and uncomment below line
// currentOrderViewShow.postValue(true)
        handler.postDelayed(runnable, 0)
    }

    fun stopCountDown() {
        handler.removeCallbacks(runnable)
    }
}
