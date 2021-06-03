package com.quedrop.customer.ui.order.view.fragment

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.LinearLayoutManager
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.model.CurrentOrderRequest
import com.quedrop.customer.model.GetCurrentOrderResponse
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.order.view.adapter.CurrentOrderMainAdapter
import com.quedrop.customer.ui.order.viewmodel.OrderViewModel
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.fragment_past_order.*

class PastOrderFragment : BaseFragment() {

    lateinit var orderViewModel: OrderViewModel
    var pastOrderAdapter: CurrentOrderMainAdapter? = null
    var arrayPastOrderList: MutableList<GetCurrentOrderResponse>? = null
    var isOrder: String = "2"

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        return inflater.inflate(
            R.layout.fragment_past_order,
            container, false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        orderViewModel = OrderViewModel(appService)

        Utils.userId = SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)
        Utils.guestId = SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyGuestId, 0)
        Utils.seceretKey = SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.accessKey = SharedPrefsUtils.getStringPreference(activity, KeysUtils.keyAccessKey)!!
        Utils.selectAddressTitle =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeySelectAddressName)!!
        Utils.selectAddress =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeySelectAddress)!!
        Utils.selectAddressType = SharedPrefsUtils.getStringPreference(
            activity,
            KeysUtils.KeySelectAddressType
        )!!
        Utils.keyLatitude =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeyLatitude)!!
        Utils.keyLongitude =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeyLongitude)!!

        arrayPastOrderList = mutableListOf()


        initMethod()
        getCurrentOrderApi()
        observeViewModel()
    }

    companion object {
        fun newInstance(): PastOrderFragment {
            return PastOrderFragment()
        }
    }

    fun onPageSelected(position: Int) {

    }


    private fun initMethod() {

        isOrder = "2"
        pastOrderAdapter = CurrentOrderMainAdapter(
            activity,
            isOrder,
            arrayPastOrderList!!

        ).apply {
            currentOrderListInvoke = { orderId: Int, timeMainRemaining1: Long, mainPos: Int ->
                currentOrderInvoke(orderId)
            }
        }
        rvPastOrder.adapter = pastOrderAdapter
    }

    private fun currentOrderInvoke(orderId: Int) {
        val orderIdMain = orderId
        (getActivity() as CustomerMainActivity).navigateToFragment(
            CurrentOrderDetailsFragment.newInstance(
                orderIdMain,
                0,
                ""
            )
        )
    }

    private fun observeViewModel() {
        orderViewModel.pastOrderList.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (getActivity() as CustomerMainActivity).hideProgress()
            textEmptyPast.visibility = View.GONE
            arrayPastOrderList?.clear()

            if (Utils.userId == 0) {

            } else {
                arrayPastOrderList?.addAll(it)
                pastOrderAdapter?.notifyDataSetChanged()
//                pastOrderAdapter?.updateAdapterItem()
            }

            // currentOrderAdapter?.notifyDataSetChanged()
        })

        orderViewModel.errorMessage.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (getActivity() as CustomerMainActivity).hideProgress()
            textEmptyPast.visibility = View.VISIBLE
            textEmptyPast.text = it

            pastOrderAdapter?.notifyDataSetChanged()
        })
    }

    private fun getCustomerOrderRequest(): CurrentOrderRequest {
        return CurrentOrderRequest(
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId,
            isOrder

        )
    }

    private fun getCurrentOrderApi() {
        (getActivity() as CustomerMainActivity).showProgress()
        orderViewModel.getCustomerPastOrderApi(getCustomerOrderRequest())
    }
}