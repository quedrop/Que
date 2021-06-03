package com.quedrop.driver.ui.order.view

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
import kotlinx.android.synthetic.main.fragment_current_order.*
import org.json.JSONException
import org.json.JSONObject


class CurrentOrderFragment : BaseFragment() {

    var currentOrderAdapter: CurrentOrderMainAdapter? = null
    var arrayCurrentOrderList: MutableList<Orders>? = null
    lateinit var mContext: Context

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {


        val view = inflater.inflate(
            R.layout.fragment_current_order,
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
        initMethod()
        getCurrentOrderApi()
        observeViewModel()

    }

    companion object {
        fun newInstance(
        ): CurrentOrderFragment {
            return CurrentOrderFragment(
            )
        }
    }

    private fun initMethod() {

        rvCurrentOrder.layoutManager = LinearLayoutManager(
            this.context!!,
            LinearLayoutManager.VERTICAL,
            false
        )

        arrayCurrentOrderList = mutableListOf()
        currentOrderAdapter = CurrentOrderMainAdapter(
            activity,
            arrayCurrentOrderList!!,
            isFromManualPayment = false,
            isFromEarnPayment = false

        )
        rvCurrentOrder.adapter = currentOrderAdapter

        currentOrderAdapter?.itemMainClick?.subscribe { orderId ->
            currentOrderInvoke(orderId)
        }!!.autoDispose(compositeDisposable)

        RxBus.instance?.listen()?.subscribe {
            if (it == "refreshOrder") {
                getCurrentOrderApi()
            }
        }?.autoDispose(compositeDisposable)
    }


    private fun observeViewModel() {
        mainViewModel.currentOrderList.observe(
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                hideProgress()
                arrayCurrentOrderList?.clear()
                arrayCurrentOrderList = it


                currentOrderAdapter?.updateData(it)
                //rvCurrentOrder.smoothScrollToPosition(0)
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
        return OrdersRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY, SharedPreferenceUtils.getInt(KEY_USERID)
        )
    }


    private fun currentOrderInvoke(orderId: String) {
        for (i in 0 until arrayCurrentOrderList?.size!!) {
            if (arrayCurrentOrderList!![i].orderId.toString() == orderId) {
                var orderArray = arrayCurrentOrderList!![i]

                val intent = Intent(mContext, OrderDetailActivity::class.java)
                intent.putExtra("orderDetail", Gson().toJson(orderArray))
                this.startActivityWithDefaultAnimations(intent)

            }
        }

    }


    fun notifyAdapter() {
        currentOrderAdapter?.notifyDataSetChanged()
    }

    private fun getCurrentOrderApi() {
        if (Utility.isNetworkAvailable(context)) {
            showProgress()
            mainViewModel.getCurrentRequest(getOrderRequest())
        } else {
            hideProgress()
            showAlertMessage(activity, getString(R.string.no_internet_connection))
        }

    }

    fun onPageSelected(position: Int) {
        // getCurrentOrderApi()
    }


    override fun onStart() {
        super.onStart()
        notifyAdapter()
    }

    override fun onStop() {
        super.onStop()
    }

    override fun onResume() {
        super.onResume()
        Log.e("CurrentOrder", "OnResume")

    }
}