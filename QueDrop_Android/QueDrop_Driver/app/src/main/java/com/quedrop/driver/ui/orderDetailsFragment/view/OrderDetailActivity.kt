package com.quedrop.driver.ui.orderDetailsFragment.view

import android.annotation.SuppressLint
import android.app.Activity
import android.content.*
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.widget.AppCompatButton
import androidx.appcompat.widget.AppCompatEditText
import androidx.lifecycle.LifecycleObserver
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.google.gson.Gson
import com.psp.google.direction.model.Direction
import com.psp.google.direction.util.DirectionConverter
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import com.quedrop.driver.base.JSDrawRoute
import com.quedrop.driver.base.RuntimePermissionActivity
import com.quedrop.driver.base.extentions.finishWithAnimation
import com.quedrop.driver.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.Orders
import com.quedrop.driver.service.model.ReceiverUser
import com.quedrop.driver.service.model.User
import com.quedrop.driver.service.request.RemoveOrderReceiptRequest
import com.quedrop.driver.service.request.SingleOrderRequest
import com.quedrop.driver.service.request.UploadOrderReceipt
import com.quedrop.driver.socket.SocketConstants
import com.quedrop.driver.socket.SocketConstants.Companion.SocketOrderDeliveryAcknowledge
import com.quedrop.driver.ui.chat.ChatActivity
import com.quedrop.driver.ui.confirmedOrderDelivery.ConfirmedOrderDeliveryActivity
import com.quedrop.driver.ui.deliveryRoute.view.DeliveryRouteActivity
import com.quedrop.driver.ui.homeFragment.view.DriverMapView
import com.quedrop.driver.ui.homeFragment.viewModel.HomeViewModel
import com.quedrop.driver.ui.order.adapter.CurrentOrderStoreListAdapter
import com.quedrop.driver.ui.orderDetailsFragment.adapter.OrderManualStoreAdapter
import com.quedrop.driver.ui.orderDetailsFragment.viewModel.OrderDetailViewModel
import com.quedrop.driver.utils.*
import io.socket.client.Ack
import kotlinx.android.synthetic.main.activity_order_details.*
import kotlinx.android.synthetic.main.toolbar_normal.*
import okhttp3.MediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody
import org.greenrobot.eventbus.EventBus
import org.json.JSONException
import org.json.JSONObject


class OrderDetailActivity : RuntimePermissionActivity(), LifecycleObserver, OnMapReadyCallback {
    override fun onMapReady(p0: GoogleMap?) {
        mGoogleMap = p0!!

    }

    lateinit var mContext: Activity

    private var currentStoreAdapter: CurrentOrderStoreListAdapter? = null
    private lateinit var orderDetailViewModel: OrderDetailViewModel
    private var orderObserverModel: OrderObserverModel? = null
    private lateinit var homeViewModel: HomeViewModel
    private var orderDetail: Orders? = null
    private var profileImagePath: String = ""


    private val IMAGE_CAPTURE_CODE = 1001
    private var bitmapReceipt: Bitmap? = null
    private var imageUri: Uri? = null

    private var rideMapView: DriverMapView? = null
    private var jsDrawRoute: JSDrawRoute? = null
    lateinit var mGoogleMap: GoogleMap
    private var selectedPosition = -1


    private var orderId: Int = 0
    private var isFromNotification: Boolean = false
    private var remoteMessage: String = ""
    private var strOrderDetail: String = ""

    val LAUNCH_SECOND_ACTIVITY = 1
    var sumOfManualAmount: Float = 0f

    var isToolTipShowing: Boolean = false


    override fun onPermissionsGranted(requestCode: Int, isGranted: Boolean) {
        if (requestCode == ARRAY_PERMISSION_CODE && isGranted) {
            openCamera()
        } else {
            Toast.makeText(mContext, "Please allow storage permission", Toast.LENGTH_LONG).show()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_order_details)
        mContext = this

        orderDetailViewModel = OrderDetailViewModel(appService)
        homeViewModel = HomeViewModel(appService)

        if (intent != null) {
            isFromNotification = intent.getBooleanExtra("FROM_NOTIFICATION", false)

            if (intent.hasExtra("remote_message")) {
                remoteMessage = intent.getStringExtra("remote_message")!!
            }
            if (intent.hasExtra("orderDetail")) {
                strOrderDetail = intent?.getStringExtra("orderDetail")!!
            }
        }

        if (isFromNotification) {
            orderId = intent.getIntExtra("ORDER_ID", 0)

        } else if (remoteMessage.isNotEmpty()) {
            val jsonObject = JSONObject(remoteMessage)
            orderId = jsonObject.getInt("order_id")
        } else {
            orderDetail = Gson().fromJson(strOrderDetail, Orders::class.java)
            orderId = orderDetail?.orderId!!.toInt()
        }


        //getSocketData()
        setUpToolBar()
        initViews()

        if (Utility.isNetworkAvailable(this)) {
            getSingleOrderDetail()
        } else {
            layoutOrderDetail.visibility = View.GONE
            btnConfirm.visibility = View.GONE
            showAlertMessage(this, getString(R.string.no_internet_connection))
        }
    }

    private fun setUpToolBar() {
        tvTitle.text = resources.getString(R.string.order_details)

        ivBack.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        info.throttleClicks().subscribe {
            addToolTipView(orderDetail?.driverNote!!)
        }.autoDispose(compositeDisposable)
    }

    private fun initViews() {

        val map =
            supportFragmentManager.findFragmentById(R.id.mapDetailsFragment) as SupportMapFragment

        map.getMapAsync { googleMap ->
            mGoogleMap = googleMap
            rideMapView = DriverMapView(
                false,
                map,
                googleMap,
                homeViewModel
            )
            rideMapView?.clearMap()
            // rideMapView?.setPolyLines(orderDetail!!)

            googleMap.uiSettings.isZoomControlsEnabled = false
            googleMap.uiSettings.isZoomGesturesEnabled = false
            googleMap.uiSettings.isScrollGesturesEnabled = false
            googleMap.uiSettings.isScrollGesturesEnabledDuringRotateOrZoom = false

            map.view?.isClickable = false

            //clickViews..
            googleMap.setOnMapClickListener {
                Log.e("Checking", ": on")
                val intent = Intent(this, DeliveryRouteActivity::class.java)
                intent.putExtra("orderDetail", Gson().toJson(orderDetail))
                this.startActivityWithDefaultAnimations(intent)
            }

        }

        //clickViews..

        btnChat.throttleClicks().subscribe {
            val customerDetails = orderDetail?.customerDetail
            val userName = customerDetails?.firstName + " " + customerDetails?.lastName
            customerDetails?.userId?.let {
                startActivityWithDefaultAnimations(
                    ChatActivity.getIntent(
                        applicationContext,
                        ReceiverUser(
                            it, userName, customerDetails.userImage,
                            orderDetail?.orderStatus!!, orderDetail?.orderId!!.toInt()
                        )
                    )
                )
            }

        }.autoDispose(compositeDisposable)

        btnConfirm.throttleClicks().subscribe {

//            if (currentStoreAdapter != null) {
//                val selectedList = currentStoreAdapter?.getSelectedItems()
//                if (!selectedList!!) {
//                    Log.e("all values ", "===> " + "false")
//                    showInfoMessage(this, "Please attach receipt")

            if (!doReceiptValidation()) {
                showInfoMessage(this, "Please attach receipt")
            } else {
                Log.e("all values ", "===> " + "true")
                if (orderDetail?.orderStatus == ORDER_STATUS_DISPATCH) {
                    val intent = Intent(
                        this,
                        ConfirmedOrderDeliveryActivity::class.java
                    )
                    intent.putExtra(
                        "orderDetail",
                        Gson().toJson(orderDetail)
                    )

                    startActivityForResultWithDefaultAnimations(intent, LAUNCH_SECOND_ACTIVITY)

                } else {
                    confirmOrder()
                }
            }


            /* if (doReceiptValidation()) {
                 if (orderDetail?.orderStatus == ORDER_STATUS_DISPATCH) {
                     val intent = Intent(
                         this,
                         ConfirmedOrderDeliveryActivity::class.java
                     )
                     intent.putExtra(
                         "orderDetail",
                         Gson().toJson(orderDetail)
                     )
                     this.startActivityWithDefaultAnimations(intent)

                 } else {
                     confirmOrder()
                 }
             } else {
                 Toast.makeText(this, "Please attach receipt", Toast.LENGTH_LONG).show()
             }*/
        }.autoDispose(compositeDisposable)


        OrderDetailObserver.itemReceiptClick.subscribe { observerModelX ->
            this.orderObserverModel = observerModelX
            selectedPosition = orderObserverModel?.position!!
            if (orderDetail?.orderStatus == ORDER_STATUS_ACCEPTED) {
                if (hasPermissions(mContext)) {
                    openCamera()
                } else {
                    requestAppPermissions(
                        ARRAY_PERMISSIONS,
                        R.string.app_name,
                        ARRAY_PERMISSION_CODE
                    )
                }
            }
        }.autoDispose(compositeDisposable)


        OrderDetailObserver.itemRemoveReceiptClick.subscribe { observerModelX ->
            showProgress()
            orderDetailViewModel.removeOrderReceipt(
                RemoveOrderReceiptRequest(
                    SharedPreferenceUtils.getString(KEY_TOKEN),
                    ACCESS_KEY,
                    observerModelX.stores.storeId,
                    observerModelX.stores.userStoreId,
                    orderId,
                    (SharedPreferenceUtils.getModelPreferences(
                        KEY_USER,
                        User::class.java
                    ) as User).userId!!

                )
            )
        }.autoDispose(compositeDisposable)


        //obeserver...
        orderDetailViewModel.singleOrderDetailArrayList.observe(
            this,
            androidx.lifecycle.Observer {
                hideProgress()
                layoutOrderDetail.visibility = View.VISIBLE
                btnConfirm.visibility = View.VISIBLE
                orderDetail = it
                setUpData()
                requestDirection()
            })

        orderDetailViewModel.errorMessage.observe(this, androidx.lifecycle.Observer {
            hideProgress()
        })

        orderDetailViewModel.receiptUploaded.observe(this, androidx.lifecycle.Observer {
            if (it) {
                if (Utility.isNetworkAvailable(this)) {
                    getSingleOrderDetail()
                } else {
                    showAlertMessage(this, getString(R.string.no_internet_connection))
                }

            }
        })

        orderDetailViewModel.removeReceiptObserver?.observe(this, androidx.lifecycle.Observer {
            hideProgress()
            if (Utility.isNetworkAvailable(this)) {
                getSingleOrderDetail()
            } else {
                showAlertMessage(this, getString(R.string.no_internet_connection))
            }
        })
    }

    private fun doReceiptValidation(): Boolean {
        val mCount = orderDetail?.stores?.size!!
        var trueCount = 0

        for (i in orderDetail?.stores?.indices!!) {
            if (orderDetail?.stores!![i].orderReceipt != "") {
                trueCount++
            }
        }
        return mCount == trueCount
    }

    private fun confirmOrder() {
        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {
                jsonObject.put(
                    SocketConstants.KeyOrderId, orderDetail?.orderId
                )
                jsonObject.put(
                    SocketConstants.KeyOrderStatus, ORDER_STATUS_DISPATCH
                )

                jsonObject.put(
                    SocketConstants.KeyUserId, (SharedPreferenceUtils.getModelPreferences(
                        KEY_USER,
                        User::class.java
                    ) as User).userId
                )

                jsonObject.put(
                    SocketConstants.KeyCustomerId, orderDetail?.customerDetail?.userId
                )

                SocketConstants.socketIOClient!!.emit(
                    SocketConstants.SocketUpdateOrderStatus,
                    jsonObject, Ack {
                        try {
                            val messageJson = JSONObject(it[0].toString())
                            val responseStatus = messageJson.getString("status").toInt()
                            runOnUiThread {
                                if (responseStatus == 1) {

                                    val intent =
                                        Intent(this, ConfirmedOrderDeliveryActivity::class.java)
                                    intent.putExtra(
                                        "orderDetail",
                                        Gson().toJson(orderDetail)
                                    )
                                    startActivityForResultWithDefaultAnimations(
                                        intent,
                                        LAUNCH_SECOND_ACTIVITY
                                    )
                                }
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

    @SuppressLint("SetTextI18n")
    private fun setUpData() {

        when (orderDetail?.orderStatus) {

            EnumUtils.ACCEPTED.stringVal -> {
                mapDetailsFragment.visibility = View.VISIBLE
                btnConfirm.visibility = View.VISIBLE
                earnCons.visibility = View.GONE
            }
            EnumUtils.DISPATCH.stringVal -> {
                mapDetailsFragment.visibility = View.VISIBLE
                btnConfirm.visibility = View.VISIBLE
                btnConfirm.text = getString(R.string.view_qr_code)
                earnCons.visibility = View.GONE
            }
            EnumUtils.DELIVERED.stringVal -> {
                mapDetailsFragment.visibility = View.GONE
                btnConfirm.visibility = View.GONE
                earnCons.visibility = View.VISIBLE

            }
            EnumUtils.PLACED.stringVal -> {
                mapDetailsFragment.visibility = View.GONE
                btnConfirm.visibility = View.GONE
                earnCons.visibility = View.VISIBLE

            }
        }

        if (orderDetail?.driverNote != "") {
            info.visibility = View.VISIBLE
            addToolTipView(orderDetail?.driverNote!!)
        } else {
            info.visibility = View.GONE
        }

        tvOrderDetailOrderId.text = "Order ID: #" + orderDetail?.orderId.toString()

        if (orderDetail?.deliveryOption == EXPRESS_DELIVERY) {
            constOrderDetailExpress.visibility = View.VISIBLE
        } else {
            constOrderDetailExpress.visibility = View.GONE
        }

        tvDateOrder.text = convertUTCDateToLocalDate(orderDetail?.orderDate!!)
        tvDUserName.text =
            orderDetail?.customerDetail?.firstName + " " + orderDetail?.customerDetail?.lastName
        tvDPhoneNum.text =
            "+" + orderDetail?.customerDetail?.countryCode.toString() + " " + orderDetail?.customerDetail?.phoneNumber
        if (orderDetail?.customerDetail?.rating != null) {
            userDRating.rating = orderDetail?.customerDetail?.rating?.toFloat()!!
        }

        if (orderDetail?.customerDetail?.userImage != null) {
            if (!isNetworkUrl(orderDetail!!.customerDetail.userImage!!)) {
                profileImagePath =
                    BuildConfig.BASE_URL + ImageConstant.USER_STORE + orderDetail?.customerDetail?.userImage
            } else {
                profileImagePath = orderDetail!!.customerDetail.userImage!!
            }
        }

        Glide.with(mContext)
            .load(profileImagePath)
            .placeholder(R.drawable.ic_user_placeholder)
            .circleCrop()
            .into(ivDUserImage)

        setUpStoreData()
        setUpBillingData()

    }

    private fun setUpStoreData() {
        rvOrderDetails.layoutManager = LinearLayoutManager(mContext)
        currentStoreAdapter = CurrentOrderStoreListAdapter(
            true,
            mContext,
            orderDetail?.orderStatus!!,
            orderDetail!!.stores.toMutableList(),
            ""
        )
        rvOrderDetails.adapter = currentStoreAdapter
    }

    override fun onDestroy() {
        super.onDestroy()
        EventBus.getDefault().unregister(this)

    }

    @SuppressLint("SetTextI18n")
    private fun setUpBillingData() {
        val billingDetails = orderDetail?.billingDetail
        if (billingDetails != null) {

            if (billingDetails.isManualStoreAvailable == 1 && orderDetail?.orderStatus != EnumUtils.DELIVERED.stringVal) {
                txtNoteView.visibility = View.VISIBLE
                txtNotes.visibility = View.VISIBLE
                grayDivider.visibility = View.VISIBLE
            } else {
                txtNoteView.visibility = View.GONE
                txtNotes.visibility = View.GONE
                grayDivider.visibility = View.GONE
            }

            /*   if (billingDetails.orderDiscount?.toInt() == 0 && billingDetails.couponDiscount?.toInt() == 0) {
                   billDivider.visibility = View.GONE
               } else {
                   billDivider.visibility = View.VISIBLE
               }


               if (billingDetails.orderDiscount?.toInt() != 0) {
                   txtOrderDiscount.text = CURRENCY + numberFormat(billingDetails.orderDiscount)
               } else {
                   txtOrderDiscount.visibility = View.GONE
                   txtOrderDiscountView.visibility = View.GONE
               }


               if (orderDetail?.billingDetail?.couponDiscount?.toInt() != 0) {
                   txtCouponDiscount.text = CURRENCY + numberFormat(billingDetails.couponDiscount)
               } else {
                   txtCouponDiscount.visibility = View.GONE
                   txtCounponDiscountView.visibility = View.GONE
               }

               if (orderDetail?.billingDetail?.serviceCharge?.toInt() != 0) {
                   txtServiceCharges.text = CURRENCY + numberFormat(billingDetails.serviceCharge)
               } else {
                   txtServiceCharges.text = getString(R.string.free)
               }
   */

            if (orderDetail?.billingDetail?.shoppingFeeDriver?.toInt() != 0) {
                txtShoppingFee.visibility = View.VISIBLE
                txtShoppingFeeView.visibility = View.VISIBLE
                txtShoppingFee.text = CURRENCY + numberFormat(billingDetails.shoppingFeeDriver)
            } else {
                txtShoppingFee.visibility = View.GONE
                txtShoppingFeeView.visibility = View.GONE
            }

            if (orderDetail?.billingDetail?.tip?.toInt() != 0) {
                txtTip.text = CURRENCY + numberFormat(billingDetails.tip)
            } else {
                txtTip.text = getString(R.string.no_prize)
            }

            if (orderDetail?.billingDetail?.deliveryCharge?.toInt() != 0) {
                txtDeliveryFee.text = CURRENCY + numberFormat(billingDetails.deliveryCharge)
            } else {
                txtDeliveryFee.text = getString(R.string.no_prize)
            }

            if (orderDetail?.billingDetail?.driverTotalEarn?.toInt() != 0) {
                txtToPay.text = CURRENCY + numberFormat(billingDetails.driverTotalEarn)
            } else {
                txtToPay.text = getString(R.string.no_prize)
            }
        }

        // addRegisteredBillData()
        val manualData = orderDetail?.billingDetail?.manualStore
        if (!manualData?.isEmpty()!!) {
            manualTotalDivider.visibility = View.VISIBLE
            manualConst.visibility = View.VISIBLE

            for (i in manualData.indices) {
                sumOfManualAmount += manualData[i].storeAmount!!
            }
            txtTotalManual.text = "$CURRENCY $sumOfManualAmount"
            addManualBillData()
        } else {
            manualTotalDivider.visibility = View.GONE
            manualConst.visibility = View.GONE
        }

    }

    private fun numberFormat(value: Float?): String {
        return String.format("%.2f", value)
    }

    private fun addManualBillData() {
        rvManualStore.layoutManager = LinearLayoutManager(
            mContext,
            LinearLayoutManager.VERTICAL,
            false
        )
        val orderManualStoreAdapter =
            OrderManualStoreAdapter(orderDetail?.billingDetail?.manualStore!!)

        rvManualStore.adapter = orderManualStoreAdapter
        orderManualStoreAdapter.notifyDataSetChanged()
    }

//    private fun addRegisteredBillData() {
//        rvBillRegisteredDetails.layoutManager = LinearLayoutManager(
//            mContext,
//            LinearLayoutManager.VERTICAL,
//            false
//        )
//        val orderRegisteredStoreAdapter =
//            OrderRegisteredStoreAdapter(orderDetail?.billingDetail?.registeredStore!!)
//
//        rvBillRegisteredDetails.adapter = orderRegisteredStoreAdapter
//        orderRegisteredStoreAdapter.notifyDataSetChanged()
//    }

    private fun openCamera() {
        val values = ContentValues()
        values.put(MediaStore.Images.Media.TITLE, "New Picture")
        values.put(MediaStore.Images.Media.DESCRIPTION, "From the Camera")
        imageUri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
        val cameraIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        cameraIntent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri)
        startActivityForResult(cameraIntent, IMAGE_CAPTURE_CODE)
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK) {
            bitmapReceipt = BitmapHelper.decodeUriToBitmap(mContext, imageUri)
            if (bitmapReceipt != null) {
                val resizeBitmap = BitmapHelper.getResizedBitmap(bitmapReceipt, 720)
                val lastImagePath = BitmapHelper.saveCompressImage(resizeBitmap)

//                currentStoreAdapter?.currentReceipt(resizeBitmap, selectedPosition)

                val multipartBody = Utility.getFileBody(KEY_RECEIPT, lastImagePath)

                if (orderDetail?.stores!![orderObserverModel?.position!!].canProvideService == 0) {
                    addAmount(multipartBody)
                } else {
                    orderDetailViewModel.uploadOrderReceipt(
                        uploadReceipt(
                            storeID = orderDetail?.stores!![orderObserverModel?.position!!].orderStoreId.toString(),
                            image = multipartBody,
                            amount = "0"
                        )
                    )
                }

            }

        }
        if (requestCode == LAUNCH_SECOND_ACTIVITY) {
            Log.e("OnActivity", "==>" + requestCode)
            if (resultCode == Activity.RESULT_CANCELED) {
                if (Utility.isNetworkAvailable(this)) {
                    getSingleOrderDetail()
                } else {
                    showAlertMessage(this, getString(R.string.no_internet_connection))
                }
            }
        }
    }


    //get single order api call
    private fun getSingleOrderDetail() {
        showProgress()
        orderDetailViewModel.getSingleOrderDetail(getOrderRequest())

    }

    private fun getOrderRequest(): SingleOrderRequest {
        return SingleOrderRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY, orderId
        )
    }

    //upload api receipt
    private fun uploadReceipt(
        storeID: String,
        image: MultipartBody.Part,
        amount: String
    ): UploadOrderReceipt {

        return UploadOrderReceipt(
            getStringRequestBody(orderDetail?.orderId!!.toString()),
            getStringRequestBody(storeID),
            getStringRequestBody(SharedPreferenceUtils.getString(KEY_TOKEN)),
            getStringRequestBody(ACCESS_KEY),
            image,
            getStringRequestBody(SharedPreferenceUtils.getInt(KEY_USERID).toString()),
            getStringRequestBody(amount)
        )
    }

    private fun getStringRequestBody(value: String): RequestBody {
        return RequestBody.create(MediaType.parse("text/plain"), value)
    }

    private fun addAmount(multipartBody: MultipartBody.Part) {
        val alertDialog: AlertDialog = AlertDialog.Builder(this).create()
        val inflater = this.layoutInflater
        alertDialog.setCancelable(false)

        val dialogView = inflater.inflate(R.layout.add_amount_dialog, null)

        if (alertDialog.window != null) {
            alertDialog.window!!.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        }
        val btnSaveAmount = dialogView.findViewById(R.id.btnSaveAmount) as AppCompatButton
        val btnCancelAmount = dialogView.findViewById(R.id.btnCancelAmount) as AppCompatButton
        val edxEnterBillAmount =
            dialogView.findViewById(R.id.edxEnterBillAmount) as AppCompatEditText

        btnSaveAmount.setOnClickListener(View.OnClickListener {
            val amount = edxEnterBillAmount.text.toString()
            if (amount != "") {
                orderDetailViewModel.uploadOrderReceipt(
                    uploadReceipt(
                        storeID = orderDetail?.stores!![orderObserverModel?.position!!].orderStoreId.toString(),
                        image = multipartBody,
                        amount = amount
                    )
                )
                alertDialog.dismiss()
            } else {
                edxEnterBillAmount.error = "Please enter amount"
            }
        })
        btnCancelAmount.setOnClickListener(View.OnClickListener {
            alertDialog.dismiss()
        })

        alertDialog.setView(dialogView)
        alertDialog.show()
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

    // get Socket event
    private val eventUpdate = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val events = intent.getStringExtra(BroadCastConstant.BROADCAST_KEY_EVENT)!!
            try {
                val jsonObject =
                    JSONObject(intent.getStringExtra(BroadCastConstant.BROADCAST_KEY_OBJ)!!)
                val orderId = jsonObject.getString("order_id")
                if (events == SocketOrderDeliveryAcknowledge) {
                    if (orderDetail?.orderId.toString() == orderId) {
                        onBackPressed()
                    }
                }
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }

    override fun onStart() {
        super.onStart()
        LocalBroadcastManager.getInstance(this).registerReceiver(
            eventUpdate,
            IntentFilter(BroadCastConstant.BROADCAST_EVENT_CHANGE)
        )
    }

    override fun onResume() {
        super.onResume()
    }

    override fun onBackPressed() {
        super.onBackPressed()
        RxBus.instance?.publish("refreshOrder")
        finishWithAnimation()
    }
}
