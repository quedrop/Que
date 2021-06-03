package com.quedrop.driver.ui.futureorder

import android.content.Context
import android.graphics.Color
import android.os.Bundle
import android.view.View
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
import com.quedrop.driver.service.model.RecurringOrderEntries
import com.quedrop.driver.service.model.Stores
import com.quedrop.driver.service.model.User
import com.quedrop.driver.service.request.GetFutureSingleOrderRequest
import com.quedrop.driver.socket.SocketConstants
import com.quedrop.driver.ui.homeFragment.view.DriverMapView
import com.quedrop.driver.ui.homeFragment.viewModel.HomeViewModel
import com.quedrop.driver.ui.order.adapter.CurrentOrderStoreListAdapter
import com.quedrop.driver.utils.*
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.SupportMapFragment
import com.psp.google.direction.model.Direction
import com.psp.google.direction.util.DirectionConverter
import io.socket.client.Ack
import kotlinx.android.synthetic.main.activity_future_order_detail.*
import kotlinx.android.synthetic.main.activity_order_details.rvOrderDetails
import kotlinx.android.synthetic.main.fragment_future_order.*
import kotlinx.android.synthetic.main.toolbar_normal.*
import kotlinx.android.synthetic.main.toolbar_normal.tvTitle
import org.json.JSONException
import org.json.JSONObject

class FutureOrderDetailActivity : BaseActivity() {

    private var mContext: Context? = null
    private var orderDetail: Orders? = null
    private var storeData: MutableList<Stores>? = mutableListOf()
    private var recurrenceOrderData: MutableList<RecurringOrderEntries>? = mutableListOf()
    private var currentStoreAdapter: CurrentOrderStoreListAdapter? = null
    private var recurrenceOrderAdapter: RecurrenceOrderAdapter? = null
    private var profileImagePath: String = ""

    private lateinit var homeViewModel: HomeViewModel
    private var rideMapView: DriverMapView? = null
    private var jsDrawRoute: JSDrawRoute? = null
    lateinit var mGoogleMap: GoogleMap

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_future_order_detail)
        mContext = this

        initViews()
    }

    private fun getFutureSingleOrder(orderId: String?) {

        val getFutureSingleOrderRequest = GetFutureSingleOrderRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            SharedPreferenceUtils.getInt(KEY_USERID),
            orderId?.toInt()!!,
            "Asia/Kolkata",
            1,
            0
        )
        mainViewModel.getFutureSingleOrderRequest(getFutureSingleOrderRequest)
    }

    private fun initViews() {
        setUpToolBar()

        if (intent != null) {
            val orderId = intent.getStringExtra("order_id")
            getFutureSingleOrder(orderId)
        }

        homeViewModel = HomeViewModel(appService)
        val map =
            supportFragmentManager.findFragmentById(R.id.mapViewFuture) as SupportMapFragment

        map.getMapAsync { googleMap ->
            mGoogleMap = googleMap
            rideMapView = DriverMapView(
                false,
                map,
                googleMap,
                homeViewModel
            )
            rideMapView?.clearMap()

            googleMap.uiSettings.isZoomControlsEnabled = false
            googleMap.uiSettings.isZoomGesturesEnabled = false
            googleMap.uiSettings.isScrollGesturesEnabled = false
            googleMap.uiSettings.isScrollGesturesEnabledDuringRotateOrZoom = false
        }


        observableModal()
        setUpStoreData()
        setUpRecurrenceOrderData()
    }

    private fun setUpToolBar() {
        tvTitle.text = resources.getString(R.string.order_details)
        ivBack.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)
    }

    private fun observableModal() {
        //obeserver...
        mainViewModel.isLoading.observe(this, androidx.lifecycle.Observer {
            if (it) {
                showProgress()
            } else {
                hideProgress()
            }
        })

        mainViewModel.isError.observe(this, androidx.lifecycle.Observer {
            storeData?.clear()
            currentStoreAdapter?.notifyDataSetChanged()
            noFutureOrderData.text = it
        })

        mainViewModel.futureSingleOrderList.observe(this, androidx.lifecycle.Observer {
            if (it != null) {
                layoutFutureOrder.visibility = View.VISIBLE
                constCustomer.visibility = View.VISIBLE
                setUpData(it)
            }
        })
    }

    private fun setUpData(it: Orders) {
        orderDetail = it
        requestDirection()
        val customerDetail = it.customerDetail

        storeData?.clear()
        storeData?.addAll(it.stores)
        currentStoreAdapter?.notifyDataSetChanged()

        recurrenceOrderData?.clear()
        recurrenceOrderData?.addAll(it.recurringOrderEntries)
        recurrenceOrderAdapter?.notifyDataSetChanged()

        if (it.recurringType == "Once") {
            tvRecurringOrderDate.text =
                convertUTCDateToLocalDate(it.repeatUntilDate.toString())
        } else if (it.recurringType == "Weekly") {

            val time = convertUTCDateToLocalDate(
                it.repeatUntilDate.toString(),
                "hh:mm a"
            )
            tvRecurringOrderDate.text =
                it.recurredOn + " at " + time

        } else if (it.recurringType == "Monthly") {
            val time = convertUTCDateToLocalDate(
                it.repeatUntilDate.toString(),
                " hh:mm a"
            )
            tvRecurringOrderDate.text = "Monthly at " + time
        } else {
            tvRecurringOrderDate.text = "Everyday"
        }
        tvRUserName.text = customerDetail.firstName + " " + customerDetail.lastName
        tvRAddress.text = customerDetail.address
        userRRating.rating = customerDetail.rating.toFloat()
        if (orderDetail?.driverNote?.isNotEmpty()!!) {
            txtDriverNote.visibility = View.VISIBLE
            txtDriverNoteView.visibility = View.VISIBLE
            txtDriverNote.text = orderDetail?.driverNote.toString()
        } else {
            txtDriverNote.visibility = View.GONE
            txtDriverNoteView.visibility = View.GONE
        }

        val userImage = it.customerDetail.userImage
        if (!isNetworkUrl(userImage!!)) {
            profileImagePath = BuildConfig.BASE_URL + ImageConstant.USER_STORE + userImage
        } else {
            profileImagePath = userImage
        }

        Glide.with(this)
            .load(profileImagePath)
            .placeholder(R.drawable.ic_user_placeholder)
            .circleCrop()
            .into(tvRUserImage)

    }

    private fun setUpStoreData() {
        rvOrderDetails.layoutManager = LinearLayoutManager(mContext)
        currentStoreAdapter = CurrentOrderStoreListAdapter(
            true,
            this,
            "",
            storeData,
           ""
        )
        rvOrderDetails.adapter = currentStoreAdapter
    }

    private fun setUpRecurrenceOrderData() {
        rvRecurrenceOrders.layoutManager = LinearLayoutManager(mContext)
        recurrenceOrderAdapter = RecurrenceOrderAdapter(
            this,
            recurrenceOrderData!!
        )
        rvRecurrenceOrders.adapter = recurrenceOrderAdapter

        recurrenceOrderAdapter?.apply {
            onAcceptClick = { view, adapterPosition ->
                acceptRejectCurrentOrder(isAccept = 1, position = adapterPosition)
            }
            onRejectClick = { view, adapterPosition ->
                acceptRejectCurrentOrder(isAccept = 0, position = adapterPosition)
            }
        }
    }

    private fun acceptRejectCurrentOrder(isAccept: Int, position: Int) {

        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {

                jsonObject.put(
                    SocketConstants.KeyUserId,
                    (SharedPreferenceUtils.getModelPreferences(
                        KEY_USER,
                        User::class.java
                    ) as User).userId
                )
                jsonObject.put(SocketConstants.KeyRecurringOrderId, orderDetail!!.recurringOrderId)
                jsonObject.put(
                    SocketConstants.KeyRecurringEntryId,
                    orderDetail!!.recurringOrderEntries[position].recurring_entry_id
                )
                jsonObject.put(SocketConstants.KeyIsAccept, isAccept)

                SocketConstants.socketIOClient!!.emit(
                    SocketConstants.SocketAcceptRejectRecurringOrder,
                    jsonObject, Ack {
                        try {
                            val acceptResponse = JSONObject(it[0].toString())
                            val responseStatus = acceptResponse.getString("status").toInt()
                            val responseMessage = acceptResponse.getString("message").toString()
                            runOnUiThread(Runnable {
                                if (responseStatus == 1) {
                                    getFutureSingleOrder(orderDetail!!.recurringOrderId.toString())
                                    recurrenceOrderAdapter?.notifyDataSetChanged()
                                    showInfoMessage(this, responseMessage)
                                } else {
                                    showAlertMessage(this, responseMessage)
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

    override fun onBackPressed() {
        super.onBackPressed()
        finishWithAnimation()
    }

    //DRAWING ROUTE...
    private fun requestDirection() {
        jsDrawRoute = JSDrawRoute(this, orderDetail!!, mGoogleMap, false)
        jsDrawRoute?.setOnDrawListener(object : JSDrawRoute.DrawEventListener {
            override fun onDrawListener(direction: Direction?, t: Boolean) {
                if (direction != null && !t) {
                    onDirectionSuccess(direction)
                } else {
                    Utility.toastLong(applicationContext, "Something went wrong in drawing route")
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
                    this,
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
            Utility.toastLong(applicationContext, "Something went wrong in drawing route")
        }
    }

}

