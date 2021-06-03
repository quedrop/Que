package com.quedrop.customer.ui.supplier.notifications

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.extentions.startActivityWithAnimation
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.ui.supplier.HomeSupplierActivity
import com.quedrop.customer.ui.supplier.myorders.SupplierOrderDetailActivity
import com.quedrop.customer.utils.ENUMNotificationType
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import com.google.gson.JsonObject
import com.omadahealth.github.swipyrefreshlayout.library.SwipyRefreshLayout
import com.omadahealth.github.swipyrefreshlayout.library.SwipyRefreshLayoutDirection
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.supplier_notification_fragment.*
import timber.log.Timber

class SupplierNotificationFragment : BaseFragment(), SwipyRefreshLayout.OnRefreshListener {

    companion object {
        fun newInstance() = SupplierNotificationFragment()
    }

    private lateinit var viewModel: SupplierNotificationViewModel
    private var adapter: NotificationAdapter? = null
    private var pageNo: Int = 0

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.supplier_notification_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel = SupplierNotificationViewModel(appService)

        Utils.Supplier.supplierUserId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.KeyUserSupplierId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeySupplierAccessKey)!!

        init()
        getSupplierNotifications(pageNo, false)
    }

    private fun init() {
        swipeRefreshLayout.setOnRefreshListener(this)

        if (adapter == null) {
            adapter = NotificationAdapter(activity).apply {
                orderInvoke = { pos: Int, orderId: Int, notificationType ->
                    orderNavigationCustomer(pos, orderId, notificationType)
                }
            }
            recyclerView.adapter = adapter
        }

        viewModel.notificationList.observe(viewLifecycleOwner, Observer {
            adapter?.notificationList?.addAll(it)
            adapter?.notifyDataSetChanged()
        })
    }

    private fun getSupplierNotifications(pageNo: Int, loadMore: Boolean) {
        val jsonObject = JsonObject()
        jsonObject.addProperty(
            "user_id",
            Utils.Supplier.supplierUserId
        ) //todo change this to dynamic
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        jsonObject.addProperty("page_num", pageNo)
        viewModel.getSupplierNotifications(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe { }
            .doAfterTerminate {
                swipeRefreshLayout.isRefreshing = false
            }
            .subscribe({
                if (it.status) {
                    textNoNotification.visibility = View.GONE
                    viewModel.notificationList.value = it.data?.get("notifications")
                } else {
                    if (!loadMore) {
                        textNoNotification.visibility = View.VISIBLE
                        textNoNotification.text = it.message
                    }
                    // activity.showToast(it.message)
                }
            }, {
                Timber.e(it.localizedMessage)
                // activity.showToast(it.localizedMessage ?: "")
            })
            .autoDispose(compositeDisposable)
    }

    override fun onRefresh(direction: SwipyRefreshLayoutDirection?) {
        if (direction == SwipyRefreshLayoutDirection.BOTTOM) {
            pageNo++
            Log.e("PageNo", "==>" + pageNo)
            getSupplierNotifications(pageNo, true)
        } else if (direction == SwipyRefreshLayoutDirection.TOP) {
            pageNo = 0
            adapter?.notificationList?.clear()
            getSupplierNotifications(pageNo, true)
        }
    }

    private fun orderNavigationCustomer(position: Int, orderId: Int, notificationType: Int) {
        when (notificationType) {

            ENUMNotificationType.ORDER_REQUEST.posVal -> {
                if (orderId != 0) {
                    (context as HomeSupplierActivity).startActivityWithAnimation<SupplierOrderDetailActivity> {
                        putExtra("order_id", orderId)
                    }
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
    }

}
