package com.quedrop.driver.ui.earnings.view

import android.content.Context
import android.os.Bundle
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.base.extentions.finishWithAnimation
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.Orders
import com.quedrop.driver.ui.earnings.adapter.ViewAllOrderAdapter
import com.quedrop.driver.utils.EARNING_DATA
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import kotlinx.android.synthetic.main.activity_view_all_order.*
import kotlinx.android.synthetic.main.toolbar_normal.*

class ViewAllOrderActivity : BaseActivity() {

    private var mContext: Context? = null
    private var viewAllOrderAdapter: ViewAllOrderAdapter? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_view_all_order)
        mContext = this

        initViews()
    }

    private fun initViews() {
        setUpToolBar()
        if (viewAllOrderAdapter == null) {
            viewAllOrderAdapter = ViewAllOrderAdapter(this).apply {
                onItemClick = { view, adapterPosition, orderId ->

                }
            }
            rvViewAllOrderList.adapter = viewAllOrderAdapter

        }
        val toJson = intent?.getStringExtra(EARNING_DATA)!!
        val myType = object : TypeToken<MutableList<Orders>>() {}.type
        val earningData = Gson().fromJson<MutableList<Orders>>(toJson, myType)
        viewAllOrderAdapter?.viewAllOrderList = earningData
        viewAllOrderAdapter?.notifyDataSetChanged()
    }

    private fun setUpToolBar() {
        tvTitle.text = resources.getString(R.string.today_all_orders)
        ivBack.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)
    }

    override fun onBackPressed() {
        super.onBackPressed()
        finishWithAnimation()
    }
}
