package com.quedrop.driver.ui.requestDetailsFragment

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.base.JSDrawRoute
import com.quedrop.driver.base.extentions.finishWithAnimation
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.Orders
import com.quedrop.driver.service.model.User
import com.quedrop.driver.socket.SocketConstants
import com.quedrop.driver.ui.homeFragment.view.DriverMapView
import com.quedrop.driver.ui.homeFragment.viewModel.HomeViewModel
import com.quedrop.driver.ui.mainActivity.view.MainActivity
import com.quedrop.driver.ui.order.adapter.CurrentOrderStoreListAdapter
import com.quedrop.driver.ui.orderDetailsFragment.viewModel.OrderDetailViewModel
import com.quedrop.driver.utils.*
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.SupportMapFragment
import com.google.gson.Gson
import com.google.gson.JsonParser
import com.psp.google.direction.model.Direction
import com.psp.google.direction.util.DirectionConverter
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import io.socket.client.Ack
import kotlinx.android.synthetic.main.fragment_request_detail.*
import kotlinx.android.synthetic.main.toolbar_normal.*
import org.json.JSONException
import org.json.JSONObject


class RequestDetailActivity : BaseActivity() {
    private var rideMapView: DriverMapView? = null
    private var orderDetail: Orders? = null

    private lateinit var homeViewModel: HomeViewModel
    lateinit var orderDetailViewModel: OrderDetailViewModel

    private var jsDrawRoute: JSDrawRoute? = null
    lateinit var mGoogleMap: GoogleMap

    private var profileImagePath: String = ""
    lateinit var mContext: Activity

    var remoteMessage: String? = ""
    var orderIdFromNotification: Int? = 0
    var fromNotification: Boolean? = false

    var orderId: String? = ""


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.fragment_request_detail)
        mContext = this

        if (intent != null) {
            if (intent.hasExtra("remote_message")) {
                remoteMessage = intent.getStringExtra("remote_message")
            }

            if (intent.hasExtra("FROM_NOTIFICATION")) {
                fromNotification = intent.getBooleanExtra("FROM_NOTIFICATION", false)
            }

        }
        if (remoteMessage != null && remoteMessage != "") {
            val jsonObject = JSONObject(remoteMessage!!)
            orderId = jsonObject.getString("order_id")
            getOrderDetails(orderId?.toInt()!!)
        } else if (fromNotification!!) {
            if (intent.hasExtra("ORDER_ID")) {
                orderIdFromNotification = intent.getIntExtra("ORDER_ID", 0)
                getOrderDetails(orderIdFromNotification?.toInt()!!)
            }
        } else {
            val toJson = intent?.getStringExtra("orderDetail")!!
            orderDetail = Gson().fromJson(toJson, Orders::class.java)
        }

        initViews()
    }

    private fun initViews() {
        homeViewModel = HomeViewModel(appService)
        orderDetailViewModel = OrderDetailViewModel(appService)

        setUpToolbar()
        observeViewModel()
        onClickView()
        if (orderDetail != null) {
            runOnUiThread {
                setUpData()
            }
        }
    }

    private fun getOrderDetails(orderId: Int) {
        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {

                jsonObject.put(SocketConstants.KeyOrderId, orderId)
                SocketConstants.socketIOClient!!.emit(SocketConstants.SocketGetOrderDetail,
                    jsonObject, Ack {
                        try {
                            val orderJson = JSONObject(it[0].toString())
                            val orderDetails = orderJson.getString("order_detail")
                            val parser = JsonParser()
                            val mJson = parser.parse(orderDetails)
                            val gson = Gson()

                            orderDetail = gson.fromJson<Orders>(mJson, Orders::class.java)
                            runOnUiThread {
                                setUpData()
                            }
                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }
                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        }
    }

    private fun onClickView() {

        tvAccept.throttleClicks().subscribe {
            acceptCurrentOrder(1)
        }.autoDispose(compositeDisposable)


        tvReject.throttleClicks().subscribe {
            rejectCurrentOrder(0)
        }.autoDispose(compositeDisposable)

    }

    private fun observeViewModel() {
        homeViewModel.countDownResponse.observe(this, Observer { remainingTime ->
            tvTime.text = remainingTime
            //TODO uncommect below timing logic
            if (remainingTime == "00:00") {
                Log.e("Time", "Over")
                rejectCurrentOrder(0)
                Handler().postDelayed({
                    onBackPressed()
                }, 1000)
                showAlertMessage(this, "Order request time out")
            }
        })
    }

    private fun setUpToolbar() {
        tvTitle.text = resources.getString(R.string.request_details)

        ivBack.throttleClicks().subscribe {
            finish()
        }.autoDispose(compositeDisposable)

        info.throttleClicks().subscribe {
            addToolTipView(orderDetail?.driverNote!!)
        }.autoDispose(compositeDisposable)
    }

    @SuppressLint("SetTextI18n")
    private fun setUpData() {
        if (!isNetworkUrl(orderDetail!!.customerDetail.userImage!!)) {
            profileImagePath =
                BuildConfig.BASE_URL + ImageConstant.USER_STORE + orderDetail?.customerDetail!!.userImage
        } else {
            profileImagePath = orderDetail!!.customerDetail.userImage!!
        }
        Glide.with(this)
            .load(profileImagePath)
            .placeholder(R.drawable.ic_user_placeholder)
            .circleCrop()
            .into(ivProfileImage)

        tvUserName.text =
            orderDetail?.customerDetail?.firstName + " " + orderDetail?.customerDetail!!.lastName
        tvAddress.text = orderDetail?.deliveryAddress
        userRating.rating = orderDetail?.customerDetail!!.rating.toFloat()
        tvOrderId.text = "Order ID: #" + orderDetail?.orderId.toString()

        if (orderDetail?.deliveryOption == EXPRESS_DELIVERY) {
            constExpress.visibility = View.VISIBLE
        } else {
            constExpress.visibility = View.GONE
        }
        if (orderDetail?.driverNote != "") {
            info.visibility = View.VISIBLE
            addToolTipView(orderDetail?.driverNote!!)
        } else {
            info.visibility = View.GONE
        }

        val map = supportFragmentManager.findFragmentById(R.id.mapFragment) as SupportMapFragment
        map.getMapAsync { googleMap ->
            mGoogleMap = googleMap
            rideMapView = DriverMapView(
                false,
                map,
                googleMap,
                homeViewModel
            )
            rideMapView?.clearMap()
            requestDirection()

            googleMap.uiSettings.isZoomControlsEnabled = false
            googleMap.uiSettings.isZoomGesturesEnabled = false
            googleMap.uiSettings.isScrollGesturesEnabledDuringRotateOrZoom = false

        }
        homeViewModel.startCountDown(orderDetail!!.requestDate!!)

        setUpStoreData()
        //setUpBillingData()
    }

    private fun setUpStoreData() {
        rvOrder.layoutManager = LinearLayoutManager(mContext)
        val orderAdapter = CurrentOrderStoreListAdapter(
            false,
            mContext,
            orderDetail?.orderStatus!!,
            orderDetail!!.stores.toMutableList(),
            ""
        )
        rvOrder.adapter = orderAdapter
        orderAdapter.notifyDataSetChanged()

    }

    private fun acceptCurrentOrder(isAccept: Int) {
        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {
                jsonObject.put(
                    SocketConstants.KeyUserId, (SharedPreferenceUtils.getModelPreferences(
                        KEY_USER,
                        User::class.java
                    ) as User).userId.toString()
                )
                jsonObject.put(
                    SocketConstants.KeyCustomerId,
                    orderDetail?.customerDetail!!.userId.toString()
                )
                jsonObject.put(SocketConstants.KeyOrderId, orderDetail!!.orderId.toString())
                jsonObject.put(SocketConstants.KeyIsAccept, isAccept.toString())
                jsonObject.put(SocketConstants.KeyDriverIds, "")

                SocketConstants.socketIOClient!!.emit(SocketConstants.SocketAcceptRejectOrder,
                    jsonObject, Ack {
                        try {
                            val acceptResponse = JSONObject(it[0].toString())
                            val responseStatus = acceptResponse.getString("status").toInt()
                            val responseMessage = acceptResponse.getString("message").toString()
                            mContext.runOnUiThread(Runnable {
                                if (responseStatus == 1) {

                                    if (remoteMessage == "") {
                                        Log.e("From Home", "==>")
                                        callListener(true)
                                    } else {
                                        Log.e("From Notification", "==>")
                                        SharedPreferenceUtils.removeCurrentOrderRequest(orderDetail?.orderId!!.toInt())
                                        clearRequestQueue()
                                        val intent = Intent(this, MainActivity::class.java)
                                        intent.putExtra("fromRequestDetail", true)
                                        startActivityWithDefaultAnimations(intent)
                                    }

                                } else {
                                    Toast.makeText(mContext, responseMessage, Toast.LENGTH_LONG)
                                        .show()
                                    rejectCurrentOrder(0)
                                }

                            })
                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }

                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }

    private fun callListener(value: Boolean) {
        val i = Intent()
        i.putExtra("accept_reject", value)
        setResult(RESULT_OK, i)
        finish()
    }


    override fun onBackPressed() {
        finishWithAnimation()
    }

    private fun rejectCurrentOrder(isAccept: Int) {
        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {
                jsonObject.put(
                    SocketConstants.KeyUserId, (SharedPreferenceUtils.getModelPreferences(
                        KEY_USER,
                        User::class.java
                    ) as User).userId.toString()
                )
                jsonObject.put(
                    SocketConstants.KeyCustomerId,
                    orderDetail?.customerDetail!!.userId.toString()
                )
                jsonObject.put(SocketConstants.KeyOrderId, orderDetail!!.orderId.toString())
                jsonObject.put(SocketConstants.KeyIsAccept, isAccept.toString())
                jsonObject.put(SocketConstants.KeyDriverIds, "")

                SocketConstants.socketIOClient!!.emit(SocketConstants.SocketAcceptRejectOrder,
                    jsonObject, Ack {
                        try {
                            val acceptResponse = JSONObject(it[0].toString())
                            val responseStatus = acceptResponse.getString("status").toInt()
                            mContext.runOnUiThread(Runnable {
                                if (responseStatus == 0) {
                                    if (remoteMessage == "") {
                                        Log.e("From Home", "==>")
                                        callListener(false)
                                    } else {
                                        Log.e("From Notification", "==>")
                                        RxBus.instance?.publish("refreshHomeScreen")
                                        onBackPressed()
                                    }

                                }
                            })
                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }

                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }

    //REMOVE ALL REQUEST FROM CURRENT QUEUE AND LEFT THE GROUP
    private fun clearRequestQueue() {
        for (dic in SharedPreferenceUtils.getOrderRequestQueue()) {
            leaveOrderRoom((dic["order_id"] as Double).toInt())
        }
        SharedPreferenceUtils.removeAllOrderFromRequestQueue()
    }


    private fun leaveOrderRoom(orderId: Int) {
        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {
                jsonObject.put(
                    SocketConstants.KeyUserId, (SharedPreferenceUtils.getModelPreferences(
                        KEY_USER,
                        User::class.java
                    ) as User).userId
                )
                jsonObject.put(
                    SocketConstants.KeyOrderId, orderId
                )

                SocketConstants.socketIOClient!!.emit(
                    SocketConstants.SocketLeaveOrderRoom,
                    jsonObject
                )

            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }

    //DRAWING ROUTE...
    private fun requestDirection() {
        jsDrawRoute = JSDrawRoute(mContext, orderDetail!!, mGoogleMap, false)
        jsDrawRoute?.setOnDrawListener(object : JSDrawRoute.DrawEventListener {
            override fun onDrawListener(direction: Direction?, error: Boolean) {
                if (direction != null && !error) {
                    onDirectionSuccess(direction)
                } else {
                    Utility.toastLong(mContext, "Something went wrong in drawing route")
                }
            }
        })
        jsDrawRoute?.initDrawRoute(false)
    }


    private fun onDirectionSuccess(direction: Direction) {
        if (direction.isOK) {
            val route = direction.routeList[0]
            val legCount = route.legList.size
            for (index in 0 until legCount) {
                val leg = route.legList[index]
                val stepList = leg.stepList
                val polylineOptionList = DirectionConverter.createTransitPolyline(
                    mContext,
                    stepList,
                    5,
                    Color.parseColor("#1c77f2"),
                    3,
                    Color.BLUE
                )
                for (polylineOption in polylineOptionList) {
                    mGoogleMap.addPolyline(polylineOption)
                }
            }
            jsDrawRoute?.setCameraUpdateBounds(route)
        } else {
            Utility.toastLong(mContext, "Something went wrong in drawing route")
        }
    }

}