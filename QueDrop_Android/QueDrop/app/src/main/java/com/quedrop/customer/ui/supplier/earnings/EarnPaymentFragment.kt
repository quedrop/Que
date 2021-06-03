package com.quedrop.customer.ui.supplier.earnings

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.RectF
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.SeekBar
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.github.mikephil.charting.components.XAxis.XAxisPosition
import com.github.mikephil.charting.components.YAxis.AxisDependency
import com.github.mikephil.charting.components.YAxis.YAxisLabelPosition
import com.github.mikephil.charting.data.BarData
import com.github.mikephil.charting.data.BarDataSet
import com.github.mikephil.charting.data.BarEntry
import com.github.mikephil.charting.data.Entry
import com.github.mikephil.charting.formatter.ValueFormatter
import com.github.mikephil.charting.highlight.Highlight
import com.github.mikephil.charting.interfaces.datasets.IBarDataSet
import com.github.mikephil.charting.listener.OnChartValueSelectedListener
import com.github.mikephil.charting.utils.Fill
import com.github.mikephil.charting.utils.MPPointF
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.BillingSummary
import com.quedrop.customer.model.SupplierOrder
import com.quedrop.customer.model.WeeklyData
import com.quedrop.customer.ui.supplier.graphhelper.DayAxisValueFormatter
import com.quedrop.customer.ui.supplier.graphhelper.MyValueFormatter
import com.quedrop.customer.ui.supplier.graphhelper.XYMarkerView
import com.quedrop.customer.ui.supplier.myorders.SupplierOrderViewModel
import com.quedrop.customer.ui.supplier.myorders.adapter.SupplierOrderAdapter
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import com.quedrop.customer.utils.Utils.CURRENCY
import com.quedrop.customer.utils.customeCalender.util.EventsCalendarUtil
import com.quedrop.customer.utils.customeCalender.views.EventsCalendar
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.google.gson.reflect.TypeToken
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.fragment_earn_payment.*
import timber.log.Timber
import java.text.SimpleDateFormat
import java.util.*


class EarnPaymentFragment : BaseFragment(), SeekBar.OnSeekBarChangeListener,
    OnChartValueSelectedListener, EventsCalendar.Callback {

    private var mContext: Context? = null

    private var orderAdapter: SupplierOrderAdapter? = null
    lateinit var viewModel: SupplierOrderViewModel

    var currentCalendar: Calendar? = null
    var orderData: MutableList<SupplierOrder>? = null
    var weeklyData: MutableList<WeeklyData>? = null
    var billingData: BillingSummary? = null

    private val requestDateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
    private val displayDateFormat = SimpleDateFormat("dd MMM", Locale.getDefault())
    private val dayDateFormat = SimpleDateFormat("EEE", Locale.getDefault())

    companion object {
        fun newInstance(): EarnPaymentFragment {
            return EarnPaymentFragment()
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_earn_payment, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        mContext = activity

        viewModel = SupplierOrderViewModel(appService)
        textEarnTitleOrder.text = getString(R.string.S_Earnings_Tab)
        Utils.Supplier.supplierUserId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.KeyUserSupplierId, 0)
        Utils.Supplier.supplierStoreID =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keySupplierStoreId, 0)

        //weekly order data setup...
        if (orderAdapter == null) {
            rvWeeklySummary.layoutManager = LinearLayoutManager(activity)
            orderAdapter =
                SupplierOrderAdapter(
                    activity,
                    true
                )
            rvWeeklySummary.adapter = orderAdapter
        }

        setUpChart()
        setCalendar()
        onClickView()
        observeViewModel()
    }

    private fun observeViewModel() {
        //obeserver...

        viewModel.orderList.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            orderData = it
            if (orderData?.isNotEmpty()!!) {
                txtWeeklySummaryView.visibility = View.VISIBLE
                orderAdapter?._orderList?.clear()
                orderAdapter?._orderList = it
                orderAdapter?.notifyDataSetChanged()
            }

        })
        viewModel.weeklyDataList.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            weeklyData = it
            setChartData()

        })
        viewModel.billingDataList.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            billingData = it
            setUpBillData()
        })

    }


    @SuppressLint("SetTextI18n")
    private fun setUpBillData() {
        if (billingData != null) {
            tvTotalEarnings.text = CURRENCY + " " + billingData?.total_amount.toString()
        } else {
            tvTotalEarnings.text = getString(R.string.no_prize)
        }
        if (billingData?.is_payment_done == 1) {
            tvPaymentDone.visibility = View.VISIBLE
        } else {
            tvPaymentDone.visibility = View.GONE
        }

    }

    private fun onClickView() {
        tvEarnDates.throttleClicks().subscribe {
            setCalendar()
            rangeCalendarCard.visibility = View.VISIBLE
        }.autoDispose(compositeDisposable)

        idPreviousMonth.throttleClicks().subscribe {
            tvEarnDates.isEnabled = false
            idNextMonth.visibility = View.VISIBLE
            currentCalendar?.add(Calendar.DAY_OF_MONTH, -7)
            setUpCalenderData(currentCalendar)

        }.autoDispose(compositeDisposable)

        idNextMonth.throttleClicks().subscribe {
            currentCalendar?.add(Calendar.DAY_OF_MONTH, 7)
            setUpCalenderData(currentCalendar)
        }.autoDispose(compositeDisposable)

    }

    fun onPageSelected(position: Int) {
        setCalendar()
        rangeCalendarCard.visibility = View.GONE
        //setUpCalenderData(Calendar.getInstance())
    }

    //calender setUp...
    private fun setCalendar() {
        val startMonth = Calendar.getInstance()
        startMonth.add(Calendar.YEAR, -1)
        val endMonth = Calendar.getInstance()
        endMonth.add(Calendar.YEAR, 1)

        rangeCalender.setSelectionMode(rangeCalender.MULTIPLE_SELECTION)
            .setMonthRange(startMonth, endMonth)
            .setWeekStartDay(Calendar.WEDNESDAY, false)
            .setIsBoldTextOnSelectionEnabled(true)
            .setCallback(this)
            .build()
        val c = Calendar.getInstance()
        rangeCalender.setCurrentSelectedDate(c)
        setUpCalenderData(c)
        // getWeekData(EventsCalendarUtil.getCurrentDate())

    }

    override fun onDaySelected(selectedDate: Calendar?) {

        Handler().postDelayed({
            rangeCalendarCard.visibility = View.GONE
        }, 500)
        setUpCalenderData(selectedDate)
    }

    override fun onDayLongPressed(selectedDate: Calendar?) {}

    override fun onMonthChanged(monthStartDate: Calendar?) {

    }

    private fun setUpCalenderData(selectedDate: Calendar?) {
        val date = selectedDate!!.time
        val orderDay = dayDateFormat.format(date)

        when (orderDay) {
            "Mon" -> {
                selectedDate.add(Calendar.DAY_OF_MONTH, -5)
            }
            "Tue" -> {
                selectedDate.add(Calendar.DAY_OF_MONTH, -6)
            }
            "Wed" -> {
                selectedDate.add(Calendar.DAY_OF_MONTH, 0)
            }
            "Thu" -> {
                selectedDate.add(Calendar.DAY_OF_MONTH, -1)
            }
            "Fri" -> {
                selectedDate.add(Calendar.DAY_OF_MONTH, -2)
            }
            "Sat" -> {
                selectedDate.add(Calendar.DAY_OF_MONTH, -3)
            }
            "Sun" -> {
                selectedDate.add(Calendar.DAY_OF_MONTH, -4)
            }
        }


        //first date of week
        val startDate = selectedDate.time
        val weekStatDate = requestDateFormat.format(startDate)
        val weekDisplayStatDate = displayDateFormat.format(startDate)

        //last date of week (start date+6)
        selectedDate.add(Calendar.DAY_OF_MONTH, 6)
        val endDate = selectedDate.time
        val weekEndDate = requestDateFormat.format(endDate)
        val weekDisplayEndDate = displayDateFormat.format(endDate)

        tvEarnDates.text = "$weekDisplayStatDate to $weekDisplayEndDate"

        getSupplierWeeklyPaymentDetail(weekStatDate, weekEndDate)

        this.currentCalendar = selectedDate

        if (isDateInCurrentWeek(currentCalendar?.time)) {
            tvEarnDates.isEnabled = true
            idNextMonth.visibility = View.GONE
        } else {
            if (EventsCalendarUtil.isFutureDay(selectedDate)) {
                tvEarnDates.isEnabled = true
                idNextMonth.visibility = View.GONE
            } else {
                tvEarnDates.isEnabled = false
                idNextMonth.visibility = View.VISIBLE
            }

        }

    }

    private fun isDateInCurrentWeek(date: Date?): Boolean {
        val currentCalendar2 = Calendar.getInstance()
        currentCalendar2.firstDayOfWeek = Calendar.WEDNESDAY
        val week = currentCalendar2[Calendar.WEEK_OF_YEAR]
        val year = currentCalendar2[Calendar.YEAR]
        val targetCalendar = Calendar.getInstance()
        targetCalendar.firstDayOfWeek = Calendar.WEDNESDAY
        targetCalendar.time = date!!
        val targetWeek = targetCalendar.get(Calendar.WEEK_OF_YEAR)
        val targetYear = targetCalendar.get(Calendar.YEAR)
        return week == targetWeek && year == targetYear
    }

    //chart setUp...
    private fun setUpChart() {
        chart!!.setOnChartValueSelectedListener(this)

        chart!!.setDrawBarShadow(false)
        chart!!.setDrawValueAboveBar(false)
        chart!!.setFitBars(true)
        chart!!.isDoubleTapToZoomEnabled = false
        chart!!.setDrawGridBackground(false)
        // chart!!.setClipValuesToContent(false)
        // chart!!.setClipDataToContent(false)

        chart!!.description.isEnabled = false

        // if more than 60 entries are displayed in the chart, no values will be
        // drawn

        // if more than 60 entries are displayed in the chart, no values will be
        // drawn
        chart!!.setMaxVisibleValueCount(7)

        // scaling can now only be done on x- and y-axis separately

        // scaling can now only be done on x- and y-axis separately
        chart!!.setPinchZoom(false)

        chart!!.setDrawGridBackground(false)
        chart!!.setNoDataText("")
        // chart.setDrawYLabels(false);

        // chart.setDrawYLabels(false);
        val xAxisFormatter: ValueFormatter =
            DayAxisValueFormatter(chart)

        val xAxis = chart!!.xAxis
        xAxis.position = XAxisPosition.BOTTOM
        //xAxis.typeface = tfLight
        xAxis.setDrawGridLines(false)
        xAxis.granularity = 1f // only intervals of 1 day

        xAxis.labelCount = 7
        xAxis.valueFormatter = xAxisFormatter
        xAxis.setDrawGridLines(false)

        val custom: ValueFormatter = MyValueFormatter("$")

        val leftAxis = chart!!.axisLeft
        //leftAxis.typeface = tfLight
        leftAxis.setLabelCount(8, false)
        leftAxis.valueFormatter = custom
        leftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART)
        leftAxis.spaceTop = 15f
        leftAxis.axisMinimum = 0f // this replaces setStartAtZero(true)
        leftAxis.setDrawGridLines(false)


        val rightAxis = chart!!.axisRight
        rightAxis.isEnabled = false
        /*rightAxis.setDrawGridLines(false)
        //rightAxis.typeface = tfLight
        rightAxis.isEnabled = false
        rightAxis.setLabelCount(8, false)
        rightAxis.valueFormatter = custom
        rightAxis.spaceTop = 15f
        rightAxis.axisMinimum = 0f // this replaces setStartAtZero(true)
        rightAxis.setDrawGridLines(false)*/


        val l = chart!!.legend
        l.isEnabled = false
        /*l.verticalAlignment = Legend.LegendVerticalAlignment.BOTTOM
        l.horizontalAlignment = Legend.LegendHorizontalAlignment.LEFT
        l.orientation = Legend.LegendOrientation.HORIZONTAL
        l.setDrawInside(false)
        l.form = LegendForm.SQUARE
        l.formSize = 9f
        l.textSize = 11f
        l.xEntrySpace = 4f*/

        val mv = XYMarkerView(mContext, xAxisFormatter)
        mv.chartView = chart // For bounds control

        chart!!.marker = mv // Set the marker to the chart


        // setting data
        //setData(6, 45F)
        // setting data
        //chart.setDrawLegend(false);
    }

    private fun setChartData() {
        val arr = ArrayList<BarEntry>()
        if (weeklyData != null) {
            val arrWeeklyData = weeklyData
            for (i in arrWeeklyData?.indices!!) {
                val obj = arrWeeklyData[i]
                arr.add(BarEntry(i.toFloat(), obj.total_amount.toFloat()))
            }
        } else {
            for (i in 0..6) {
                arr.add(BarEntry(i.toFloat(), 0F))
            }
        }

        val set1: BarDataSet
        if (chart!!.data != null &&
            chart!!.data.dataSetCount > 0
        ) {
            set1 = chart!!.data.getDataSetByIndex(0) as BarDataSet
            set1.values = arr
            chart!!.data.notifyDataChanged()
            chart!!.notifyDataSetChanged()
        } else {
            set1 = BarDataSet(arr, "Weekly Earning")
            set1.setDrawIcons(false)
            val startColor1 = ContextCompat.getColor(
                mContext!!,
                R.color.colorThemeGreen
            )

            val endColor1 = ContextCompat.getColor(mContext!!, R.color.colorThemeGreen)
            val gradientFills: MutableList<Fill> = ArrayList()
            gradientFills.add(Fill(startColor1, endColor1))
            set1.fills = gradientFills
            val dataSets = ArrayList<IBarDataSet>()
            dataSets.add(set1)
            val data = BarData(dataSets)
            data.setValueTextSize(10f)
            //data.setValueTypeface(tfLight)
            data.barWidth = 0.7f
            chart!!.data = data
        }

    }

    override fun onProgressChanged(
        seekBar: SeekBar?,
        progress: Int,
        fromUser: Boolean
    ) {
        chart!!.invalidate()
    }

    override fun onStartTrackingTouch(seekBar: SeekBar?) {}

    override fun onStopTrackingTouch(seekBar: SeekBar?) {}

    private val onValueSelectedRectF = RectF()

    @SuppressLint("LogNotTimber")
    override fun onValueSelected(
        e: Entry?,
        h: Highlight?
    ) {
        if (e == null) return
        val bounds = onValueSelectedRectF
        chart!!.getBarBounds(e as BarEntry?, bounds)
        val position = chart!!.getPosition(e, AxisDependency.LEFT)
        Log.i("bounds", bounds.toString())
        Log.i("position", position.toString())
        Log.i(
            "x-index",
            "low: " + chart!!.lowestVisibleX + ", high: "
                    + chart!!.highestVisibleX
        )
        MPPointF.recycleInstance(position)
    }

    override fun onNothingSelected() {}


    //api request...
    private fun getSupplierWeeklyPaymentDetail(
        weekStatDate: String,
        weekEndDate: String
    ) {
        val jsonObject = JsonObject()

        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        jsonObject.addProperty("user_id", Utils.Supplier.supplierUserId)
        jsonObject.addProperty("week_start_date", weekStatDate)
        jsonObject.addProperty("week_end_date", weekEndDate)
        jsonObject.addProperty("store_id", Utils.Supplier.supplierStoreID)

        viewModel.getWeeklyPaymentRequest(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe { }
            .doAfterTerminate { }
            .subscribe({
                if (it.status) {
                    noWeekData.visibility = View.GONE
                    rvWeeklySummary.visibility = View.VISIBLE
                    val yourMap: Map<String, Nothing>? = it.data
                    val jsonObject = Gson().toJsonTree(yourMap).asJsonObject
                    val orderType = object : TypeToken<MutableList<SupplierOrder?>?>() {}.type
                    val orderList: MutableList<SupplierOrder> =
                        Gson().fromJson(jsonObject.get("orders"), orderType)
                    viewModel.orderList.value = orderList

                    val weeklyType = object : TypeToken<MutableList<WeeklyData?>?>() {}.type
                    val weeklyDataList: MutableList<WeeklyData> =
                        Gson().fromJson(jsonObject.get("weekly_data"), weeklyType)
                    viewModel.weeklyDataList.value = weeklyDataList

                    val billingType = object : TypeToken<BillingSummary?>() {}.type
                    val billingDataList: BillingSummary =
                        Gson().fromJson(jsonObject.get("billing_summary"), billingType)
                    viewModel.billingDataList.value = billingDataList

                } else {
                    noWeekData.visibility = View.VISIBLE
                    rvWeeklySummary.visibility = View.GONE
                    noWeekData.text = it.message
                    orderAdapter?._orderList?.clear()
                    orderAdapter?.notifyDataSetChanged()
                    billingData = null
                    weeklyData = null
                    setUpBillData()
                    setChartData()
                }
            }, {
                Timber.e(it.localizedMessage)
                //  activity.showToast(it.localizedMessage ?: "")
            }).autoDispose(compositeDisposable)
    }

}
