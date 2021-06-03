package com.quedrop.customer.ui.supplier.myorders

import android.app.Dialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.widget.Button
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.ui.supplier.myorders.adapter.SupplierOrderAdapter
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import com.google.gson.JsonObject
import com.quedrop.customer.ui.supplier.myorders.adapter.FreshProduceCategoryAdapter
import com.quedrop.customer.ui.supplier.payment.adapters.BankListAdapter
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_add_edit_payment.*
import kotlinx.android.synthetic.main.supplier_order_fragment.*
import timber.log.Timber

class SupplierOrderFragment : BaseFragment() {

    companion object {
        fun newInstance() = SupplierOrderFragment()
    }

    private lateinit var viewModel: SupplierOrderViewModel
    private var orderAdapter: SupplierOrderAdapter? = null

    var dialog: Dialog? = null
    val currentOrder = 1
    val PastOrder = 2


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.supplier_order_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel = SupplierOrderViewModel(appService)

        Utils.Supplier.supplierUserId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.KeyUserSupplierId, 0)
        Utils.Supplier.supplierStoreID =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keySupplierStoreId, 0)
        Utils.seceretKey = SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeySupplierAccessKey)!!
        init()

        viewModel.orderList.observe(viewLifecycleOwner, Observer {
            orderAdapter?._orderList?.clear()
            orderAdapter?._orderList = it
            orderAdapter?.notifyDataSetChanged()
        })

        getOrderData(currentOrder)
    }

    fun init() {

        if (orderAdapter == null) {
            rvOrder.layoutManager = LinearLayoutManager(activity)
            orderAdapter = SupplierOrderAdapter(activity, false)
            rvOrder.adapter = orderAdapter
        }

        tvCurrentOrder.setOnClickListener {

            tvCurrentOrder.setBackgroundResource(R.drawable.view_tab_order_press)
            tvCurrentOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))

            tvPastOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorWhite))
            tvPastOrder.background = null

            getOrderData(currentOrder)
        }

        tvPastOrder.setOnClickListener {

            tvPastOrder.setBackgroundResource(R.drawable.view_tab_order_press)
            tvPastOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))

            tvCurrentOrder.setTextColor(ContextCompat.getColor(activity, R.color.colorWhite))
            tvCurrentOrder.background = null

            getOrderData(PastOrder)

        }

    }

    private fun getOrderData(orderType: Int) {
        val jsonObject = JsonObject()
        jsonObject.addProperty("user_id", Utils.Supplier.supplierUserId)
        jsonObject.addProperty("store_id", Utils.Supplier.supplierStoreID)
        jsonObject.addProperty("is_for_current", orderType)
        jsonObject.addProperty("page_num", 1)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)


        viewModel.getSupplierOrderApi(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe { }
            .doAfterTerminate { }
            .subscribe({
                if (it.status) {
                    textNoOrder.visibility = View.GONE
                    viewModel.orderList.value = it.data?.get("supplier_order")
                } else {
                    orderAdapter?._orderList?.clear()
                    orderAdapter?.notifyDataSetChanged()

                    textNoOrder.visibility = View.VISIBLE
                    textNoOrder.text = it.message
                }
            }, {
                Timber.e(it.localizedMessage)
            }).autoDispose(compositeDisposable)
    }


    override fun onDestroyView() {
        super.onDestroyView()
        orderAdapter = null
        dialog?.dismiss()
    }
}
