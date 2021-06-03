package com.quedrop.customer.ui.order.view.fragment

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.os.CountDownTimer
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.recyclerview.widget.LinearLayoutManager
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.CurrentOrderRequest
import com.quedrop.customer.model.GetCurrentOrderResponse
import com.quedrop.customer.model.RescheduleOrder
import com.quedrop.customer.model.User
import com.quedrop.customer.network.ResponseWrapper
import com.quedrop.customer.socket.SocketConstants
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.order.view.adapter.CurrentOrderMainAdapter
import com.quedrop.customer.ui.order.viewmodel.OrderViewModel
import com.quedrop.customer.utils.*
import io.socket.client.Ack
import kotlinx.android.synthetic.main.fragment_current_order.*
import org.json.JSONException
import org.json.JSONObject
import timber.log.Timber
import java.text.SimpleDateFormat
import java.util.*


class CurrentOrderFragment(val orderId: Int, val remoteMessage: String) : BaseFragment() {

    val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")

    private var serverCalender: Calendar? = null
    private var serverTimer: CountDownTimer? = null
    var currentOrderAdapter: CurrentOrderMainAdapter? = null
    var arrayCurrentOrderList: MutableList<GetCurrentOrderResponse>? = null
    lateinit var orderViewModel: OrderViewModel
    var isOrder: String = "1"
    var posReschedule: Int = 0
    var orderStatus = "Placed"

    companion object {
        fun newInstance(orderId: Int, remoteMessage: String): CurrentOrderFragment {
            return CurrentOrderFragment(orderId, remoteMessage)
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        return inflater.inflate(
            R.layout.fragment_current_order,
            container, false
        )
    }


    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        orderViewModel = OrderViewModel(appService)

        Utils.userId = SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyGuestId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keyAccessKey)!!
        Utils.selectAddressTitle =
            SharedPrefsUtils.getStringPreference(
                activity,
                KeysUtils.KeySelectAddressName
            )!!
        Utils.selectAddress =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeySelectAddress)!!
        Utils.selectAddressType =
            SharedPrefsUtils.getStringPreference(
                activity,
                KeysUtils.KeySelectAddressType
            )!!
        Utils.keyLatitude =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeyLatitude)!!
        Utils.keyLongitude =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeyLongitude)!!

        arrayCurrentOrderList = mutableListOf()

        LocalBroadcastManager.getInstance(requireContext()).registerReceiver(
            eventUpdate,
            IntentFilter(BroadCastConstant.BROADCAST_EVENT_CHANGE)
        )

        if (orderId != 0) {
            currentOrderInvoke(orderId, 0)
        }


        initMethod()
        getCurrentOrderApi()
        observeViewModel()

        RxBus.instance?.listen()?.subscribe {
            if (it == "refreshOrders") {
                getCurrentOrderApi()
            }
        }?.autoDispose(compositeDisposable)
    }

    private fun initMethod() {
        isOrder = "1"

        rvCurrentOrder.layoutManager = LinearLayoutManager(
            activity,
            LinearLayoutManager.VERTICAL,
            false
        )

        arrayCurrentOrderList = mutableListOf()
        currentOrderAdapter = CurrentOrderMainAdapter(
            activity,
            isOrder,
            arrayCurrentOrderList!!

        ).apply {
            currentOrderListInvoke = { orderId: Int, timeMainRemaining1: Long, mainPos: Int ->
                currentOrderInvoke(orderId, timeMainRemaining1)
            }

            rescheduleInvokeMain = {
                rescheduleApi(it)
            }
            refereshTimer = {
                getSocketGetUpdatedEstimatedTime(it)
            }
        }
        rvCurrentOrder.adapter = currentOrderAdapter

    }

    private fun getRescheduleOrder(pos: Int): RescheduleOrder {
        return RescheduleOrder(
            Utils.seceretKey,
            Utils.accessKey,
            arrayCurrentOrderList?.get(pos)?.order_id!!
        )
    }

    private fun rescheduleApi(pos: Int) {
        posReschedule = pos
        (activity as CustomerMainActivity).showProgress()
        orderViewModel.getRescheduleOrderApi(getRescheduleOrder(pos))
    }


    private fun observeViewModel() {

//        orderViewModel.doFirstWork(intentTimeRemaining)

        orderViewModel.currentOrderList.observe(
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                (getActivity() as CustomerMainActivity).hideProgress()
                textEmptyCurrent.visibility = View.GONE
                arrayCurrentOrderList?.clear()

                if (Utils.userId == 0) {

                } else {
                    arrayCurrentOrderList?.addAll(it)
                    doFirstWork()
                }
                currentOrderAdapter?.notifyDataSetChanged()
            })

        orderViewModel.errorMessage.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (getActivity() as CustomerMainActivity).hideProgress()
            textEmptyCurrent.visibility = View.VISIBLE
            textEmptyCurrent.text = it
            currentOrderAdapter?.notifyDataSetChanged()
        })

        orderViewModel.errorMessageRescheduleOrder.observe(
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                (getActivity() as CustomerMainActivity).hideProgress()
                Toast.makeText(activity, it.toString(), Toast.LENGTH_SHORT).show()
            })

        orderViewModel.responseRescheduleOrder.observe(
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                (activity as CustomerMainActivity).hideProgress()
                getCurrentOrderApi()
                sendSocketEvent(it)
            })
    }

    fun doFirstWork() {
        serverCalender = Calendar.getInstance()
        val serverTime = arrayCurrentOrderList?.get(posReschedule)?.server_time!!
        orderStatus = arrayCurrentOrderList?.get(posReschedule)?.order_status!!
        serverCalender?.time = dateFormat.parse(serverTime)
        serverTimer?.cancel()
        serverTimer = object : CountDownTimer(3000, 1000) {
            override fun onFinish() {
                serverTimer = null
            }

            override fun onTick(millisUntilFinished: Long) {

                if (orderStatus == "Placed") {
                    serverCalender?.add(Calendar.SECOND, 1)
                    currentOrderAdapter?.updateServerTimer(
                        dateFormat.format(serverCalender?.time)
                    )
                } else {
                    serverTimer?.cancel()
                    serverTimer = null
                    currentOrderAdapter?.notifyDataSetChanged()
                }

            }

        }.start()
    }


    private fun getCustomerOrderRequest(): CurrentOrderRequest {
        return CurrentOrderRequest(
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId,
            isOrder
        )
    }

    private fun currentOrderInvoke(orderId: Int, timeMainRemaining1: Long) {
        val orderIdMain = orderId

        (getActivity() as CustomerMainActivity).navigateToFragment(
            CurrentOrderDetailsFragment.newInstance(
                orderIdMain, timeMainRemaining1, remoteMessage
            ), this, ConstantUtils.ORDER_MANAGE_CODE
        )
    }

    private fun getCurrentOrderApi() {
        orderViewModel.getCustomerCurrentOrderApi(getCustomerOrderRequest())
    }


    override fun onDestroy() {
        super.onDestroy()
        LocalBroadcastManager.getInstance(requireContext()).unregisterReceiver(eventUpdate)

    }

    private val eventUpdate = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val events = intent.getStringExtra(BroadCastConstant.BROADCAST_KEY_EVENT)!!
            try {
                val jsonObject = JSONObject(intent.getStringExtra(BroadCastConstant.BROADCAST_KEY_OBJ)!!)
                parseResponse(events, jsonObject)
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }

    private fun parseResponse(event: String, argument: JSONObject) {
        when (event) {
            SocketConstants.SocketOrderAccepted -> {
                getCurrentOrderApi()
            }
        }
    }


    private fun sendSocketEvent(data: ResponseWrapper?) {

        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {

                jsonObject.put(
                    SocketConstants.KeyUserId, (SharedPrefsUtils.getModelPreferences(
                        activity, KeysUtils.keyUser,
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

                            //dialogAlaram()

                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }

                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        } else {
            Timber.e("Socket not connected")
        }

    }

    private fun getSocketGetUpdatedEstimatedTime(orderId: Int) {

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
//                            val message = messageJson.getString("estimated_delivery_time").toInt()
//                            val orderId = messageJson.getString("order_id").toInt()
//                            val updatedServerTime = messageJson.getString("updated_server_time")

                            if (responseStatus == 1) {
                                activity.runOnUiThread {
                                    getCurrentOrderApi()
                                }

                            }

                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }

                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        } else {
            Timber.e("Socket not connected")
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == ConstantUtils.ORDER_MANAGE_CODE && resultCode == Activity.RESULT_OK) {
            getCurrentOrderApi()
        } else if (requestCode == ConstantUtils.ORDER_MANAGE_CODE && resultCode == Activity.RESULT_CANCELED) {

        }
    }
}