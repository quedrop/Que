package com.quedrop.driver.ui.homeFragment.view

import android.annotation.SuppressLint
import android.app.Activity
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.os.Bundle
import android.os.Handler
import android.text.SpannableStringBuilder
import android.text.method.LinkMovementMethod
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.SupportMapFragment
import com.google.gson.Gson
import com.google.gson.JsonParser
import com.google.gson.reflect.TypeToken
import com.psp.google.direction.model.Direction
import com.psp.google.direction.util.DirectionConverter
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import com.quedrop.driver.api.authentication.LoggedInUserCache
import com.quedrop.driver.base.BaseFragment
import com.quedrop.driver.base.JSDrawRoute
import com.quedrop.driver.base.QueDropDriverApplication
import com.quedrop.driver.base.extentions.makeClickSpannable
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.subscribeAndObserveOnMainThread
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.MainOrderResponse
import com.quedrop.driver.service.model.Orders
import com.quedrop.driver.service.model.User
import com.quedrop.driver.service.request.GetManualStorePaymentRequest
import com.quedrop.driver.socket.SocketConstants
import com.quedrop.driver.socket.SocketHandler
import com.quedrop.driver.socket.driversocket.DriverRepository
import com.quedrop.driver.socket.model.DriverStatusRequest
import com.quedrop.driver.ui.earnings.view.ViewAllOrderActivity
import com.quedrop.driver.ui.futureorder.FutureOrderFragment
import com.quedrop.driver.ui.homeFragment.viewModel.HomeViewModel
import com.quedrop.driver.ui.mainActivity.view.MainActivity
import com.quedrop.driver.ui.mainFragment.MainFragment
import com.quedrop.driver.ui.order.adapter.CurrentOrderStoreListAdapter
import com.quedrop.driver.ui.requestDetailsFragment.RequestDetailActivity
import com.quedrop.driver.utils.*
import com.quedrop.driver.utils.SharedPreferenceUtils.Companion.getCurrentOrderRequest
import com.quedrop.driver.utils.SharedPreferenceUtils.Companion.getOrderRequestQueue
import com.quedrop.driver.utils.localnotification.MyNotificationPublisher.Companion.getNotification
import com.quedrop.driver.utils.localnotification.MyNotificationPublisher.Companion.scheduleNotification
import io.socket.client.Ack
import kotlinx.android.synthetic.main.fragment_home.*
import org.json.JSONException
import org.json.JSONObject
import org.ocpsoft.prettytime.PrettyTime
import java.text.SimpleDateFormat
import java.util.*
import javax.inject.Inject


class HomeFragment : BaseFragment() {

    companion object {
        fun newInstance(remoteMessage: String): HomeFragment {
            return HomeFragment()
        }
    }

    private var notificationManager: NotificationManager? = null
    private var driverMapView: DriverMapView? = null
    private var orderDetail: Orders? = null
    private var socketHandler: SocketHandler? = null
    lateinit var homeViewModel: HomeViewModel
    private var jsDrawRoute: JSDrawRoute? = null
    lateinit var mGoogleMap: GoogleMap
    private var profileImagePath: String = ""
    private lateinit var mContext: Activity

    //Earning
    private var earningData: MainOrderResponse? = null

    @Inject
    lateinit var driverRepository: DriverRepository

    @Inject
    lateinit var loggedInUserCache: LoggedInUserCache

    override fun onAttach(context: Context) {
        super.onAttach(context)
        if (context is MainActivity) {
            mContext = context
        }
    }

    override fun onAttach(activity: Activity) {
        super.onAttach(activity)
        if (activity is MainActivity) {
            mContext = activity
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        QueDropDriverApplication.component.inject(this)

    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_home, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        LocalBroadcastManager.getInstance(requireContext()).registerReceiver(
            eventUpdate,
            IntentFilter(BroadCastConstant.BROADCAST_EVENT_CHANGE)
        )

        notificationManager = mContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        homeViewModel = HomeViewModel(appService)
        socketHandler = SocketHandler(mContext)
        socketHandler?.socketListener = (this)

        val map = childFragmentManager.findFragmentById(R.id.mapFragment) as SupportMapFragment
        map.getMapAsync { googleMap ->
            mGoogleMap = googleMap
            driverMapView = DriverMapView(
                false,
                map,
                googleMap,
                homeViewModel
            )

            driverMapView?.clearMap()
        }

        (activity as MainActivity).intent?.let { intent ->

            intent.getStringExtra("remote_message").let {
                if (it != null) {
                    if (!it.isNullOrBlank()) {
                        val jsonObject = JSONObject(it)
                        if (jsonObject.has("notification_type")) {
                            val notificationType = jsonObject.getString("notification_type")
                            if (notificationType.toInt() == ENUMNotificationType.NOTIFICATION_DRIVER_WEEKLY_PAYMENT.posVal || notificationType.toInt() == ENUMNotificationType.NOTIFICATION_MANUAL_STORE_PAYMENT.posVal) {
                                if (parentFragment is MainFragment) {
                                    (parentFragment!! as MainFragment).openEarningScreen()
                                }
                            }
                        }
                    }
                }
            }
            intent.getBooleanExtra(Key__Manual_payment, false).let {
                if (it) {
                    if (parentFragment is MainFragment) {
                        (parentFragment!! as MainFragment).openEarningScreen()
                    }
                }
            }

            intent.getBooleanExtra(Key_Earning_payment, false).let {
                if (it) {
                    if (parentFragment is MainFragment) {
                        (parentFragment!! as MainFragment).openEarningScreen()
                    }
                }
            }

            if (intent.hasExtra("fromRequestDetail")) {
                intent.getBooleanExtra("fromRequestDetail", false).let {
                    if (it) {
                        if (parentFragment is MainFragment) {
                            (parentFragment!! as MainFragment).openOderScreen()
                        }
                    }
                }
            }
        }

        initViews()

        //refresh home
        RxBus.instance?.listen()?.subscribe {
            if (it == "refreshHomeScreen") {
                notificationManager?.cancelAll()
                setupAcceptReject(false)
            }
        }?.autoDispose(compositeDisposable)

        if (getCurrentOrderRequest() == 0) {
        } else {
            getOrderDetails(getCurrentOrderRequest())
        }
    }


    private fun initViews() {
        //Observer.....
        homeViewModel.countDownResponse.observe(
            activity as MainActivity,
            Observer { remainingTime ->
                tvTime.text = remainingTime
                if (remainingTime == "00:00") {
                    //For testing remove above if loop and uncomment below line
                    currentOrderView.visibility = View.GONE
                    driverMapView?.setCurrentMarker()
                    rejectCurrentRequest(0)
                    SharedPreferenceUtils.setBoolean(KEY_IS_ANY_CURRENT_ORDER, false)
                    SharedPreferenceUtils.setString(KEY_LAST_ORDER_ID, "")
                }
            })

        mainViewModel.isError.observe(activity as MainActivity, Observer {
            showAlertMessage(mContext, it.toString())
        })

        mainViewModel.earningObserver.observe(activity as MainActivity, Observer { it ->
            cvEarn.visibility = View.VISIBLE
            ivEarningView.visibility = View.GONE
            currentOrderView.visibility = View.GONE
            ivGoOnline.visibility = View.GONE
            ivEarn1.setBackgroundResource(R.drawable.ic_ellipse)
            ivEarn2.setBackgroundResource(R.drawable.ic_ellipse_gray)
            earningData = it
            tvEarnDollar.text = it.data.today_total_earning.toString() + " " + CURRENCY
            tvEarnPastOrder.text = "LAST ORDER"
            val cal = earningData?.data?.last_order_date?.getCalenderDate(dateFormat)
            val time = PrettyTime()
            tvEarnTime.text = "Last order at " + time.format(cal)
            btnViewAllOrder.setText(R.string.view_all_orders)
        })

        onCLickView()
        checkDriverStatus()
    }


    private fun checkDriverStatus() {
        loggedInUserCache.getLoggedInUser()?.userId?.let { userId ->
            driverRepository.getDriverStatus(DriverStatusRequest(userId))
                .subscribeAndObserveOnMainThread {
                    if (it) {
                        onlineDriver()
                    } else {
                        offlineDriver()
                    }
                }.autoDispose()
        }
    }

    @SuppressLint("SetTextI18n")
    private fun onCLickView() {

        ivGoOnline.throttleClicks().subscribe {
            if (ivGoOnline.contentDescription == "offline") {
                changeDriverStatus(1, false)
            } else {
                changeDriverStatus(0, false)
            }

        }.autoDispose(compositeDisposable)

        tvAccept.throttleClicks().subscribe {
            acceptCurrentOrder(1)
        }.autoDispose(compositeDisposable)

        tvReject.throttleClicks().subscribe {
            rejectCurrentRequest(0)
        }.autoDispose(compositeDisposable)

        currentOrderView.throttleClicks().subscribe {
            val intent = Intent(mContext, RequestDetailActivity::class.java)
            intent.putExtra("orderDetail", Gson().toJson(orderDetail))
            startActivityForResult(intent, 309)

        }.autoDispose(compositeDisposable)

        ivPendingOrder.throttleClicks().subscribe {
            (getActivity() as MainActivity).navigateToFragment(FutureOrderFragment.newInstance())
        }.autoDispose(compositeDisposable)

        //Earn Module
        ivEarningView.throttleClicks().subscribe {
            val c = Calendar.getInstance()
            getEarningDataForHome(getDate(c))
        }.autoDispose(compositeDisposable)

        ivEarnBack.throttleClicks().subscribe {
            cvEarn.visibility = View.GONE
            ivEarningView.visibility = View.VISIBLE
            ivGoOnline.visibility = View.VISIBLE
        }.autoDispose(compositeDisposable)

        btnViewAllOrder.throttleClicks().subscribe {
            if (btnViewAllOrder.text == getString(R.string.view_all_orders)) {
                val intent = Intent(mContext, ViewAllOrderActivity::class.java)
                intent.putExtra(EARNING_DATA, Gson().toJson(earningData?.data?.orders))
                startActivityWithDefaultAnimations(intent)

            } else {
                if (parentFragment is MainFragment) {
                    (parentFragment!! as MainFragment).openEarningScreen()
                }
            }
        }.autoDispose(compositeDisposable)

        ivEarn1.throttleClicks().subscribe {
            ivEarn1.setBackgroundResource(R.drawable.ic_ellipse)
            ivEarn2.setBackgroundResource(R.drawable.ic_ellipse_gray)


            tvEarnDollar.text = earningData?.data?.today_total_earning.toString() + " " + CURRENCY
            tvEarnPastOrder.text = getString(R.string.last_order)

            val cal = earningData?.data?.last_order_date?.getCalenderDate(dateFormat)
            val time = PrettyTime()
            tvEarnTime.text = "Last order at " + time.format(cal)
            btnViewAllOrder.setText(R.string.view_all_orders)

        }.autoDispose(compositeDisposable)

        ivEarn2.throttleClicks().subscribe {
            ivEarn2.setBackgroundResource(R.drawable.ic_ellipse)
            ivEarn1.setBackgroundResource(R.drawable.ic_ellipse_gray)

            tvEarnDollar.text = earningData?.data?.today_total_earning.toString() + " " + CURRENCY
            tvEarnPastOrder.text = getString(R.string.today)
            tvEarnTime.text = earningData?.data?.today_total_order.toString() + " Trip Completed"
            btnViewAllOrder.setText(R.string.see_weekly_summary)

        }.autoDispose(compositeDisposable)
    }

    private fun getDate(selectedDate: Calendar?): String {
        val date = selectedDate?.time
        val format1 = SimpleDateFormat("dd-MMMM-yyyy", Locale.getDefault())
        val formatedDate = format1.format(date!!)
        val format2 = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val orderDate = format2.format(date)
        return orderDate
    }

    private fun getEarningDataForHome(date: String) {
        val getManualStorePaymentRequest = GetManualStorePaymentRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            SharedPreferenceUtils.getInt(KEY_USERID),
            date
        )
        mainViewModel.getEarningDataForHomeRequest(getManualStorePaymentRequest)
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 309) {
            if (resultCode == Activity.RESULT_OK) {
                val valueResult = data?.getBooleanExtra("accept_reject", false)!!
                setupAcceptReject(valueResult)
            } else {
                Log.e("onActivityResult: ", "==> cancelled")
            }
        }
    }

    private fun setupAcceptReject(valueResult: Boolean) {
        currentOrderView.visibility = View.GONE
        notificationManager?.cancelAll()
        if (valueResult) {
            SharedPreferenceUtils.removeCurrentOrderRequest(orderDetail?.orderId!!.toInt())
            clearRequestQueue()
            driverMapView?.setCurrentMarker()
            homeViewModel.stopCountDown()

            RxBus.instance?.publish("refreshOrder")

            if (parentFragment is MainFragment) {
                (parentFragment!! as MainFragment).openOderScreen()
            }
        } else {
            //TODO CRASH: Caused by: org.json.JSONException: No value for order_details
            val orderDetail = SharedPreferenceUtils.getSingleOrderDetailsRequestFromQueue()
            SharedPreferenceUtils.removeCurrentOrderRequest(orderDetail?.orderId!!.toInt())
            SharedPreferenceUtils.removeOrderFromRequestQueue(orderDetail.orderId.toInt())
            loadNextOrderIfThere()
            driverMapView?.setCurrentMarker()
            homeViewModel.stopCountDown()
        }

    }

    fun onPageSelected(position: Int) {
        if (getCurrentOrderRequest() == 0) {
            currentOrderView.visibility = View.GONE
            if (ivGoOnline.contentDescription == "online")
                driverMapView?.setCurrentMarker()
        }

        updateLocationToServer()
    }

    private fun onlineDriver() {
        ivGoOnline.setImageDrawable(
            ContextCompat.getDrawable(
                mContext,
                R.drawable.ic_driver_online
            )
        )
        ivGoOnline.contentDescription = "online"
        Handler().postDelayed({ driverMapView?.setCurrentMarker() }, 500)
    }

    private fun offlineDriver() {
        ivGoOnline.setImageDrawable(
            ContextCompat.getDrawable(
                mContext,
                R.drawable.ic_driver_offline
            )
        )
        ivGoOnline.contentDescription = "offline"
        driverMapView?.clearMap()
        currentOrderView.visibility = View.GONE
    }

    private fun changeDriverStatus(isOnline: Int, onDestroy: Boolean) {
        loggedInUserCache.getLoggedInUser()?.userId?.let { userId ->
            driverRepository.changeDriverStatus(DriverStatusRequest(userId, isOnline))
                .subscribeAndObserveOnMainThread {
                    if (it.isSuccess()) {
                        if (!onDestroy) {
                            if (it.isDriverOnline()) {
                                onlineDriver()
                            } else {
                                offlineDriver()
                            }
                        }
                    } else {
                        it.message?.let { message ->
                            showInfoMessage(activity, message)
                        }
                    }
                }.autoDispose()
        }
    }


    // get Socket event
    private val eventUpdate = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val events = intent.getStringExtra(BroadCastConstant.BROADCAST_KEY_EVENT)!!
            try {
                val jsonObject =
                    JSONObject(intent.getStringExtra(BroadCastConstant.BROADCAST_KEY_OBJ)!!)
                parseResponse(events, jsonObject)

            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }

    private fun parseResponse(event: String, argument: JSONObject) {
        when (event) {
            SocketConstants.SocketGetOrderRequest -> {
                val orderId = argument.getString("order_id")

                val dicDetail = argument.getString("order_details")
                val parser = JsonParser()
                val mJson = parser.parse(dicDetail)
                val gson = Gson()

                val objorderDetail = gson.fromJson(mJson, Orders::class.java)

                joinOrderRoom(objorderDetail.orderId)

                val type = object : TypeToken<HashMap<String, Any?>>() {}.type
                val result = gson.fromJson<HashMap<String, Any?>>(argument.toString(), type)

                SharedPreferenceUtils.addOrderRequestToQueue(result)


                if (getCurrentOrderRequest() == 0) {
                    SharedPreferenceUtils.setCurrentOrderRequest(objorderDetail.orderId.toInt())
                    showCurrentOrder(objorderDetail)
                } else {
                    //GENERATE LOCAL NOTIICATION
                }
            }
            SocketConstants.SocketDriverVerificationChange -> {
                val userId = argument.getString("user_id")
                val isDriverVerified = argument.getString("is_driver_verified")

                val user =
                    (SharedPreferenceUtils.getModelPreferences(KEY_USER, User::class.java)) as User?

                if (user != null && user.userId == userId.toInt()) {
                    user.isDriverVerified = isDriverVerified.toInt()
                    SharedPreferenceUtils.setModelPreferences(KEY_USER, user)

                    if (user.isDriverVerified == 0) {
                        offlineDriver()

                        scheduleNotification(
                            mContext,
                            getNotification(
                                mContext,
                                getString(R.string.app_name),
                                getString(R.string.driver_refute_noti)
                                , ""
                            ),
                            100
                        )
                    } else {
                        scheduleNotification(
                            mContext,
                            getNotification(
                                mContext,
                                getString(R.string.app_name),
                                getString(R.string.driver_verified)
                                , ""
                            ),
                            100
                        )
                    }
                }
            }

            SocketConstants.SocketOrderAccepted -> {
                val userId = argument.getString("driver_id")
                val message = argument.getString("message")
                val status = argument.getString("status").toInt()
                val orderId = argument.getString("order_id").toInt()

                if (status == 1) {
                    val user = (SharedPreferenceUtils.getModelPreferences(
                        KEY_USER,
                        User::class.java
                    )) as User?
                    if (user != null && user.userId == userId.toInt()) {
                        notificationManager?.cancelAll()
                        currentOrderView.visibility = View.GONE
                        SharedPreferenceUtils.removeCurrentOrderRequest(orderId)
                        SharedPreferenceUtils.removeOrderFromRequestQueue(orderId)
                        loadNextOrderIfThere()
                        driverMapView?.setCurrentMarker()
                        homeViewModel.stopCountDown()

                        scheduleNotification(
                            mContext,
                            getNotification(mContext, getString(R.string.app_name), message, ""),
                            100
                        )
                    }
                }
            }
        }
    }

    @SuppressLint("SetTextI18n")
    private fun showCurrentOrder(objorderDetail: Orders) {

        orderDetail = objorderDetail

        tvAccept.visibility = View.VISIBLE
        tvReject.visibility = View.VISIBLE
        tvAccepted.visibility = View.GONE

//       TODO java.lang.IllegalStateException: Fragment HomeFragment{9a6fb3} (a381bb51-e1ae-4bd2-81a6-f62b7cb0a6e8)} not attached to an activity.
//    at androidx.fragment.app.Fragment.requireActivity(Fragment.java:833)
//    at com.quedrop.driver.ui.homeFragment.view.HomeFragment.showCurrentOrder(HomeFragment.kt:578)

        homeViewModel.currentOrderViewShow.observe(activity as MainActivity, Observer {
            currentOrderView.visibility = View.VISIBLE

            profileImagePath = if (!isNetworkUrl(orderDetail!!.customerDetail.userImage!!)) {
                BuildConfig.BASE_URL + ImageConstant.USER_STORE + orderDetail!!.customerDetail.userImage
            } else {
                orderDetail!!.customerDetail.userImage!!
            }
            Utility.loadGlideImage(
                activity,
                profileImagePath,
                R.drawable.ic_user_placeholder,
                ivProfileImage
            )
            tvUserName.text =
                orderDetail?.customerDetail?.firstName + " " + orderDetail?.customerDetail?.lastName
            userRating.rating = orderDetail?.customerDetail?.rating!!.toFloat()
            tvAddress.text = orderDetail?.deliveryAddress ?: ""
//            tvOrderNo.text = " Order ID: #" + orderDetail?.orderId
//            tvOrderNo.text = setOrderIdSpan(orderDetail).toString()

            tvOrderNo.text = setOrderText(orderDetail!!)

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
            requestDirection()

        })
        homeViewModel.startCountDown(orderDetail?.requestDate!!)
    }

    private fun setOrderText(orders: Orders): String {
        var orderText: String = ""
        if (orders.deliveryOption == EXPRESS_DELIVERY) {
            orderText = " Order ID: #" + orderDetail?.orderId + " with " + "Express Delivery"
        } else {
            orderText = " Order ID: #" + orderDetail?.orderId
        }
        return orderText
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
                            orderDetail = gson.fromJson(mJson, Orders::class.java)

                            if (orderDetail!!.orderId != null)
                                joinOrderRoom(orderDetail!!.orderId!!.toInt())
                            mContext.runOnUiThread {
                                showCurrentOrder(orderDetail!!)
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

    private fun updateLocationToServer() {
        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {
                jsonObject.put(
                    SocketConstants.KeyUserId, (SharedPreferenceUtils.getModelPreferences(
                        KEY_USER, User::class.java
                    ) as User).userId
                )
                jsonObject.put(
                    SocketConstants.KeyLatitude, SharedPreferenceUtils.getString(
                        KEY_LATITUDE
                    )
                )
                jsonObject.put(
                    SocketConstants.KeyLongitude, SharedPreferenceUtils.getString(
                        KEY_LONGITUDE
                    )
                )
                SocketConstants.socketIOClient!!.emit(
                    SocketConstants.SocketUpdateDriverLocation,
                    jsonObject
                )

            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }

    private fun joinOrderRoom(orderId: Int) {
        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {
                jsonObject.put(
                    SocketConstants.KeyUserId, (SharedPreferenceUtils.getModelPreferences(
                        KEY_USER,
                        User::class.java
                    ) as User).userId
                )
                jsonObject.put(SocketConstants.KeyOrderId, orderId)

                SocketConstants.socketIOClient!!.emit(
                    SocketConstants.SocketJoinOrderRoom,
                    jsonObject
                )

            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
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

    private fun acceptCurrentOrder(isAccept: Int) {
        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {
                val dic =
                    SharedPreferenceUtils.getSingleOrderRequestQueue(orderDetail!!.orderId!!.toInt())

                val driverIdList = dic["order_drivers"].toString()
                jsonObject.put(
                    SocketConstants.KeyUserId, (SharedPreferenceUtils.getModelPreferences(
                        KEY_USER,
                        User::class.java
                    ) as User).userId
                )
                jsonObject.put(
                    SocketConstants.KeyCustomerId,
                    orderDetail!!.customerDetail.userId.toString()
                )
                jsonObject.put(SocketConstants.KeyOrderId, orderDetail!!.orderId.toInt())
                jsonObject.put(SocketConstants.KeyIsAccept, isAccept)
                jsonObject.put(
                    SocketConstants.KeyDriverIds,
                    driverIdList
                )

                SocketConstants.socketIOClient!!.emit(SocketConstants.SocketAcceptRejectOrder,
                    jsonObject, Ack {
                        try {
                            val acceptResponse = JSONObject(it[0].toString())
                            val responseStatus = acceptResponse.getString("status").toInt()
                            val responseMessage = acceptResponse.getString("message").toString()
                            mContext.runOnUiThread(Runnable {
                                if (responseStatus == 1) {
                                    notificationManager?.cancelAll()

                                    tvAccept.visibility = View.GONE
                                    tvReject.visibility = View.GONE
                                    tvAccepted.visibility = View.VISIBLE
                                    SharedPreferenceUtils.removeCurrentOrderRequest(orderDetail!!.orderId!!.toInt())
                                    clearRequestQueue()
                                    driverMapView?.setCurrentMarker()
                                    homeViewModel.stopCountDown()

                                    Handler().postDelayed({

                                        RxBus.instance?.publish("refreshOrder")

                                        if (parentFragment is MainFragment) {
                                            (parentFragment!! as MainFragment).openOderScreen()
                                        }

                                    }, 1000)

                                    orderDetail = null

                                } else {
                                    showInfoMessage(activity, responseMessage)
                                    driverMapView?.setCurrentMarker()
                                    rejectCurrentRequest(0)
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

    private fun rejectCurrentRequest(isAccept: Int) {
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
                    SocketConstants.KeyCustomerId,
                    orderDetail?.customerDetail!!.userId
                )
                jsonObject.put(SocketConstants.KeyOrderId, orderDetail!!.orderId)
                jsonObject.put(SocketConstants.KeyIsAccept, isAccept)
                jsonObject.put(SocketConstants.KeyDriverIds, "")

                SocketConstants.socketIOClient!!.emit(SocketConstants.SocketAcceptRejectOrder,
                    jsonObject, Ack {
                        try {

                            val acceptResponse = JSONObject(it[0].toString())
                            val responseStatus = acceptResponse.getString("status").toInt()
                            mContext.runOnUiThread(Runnable {
                                if (responseStatus == 0) {
                                    notificationManager?.cancelAll()

                                    currentOrderView.visibility = View.GONE
                                    SharedPreferenceUtils.removeCurrentOrderRequest(orderDetail!!.orderId)
                                    SharedPreferenceUtils.removeOrderFromRequestQueue(orderDetail!!.orderId)
                                    loadNextOrderIfThere()
                                    driverMapView?.setCurrentMarker()
                                    homeViewModel.stopCountDown()
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
        for (dic in getOrderRequestQueue()) {
            leaveOrderRoom((dic["order_id"] as Double).toInt())
        }
        SharedPreferenceUtils.removeAllOrderFromRequestQueue()
    }

    //LOAD NEXT ORDER
    private fun loadNextOrderIfThere() {
        if (getOrderRequestQueue().size > 0) {
            //LOAD NEXT REQUEST
            val objorderDetail = SharedPreferenceUtils.getSingleOrderDetailsRequestFromQueue()
            if (getCurrentOrderRequest() == 0) {
                SharedPreferenceUtils.setCurrentOrderRequest(objorderDetail!!.orderId!!.toInt())
                mContext.runOnUiThread(Runnable {
                    showCurrentOrder(objorderDetail)
                })
            }
        }
    }

    override fun onResume() {
        super.onResume()
        updateLocationToServer()
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

    override fun onDestroy() {
        super.onDestroy()
        changeDriverStatus(0, true)
    }

    private fun setOrderIdSpan(orderDetail: Orders?) {

        val agreementSpan = SpannableStringBuilder()
        agreementSpan.append("Order Id:" + " ")
        agreementSpan.append(getIdSpan(orderDetail?.orderId.toString()))

        if (orderDetail?.deliveryOption == EXPRESS_DELIVERY) {
            agreementSpan.append("with" + " ")
            agreementSpan.append(getExpressSpan())
        }

        tvOrderNo.text = agreementSpan
        tvOrderNo.movementMethod = LinkMovementMethod.getInstance()

    }

    private fun getIdSpan(orderId: String) = orderId.makeClickSpannable(
        {
        },
        ContextCompat.getColor(activity, R.color.colorBlack),
        false,
        false,
        orderId,
        null
    )

    private fun getExpressSpan() = getString(R.string.express_delivery).makeClickSpannable(
        {
        },
        ContextCompat.getColor(activity, R.color.colorBlack),
        false,
        false,
        resources.getString(R.string.express_delivery),
        null
    )
}
