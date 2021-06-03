package com.quedrop.driver.ui.earnings.view

import android.content.Context
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup

import com.quedrop.driver.R
import com.quedrop.driver.base.BaseFragment
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.Orders
import com.quedrop.driver.service.request.GetManualStorePaymentRequest
import com.quedrop.driver.ui.order.adapter.CurrentOrderMainAdapter
import com.quedrop.driver.utils.*
import com.quedrop.driver.utils.customeCalender.views.EventsCalendar
import kotlinx.android.synthetic.main.fragment_future_order.calendarCard
import kotlinx.android.synthetic.main.fragment_future_order.tvDate
import kotlinx.android.synthetic.main.fragment_manual_store.*
import java.text.SimpleDateFormat
import java.util.*

class ManualStoreFragment : BaseFragment(), EventsCalendar.Callback {

    private var mContext: Context? = null
    var currentOrderAdapter: CurrentOrderMainAdapter? = null
    var arrayCurrentOrderList: MutableList<Orders>? = mutableListOf()


    companion object {
        fun newInstance(): ManualStoreFragment {
            return ManualStoreFragment()
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_manual_store, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        mContext = activity

        initViews()
//
//        (activity as MainActivity).intent?.let { intent ->
//
//            intent.getStringExtra("remote_message").let {
//                if (it != null) {
//                    Log.i(NOTI_LOGS, "Main Fragment" + it.toString())
//                    if (it.isNotEmpty()) {
//                        val jsonObject = JSONObject(it)
//                        val notificationType = jsonObject.getInt("notification_type")
//
//                        if (notificationType == ENUMNotificationType.NOTIFICATION_DRIVER_WEEKLY_PAYMENT.posVal) {
//                            if (parentFragment is EarningsFragment) {
//                                (parentFragment!! as EarningsFragment).openEarningPaymentScreen()
//                            }
//                        }
//                    }
//
//                }
//            }
//
//            intent.getBooleanExtra(Key_Earning_payment, false).let {
//                if (it) {
//
//                    if (parentFragment is EarningsFragment) {
//                        (parentFragment!! as EarningsFragment).openEarningPaymentScreen()
//                    }
//                }
//            }
//        }
//
//

    }

    private fun initViews() {
        onClickView()
        setCalendar()


        currentOrderAdapter = CurrentOrderMainAdapter(
            activity,
            arrayCurrentOrderList,
            isFromManualPayment = true,
            isFromEarnPayment = false
        )
        rvManualStore.adapter = currentOrderAdapter

        //obeserver...
        mainViewModel.isLoading.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            if (it) {
                showProgress()
            } else {
                hideProgress()
            }
        })

        mainViewModel.isError.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            arrayCurrentOrderList?.clear()
            currentOrderAdapter?.notifyDataSetChanged()
            noManualStoreData.visibility = View.VISIBLE
            rvManualStore.visibility = View.GONE
            noManualStoreData.text = it
            //showAlertMessage(activity, it)
        })

        mainViewModel.manualStorePaymentObserver.observe(
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                val orderData = it.data.orders
                if (orderData.isNotEmpty()) {
                    noManualStoreData.visibility = View.GONE
                    rvManualStore.visibility = View.VISIBLE
                    arrayCurrentOrderList?.clear()
                    arrayCurrentOrderList?.addAll(orderData)
                    currentOrderAdapter?.notifyDataSetChanged()
                }
            })
    }

    private fun onClickView() {
        layoutDate.throttleClicks().subscribe {
            layoutDate.visibility = View.GONE
            calendarCard.visibility = View.VISIBLE
        }.autoDispose(compositeDisposable)

    }

    private fun setCalendar() {
        val startMonth = Calendar.getInstance()
        startMonth.add(Calendar.YEAR, -1)
        val endMonth = Calendar.getInstance()
        endMonth.add(Calendar.YEAR, 1)

        eventsSingleCalendar.setSelectionMode(eventsSingleCalendar.SINGLE_SELECTION)
            .setMonthRange(startMonth, endMonth)
            .setWeekStartDay(Calendar.WEDNESDAY, false)
            .setIsBoldTextOnSelectionEnabled(true)
            .setCallback(this)
            .build()

        val c = Calendar.getInstance()
        eventsSingleCalendar.setCurrentSelectedDate(c)
        Log.e("Calender1", "==>" + c.time)

        getManualStorePaymentDetail(UtilityMethod.getFormattedDate(Calendar.getInstance(), "yyyy-MM-dd"))
        tvDate.text = UtilityMethod.getFormattedDate(Calendar.getInstance(), "dd-MMMM-yyyy")
    }

    fun onPageSelected(position: Int) {
        setCalendar()
        layoutDate.visibility = View.VISIBLE
        calendarCard.visibility = View.GONE
    }

    override fun onDaySelected(selectedDate: Calendar?) {
        layoutDate.visibility = View.VISIBLE
        calendarCard.visibility = View.GONE
        getManualStorePaymentDetail(UtilityMethod.getFormattedDate(selectedDate, "yyyy-MM-dd"))
        tvDate.text = UtilityMethod.getFormattedDate(selectedDate, "dd-MMMM-yyyy")
    }

    private fun getDate(selectedDate: Calendar?): String {
        val date = selectedDate?.time
        val format1 = SimpleDateFormat("dd-MMMM-yyyy", Locale.getDefault())
        val formatedDate = format1.format(date!!)


        val format2 = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val orderDate = format2.format(date)
        return orderDate
    }

    override fun onDayLongPressed(selectedDate: Calendar?) {

    }

    override fun onMonthChanged(monthStartDate: Calendar?) {
    }

    private fun getManualStorePaymentDetail(orderDate: String) {
        val getManualStorePaymentRequest = GetManualStorePaymentRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            SharedPreferenceUtils.getInt(KEY_USERID),
            orderDate
        )
        mainViewModel.getManualStorePaymentRequest(getManualStorePaymentRequest)
    }

    override fun onResume() {
        super.onResume()
        setCalendar()
        layoutDate.visibility = View.VISIBLE
        calendarCard.visibility = View.GONE
    }

}
