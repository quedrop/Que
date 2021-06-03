package com.quedrop.customer.ui.order.view.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.*
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.order.viewmodel.OrderViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.ui.order.view.adapter.*
import com.quedrop.customer.utils.*
import kotlinx.android.synthetic.main.fragment_past_order_details.ivBackOrderDetails
import kotlinx.android.synthetic.main.fragment_past_order_details.ivDriverImage
import kotlinx.android.synthetic.main.fragment_past_order_details.linearHorizontalOrder1
import kotlinx.android.synthetic.main.fragment_past_order_details.noteConstraint
import kotlinx.android.synthetic.main.fragment_past_order_details.rvMainCartListCurrent
import kotlinx.android.synthetic.main.fragment_past_order_details.rvMainReceipt
import kotlinx.android.synthetic.main.fragment_past_order_details.rvManualStore
import kotlinx.android.synthetic.main.fragment_past_order_details.rvRegisteredStore
import kotlinx.android.synthetic.main.fragment_past_order_details.statusViewScroller
import kotlinx.android.synthetic.main.fragment_past_order_details.tvCouponDiscount
import kotlinx.android.synthetic.main.fragment_past_order_details.tvDateOrder
import kotlinx.android.synthetic.main.fragment_past_order_details.tvDeliveryFeeRs
import kotlinx.android.synthetic.main.fragment_past_order_details.tvDriverRate
import kotlinx.android.synthetic.main.fragment_past_order_details.tvFeeCoupon
import kotlinx.android.synthetic.main.fragment_past_order_details.tvFeeOrder
import kotlinx.android.synthetic.main.fragment_past_order_details.tvOrderDiscount
import kotlinx.android.synthetic.main.fragment_past_order_details.tvPayRsRv
import kotlinx.android.synthetic.main.fragment_past_order_details.tvServiceChargeRs
import kotlinx.android.synthetic.main.fragment_past_order_details.tvShoppingFee
import kotlinx.android.synthetic.main.fragment_past_order_details.tvShoppingRs

import java.text.SimpleDateFormat
import java.util.*


class PastOrderDetailsFragment(
    var orderId: Int
) : BaseFragment() {

    var arraySingleOrderList: MutableList<StoreSingleDetails>? = null
    var pastOrderDetailsStoreAdapter: PastOrderDetailsStoreAdapter? = null
    var receiptAdapter: ReceiptAdapter? = null
    lateinit var orderViewModel: OrderViewModel
    var getOrderDetails: GetSingleOrderDetailsResponse? = null
    var orderStatusList: List<String>? = null
    var orderStatusUpdate: String = "Placed"
    var arrayRegisteredStoreList: MutableList<RegisteredStore>? = null
    var arrayManualStoreList: MutableList<ManualStore>? = null
    var registeredOrderAdapter: RegisteredStoreAdapter? = null
    var manualStoreAdapter: ManualStoreAdapter? = null


    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        return inflater.inflate(
            R.layout.fragment_past_order_details,
            container, false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        orderViewModel = OrderViewModel(appService)
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

        initMethod()
        onClickMethod()
        observeViewModel()
        getSingleOrderApi()

    }

    companion object {
        //        fun newInstance()
        fun newInstance(
            orderId: Int
        ): PastOrderDetailsFragment {

            return PastOrderDetailsFragment(
                orderId
            )
        }
    }

    fun onPageSelected(position: Int) {

    }

    private fun onClickMethod() {

        ivBackOrderDetails.throttleClicks().subscribe {
            activity.onBackPressed()
        }.autoDispose(compositeDisposable)

    }


    private fun initMethod() {
        arraySingleOrderList = mutableListOf()

        receiptAdapter = ReceiptAdapter(
            activity,
            arraySingleOrderList!!

        ).apply {
            receiptInvoke = { pos: Int,arrayCounterList :ArrayList<Int> ->
                receiptInvokeMain(pos,arrayCounterList)
            }

        }
        rvMainReceipt.adapter = receiptAdapter

        rvMainCartListCurrent.layoutManager = LinearLayoutManager(
            context,
            LinearLayoutManager.VERTICAL,
            false
        )

        pastOrderDetailsStoreAdapter = PastOrderDetailsStoreAdapter(
            activity,
            arraySingleOrderList!!

        )
        rvMainCartListCurrent.adapter = pastOrderDetailsStoreAdapter


        arrayRegisteredStoreList = mutableListOf()
        arrayManualStoreList = mutableListOf()

        rvRegisteredStore.layoutManager = LinearLayoutManager(
            context,
            LinearLayoutManager.VERTICAL,
            false
        )

        registeredOrderAdapter = RegisteredStoreAdapter(
            activity,
            arrayRegisteredStoreList!!

        )
        rvRegisteredStore.adapter = registeredOrderAdapter

        rvManualStore.layoutManager = LinearLayoutManager(
            context,
            LinearLayoutManager.VERTICAL,
            false
        )

        manualStoreAdapter = ManualStoreAdapter(
            activity,
            arrayManualStoreList!!

        )
        rvManualStore.adapter = manualStoreAdapter


    }

    private fun receiptInvokeMain(pos: Int,arrayCounterList:ArrayList<Int>) {
        (getActivity() as CustomerMainActivity).navigateToFragment(
            ReceiptFragment.newInstance(
                arraySingleOrderList?.get(pos)?.order_receipt!!,
                arrayCounterList.get(pos)
            )
        )
    }


    private fun statusUpdate() {

        statusViewScroller.statusView.run {
            currentCount = ConstantUtils.THREE

            lineColor = ContextCompat.getColor(activity,R.color.colorThemeGreen)
            lineColorCurrent = ContextCompat.getColor(activity,R.color.colorThemeGreen)

//            circleFillColorCurrent = resources.getColor(R.color.colorThemeGreen)
        }


    }

    private fun setAllDetails() {
//        tvDateOrder.text = getOrderDetails?.order_date
//        tvOTotalOrder.text = "$" + getOrderDetails?.order_amount
//        tvStatusOrder.text = getOrderDetails?.order_status

        val inputConverter  = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.ENGLISH).parse(getOrderDetails?.order_date!!)

        inputConverter?.let {
            val simpleDateFormatDate  = SimpleDateFormat("dd MMM yyyy ", Locale.ENGLISH).format(it)
            val simpleDateFormatTime  = SimpleDateFormat("HH:mm a", Locale.ENGLISH).format(it)
            tvDateOrder.text = simpleDateFormatDate + "at " + simpleDateFormatTime
        }


        if (getOrderDetails?.driver_detail?.rating != "0") {

        } else {
            tvDriverRate.rating = getOrderDetails?.driver_detail?.rating!!.toFloat()
        }

        if (getOrderDetails?.billing_detail?.order_discount != "0") {
            tvOrderDiscount.visibility = View.VISIBLE
            linearHorizontalOrder1.visibility = View.VISIBLE
            tvFeeOrder.visibility = View.VISIBLE
            tvFeeOrder.text =
                "$" + String.format(
                    "%.2f",
                    getOrderDetails?.billing_detail?.order_discount!!.toFloat()
                )
        } else {
            linearHorizontalOrder1.visibility = View.GONE
            tvOrderDiscount.visibility = View.GONE
            tvFeeOrder.visibility = View.GONE
        }

        if (getOrderDetails?.billing_detail?.coupon_discount != "0") {
            linearHorizontalOrder1.visibility = View.VISIBLE
            tvCouponDiscount.visibility = View.VISIBLE
            tvFeeCoupon.visibility = View.VISIBLE
            tvFeeCoupon.text =
                "$" + String.format(
                    "%.2f",
                    getOrderDetails?.billing_detail?.coupon_discount!!.toFloat()
                )
        } else {
            linearHorizontalOrder1.visibility = View.GONE
            tvCouponDiscount.visibility = View.GONE
            tvFeeCoupon.visibility = View.GONE
        }

        tvShoppingRs.text =
            "$" + String.format("%.2f", getOrderDetails?.billing_detail?.shopping_fee!!.toFloat())

        tvServiceChargeRs.text =
            "$" + String.format("%.2f", getOrderDetails?.billing_detail?.service_charge!!.toFloat())
        tvDeliveryFeeRs.text =
            "$" + String.format(
                "%.2f",
                getOrderDetails?.billing_detail?.delivery_charge!!.toFloat()
            )
        if (!getOrderDetails?.driver_detail?.user_image.isNullOrEmpty()) {

            if (ValidationUtils.isCheckUrlOrNot(getOrderDetails?.driver_detail?.user_image!!)) {
                Glide.with(activity)
                    .load(getOrderDetails?.driver_detail?.user_image)
                    .centerCrop()
                    .placeholder(R.drawable.customer_unpress)
                    .into(ivDriverImage)
            } else {

                Glide.with(activity).load(
                    URLConstant.urlUser
                            + getOrderDetails?.driver_detail?.user_image
                ).centerCrop()
                    .placeholder(R.drawable.customer_unpress)
                    .into(ivDriverImage)
            }
        }

        tvPayRsRv.text =
            resources.getString(R.string.rs) + String.format(
                "%.2f",
                getOrderDetails?.billing_detail?.total_pay!!.toFloat()
            )

        if (getOrderDetails?.billing_detail?.is_manual_store_available == "1") {
            noteConstraint.visibility = View.GONE
            tvShoppingFee.visibility = View.VISIBLE
            tvShoppingRs.visibility = View.VISIBLE

        } else {
            noteConstraint.visibility = View.GONE
            tvShoppingFee.visibility = View.GONE
            tvShoppingRs.visibility = View.GONE
        }

        statusUpdate()
        orderStatusUpdate = getOrderDetails?.order_status!!
        receiptAdapter?.notifyDataSetChanged()


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

    private fun observeViewModel() {

        orderViewModel.orderDetails.observe(
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                (getActivity() as CustomerMainActivity).hideProgress()


                if (Utils.userId == 0) {

                } else {
                    getOrderDetails = it

                    arraySingleOrderList?.clear()
                    arrayRegisteredStoreList?.clear()
                    arrayManualStoreList?.clear()
                    arraySingleOrderList?.addAll(it.stores)
                    arrayRegisteredStoreList?.addAll(it.billing_detail.registered_stores)
                    arrayManualStoreList?.addAll(it.billing_detail.manual_stores)

                    setAllDetails()
//                    arraySingleOrderList?.addAll(getOrderDetails?.stores)
                }
                pastOrderDetailsStoreAdapter?.notifyDataSetChanged()
                receiptAdapter?.notifyDataSetChanged()
                registeredOrderAdapter?.notifyDataSetChanged()
                manualStoreAdapter?.notifyDataSetChanged()

                // currentOrderAdapter?.notifyDataSetChanged()
            })

        orderViewModel.errorMessage.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (getActivity() as CustomerMainActivity).hideProgress()

            pastOrderDetailsStoreAdapter?.notifyDataSetChanged()
            receiptAdapter?.notifyDataSetChanged()
        })

    }

    override fun onDestroy() {
        super.onDestroy()
    }


}