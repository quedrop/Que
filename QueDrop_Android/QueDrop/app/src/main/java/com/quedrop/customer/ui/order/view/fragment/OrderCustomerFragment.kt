package com.quedrop.customer.ui.order.view.fragment

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.login.view.LoginActivity
import com.quedrop.customer.utils.ConstantUtils
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.fragment_order_customer.*


class OrderCustomerFragment(val orderId: Int, val remoteMessage: String) : BaseFragment() {


    private var fragmentCurrentOrder: CurrentOrderFragment? = null
    private var fragmentFutureOrder: FutureOrderFragment? = null
    private var fragmentPastOrder: PastOrderFragment? = null


    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        return inflater.inflate(
            R.layout.fragment_order_customer,
            container, false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        Utils.userId = SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)

        tvCurrentOrder.setBackgroundResource(R.drawable.view_tab_order_press)
        tvFutureOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorWhite))
        tvCurrentOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))
        tvFutureOrder.background = null
        tvPastOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorWhite))
        tvPastOrder.background = null

        if (Utils.userId == 0) {
            gustOrderConst.visibility = View.VISIBLE
            layoutOrderTab.visibility = View.GONE
        } else {
            gustOrderConst.visibility = View.GONE
            layoutOrderTab.visibility = View.VISIBLE

            loadCurrentOrderFragment()
        }
        onClickViewMethod()
    }


    companion object {
        fun newInstance(orderId: Int, remoteMessage: String): OrderCustomerFragment {

            return OrderCustomerFragment(orderId, remoteMessage)
        }
    }

    fun onPageSelected(position: Int) {
        if (Utils.userId == 0) {

        } else {
            loadCurrentOrderFragment()

            tvCurrentOrder.setBackgroundResource(R.drawable.view_tab_order_press)
            tvCurrentOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))

            tvFutureOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorWhite))
            tvFutureOrder.background = null

            tvPastOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorWhite))
            tvPastOrder.background = null
        }
    }


    private fun onClickViewMethod() {

        btnLogin.throttleClicks().subscribe {
            startActivityForResult(
                Intent(context, LoginActivity::class.java),
                ConstantUtils.REQUEST_LOGIN_ORDER
            )
        }.autoDispose(compositeDisposable)

        tvCurrentOrder.throttleClicks().subscribe {
            tvCurrentOrder.setBackgroundResource(R.drawable.view_tab_order_press)
            tvCurrentOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))

            tvFutureOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorWhite))
            tvFutureOrder.background = null

            tvPastOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorWhite))
            tvPastOrder.background = null

            loadCurrentOrderFragment()
        }.autoDispose(compositeDisposable)

        tvFutureOrder.throttleClicks().subscribe {
            tvFutureOrder.setBackgroundResource(R.drawable.view_tab_order_press)
            tvFutureOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))

            tvCurrentOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorWhite))
            tvCurrentOrder.background = null

            tvPastOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorWhite))
            tvPastOrder.background = null

            loadFutureOrderFragment()
        }.autoDispose(compositeDisposable)

        tvPastOrder.throttleClicks().subscribe {
            tvPastOrder.setBackgroundResource(R.drawable.view_tab_order_press)
            tvPastOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))

            tvFutureOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorWhite))
            tvFutureOrder.background = null

            tvCurrentOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorWhite))
            tvCurrentOrder.background = null

            loadPastOrderFragment()
        }.autoDispose(compositeDisposable)

    }

    private fun loadCurrentOrderFragment() {
        val transaction =
            (activity as CustomerMainActivity).supportFragmentManager.beginTransaction()

        fragmentCurrentOrder = CurrentOrderFragment(orderId, remoteMessage)
        transaction.replace(R.id.fragmentOrders, fragmentCurrentOrder!!)
        transaction.commit()
    }

    private fun loadFutureOrderFragment() {
        val transaction =
            (activity as CustomerMainActivity).supportFragmentManager.beginTransaction()

        fragmentFutureOrder = FutureOrderFragment()
//        fragmentListNearBy!!.arguments = bundle
        transaction.replace(R.id.fragmentOrders, fragmentFutureOrder!!)
        transaction.commit()

    }

    private fun loadPastOrderFragment() {
        val transaction =
            (activity as CustomerMainActivity).supportFragmentManager.beginTransaction()

        fragmentPastOrder = PastOrderFragment()
        transaction.replace(R.id.fragmentOrders, fragmentPastOrder!!)
        transaction.commit()
    }

}