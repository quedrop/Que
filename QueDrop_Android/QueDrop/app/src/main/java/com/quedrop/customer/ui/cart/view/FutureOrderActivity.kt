package com.quedrop.customer.ui.cart.view

import android.app.Dialog
import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.Toast

import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.model.GetRecurringRequest
import com.quedrop.customer.model.GetRecurringTypeResponse
import com.quedrop.customer.ui.cart.view.datepicker.SlyCalendarDialog
import com.quedrop.customer.ui.cart.view.timepicker.TimePickerPopWin
import com.quedrop.customer.ui.cart.viewmodel.CartViewModel
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.activity_future_order2.*
import kotlinx.android.synthetic.main.activity_recurring_order.*
import kotlinx.android.synthetic.main.fragment_time.loop_view
import java.text.SimpleDateFormat
import java.util.*
import android.content.Intent
import android.app.Activity
import androidx.core.content.ContextCompat
import com.quedrop.customer.ui.cart.view.adapter.CustomeSpinnerAdapter
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils


class FutureOrderActivity : BaseActivity(), SlyCalendarDialog.Callback {
    var onceDate: String? = null
    var monthlyStartDate: String? = null
    var repeatUntilDate: Boolean = false
    var monthlyEndDate: String? = null
    var recurringTypeId: Int = 0
    var recurringOn: String = ""
    var recurringTime: String = ""
    var label: String = ""
    var repeatUntilDateString: String = ""
    var sundayBoolean = true
    var mondayBoolean = false
    var tuesdayBoolean = false
    var wednesdayBoolean = false
    var thursdayBoolean = false
    var fridayBoolean = false
    var saturdayBoolean = false

    override fun onCancelled() {

    }

    override fun onDataSelected(
        firstDate: Calendar?,
        secondDate: Calendar?,
        hours: Int,
        minutes: Int
    ) {
        if (firstDate != null) {
            if (secondDate == null) {
//                firstDate.set(Calendar.HOUR_OF_DAY, hours)
//                firstDate.set(Calendar.MINUTE, minutes)
                Toast.makeText(
                    this,
                    SimpleDateFormat(getString(R.string.dateFormat)).format(
                        firstDate.time
                    ),
                    Toast.LENGTH_LONG

                ).show()

                if(repeatUntilDate){

                    repeatUntilDateString = SimpleDateFormat(getString(R.string.dateFormat)).format(
                        firstDate.time
                    )

                }else {

                    onceDate = SimpleDateFormat(getString(R.string.dateFormat)).format(
                        firstDate.time
                    )

                    recurringOn = onceDate.toString()
                    SharedPrefsUtils.setStringPreference(
                        applicationContext,
                        KeysUtils.keyOnceDate,
                        onceDate!!
                    )

                }
            } else {
                Toast.makeText(
                    this,
                    getString(
                        R.string.period,
                        SimpleDateFormat(
                            getString(R.string.dateFormat)
                        ).format(firstDate.time),
                        SimpleDateFormat(
                            getString(R.string.dateFormat)
                        ).format(secondDate.time)
                    ),
                    Toast.LENGTH_LONG

                ).show()

                monthlyStartDate = SimpleDateFormat(
                    getString(R.string.dateFormat)
                ).format(firstDate.time)

                monthlyEndDate = SimpleDateFormat(
                    getString(R.string.dateFormat)
                ).format(secondDate.time)

                recurringOn = monthlyStartDate.toString()+","+monthlyEndDate.toString()



                SharedPrefsUtils.setStringPreference(
                    applicationContext,
                    KeysUtils.keyMonthlyStartDate,
                    monthlyStartDate!!
                )
                SharedPrefsUtils.setStringPreference(
                    applicationContext,
                    KeysUtils.keyMonthlyEndDate,
                    monthlyEndDate!!
                )
            }
        }
    }


    lateinit var cartViewModel: CartViewModel
    var startYear: Int? = null
    var hours: Int? = null
    var minutes: Int? = null
    var seconds: Int? = null
    var AM_PMS: String? = null
    var startMonth: Int? = null
    var startDay: Int? = null
    var spinnerAdapter: CustomeSpinnerAdapter? = null
    var arrayListRecurringType: MutableList<GetRecurringTypeResponse>? = null
    var weeklyFlag: Boolean = false


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_future_order2)

        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyUserId,0)
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyGuestId,0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyAccessKey)!!

        cartViewModel = CartViewModel(appService)

        initMethod()
        observeViewModel()
        onClickMethod()
        getRecurringTypeApi()

    }

    private fun initMethod() {

        repeatUntilDateColor()
        val calendar = Calendar.getInstance()
        startYear = calendar.get(Calendar.YEAR)
        startMonth = calendar.get(Calendar.MONTH)
        startDay = calendar.get(Calendar.DAY_OF_MONTH)

        val timePickerPopWin = TimePickerPopWin.Builder(
            this,
            object : TimePickerPopWin.OnTimePickListener {
                override fun onTimePickCompleted(
                    hour: Int,
                    minute: Int,
                    AM_PM: String,
                    time: String
                ) {

                    hours = hour
                    minutes = minute
                    seconds = 0
                    AM_PMS = AM_PM

                    var hourmain = 0

                    if (AM_PM == "PM") {
                        hourmain = hour

                        if (hourmain == 12) {
                            hourmain = 0
                        } else {
                            hourmain += 12
                        }
                    } else {
                        hourmain = hour
                    }
                    val input = hourmain.toString() + ":" + minutes + ":" + seconds + " "

                    recurringTime = input
                    Toast.makeText(
                        applicationContext,
                        recurringTime,
                        Toast.LENGTH_SHORT
                    ).show()
                }
            })
            .build()
        timePickerPopWin.showPopWin(loop_view)

        arrayListRecurringType = mutableListOf()


    }

    private fun onClickMethod() {


        ivBackFuture.setOnClickListener {
            onBackPressed()
        }

        tvRepeatUntil.setOnClickListener {
            if (repeatUntilDate) {
                SlyCalendarDialog()
                    .setSingle(true)
                    .setFirstMonday(false)
                    .setCallback(this@FutureOrderActivity)
                    .show(supportFragmentManager, "TAG_SLYCALENDAR")
            }
        }

        tvLabel.setOnClickListener {

            editLabelAdvance.visibility = View.VISIBLE
            ivCloseFuture.visibility = View.VISIBLE
        }

        ivCloseFuture.setOnClickListener {
            if (editLabelAdvance.text.toString().isEmpty()) {


            } else {
                editLabelAdvance.setText("")
            }
        }

        btnSaveFuture.setOnClickListener {


            val intent = Intent()
            intent.putExtra(KeysUtils.keyRecurringTypeId, recurringTypeId)
            intent.putExtra(KeysUtils.keyRecurringOn, recurringOn)
            intent.putExtra(KeysUtils.keyRecurringTime, recurringTime)
            intent.putExtra(KeysUtils.keyLabel, label)
            intent.putExtra(KeysUtils.keyRepeatUntilDate, repeatUntilDateString)
            setResult(Activity.RESULT_OK, intent)
            finish()
        }


        tvSunday.setOnClickListener {
            if (weeklyFlag) {

            } else {
                if(sundayBoolean){
                    sundayUnpress()
                    sundayBoolean = false
                }else{
                    sundayPress()
                    sundayBoolean = true
                }

            }

        }

        tvMonday.setOnClickListener {


            if(weeklyFlag) {

            } else {
                if(mondayBoolean){
                    mondayUnpress()
                    mondayBoolean = false
                }else{
                    mondayPress()
                    mondayBoolean = true
                }
            }
        }

        tvTuesday.setOnClickListener {
            if(weeklyFlag) {

            } else {
                if(tuesdayBoolean){
                    tuesdayUnpress()
                    tuesdayBoolean = false
                }else{
                    tuesdayPress()
                    tuesdayBoolean = true
                }
            }
        }

        tvWednesday.setOnClickListener {
            if (weeklyFlag) {


            } else {
                if(wednesdayBoolean){
                    wednesdayUnpress()
                    wednesdayBoolean = false
                }else{
                    wednesdayPress()
                    wednesdayBoolean = true
                }
            }
        }

        tvThursday.setOnClickListener {
            if(weeklyFlag) {

            } else {
                if(thursdayBoolean){
                    thursdayUnpress()
                    thursdayBoolean = false
                }else{
                    thursdayPress()
                    thursdayBoolean = true
                }
            }
        }
        tvFriday.setOnClickListener {
            if(weeklyFlag) {

            } else {
                if(fridayBoolean){
                    fridayUnpress()
                    fridayBoolean = false
                }else{
                    fridayPress()
                    fridayBoolean = true
                }
            }
        }
        tvSaturday.setOnClickListener {
            if(weeklyFlag) {

            } else {
                if(saturdayBoolean){
                    saturdayUnpress()
                    saturdayBoolean = false
                }else{
                    saturdayPress()
                    saturdayBoolean = true
                }
            }
        }

    }

    private fun createDialog(id: Int): Dialog? {
        // TODO Auto-generated method stub
        return if (id == 555) {


            Utils.datePicker(
                this,
                startYear!!,
                startMonth!!,
                startDay!!,
                tvRepeatUntil
            )

        } else if (id == 666) {
            Utils.datePicker(this, startYear!!, startMonth!!, startDay!!, endDatePicker2)
        } else null
    }

    private fun observeViewModel() {
        cartViewModel.arrayRecurringResponse.observe(this, androidx.lifecycle.Observer {

            hideProgress()
            arrayListRecurringType = it.toMutableList()
            spinnerAdapter = CustomeSpinnerAdapter(
                applicationContext,
                arrayListRecurringType!!
            )
            spinner.adapter = spinnerAdapter
            setOnItem()
        })

        cartViewModel.errorMessage.observe(this, androidx.lifecycle.Observer {
            hideProgress()
        })
    }

    private fun getRecurringTypeApi() {

        showProgress()
        cartViewModel.getRecurringTypesApi(getRecurringTypeRequest())
    }

    private fun getRecurringTypeRequest(): GetRecurringRequest {
        return GetRecurringRequest(Utils.seceretKey, Utils.accessKey)
    }

    private fun setOnItem() {
        spinner.onItemSelectedListener = (object : AdapterView.OnItemSelectedListener {
            override fun onNothingSelected(parent: AdapterView<*>?) {

            }

            override fun onItemSelected(
                parent: AdapterView<*>?,
                view: View?,
                position: Int,
                id: Long
            ) {
                when (arrayListRecurringType?.get(position)?.recurring_type) {


                    resources.getString(R.string.once) -> {
                        recurringTypeId = arrayListRecurringType?.get(position)?.recurring_type_id!!

                        weeklyFlag = false
                        repeatUntilDate = false
                        repeatUntilDateString = ""
                        recurringOn = ""
                        repeatUntilDateColor()
                        linearHorizontal.visibility = View.GONE

                        onceDate = SharedPrefsUtils.getStringPreference(
                            applicationContext,
                            KeysUtils.keyOnceDate
                        )

                        if (onceDate.isNullOrBlank()) {
                            SlyCalendarDialog()
                                .setSingle(true)
                                .setFirstMonday(false)
                                .setCallback(this@FutureOrderActivity)
                                .show(supportFragmentManager, "TAG_SLYCALENDAR")

                        } else {
                            val dateFormat =
                                SimpleDateFormat(resources.getString(R.string.dateFormat))
                            val startDate = dateFormat.parse(onceDate)
                            SlyCalendarDialog()
                                .setSingle(true)
                                .setFirstMonday(false)
                                .setStartDate(startDate)
                                .setCallback(this@FutureOrderActivity)
                                .show(supportFragmentManager, "TAG_SLYCALENDAR")
                        }
                    }

                    resources.getString(R.string.everyday) -> {
                        recurringTypeId = arrayListRecurringType?.get(position)?.recurring_type_id!!
                        repeatUntilDateString = ""
                        recurringOn = ""
                        repeatUntilDate = true
                        weeklyFlag = true
                        repeatUntilDateColor()
                        linearHorizontal.visibility = View.VISIBLE
                        sundayPress()
                        mondayPress()
                        tuesdayPress()
                        wednesdayPress()
                        thursdayPress()
                        fridayPress()
                        saturdayPress()
                    }


                    resources.getString(R.string.weekly) -> {
                        recurringTypeId = arrayListRecurringType?.get(position)?.recurring_type_id!!
                        repeatUntilDateString = ""
                        repeatUntilDate = true
                        weeklyFlag = false
                        repeatUntilDateColor()
                        linearHorizontal.visibility = View.VISIBLE
                        sundayPress()
                        mondayUnpress()
                        tuesdayUnpress()
                        wednesdayUnpress()
                        thursdayUnpress()
                        fridayUnpress()
                        saturdayUnpress()
                    }


                    resources.getString(R.string.monthly) -> {
                        recurringTypeId = arrayListRecurringType?.get(position)?.recurring_type_id!!
                        repeatUntilDateString = ""
                        repeatUntilDate = false
                        weeklyFlag = false
                        repeatUntilDateColor()
                        linearHorizontal.visibility = View.GONE

                        monthlyStartDate = SharedPrefsUtils.getStringPreference(
                            applicationContext,
                            KeysUtils.keyMonthlyStartDate
                        )
                        monthlyEndDate = SharedPrefsUtils.getStringPreference(
                            applicationContext,
                            KeysUtils.keyMonthlyEndDate
                        )



                        if (monthlyEndDate.isNullOrBlank() || monthlyEndDate.isNullOrBlank()) {


                            SlyCalendarDialog()
                                .setSingle(false)
                                .setFirstMonday(false)
                                .setCallback(this@FutureOrderActivity)
                                .show(supportFragmentManager, "TAG_SLYCALENDAR")
                        } else {
                            val dateFormat =
                                SimpleDateFormat(resources.getString(R.string.dateFormat))
                            val startDate = dateFormat.parse(monthlyStartDate)
                            val endDate = dateFormat.parse(monthlyEndDate)

                            SlyCalendarDialog()
                                .setSingle(false)
                                .setStartDate(startDate)
                                .setEndDate(endDate)
                                .setFirstMonday(false)
                                .setCallback(this@FutureOrderActivity)
                                .show(supportFragmentManager, "TAG_SLYCALENDAR1")
                        }
                    }
                }
                spinnerAdapter?.notifyDataSetChanged()
            }
        })
    }

    private fun sundayUnpress() {
        tvSunday.setTextColor(ContextCompat.getColor(this,R.color.colorDarkGrey))
        tvSunday.setBackgroundResource(R.drawable.view_rounded_search_image)
    }

    private fun mondayUnpress() {
        tvMonday.setTextColor(ContextCompat.getColor(this,R.color.colorDarkGrey))
        tvMonday.setBackgroundResource(R.drawable.view_rounded_search_image)
    }

    private fun tuesdayUnpress() {
        tvTuesday.setTextColor(ContextCompat.getColor(this,R.color.colorDarkGrey))
        tvTuesday.setBackgroundResource(R.drawable.view_rounded_search_image)
    }

    private fun wednesdayUnpress() {
        tvWednesday.setTextColor(ContextCompat.getColor(this,R.color.colorDarkGrey))
        tvWednesday.setBackgroundResource(R.drawable.view_rounded_search_image)
    }

    private fun thursdayUnpress() {
        tvThursday.setTextColor(ContextCompat.getColor(this,R.color.colorDarkGrey))
        tvThursday.setBackgroundResource(R.drawable.view_rounded_search_image)
    }

    private fun fridayUnpress() {
        tvFriday.setTextColor(ContextCompat.getColor(this,R.color.colorDarkGrey))
        tvFriday.setBackgroundResource(R.drawable.view_rounded_search_image)
    }

    private fun saturdayUnpress() {
        tvSaturday.setTextColor(ContextCompat.getColor(this,R.color.colorDarkGrey))
        tvSaturday.setBackgroundResource(R.drawable.view_rounded_search_image)

    }

    private fun sundayPress() {

        tvSunday.setBackgroundResource(R.drawable.view_tab_order_press)
        tvSunday.setTextColor(ContextCompat.getColor(this,R.color.colorWhite))
    }

    private fun mondayPress() {

        tvMonday.setBackgroundResource(R.drawable.view_tab_order_press)
        tvMonday.setTextColor(ContextCompat.getColor(this,R.color.colorWhite))
    }

    private fun tuesdayPress() {

        tvTuesday.setBackgroundResource(R.drawable.view_tab_order_press)
        tvTuesday.setTextColor(ContextCompat.getColor(this,R.color.colorWhite))
    }

    private fun wednesdayPress() {

        tvWednesday.setBackgroundResource(R.drawable.view_tab_order_press)
        tvWednesday.setTextColor(ContextCompat.getColor(this,R.color.colorWhite))
    }

    private fun thursdayPress() {

        tvThursday.setBackgroundResource(R.drawable.view_tab_order_press)
        tvThursday.setTextColor(ContextCompat.getColor(this,R.color.colorWhite))
    }

    private fun fridayPress() {

        tvFriday.setBackgroundResource(R.drawable.view_tab_order_press)
        tvFriday.setTextColor(ContextCompat.getColor(this,R.color.colorWhite))
    }

    private fun saturdayPress() {

        tvSaturday.setBackgroundResource(R.drawable.view_tab_order_press)
        tvSaturday.setTextColor(ContextCompat.getColor(this,R.color.colorWhite))
    }

    private fun repeatUntilDateColor() {
        if (repeatUntilDate) {
            tvRepeatUntil.setTextColor(ContextCompat.getColor(this,R.color.colorBlack))
        } else {
            tvRepeatUntil.setTextColor(ContextCompat.getColor(this,R.color.colorLightGrey))
        }
    }

}
