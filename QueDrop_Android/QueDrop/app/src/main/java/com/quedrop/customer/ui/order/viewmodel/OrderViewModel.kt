package com.quedrop.customer.ui.order.viewmodel

import android.os.Handler
import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.network.ResponseWrapper
import com.quedrop.customer.ui.home.view.GoogleMapDirection
import com.google.android.gms.maps.model.LatLng

import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import java.util.*

class OrderViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val currentOrderList: MutableLiveData<List<GetCurrentOrderResponse>> = MutableLiveData()
    val pastOrderList: MutableLiveData<List<GetCurrentOrderResponse>> = MutableLiveData()
    val orderDetails: MutableLiveData<GetSingleOrderDetailsResponse> = MutableLiveData()
    val orderBillingDetails: MutableLiveData<GetConfirmOrderDetails> = MutableLiveData()
    val user: MutableLiveData<User> = MutableLiveData()
    private var orderEndTime = ""
    private var endTime = 0
    val countDownResponse: MutableLiveData<String> = MutableLiveData()
    val customerSupportMessage: MutableLiveData<String> = MutableLiveData()
    val rateReviewMessage: MutableLiveData<String> = MutableLiveData()
    val currentOrderViewShow: MutableLiveData<Boolean> = MutableLiveData()
    val timerValue: MutableLiveData<Long> = MutableLiveData()
    val errorMessageRescheduleOrder: MutableLiveData<String> = MutableLiveData()
    val responseRescheduleOrder: MutableLiveData<ResponseWrapper> = MutableLiveData()

    val responseGooglePay: MutableLiveData<GooglePayResponse> = MutableLiveData()


    fun getGooglePaymentCharge(googlePayRequest: GooglePayRequest) {
        apiService.googlePayCharge(googlePayRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ customerOrderResponse ->
                if (customerOrderResponse.status) {
                    responseGooglePay.value = customerOrderResponse.data.apple_pay_secret
                } else {
                    errorMessage.value = customerOrderResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }


    fun getCustomerCurrentOrderApi(getCustomerOrderRequest: CurrentOrderRequest) {
        apiService.getCustomerOrders(getCustomerOrderRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ customerOrderResponse ->

                if (customerOrderResponse.status) {
                    currentOrderList.value = customerOrderResponse.data.current_order

                } else {
                    errorMessage.value = customerOrderResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getCustomerPastOrderApi(getCustomerOrderRequest: CurrentOrderRequest) {


        apiService.getCustomerOrders(getCustomerOrderRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ customerOrderResponse ->

                if (customerOrderResponse.status) {

                    pastOrderList.value = customerOrderResponse.data.past_order
                } else {
                    errorMessage.value = customerOrderResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getSingleOrderDetailsApi(getSingleOrderDetailsRequest: SingleOrderDetails) {


        apiService.getSingleOrderDetails(getSingleOrderDetailsRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ getSingleOrderResponse ->

                if (getSingleOrderResponse.status) {
                    orderDetails.value = getSingleOrderResponse.data.order_details
                } else {
                    errorMessage.value = getSingleOrderResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getConfirmOrderApi(getSingleOrderDetailsRequest: SingleOrderDetails) {


        apiService.getConfirmOrderDetails(getSingleOrderDetailsRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ getConfirmOrderResponse ->

                if (getConfirmOrderResponse.status) {
                    orderBillingDetails.value = getConfirmOrderResponse.data.order_billing_details
                } else {
                    errorMessage.value = getConfirmOrderResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getRescheduleOrderApi(getRescheduleOrderRequest: RescheduleOrder) {


        apiService.rescheduleOrder(getRescheduleOrderRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ rescheduleOrderResponse ->

                if (rescheduleOrderResponse.status) {
                    responseRescheduleOrder.value = rescheduleOrderResponse.data
                } else {
                    errorMessageRescheduleOrder.value = rescheduleOrderResponse.message
                }
            }, {
                errorMessageRescheduleOrder.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getSubmitOrderQueryApi(getCustomerSupportRequest: GetCustomerSupprt) {


        apiService.getSubmitOrderQuery(getCustomerSupportRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ getSubmitQueryResponse ->

                if (getSubmitQueryResponse.status) {
                    customerSupportMessage.value = getSubmitQueryResponse.message
                } else {
                    errorMessage.value = getSubmitQueryResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getRateReviewApi(getRateReviewRequest: GetRateReview) {


        apiService.getRateReview(getRateReviewRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ getRateReviewResponse ->

                if (getRateReviewResponse.status) {
                    rateReviewMessage.value = getRateReviewResponse.message
                } else {
                    errorMessage.value = getRateReviewResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    val mapDirectionData: MutableLiveData<GoogleMapDirection> = MutableLiveData()


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
                errorMessage.value = it.toString()
            }).autoDispose(compositeDisposable)

    }


    fun doFirstWork(timeRemaining12: String) {
        val handler = Handler()
        if (timeRemaining12.isNotEmpty()) {
            var timeRemaining = timeRemaining12.toLong() - 3
            Log.e("from timeTemaing", timerValue.toString())
            handler.postDelayed(object : Runnable {
                override fun run() {

                    timerValue.value = timeRemaining
                    timeRemaining -= 1000
                    Log.e("from orderVM", timerValue.toString())



                    if (timeRemaining >= 0) {
                        handler.postDelayed(this, 1000)
                    } else {
                        handler.removeCallbacks(this)
//                    navigationVisibility()
                    }
                }
            }, 1000)
        }
    }

//    fun doSecondWork() {
//
//
//        var handler = Handler()
//
//        var timeRemaining = (30 * 60 * 1000).toLong()
//
//        handler.postDelayed(object : Runnable {
//            override fun run() {
//
//                textView.text = Utils.msToString(timeRemaining)
////                    timeRemainingMain12 = Utils.msToString(timeRemaining)
//                timeRemaining = timeRemaining - 1000
//
//
//
//                if (timeRemaining >= 0) {
//                    handler.postDelayed(this, 1000)
//                } else {
//                    handler.removeCallbacks(this)
//
//                }
//            }
//        }, 1000)
//    }


}

/*
   val handler = Handler()
    private var runnable = object : Runnable {
        @RequiresApi(Build.VERSION_CODES.O)
        override fun run() {
            try {
                handler.postDelayed(this, 1000)
                if (endTime > 0) {
                    val minutes = (endTime/60)
                    val seconds = endTime - minutes*60

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
                    endTime =0
                    //   Log.e("endTimeElse",endTime.toString())
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
        //   handler.postDelayed(runnable, 0)
    }

    private fun countRemainingTime() {

        try {

            val formatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            val endDate = formatter.parse(
                orderEndTime.replace(
                    "Z$".toRegex(),
                    "+0000"
                )
            )!!
            val currentDate = Calendar.getInstance().time

            //  Log.e("OrderDate", endDate.toString())
            //  Log.e("CurrentDate", currentDate.toString())

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
            endTime = 120 - diff.toInt()

            if (endTime > 0) {
                currentOrderViewShow.postValue(true)
            }
            handler.postDelayed(runnable, 0)
        }catch (e:Exception){}
    }

    fun stopCountDown() {
        handler.removeCallbacks(runnable)
    }
 */