package com.quedrop.driver.ui.notificationFragment

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import com.bumptech.glide.Glide
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseFragment
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.service.request.NotificationListRequest
import com.quedrop.driver.ui.orderDetailsFragment.view.OrderDetailActivity
import com.quedrop.driver.ui.requestDetailsFragment.RequestDetailActivity
import com.quedrop.driver.utils.*
import com.omadahealth.github.swipyrefreshlayout.library.SwipyRefreshLayout
import com.omadahealth.github.swipyrefreshlayout.library.SwipyRefreshLayoutDirection
import kotlinx.android.synthetic.main.fragment_notification.*
import kotlinx.android.synthetic.main.toolbar_login.*


class NotificationFragment : BaseFragment(), SwipyRefreshLayout.OnRefreshListener {

    companion object {
        fun newInstance(): NotificationFragment {
            return NotificationFragment()
        }
    }

    private lateinit var viewModel: NotificationViewModel
    private var adapter: NotificationAdapter? = null
    private var pageNo: Int = 0

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_notification, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel = NotificationViewModel(appService)
        initViews()
        if (Utility.isNetworkAvailable(context)) {
            getNotificationList(pageNo)
        } else {
            showAlertMessage(activity, getString(R.string.no_internet_connection))
        }
    }

    private fun setUpToolbar() {
        tvTitleLogin.text = "Notifications"
    }


    private fun initViews() {
        setUpToolbar()
        swipeRefreshLayout.setOnRefreshListener(this)

        if (adapter == null) {
            adapter = NotificationAdapter(activity)
            recyclerView.adapter = adapter
        }

        adapter?.apply {
            onItemClick = { view, adapterPosition, notificationType, orderId ->


                when (notificationType) {

                    ENUMNotificationType.ORDER_REQUEST.posVal -> {
                        navigateToRequestDetail(orderId)
                    }
                    ENUMNotificationType.ORDER_ACCEPT.posVal -> {

                    }
                    ENUMNotificationType.ORDER_REJECT.posVal -> {

                    }
                    ENUMNotificationType.ORDER_REQUEST_TIMEOUT.posVal -> {
                        navigateToOrderDetail(orderId)

                    }
                    ENUMNotificationType.RECURRING_ORDER_PLACED.posVal -> {

                    }
                    ENUMNotificationType.ORDER_DISPATCH.posVal -> {
                        navigateToOrderDetail(orderId)

                    }
                    ENUMNotificationType.ORDER_RECEIPT.posVal -> {
                        navigateToOrderDetail(orderId)

                    }
                    ENUMNotificationType.ORDER_CANCELLED.posVal -> {
                        navigateToOrderDetail(orderId)

                    }
                    ENUMNotificationType.ORDER_DELIVERED.posVal -> {
                        navigateToOrderDetail(orderId)

                    }
                    ENUMNotificationType.DRIVER_VERIFICATION.posVal -> {

                    }
                    ENUMNotificationType.RATING.posVal -> {

                    }
                    ENUMNotificationType.NEAR_BY_PLACE.posVal -> {

                    }
                    ENUMNotificationType.UNKNOWN_TYPE.posVal -> {

                    }
                }
            }
        }

        viewModel.notificationList.observe(viewLifecycleOwner, Observer {
            swipeRefreshLayout.isRefreshing = false
            adapter?.notificationList?.addAll(it.notifications!!)
            adapter?.notifyDataSetChanged()
        })
    }

    private fun navigateToOrderDetail(orderId: Int) {
        val intent = Intent(context, OrderDetailActivity::class.java)
        intent.putExtra("ORDER_ID", orderId)
        intent.putExtra("FROM_NOTIFICATION", true)
        startActivityWithDefaultAnimations(intent)
    }

    private fun navigateToRequestDetail(orderId: Int) {
        val intent = Intent(context, RequestDetailActivity::class.java)
        intent.putExtra("ORDER_ID", orderId)
        intent.putExtra("FROM_NOTIFICATION", true)
        startActivityWithDefaultAnimations(intent)
    }

    private fun getNotificationList(pageNo: Int) {
        viewModel.getDriverNotification(notificationListRequest(pageNo))
    }

    private fun notificationListRequest(pageNo: Int): NotificationListRequest {
        return NotificationListRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            SharedPreferenceUtils.getInt(KEY_USERID),
            pageNo

        )
    }

    fun onPageSelected(position: Int) {
        Log.e("NotificationFragment: ", "pageno==>$pageNo")
        //  getNotificationList(pageNo)
    }

    override fun onRefresh(direction: SwipyRefreshLayoutDirection?) {
        if (direction == SwipyRefreshLayoutDirection.BOTTOM) {
            pageNo++
            Log.e("PageNo", "==>" + pageNo)

            if (Utility.isNetworkAvailable(context)) {
                getNotificationList(pageNo)
            } else {
                swipeRefreshLayout.isRefreshing = false
                showAlertMessage(activity, getString(R.string.no_internet_connection))
            }

        } else if (direction == SwipyRefreshLayoutDirection.TOP) {
            if (Utility.isNetworkAvailable(context)) {
                pageNo = 0
                adapter?.notificationList?.clear()
                getNotificationList(pageNo)
            } else {
                swipeRefreshLayout.isRefreshing = false
                showAlertMessage(activity, getString(R.string.no_internet_connection))
            }
        }
    }

}
