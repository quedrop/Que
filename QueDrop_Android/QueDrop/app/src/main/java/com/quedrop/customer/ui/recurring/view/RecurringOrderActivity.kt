package com.quedrop.customer.ui.recurring.view

import android.app.Dialog
import android.content.Intent
import android.os.Bundle
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.ui.recurring.viewmodel.RecurringOrderViewModel
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.activity_recurring_order.*
import java.util.*


class RecurringOrderActivity : BaseActivity() {


    var startYear: Int? = null
    var startMonth: Int? = null
    var startDay: Int? = null
    var mHour: Int? = null
    var mMinute: Int? = null
    var startDateString: String? = null
    var startTimeString: String? = null
    var endDateString: String? = null
    var endTimeString: String? = null
    lateinit var recurringOrderViewModel:RecurringOrderViewModel


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_recurring_order)


        recurringOrderViewModel = RecurringOrderViewModel(appService)
        initMethod()
        observeViewModel()
        onClickMethod()
    }

    private fun initMethod() {

        var calendar = Calendar.getInstance()
        startYear = calendar.get(Calendar.YEAR)
        startMonth = calendar.get(Calendar.MONTH)
        startDay = calendar.get(Calendar.DAY_OF_MONTH)
        mHour = calendar.get(Calendar.HOUR_OF_DAY)
        mMinute = calendar.get(Calendar.MINUTE)

        Utils.showDate(startYear!!, startMonth!! + 1, startDay!!, startDatePicker1)
        Utils.showDate(startYear!!, startMonth!! + 1, startDay!!, endDatePicker2)

        Utils.showTime(mHour!!, mMinute!!, startTimePicker1)
        Utils.showTime(mHour!!, mMinute!!, endTimePicker2)

    }

    private fun onClickMethod() {

        ivBackRecurring.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        startDateRelative.throttleClicks().subscribe {
            createdDialog(555)!!.show();
        }.autoDispose(compositeDisposable)

        startTimeRelative.throttleClicks().subscribe {
            showDialog(777)
        }.autoDispose(compositeDisposable)

        endDateRelative.throttleClicks().subscribe {
            showDialog(666)
        }.autoDispose(compositeDisposable)

        endTimeRelative.throttleClicks().subscribe {
            showDialog(888)
        }.autoDispose(compositeDisposable)


        btnSaveRecurringOrder.throttleClicks().subscribe {

            startDateString = startDatePicker1.text.toString()
            startTimeString = startTimePicker1.text.toString()
            endDateString = endDatePicker2.text.toString()
            endTimeString = endTimePicker2.text.toString()

            var intent = Intent()
//            intent.putExtra(KeysUtils.keyStartDate, startDateString)
//            intent.putExtra(KeysUtils.keyStartTime, startTimeString)
//            intent.putExtra(KeysUtils.keyEndDate, endDateString)
//            intent.putExtra(KeysUtils.keyEndTime, endTimeString)
            setResult(RESULT_OK, intent)
            finish()
        }.autoDispose(compositeDisposable)
    }

    private fun createdDialog(id: Int): Dialog? {
        // TODO Auto-generated method stub
        return if (id == 555) {

            Utils.datePicker(
                this,
                startYear!!,
                startMonth!!,
                startDay!!,
                startDatePicker1
            )

        } else if (id == 666) {
            Utils.datePicker(this, startYear!!, startMonth!!, startDay!!, endDatePicker2)
        } else if (id == 777) {
            Utils.TimePicker(this, mHour!!, mMinute!!, startTimePicker1)
        } else if (id == 888) {
            Utils.TimePicker(this, mHour!!, mMinute!!, endTimePicker2)
        } else null
    }

    private fun observeViewModel() {
        recurringOrderViewModel.addressList.observe(this, androidx.lifecycle.Observer {

            hideProgress()


        })

        recurringOrderViewModel.errorMessage.observe(this, androidx.lifecycle.Observer {
            hideProgress()
        })
    }


    override fun onBackPressed() {
        super.onBackPressed()
    }


}
