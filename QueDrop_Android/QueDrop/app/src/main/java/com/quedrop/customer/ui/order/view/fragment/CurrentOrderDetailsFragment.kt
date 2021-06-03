package com.quedrop.customer.ui.order.view.fragment

import android.annotation.SuppressLint
import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.QueDropApplication
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ResponseWrapper
import com.quedrop.customer.socket.SocketConstants
import com.quedrop.customer.ui.chat.ChatActivity
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.order.view.adapter.CurrentOrderDetailsStoreAdapter
import com.quedrop.customer.ui.order.view.adapter.ManualStoreAdapter
import com.quedrop.customer.ui.order.view.adapter.ReceiptAdapter
import com.quedrop.customer.ui.order.view.adapter.RegisteredStoreAdapter
import com.quedrop.customer.ui.order.viewmodel.OrderViewModel
import com.quedrop.customer.utils.*
import io.socket.client.Ack
import kotlinx.android.synthetic.main.fragment_current_order_details.*
import org.json.JSONException
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*


class CurrentOrderDetailsFragment(
    var orderId: Int,
    var timeMainRemaining1: Long,
    var remoteMessage: String
) : BaseFragment() {

    lateinit var orderViewModel: OrderViewModel

    var receiptAdapter: ReceiptAdapter? = null
    var manualStoreAdapter: ManualStoreAdapter? = null
    var registeredOrderAdapter: RegisteredStoreAdapter? = null
    var currentSingleOrderDetailsAdapter: CurrentOrderDetailsStoreAdapter? = null

    var getOrderDetails: GetSingleOrderDetailsResponse? = null
    var arrayManualStoreList: MutableList<ManualStore>? = null
    var arraySingleOrderList: MutableList<StoreSingleDetails>? = null
    var arrayRegisteredStoreList: MutableList<RegisteredStore>? = null

    var orderStatusUpdate: String = "Placed"
    var orderDate: String = ""
    var updateServerTime: String = ""
    var timerVal: Int = 0
    var flagManual: Boolean = true

    //    var tvReceipt: TextView? = null
//    var statusLinear: LinearLayout? = null
//    var bottomConstraint: ConstraintLayout? = null
//    var rvMainReceipt: RecyclerView? = null
//    var btnScanQR: TextView? = null
//    var btnReschedule: TextView? = null
    var flagClickReschedule: Boolean = false

    companion object {
        fun newInstance(
            orderId: Int,
            timeMainRemaining1: Long,
            remoteMessage: String
        ): CurrentOrderDetailsFragment {
            return CurrentOrderDetailsFragment(
                orderId,
                timeMainRemaining1,
                remoteMessage
            )
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_current_order_details, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        orderViewModel = OrderViewModel(appService)


        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(this.requireContext(), KeysUtils.keyUserId, 0)
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(this.requireContext(), KeysUtils.keyGuestId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(this.requireContext(), KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(this.requireContext(), KeysUtils.keyAccessKey)!!
        Utils.selectAddressTitle = SharedPrefsUtils.getStringPreference(
            this.requireContext(),
            KeysUtils.KeySelectAddressName
        )!!
        Utils.selectAddress = SharedPrefsUtils.getStringPreference(
            this.requireContext(),
            KeysUtils.KeySelectAddress
        )!!
        Utils.selectAddressType = SharedPrefsUtils.getStringPreference(
            this.requireContext(),
            KeysUtils.KeySelectAddressType
        )!!
        Utils.keyLatitude =
            SharedPrefsUtils.getStringPreference(this.requireContext(), KeysUtils.KeyLatitude)!!
        Utils.keyLongitude =
            SharedPrefsUtils.getStringPreference(this.requireContext(), KeysUtils.KeyLongitude)!!

        LocalBroadcastManager.getInstance(requireContext()).registerReceiver(
            eventUpdate,
            IntentFilter(BroadCastConstant.BROADCAST_EVENT_CHANGE)
        )

        initMethod()
        onClickMethod()
        observeViewModel()
        getSingleOrderApi()

        if (remoteMessage != "") {
            val jsonObject = JSONObject(remoteMessage)
            if (jsonObject.getString("notification_type")
                    .toInt() == ENUMNotificationType.CHAT.posVal
            ) {
                val myIntent = Intent(QueDropApplication.context, ChatActivity::class.java)
                myIntent.putExtra(ChatActivity.REMOTE_MESSAGE, remoteMessage)
                context?.startActivity(myIntent)
            }
        }
    }

    private fun onClickMethod() {

        ivBackOrderDetails.throttleClicks().subscribe {
            //activity.onBackPressed()
            goBackToPreviousFragment()
        }.autoDispose(compositeDisposable)

        btnScanQR?.throttleClicks()?.subscribe {
            addScanQRNavigate(orderId)
        }?.autoDispose(compositeDisposable)

        btnReschedule?.throttleClicks()?.subscribe {
            rescheduleApi()
        }?.autoDispose(compositeDisposable)

        chatButtonView.throttleClicks().subscribe {
            val driverDetails = getOrderDetails?.driver_detail
            val userName = driverDetails?.first_name + " " + driverDetails?.last_name
            driverDetails?.user_id?.let {
                startActivityWithDefaultAnimations(
                    ChatActivity.getIntent(
                        activity,
                        ReceiverUser(
                            it,
                            userName,
                            driverDetails.user_image,
                            getOrderDetails?.order_status,
                            getOrderDetails?.order_id
                        )
                    )
                )
            } ?: run {
                Toast.makeText(activity, "Please try again", Toast.LENGTH_SHORT).show()
            }
        }.autoDispose()

        tvTrackOrder.throttleClicks().subscribe() {
            navigateToDriverLocation(orderId)
        }.autoDispose(compositeDisposable)
    }

    private fun addScanQRNavigate(orderId: Int) {
        val orderIdMain = orderId
        (getActivity() as CustomerMainActivity).navigateToFragment(
            ScanQRFragment.newInstance(
                orderIdMain
            )
        )
//
//        (activity as CustomerMainActivity).navigateToFragment(
//            ConfirmOrderFragment.newInstance(
//                orderIdMain
//            )
//        )
    }

    private fun navigateToDriverLocation(orderId: Int) {
        val orderIdMain = orderId
        SharedPrefsUtils.setModelPreferences(
            activity,
            KeysUtils.keyOrderDetails,
            getOrderDetails as GetSingleOrderDetailsResponse
        )
        (getActivity() as CustomerMainActivity).navigateToFragment(
            DriverLocationFragment.newInstance(
                orderIdMain,
                getOrderDetails?.driver_detail?.user_id!!
            )
        )
    }

    private fun initMethod() {
        rvMainReceipt?.layoutManager = LinearLayoutManager(
            context,
            LinearLayoutManager.HORIZONTAL,
            false
        )

        arraySingleOrderList = mutableListOf()
        receiptAdapter = ReceiptAdapter(
            this.requireContext(),
            arraySingleOrderList!!

        ).apply {
            receiptInvoke = { pos: Int, arrayCounterList: ArrayList<Int> ->
                receiptInvokeMain(pos, arrayCounterList)
            }

        }
        rvMainReceipt?.adapter = receiptAdapter

        arrayRegisteredStoreList = mutableListOf()
        arrayManualStoreList = mutableListOf()

        rvRegisteredStore.layoutManager = LinearLayoutManager(
            context,
            LinearLayoutManager.VERTICAL,
            false
        )

        registeredOrderAdapter = RegisteredStoreAdapter(
            this.requireContext(),
            arrayRegisteredStoreList!!

        )
        rvRegisteredStore.adapter = registeredOrderAdapter

        rvManualStore.layoutManager = LinearLayoutManager(
            context,
            LinearLayoutManager.VERTICAL,
            false
        )

        manualStoreAdapter = ManualStoreAdapter(
            this.requireContext(),
            arrayManualStoreList!!

        ).apply {
            manualStoreInvoke = {
                clickManualStore(it)
            }
        }
        rvManualStore.adapter = manualStoreAdapter
        rvMainCartListCurrent.layoutManager =
            LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false)
    }


    private fun getRescheduleOrder(): RescheduleOrder {
        return RescheduleOrder(
            Utils.seceretKey,
            Utils.accessKey,
            orderId
        )
    }

    private fun rescheduleApi() {
        (activity as CustomerMainActivity).showProgress()
        orderViewModel.getRescheduleOrderApi(getRescheduleOrder())
    }


    private fun clickManualStore(isFlagManual: Boolean) {
        flagManual = isFlagManual
        if (!flagManual) {
            tvPayRsRv.text = resources.getString(R.string.pendingStatus)
        }
    }

    private fun removeTimerInvokeMethod() {
        if (timeMainRemaining1.toString().isEmpty()) {
            if (orderStatusUpdate == EnumUtils.PLACED.stringVal) {
                tvReceipt?.visibility = View.GONE
                bottomConstraint?.visibility = View.GONE
                rvMainReceipt?.visibility = View.GONE
                btnScanQR?.visibility = View.GONE
                statusLinear?.visibility = View.GONE
                btnReschedule?.visibility = View.VISIBLE
            } else if (orderStatusUpdate == EnumUtils.DELIVERED.stringVal) {
                tvReceipt?.visibility = View.VISIBLE
                bottomConstraint?.visibility = View.VISIBLE
                rvMainReceipt?.visibility = View.VISIBLE
                btnScanQR?.visibility = View.GONE
                statusLinear?.visibility = View.VISIBLE
                btnReschedule?.visibility = View.GONE
                tvTrackOrder?.visibility = View.GONE
            } else {
                tvReceipt?.visibility = View.VISIBLE
                bottomConstraint?.visibility = View.VISIBLE
                rvMainReceipt?.visibility = View.VISIBLE
                btnScanQR?.visibility = View.VISIBLE
                statusLinear?.visibility = View.VISIBLE
                btnReschedule?.visibility = View.GONE

            }
        } else {
            if (orderStatusUpdate == EnumUtils.PLACED.stringVal) {
                tvReceipt?.visibility = View.GONE
                bottomConstraint?.visibility = View.GONE
                rvMainReceipt?.visibility = View.GONE
                btnScanQR?.visibility = View.GONE
                statusLinear?.visibility = View.GONE
                btnReschedule?.visibility = View.VISIBLE
            } else if (orderStatusUpdate == EnumUtils.DELIVERED.stringVal) {
                tvReceipt?.visibility = View.VISIBLE
                bottomConstraint?.visibility = View.VISIBLE
                rvMainReceipt?.visibility = View.VISIBLE
                btnScanQR?.visibility = View.GONE
                statusLinear?.visibility = View.VISIBLE
                btnReschedule?.visibility = View.GONE
                tvTrackOrder?.visibility = View.GONE
            } else {
                tvReceipt?.visibility = View.VISIBLE
                bottomConstraint?.visibility = View.VISIBLE
                rvMainReceipt?.visibility = View.VISIBLE
                btnScanQR?.visibility = View.VISIBLE
                statusLinear?.visibility = View.VISIBLE
                btnReschedule?.visibility = View.GONE
            }
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
            SocketConstants.SocketStatusChanged -> {
                val orderStatus = argument.getString("order_status")
                getSingleOrderApi()
                statusUpdate(orderStatus)
                orderStatusUpdate = orderStatusUpdate
                currentSingleOrderDetailsAdapter?.notifyDataSetChanged()

                removeTimerInvokeMethod()

            }
            SocketConstants.SocketOrderAccepted -> {
                val orderId = argument.getString("order_id")
                val driverId = argument.getString("driver_id")
                val status = argument.getString("status")
                getSingleOrderApi()
                orderStatusUpdate = status
                currentSingleOrderDetailsAdapter?.notifyDataSetChanged()

                removeTimerInvokeMethod()

            }
        }
    }

    private fun receiptInvokeMain(pos: Int, arrayCounterList: ArrayList<Int>) {
        (getActivity() as CustomerMainActivity).navigateToFragment(
            ReceiptFragment.newInstance(
                arraySingleOrderList?.get(pos)?.order_receipt!!,
                arrayCounterList[pos]
            )
        )
    }

    private fun statusUpdate(orderStatus: String) {
        statusViewScroller.statusView.run {

            when (orderStatus) {
                EnumUtils.ACCEPTED.stringVal -> {
                    currentCount = ConstantUtils.ONE
                    lineColor = ContextCompat.getColor(this.context, R.color.colorLightGrey)
                }
                EnumUtils.DISPATCH.stringVal -> {
                    currentCount = ConstantUtils.TWO
                    lineColor = ContextCompat.getColor(this.context, R.color.colorLightGrey)
                }
                EnumUtils.DELIVERED.stringVal -> {
                    currentCount = ConstantUtils.THREE
                    lineColor = ContextCompat.getColor(this.context, R.color.colorThemeGreen)
                }
            }
            lineColorCurrent = ContextCompat.getColor(this.context, R.color.colorThemeGreen)
        }
    }

    @SuppressLint("SetTextI18n")
    private fun setAllDetails() {
        val inputConverter = SimpleDateFormat(
            "yyyy-MM-dd HH:mm:ss",
            Locale.ENGLISH
        ).parse(getOrderDetails?.order_date!!)
        inputConverter?.let {
            val simpleDateFormatDate = SimpleDateFormat("dd MMM yyyy ", Locale.ENGLISH).format(it)
            val simpleDateFormatTime = SimpleDateFormat("HH:mm a", Locale.ENGLISH).format(it)
            tvDateOrder.text = simpleDateFormatDate + "at " + simpleDateFormatTime
        }

        if (getOrderDetails?.delivery_option == ConstantUtils.EXPRESS_DELIVERY) {
            consExpress.visibility = View.VISIBLE
        } else {
            consExpress.visibility = View.GONE
        }

        if ((getOrderDetails?.driver_detail?.first_name + " " + getOrderDetails?.driver_detail?.last_name).isNotEmpty()) {
            tvDriverName.text =
                getOrderDetails?.driver_detail?.first_name + " " + getOrderDetails?.driver_detail?.last_name
        }

        if (getOrderDetails?.driver_detail?.rating != "0") {

        } else {
            tvDriverRate.rating = getOrderDetails?.driver_detail?.rating!!.toFloat()
        }

        if (getOrderDetails?.billing_detail?.order_discount != "0") {
            tvOrderDiscount.visibility = View.VISIBLE
            linearHorizontalOrder1.visibility = View.VISIBLE
            tvFeeOrder.visibility = View.VISIBLE
            tvFeeOrder.text = "$" + String.format(
                "%.2f",
                getOrderDetails?.billing_detail?.order_discount!!.toFloat()
            )
        } else {
            linearHorizontalOrder1.visibility = View.GONE
            tvOrderDiscount.visibility = View.GONE
            tvFeeOrder.visibility = View.GONE
        }

        if (getOrderDetails?.billing_detail?.coupon_discount != "0") {
            linearHorizontalOrder1.visibility = View.VISIBLE
            tvCouponDiscount.visibility = View.VISIBLE
            tvFeeCoupon.visibility = View.VISIBLE
            tvFeeCoupon.text =
                "$" + String.format(
                    "%.2f",
                    getOrderDetails?.billing_detail?.coupon_discount!!.toFloat()
                )
        } else {
            linearHorizontalOrder1.visibility = View.GONE
            tvCouponDiscount.visibility = View.GONE
            tvFeeCoupon.visibility = View.GONE
        }

        tvShoppingRs.text =
            "$" + String.format("%.2f", getOrderDetails?.billing_detail?.shopping_fee!!.toFloat())
        tvServiceChargeRs.text =
            "$" + String.format("%.2f", getOrderDetails?.billing_detail?.service_charge!!.toFloat())
        tvDeliveryFeeRs.text = "$" + String.format(
            "%.2f",
            getOrderDetails?.billing_detail?.delivery_charge!!.toFloat()
        )

        if (flagManual) {
            tvPayRsRv.text =
                "$" + String.format("%.2f", getOrderDetails?.billing_detail?.total_pay!!.toFloat())
        } else {
            tvPayRsRv.text = resources.getString(R.string.pendingStatus)
        }
        if (!getOrderDetails?.driver_detail?.user_image.isNullOrEmpty()) {

            if (ValidationUtils.isCheckUrlOrNot(getOrderDetails?.driver_detail?.user_image!!)) {
                Glide.with(this.requireContext()).load(
                    getOrderDetails?.driver_detail?.user_image
                ).placeholder(R.drawable.customer_unpress).centerCrop().into(ivDriverImage)
            } else {

                Glide.with(this.requireContext()).load(
                    URLConstant.urlUser
                            + getOrderDetails?.driver_detail?.user_image
                ).placeholder(R.drawable.customer_unpress).centerCrop().into(ivDriverImage)
            }
        }
        if (getOrderDetails?.driver_note != "") {
            driverNoteConstraint.visibility = View.VISIBLE
            tvInfo.text = "\u25CF" + " " + getOrderDetails?.driver_note
        } else {
            driverNoteConstraint.visibility = View.GONE
        }

        if (getOrderDetails?.billing_detail?.is_manual_store_available == "1") {
            noteConstraint.visibility = View.VISIBLE
            tvShoppingFee.visibility = View.VISIBLE
            tvShoppingRs.visibility = View.VISIBLE

        } else {
            noteConstraint.visibility = View.GONE
            tvShoppingFee.visibility = View.GONE
            tvShoppingRs.visibility = View.GONE
        }

        statusUpdate(getOrderDetails?.order_status!!)

        orderDate = getOrderDetails?.order_date!!
        orderStatusUpdate = getOrderDetails?.order_status!!
        timerVal = getOrderDetails?.timer_value!!
        updateServerTime = getOrderDetails?.updated_server_time!!
        receiptAdapter?.notifyDataSetChanged()

        currentSingleOrderDetailsAdapter = CurrentOrderDetailsStoreAdapter(
            this.requireContext(),
            timeMainRemaining1,
            orderStatusUpdate,
            orderDate,
            getOrderDetails?.updated_server_time!!,
            arraySingleOrderList!!,
            timerVal

        ).apply {
            removeTimerInvoke = {
                timeMainRemaining1 = it
                removeTimerInvokeMethod()
            }

            removeTimerInvokeCheckVisibilty = {
                btnReschedule?.visibility = View.GONE
            }

            refreshDataFromSocketResponse = {
                getSocketGetUpdatedEstimatedTime()
            }
        }
        rvMainCartListCurrent.adapter = currentSingleOrderDetailsAdapter

        currentSingleOrderDetailsAdapter?.notifyDataSetChanged()
        removeTimerInvokeMethod()


    }

    private fun getSingleOrderDetails(): SingleOrderDetails {
        return SingleOrderDetails(
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId,
            orderId

        )
    }

    private fun getSingleOrderApi() {
        (activity as CustomerMainActivity).showProgress()
        orderViewModel.getSingleOrderDetailsApi(getSingleOrderDetails())

    }

    private fun observeViewModel() {
        orderViewModel.responseRescheduleOrder.observe(
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                (activity as CustomerMainActivity).hideProgress()
                flagClickReschedule = true
                if (it.driver_ids == "") {
                    getSingleOrderApi()
                } else {
                    getSingleOrderApi()
                    sendSocketEvent(it)
                }
            })

        orderViewModel.orderDetails.observe(
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                (getActivity() as CustomerMainActivity).hideProgress()

                topConst.visibility = View.VISIBLE
                bottomConstraint.visibility = View.VISIBLE

                if (Utils.userId == 0) {

                } else {
                    getOrderDetails = it

                    arraySingleOrderList?.clear()
                    arrayRegisteredStoreList?.clear()
                    arrayManualStoreList?.clear()
                    arraySingleOrderList?.addAll(it.stores)
                    arrayRegisteredStoreList?.addAll(it.billing_detail.registered_stores)
                    arrayManualStoreList?.addAll(it.billing_detail.manual_stores)
                    setAllDetails()
                }
                currentSingleOrderDetailsAdapter?.notifyDataSetChanged()
                receiptAdapter?.notifyDataSetChanged()
                registeredOrderAdapter?.notifyDataSetChanged()
                manualStoreAdapter?.notifyDataSetChanged()
            })

        orderViewModel.errorMessageRescheduleOrder.observe(
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                (getActivity() as CustomerMainActivity).hideProgress()
                Toast.makeText(activity, it.toString(), Toast.LENGTH_SHORT).show()
            })

        orderViewModel.errorMessage.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (getActivity() as CustomerMainActivity).hideProgress()

            currentSingleOrderDetailsAdapter?.notifyDataSetChanged()
            receiptAdapter?.notifyDataSetChanged()
        })

    }

    private fun sendSocketEvent(data: ResponseWrapper?) {

        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {
                jsonObject.put(
                    SocketConstants.KeyUserId, (SharedPrefsUtils.getModelPreferences(
                        this.requireContext(), KeysUtils.keyUser,
                        User::class.java
                    ) as User).user_id.toString()
                )

                jsonObject.put(SocketConstants.KeyOrderId, data?.order_id?.toInt())
                jsonObject.put(SocketConstants.KeyDriverId, data?.driver_ids.toString())

                SocketConstants.socketIOClient!!.emit(SocketConstants.SocketPlaceOrder,
                    jsonObject, Ack {
                        try {
                            val messageJson = JSONObject(it[0].toString())
                            val responseStatus = messageJson.getString("status").toInt()
                            val message = messageJson.getString("message")

//                            dialogAlaram()

                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }

                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        } else {
            Log.e("Socket", "isDisconnecting=")
        }

    }


    private fun getSocketGetUpdatedEstimatedTime() {
        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {
                jsonObject.put(
                    SocketConstants.KeyUserId,
                    (SharedPrefsUtils.getModelPreferences(
                        activity,
                        KeysUtils.keyUser,
                        User::class.java
                    ) as User).user_id.toString()
                )
                jsonObject.put(SocketConstants.KeyOrderId, orderId)

                SocketConstants.socketIOClient!!.emit(SocketConstants.SocketGetUpdatedEstimatedTime,
                    jsonObject, Ack {
                        try {
                            val messageJson = JSONObject(it[0].toString())
                            val responseStatus = messageJson.getString("status").toInt()
                            if (responseStatus == 1) {
                                getSingleOrderApi()
                            }
                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }
                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        } else {
            Log.e("Socket", "isDisconnecting")
        }

    }

    override fun onDestroy() {
        super.onDestroy()
        LocalBroadcastManager.getInstance(requireContext()).unregisterReceiver(eventUpdate)
        if (flagClickReschedule) {
            targetFragment?.onActivityResult(targetRequestCode, Activity.RESULT_OK, null)
            parentFragmentManager.popBackStack()
        }
        //else {
        //targetFragment?.onActivityResult(targetRequestCode, Activity.RESULT_CANCELED, null)
        // parentFragmentManager.popBackStack()

        // goBackToPreviousFragment()
        // }
    }

    private fun goBackToPreviousFragment() {
        val fm = requireActivity().supportFragmentManager
        if (fm.backStackEntryCount > 0) {
            fm.popBackStack()
        }
    }
}