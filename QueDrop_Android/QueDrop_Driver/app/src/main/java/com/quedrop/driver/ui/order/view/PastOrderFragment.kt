package com.quedrop.driver.ui.order.view

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.recyclerview.widget.LinearLayoutManager
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseFragment
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.service.model.Orders
import com.quedrop.driver.service.request.OrdersRequest
import com.quedrop.driver.socket.SocketConstants
import com.quedrop.driver.ui.mainActivity.view.MainActivity
import com.quedrop.driver.ui.order.adapter.CurrentOrderMainAdapter
import com.quedrop.driver.ui.orderDetailsFragment.view.OrderDetailActivity
import com.quedrop.driver.utils.*
import com.google.gson.Gson
import kotlinx.android.synthetic.main.fragment_past_order.*
import org.json.JSONException
import org.json.JSONObject

class PastOrderFragment : BaseFragment() {
    var pastOrderAdapter: CurrentOrderMainAdapter? = null
    var arrayPastOrderList: MutableList<Orders>? = null
    lateinit var mContext: Context

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(
            R.layout.fragment_past_order,
            container, false
        )
        mContext = activity
        return view

    }

    // get Socket event
    private val eventUpdate = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val events = intent.getStringExtra(BroadCastConstant.BROADCAST_KEY_EVENT)!!
            try {
                val jsonObject =
                    JSONObject(intent.getStringExtra(BroadCastConstant.BROADCAST_KEY_OBJ)!!)
                Log.e("PastOrder", "==>onReceive:" + events)
                if (events == SocketConstants.SocketOrderDeliveryAcknowledge) {
                    getCurrentOrderApi()
                }
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        LocalBroadcastManager.getInstance(mContext).registerReceiver(
            eventUpdate,
            IntentFilter(BroadCastConstant.BROADCAST_EVENT_CHANGE)
        )
        arrayPastOrderList = mutableListOf()

        initMethod()
        getCurrentOrderApi()
        observeViewModel()
    }

    companion object {
        fun newInstance(): PastOrderFragment {
            return PastOrderFragment()
        }
    }

    fun onPageSelected(position: Int) {

    }

    @SuppressLint("CheckResult")
    private fun initMethod() {
        rvPastOrder.layoutManager = LinearLayoutManager(
            this.context!!,
            LinearLayoutManager.VERTICAL,
            false
        )
        pastOrderAdapter = CurrentOrderMainAdapter(
            activity,
            arrayPastOrderList!!,
            false,
            isFromEarnPayment = false

        )
        pastOrderAdapter?.itemMainClick?.subscribe { orderId ->
            currentOrderInvoke(orderId)
        }
        rvPastOrder.adapter = pastOrderAdapter


        RxBus.instance?.listen()?.subscribe {
            if (it == "refreshOrder") {
                getCurrentOrderApi()
            }
        }?.autoDispose(compositeDisposable)
    }

    private fun observeViewModel() {
        mainViewModel.pastOrderList.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (getActivity() as MainActivity).hideProgress()
            arrayPastOrderList?.clear()
            arrayPastOrderList?.addAll(it!!)
            pastOrderAdapter?.notifyDataSetChanged()
        })

        mainViewModel.isError.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (getActivity() as MainActivity).hideProgress()

        })

        mainViewModel.isLoading.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            if (it) {
                showProgress()
            } else {
                hideProgress()
            }
        })
    }

    private fun getOrderRequest(): OrdersRequest {
        //

        return OrdersRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY, SharedPreferenceUtils.getInt(KEY_USERID)
        )
    }

    private fun currentOrderInvoke(orderId: String) {
        for (i in 0 until arrayPastOrderList?.size!!) {
            if (arrayPastOrderList!![i].orderId.toString() == orderId) {
                var orderArray = arrayPastOrderList!![i]
                val intent = Intent(activity, OrderDetailActivity::class.java)
                intent.putExtra("orderDetail", Gson().toJson(orderArray))
                this.startActivityWithDefaultAnimations(intent)
            }
        }
    }

    private fun getCurrentOrderApi() {
        if (Utility.isNetworkAvailable(context)) {
            (getActivity() as MainActivity).showProgress()
            mainViewModel.getPastOrderRequest(getOrderRequest())
        } else {
            hideProgress()
            showAlertMessage(activity, getString(R.string.no_internet_connection))
        }

    }

    override fun onResume() {
        super.onResume()
//        getCurrentOrderApi()
    }

    fun notifyAdapter() {
        pastOrderAdapter?.notifyDataSetChanged()
    }

}