package com.quedrop.driver.ui.earnings.view

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
import com.app.vinu.ui.customeCalender.util.EventsCalendarUtil
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
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseFragment
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.graphhelper.DayAxisValueFormatter
import com.quedrop.driver.graphhelper.MyValueFormatter
import com.quedrop.driver.graphhelper.XYMarkerView
import com.quedrop.driver.service.model.MainOrderResponse
import com.quedrop.driver.service.model.Orders
import com.quedrop.driver.service.request.GetWeeklyPaymentRequest
import com.quedrop.driver.ui.order.adapter.CurrentOrderMainAdapter
import com.quedrop.driver.utils.*
import com.quedrop.driver.utils.customeCalender.views.EventsCalendar
import kotlinx.android.synthetic.main.fragment_earn_payment.*
import java.text.SimpleDateFormat
import java.util.*


class EarnPaymentFragment : BaseFragment(), SeekBar.OnSeekBarChangeListener,
    OnChartValueSelectedListener, EventsCalendar.Callback {

    private var mContext: Context? = null

    var currentOrderAdapter: CurrentOrderMainAdapter? = null
    var arrayCurrentOrderList: MutableList<Orders>? = mutableListOf()
    var mainOrderResponse: MainOrderResponse? = null

    var currentCalendar: Calendar? = null

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

        //weekly order data setup...
        currentOrderAdapter = CurrentOrderMainAdapter(
            activity,
            arrayCurrentOrderList,
            isFromManualPayment = false,
            isFromEarnPayment = true
        )
        rvWeeklySummary.adapter = currentOrderAdapter

        setUpChart()
        setCalendar()
        onClickView()
        observeViewModel()
    }

    private fun observeViewModel() {
        //obeserver...
        mainViewModel.isLoading.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            if (it) {
                showProgress()
            } else {
                hideProgress()
            }
        })

        mainViewModel.isError.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            mainOrderResponse = null
            arrayCurrentOrderList?.clear()
            currentOrderAdapter?.notifyDataSetChanged()
            txtWeeklySummaryView.visibility = View.GONE
            setUpBillData()
            setChartData()
        })

        mainViewModel.weeklyPaymentObserver.observe(
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                mainOrderResponse = it
                val weeklyData = it.data.weeklyData
                val orderData = it.data.orders

                if (weeklyData.isNotEmpty()) {

                }
                if (orderData.isNotEmpty()) {
                    txtWeeklySummaryView.visibility = View.VISIBLE
                    arrayCurrentOrderList?.clear()
                    arrayCurrentOrderList?.addAll(orderData)
                    currentOrderAdapter?.notifyDataSetChanged()
                }
                setUpBillData()
                setChartData()
            })
    }

    @SuppressLint("SetTextI18n")
    private fun setUpBillData() {
        val billingData = mainOrderResponse?.data?.billingSummary
        if (mainOrderResponse?.data != null) {
            txtDeliveryEarning.text = CURRENCY + " " + billingData?.totalDeliveryEarning.toString()
            txtShippingEarning.text = CURRENCY + " " + billingData?.totalShoppingEarning.toString()
            txtTipReceived.text = CURRENCY + " " + billingData?.totalTipEarning.toString()
            txtTotalEarning.text = CURRENCY + " " + billingData?.totalAmount.toString()
            tvTotalEarnings.text = CURRENCY + " " + billingData?.totalAmount.toString()
            txtTipReferring.text = CURRENCY + " " + billingData?.totalReferralEarning.toString()
        } else {
            txtDeliveryEarning.text = getString(R.string.no_prize)
            txtShippingEarning.text = getString(R.string.no_prize)
            txtTipReceived.text = getString(R.string.no_prize)
            txtTotalEarning.text = getString(R.string.no_prize)
            tvTotalEarnings.text = getString(R.string.no_prize)
            txtTipReferring.text = getString(R.string.no_prize)
        }
        if (billingData?.isPaymentDone == 1) {
            tvPaymentDone.visibility = View.VISIBLE
        } else {
            tvPaymentDone.visibility = View.GONE
        }

    }

    private fun onClickView() {
        tvEarnDates.throttleClicks().subscribe {
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

        if (rangeCalender != null) {
            rangeCalender.setSelectionMode(rangeCalender.MULTIPLE_SELECTION)
                .setMonthRange(startMonth, endMonth)
                .setWeekStartDay(Calendar.WEDNESDAY, false)
                .setIsBoldTextOnSelectionEnabled(true)
                .setCallback(this)
                .build()
            val c = Calendar.getInstance()
            rangeCalender.setCurrentSelectedDate(c)
            setUpCalenderData(c)
        }
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

        getDriverWeeklyPaymentDetail(weekStatDate, weekEndDate)

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
        if (mainOrderResponse?.data != null) {
            val arrWeeklyData = mainOrderResponse?.data?.weeklyData
            for (i in arrWeeklyData?.indices!!) {
                val obj = arrWeeklyData[i]
                arr.add(BarEntry(i.toFloat(), obj.totalAmount.toFloat()))
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

    private fun setData(count: Int, range: Float) {
        val start = 1f
        val values = ArrayList<BarEntry>()
        var i = start.toInt()
        while (i < start + count) {
            val valD = (Math.random() * (range + 1)).toFloat()
            values.add(BarEntry(i.toFloat(), valD))

            i++
        }
        val set1: BarDataSet
        if (chart!!.data != null &&
            chart!!.data.dataSetCount > 0
        ) {
            set1 = chart!!.data.getDataSetByIndex(0) as BarDataSet
            set1.values = values
            chart!!.data.notifyDataChanged()
            chart!!.notifyDataSetChanged()
        } else {
            set1 = BarDataSet(values, "Weekly Earning")
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
    private fun getDriverWeeklyPaymentDetail(startDate: String, endDate: String) {
        val getWeeklyPaymentRequest = GetWeeklyPaymentRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            SharedPreferenceUtils.getInt(KEY_USERID),
            startDate,
            endDate
        )
        mainViewModel.getWeeklyPaymentRequest(getWeeklyPaymentRequest)
    }
}
