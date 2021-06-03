package com.quedrop.customer.ui.order.view.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.recyclerview.widget.LinearLayoutManager
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.GetCustomerSupprt
import com.quedrop.customer.model.GetSingleOrderDetailsResponse
import com.quedrop.customer.model.SingleOrderDetails
import com.quedrop.customer.model.StoreSingleDetails
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.order.view.adapter.CustomerStoreSupportAdapter
import com.quedrop.customer.ui.order.viewmodel.OrderViewModel
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.fragment_customer_support.*

class CustomerSupportFragment(var orderId: Int) : BaseFragment() {

    lateinit var orderViewModel: OrderViewModel
    var customerStoreSupportAdapter: CustomerStoreSupportAdapter?=null
    var arrayStoreCustomerSupportList : MutableList<StoreSingleDetails>?=null
    var getOrderDetails: GetSingleOrderDetailsResponse? = null
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        return inflater.inflate(
            R.layout.fragment_customer_support,
            container, false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyGuestId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keyAccessKey)!!
        Utils.selectAddressTitle =
            SharedPrefsUtils.getStringPreference(
                activity,
                KeysUtils.KeySelectAddressName
            )!!
        Utils.selectAddress =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeySelectAddress)!!
        Utils.selectAddressType =
            SharedPrefsUtils.getStringPreference(
                activity,
                KeysUtils.KeySelectAddressType
            )!!
        Utils.keyLatitude =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeyLatitude)!!
        Utils.keyLongitude =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeyLongitude)!!

        orderViewModel = OrderViewModel(appService)
        initMethod()
        onclickMethod()
        observeViewModel()
        getSingleOrderApi()
    }

    companion object {
        fun newInstance(orderId: Int): CustomerSupportFragment {
            return CustomerSupportFragment(orderId)
        }
    }

    fun onPageSelected(position: Int) {

    }

    private fun initMethod() {

        editOrderIdSupport.setText("#"+orderId.toString()+"")

        customerStoreSupportRv.layoutManager = LinearLayoutManager(
            context,
            LinearLayoutManager.VERTICAL,
            false
        )

        arrayStoreCustomerSupportList = mutableListOf()

        customerStoreSupportAdapter = CustomerStoreSupportAdapter(
            activity,
            arrayStoreCustomerSupportList!!

        )
        customerStoreSupportRv.adapter = customerStoreSupportAdapter

    }

    private fun onclickMethod() {
        ivBackSupport.throttleClicks().subscribe {
            activity.onBackPressed()
        }.autoDispose(compositeDisposable)

        btnSendSupport.throttleClicks().subscribe {
            getSubmitOrderQuery()
        }.autoDispose(compositeDisposable)
    }

    private fun observeViewModel(){
        orderViewModel.orderDetails.observe(
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                (getActivity() as CustomerMainActivity).hideProgress()


                if (Utils.userId == 0) {

                } else {
                    getOrderDetails = it
                    arrayStoreCustomerSupportList?.addAll(it.stores)
                    customerStoreSupportAdapter?.notifyDataSetChanged()
//                    arraySingleOrderList?.addAll(getOrderDetails?.stores)
                }


                // currentOrderAdapter?.notifyDataSetChanged()
            })

        orderViewModel.customerSupportMessage.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (getActivity() as CustomerMainActivity).hideProgress()
            Toast.makeText(activity,it, Toast.LENGTH_SHORT).show()
            activity.onBackPressed()
        })

        orderViewModel.errorMessage.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (getActivity() as CustomerMainActivity).hideProgress()
        })
    }

    private fun getCustomerSupport(): GetCustomerSupprt {
        return GetCustomerSupprt(
            Utils.seceretKey,
            Utils.accessKey,
            orderId,
            editAddProblemSupport.text.toString())

    }

    private fun getSubmitOrderQuery() {
        (activity as CustomerMainActivity).showProgress()
        orderViewModel.getSubmitOrderQueryApi(getCustomerSupport())
    }

    private fun getSingleOrderDetails(): SingleOrderDetails {

        return SingleOrderDetails(
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId,
            orderId

        )
    }

    private fun getSingleOrderApi() {
        (activity as CustomerMainActivity).showProgress()
        orderViewModel.getSingleOrderDetailsApi(getSingleOrderDetails())

    }
}