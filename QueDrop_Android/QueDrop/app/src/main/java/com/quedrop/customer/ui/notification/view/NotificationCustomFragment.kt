package com.quedrop.customer.ui.notification.view

import android.app.Dialog
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.notification.viewmodel.NotificationViewModel
import com.quedrop.customer.ui.order.view.fragment.CurrentOrderDetailsFragment
import com.quedrop.customer.utils.*
import com.google.gson.JsonObject
import com.omadahealth.github.swipyrefreshlayout.library.SwipyRefreshLayout
import com.omadahealth.github.swipyrefreshlayout.library.SwipyRefreshLayoutDirection
import com.quedrop.customer.base.rxjava.throttleClicks
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.fragment_notification_customer.*
import kotlinx.android.synthetic.main.fragment_notification_customer.recyclerView
import kotlinx.android.synthetic.main.fragment_notification_customer.swipeRefreshLayout
import kotlinx.android.synthetic.main.fragmnet_toolbar.*
import timber.log.Timber

class NotificationCustomFragment : BaseFragment(), SwipyRefreshLayout.OnRefreshListener {

    private lateinit var viewModel: NotificationViewModel
    private var adapter: NotificationCustomerAdapter? = null
    private var pageNo: Int = 0
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        return inflater.inflate(
            R.layout.fragment_notification_customer,
            container, false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(this.requireContext(), KeysUtils.keyUserId, 0)
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(this.requireContext(), KeysUtils.keyGuestId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(this.requireContext(), KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(this.requireContext(), KeysUtils.keyAccessKey)!!


        viewModel = NotificationViewModel(appService)
        init()
        getSupplierNotifications(pageNo)
    }


    companion object {
        fun newInstance(): NotificationCustomFragment {
            return NotificationCustomFragment()
        }
    }

    fun onPageSelected(position: Int) {

//        if(Utils.userId == 0) {
//
//        } else {
//            init()
//            getSupplierNotifications(pageNo)
//        }
    }

    private fun init() {
        onClickViews()
        textEmptyNotification.visibility = View.GONE
        swipeRefreshLayout.setOnRefreshListener(this)

        if (adapter == null) {
            adapter = NotificationCustomerAdapter(requireContext())
                .apply {
                    orderInvoke = { pos: Int, orderId: Int ->
                        orderNavigationCustomer(pos, orderId)
                    }
                }
            recyclerView.adapter = adapter
        }

        viewModel.notificationList.observe(viewLifecycleOwner, Observer {
            textEmptyNotification.visibility = View.GONE
            adapter?.notificationList?.addAll(it)
            adapter?.notifyDataSetChanged()
        })

    }

    private fun onClickViews() {
        ivNotificationBack.throttleClicks().subscribe {
            activity.onBackPressed()
        }.autoDispose(compositeDisposable)
    }


    private fun getSupplierNotifications(pageNo: Int) {
        var dialog: Dialog? = null
        val jsonObject = JsonObject()
        jsonObject.addProperty("user_id", Utils.userId)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.accessKey)
        jsonObject.addProperty("page_num", pageNo)
        viewModel.getSupplierNotifications(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe {
                //dialog = DialogCaller.showProgressDialog(activity)
            }
            .doAfterTerminate {
                //dialog?.dismiss()
                swipeRefreshLayout.isRefreshing = false
            }
            .subscribe({
                if (it.status) {
                    viewModel.notificationList.value = it.data?.get("notifications")
                } else {
                    textEmptyNotification.visibility = View.VISIBLE
                    textEmptyNotification.text = it.message
//                    activity.showToast(it.message)
                }
            }, {
                Timber.e(it.localizedMessage)
                // activity.showToast(it.localizedMessage ?: "")
            })
            .autoDispose(compositeDisposable)
    }


    private fun orderNavigationCustomer(position: Int, orderId: Int) {
        when (position) {

            ENUMNotificationType.ORDER_REQUEST.posVal -> {
                (getActivity() as CustomerMainActivity).navigateToFragment(
                    CurrentOrderDetailsFragment.newInstance(orderId, 0, "")
                )
            }
            ENUMNotificationType.ORDER_ACCEPT.posVal -> {
                (getActivity() as CustomerMainActivity).navigateToFragment(
                    CurrentOrderDetailsFragment.newInstance(orderId, 0, "")
                )
            }
            ENUMNotificationType.ORDER_REJECT.posVal -> {
                (getActivity() as CustomerMainActivity).navigateToFragment(
                    CurrentOrderDetailsFragment.newInstance(orderId, 0, "")
                )
            }
            ENUMNotificationType.ORDER_REQUEST_TIMEOUT.posVal -> {
                (getActivity() as CustomerMainActivity).navigateToFragment(
                    CurrentOrderDetailsFragment.newInstance(orderId, 0, "")
                )
            }
            ENUMNotificationType.RECURRING_ORDER_PLACED.posVal -> {
                (getActivity() as CustomerMainActivity).navigateToFragment(
                    CurrentOrderDetailsFragment.newInstance(orderId, 0, "")
                )
            }
            ENUMNotificationType.ORDER_DISPATCH.posVal -> {
                (getActivity() as CustomerMainActivity).navigateToFragment(
                    CurrentOrderDetailsFragment.newInstance(orderId, 0, "")
                )
            }
            ENUMNotificationType.ORDER_RECEIPT.posVal -> {
                (getActivity() as CustomerMainActivity).navigateToFragment(
                    CurrentOrderDetailsFragment.newInstance(orderId, 0, "")
                )
            }
            ENUMNotificationType.ORDER_CANCELLED.posVal -> {
                (getActivity() as CustomerMainActivity).navigateToFragment(
                    CurrentOrderDetailsFragment.newInstance(orderId, 0, "")
                )
            }
            ENUMNotificationType.ORDER_DELIVERED.posVal -> {
                (getActivity() as CustomerMainActivity).navigateToFragment(
                    CurrentOrderDetailsFragment.newInstance(orderId, 0, "")
                )
            }
            ENUMNotificationType.DRIVER_VERIFICATION.posVal -> {
                (getActivity() as CustomerMainActivity).navigateToFragment(
                    CurrentOrderDetailsFragment.newInstance(orderId, 0, "")
                )
            }
            ENUMNotificationType.RATING.posVal -> {
                (getActivity() as CustomerMainActivity).navigateToFragment(
                    CurrentOrderDetailsFragment.newInstance(orderId, 0, "")
                )
            }
            ENUMNotificationType.NEAR_BY_PLACE.posVal -> {
                (getActivity() as CustomerMainActivity).navigateToFragment(
                    CurrentOrderDetailsFragment.newInstance(orderId, 0, "")
                )
            }
            ENUMNotificationType.CHAT.posVal -> {
                (getActivity() as CustomerMainActivity).navigateToFragment(
                    CurrentOrderDetailsFragment.newInstance(orderId, 0, "")
                )
            }
            ENUMNotificationType.UNKNOWN_TYPE.posVal -> {
                (getActivity() as CustomerMainActivity).navigateToFragment(
                    CurrentOrderDetailsFragment.newInstance(orderId, 0, "")
                )
            }

        }
    }

    override fun onRefresh(direction: SwipyRefreshLayoutDirection?) {
        if (direction == SwipyRefreshLayoutDirection.BOTTOM) {
            pageNo++
            Log.e("PageNo", "==>" + pageNo)
            getSupplierNotifications(pageNo)
        } else if (direction == SwipyRefreshLayoutDirection.TOP) {
            pageNo = 0
            adapter?.notificationList?.clear()
            getSupplierNotifications(pageNo)
        }
    }

}