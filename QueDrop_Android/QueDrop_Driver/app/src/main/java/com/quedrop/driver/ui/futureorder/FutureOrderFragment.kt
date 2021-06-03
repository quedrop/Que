package com.quedrop.driver.ui.futureorder

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseFragment
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.Orders
import com.quedrop.driver.service.request.GetFutureOrderDatesRequest
import com.quedrop.driver.service.request.GetFutureOrderRequest
import com.quedrop.driver.utils.*
import com.quedrop.driver.utils.customeCalender.views.EventsCalendar
import kotlinx.android.synthetic.main.fragment_future_order.*
import kotlinx.android.synthetic.main.toolbar_normal.*
import java.util.*

class FutureOrderFragment : BaseFragment(), EventsCalendar.Callback {

    var mContext: Context? = null
    var futureOrderAdapter: FutureOrderAdapter? = null
    var arrayFutureOrderList: MutableList<Orders>? = mutableListOf()


    companion object {
        fun newInstance(): FutureOrderFragment {
            return FutureOrderFragment()
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_future_order, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        mContext = activity
        initViews()
    }

    private fun initViews() {
        setUpToolBar()
        onClickViews()
        setCalendar()
        getFutureOrdersDates()
        setUpFutureOrderData()
        observableModal()
    }

    private fun getFutureOrders(orderDate: String) {
        val getFutureOrderRequest = GetFutureOrderRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            SharedPreferenceUtils.getInt(KEY_USERID),
            orderDate,
            "0"
        )

        mainViewModel.getFutureOrderRequest(getFutureOrderRequest)
    }

    private fun getFutureOrdersDates() {
        val getFutureOrderDatesRequest = GetFutureOrderDatesRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            SharedPreferenceUtils.getInt(KEY_USERID),
            0
        )

        mainViewModel.getFutureOrderDatesRequest(getFutureOrderDatesRequest)
    }

    private fun observableModal() {
        //obeserver...
        mainViewModel.isLoading.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            if (it) {
                showProgress()
            } else {
                hideProgress()
            }
        })

        mainViewModel.isError.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            arrayFutureOrderList?.clear()
            futureOrderAdapter?.notifyDataSetChanged()
            noFutureOrderData.visibility = View.VISIBLE
            rvFutureOrder.visibility = View.GONE
            noFutureOrderData.text = it
        })

        mainViewModel.futureOrderList.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            if (it?.isNotEmpty()!!) {
                noFutureOrderData.visibility = View.GONE
                rvFutureOrder.visibility = View.VISIBLE
                arrayFutureOrderList?.clear()
                arrayFutureOrderList?.addAll(it)
                futureOrderAdapter?.notifyDataSetChanged()
            }
        })

        mainViewModel.futureOrderDateListObserver.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            for(i in it.indices){
                futureCalender.addEvent(UtilityMethod.getDateFormatFroDots(it[i].futureOrderDates!!))
            }
        })
    }

    private fun setUpFutureOrderData() {
        futureOrderAdapter = FutureOrderAdapter(
            activity,
            arrayFutureOrderList!!
        )

        rvFutureOrder.adapter = futureOrderAdapter

        futureOrderAdapter?.itemMainClick?.throttleClicks()?.subscribe { orderId ->
            currentOrderInvoke(orderId)
        }?.autoDispose(compositeDisposable)

        futureOrderAdapter?.apply {
            onCalenderClick = { view, adapterPosition ->
                cvFutureCalendarCard.visibility = View.VISIBLE
                futureCalender.clearEvents()
                var str = arrayFutureOrderList[adapterPosition].recurredOn!!.split(",")
                for(i in str.indices) {
                    futureCalender.addEvent(UtilityMethod.getDateFormatFroDots(str[i]))
                }
            }
        }
    }

    private fun currentOrderInvoke(orderId: String) {
        for (i in 0 until arrayFutureOrderList?.size!!) {
            if (arrayFutureOrderList!![i].recurringOrderId.toString() == orderId) {
                val intent = Intent(activity, FutureOrderDetailActivity::class.java)
                intent.putExtra("order_id", orderId)
                startActivityWithDefaultAnimations(intent)
            }
        }
    }

    private fun onClickViews() {
        layoutFutureConst.throttleClicks().subscribe {
            cvFutureCalendarCard.visibility = View.VISIBLE
            getFutureOrdersDates()
        }.autoDispose(compositeDisposable)
    }

    private fun setUpToolBar() {
        tvTitle.setText(R.string.queue_order_request)
        ivBack.throttleClicks().subscribe {
            goBackToPreviousFragment()
        }.autoDispose(compositeDisposable)
    }

    private fun goBackToPreviousFragment() {
        val fm = getActivity()!!.supportFragmentManager
        if (fm.backStackEntryCount > 0) {
            fm.popBackStack()
        }
    }

    private fun setCalendar() {
        val startMonth = Calendar.getInstance()
        startMonth.add(Calendar.YEAR, -1)
        val endMonth = Calendar.getInstance()
        endMonth.add(Calendar.YEAR, 1)

        futureCalender.setSelectionMode(futureCalender.SINGLE_SELECTION)
            .setMonthRange(startMonth, endMonth)
            .setWeekStartDay(Calendar.WEDNESDAY, false)
            .setIsBoldTextOnSelectionEnabled(true)
            .setCallback(this)
            .build()

        futureCalender.setCurrentSelectedDate(Calendar.getInstance())
        getFutureOrders("2020-03-22")
        tvDate.text = UtilityMethod.getFormattedDate(Calendar.getInstance(), "dd-MMMM-yyyy")
    }

    override fun onDaySelected(selectedDate: Calendar?) {
        cvFutureCalendarCard.visibility = View.GONE
        getFutureOrders(UtilityMethod.getFormattedDate(selectedDate, "yyyy-MM-dd"))
        tvDate.text = UtilityMethod.getFormattedDate(selectedDate, "dd-MMMM-yyyy")
    }

    override fun onDayLongPressed(selectedDate: Calendar?) {

    }

    override fun onMonthChanged(monthStartDate: Calendar?) {
    }
}

