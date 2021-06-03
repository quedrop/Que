package com.quedrop.customer.ui.supplier.payment

import android.os.Bundle
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityWithAnimation
import com.quedrop.customer.base.rxjava.throttleClicks
import kotlinx.android.synthetic.main.activity_payment_list.*

class PaymentListActivity : BaseActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_payment_list)
        tvAdd.throttleClicks().subscribe{
            startActivityWithAnimation<AddEditPaymentActivity> {  }
        }.autoDispose()
    }
}
