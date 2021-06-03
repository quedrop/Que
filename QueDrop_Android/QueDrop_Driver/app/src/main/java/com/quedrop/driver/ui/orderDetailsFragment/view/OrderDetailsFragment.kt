package com.quedrop.driver.ui.orderDetailsFragment.view

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import co.csadev.kwikpicker.KwikPicker
import com.bumptech.glide.Glide
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseFragment
import com.quedrop.driver.service.model.OrderDetail
import com.quedrop.driver.service.request.UploadOrderReceipt
import com.quedrop.driver.socket.SocketHandler
import com.quedrop.driver.ui.homeFragment.view.DriverMapView
import com.quedrop.driver.ui.homeFragment.viewModel.HomeViewModel
import com.quedrop.driver.ui.orderDetailsFragment.viewModel.OrderDetailViewModel
import com.quedrop.driver.utils.*
import com.tbruyelle.rxpermissions2.RxPermissions
import com.yalantis.ucrop.UCrop
import kotlinx.android.synthetic.main.activity_identity_verification.*
import kotlinx.android.synthetic.main.activity_order_details.*
import okhttp3.MediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody
import java.io.File

/**
 * A simple [Fragment] subclass.
 */
class OrderDetailsFragment : BaseFragment() {
    // private var listener: OrderConfirmedListener? = null
    private var mCurrentFragment: Fragment? = null
    private var rideMapView: DriverMapView? = null
    private var orderDetail: OrderDetail? = null
    private var socketHandler: SocketHandler? = null
    lateinit var orderDetailViewModel: OrderDetailViewModel
    private lateinit var homeViewModel: HomeViewModel
    private lateinit var rxPermissions: RxPermissions
    private lateinit var orderDetailsFragment: OrderDetailsFragment
    private var imageList: ArrayList<Any> = arrayListOf(0, 0, 0, 0)
    private var imagePosition = -1

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.activity_order_details, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        orderDetail = arguments?.getParcelable<OrderDetail>("orderDetail")!!
        homeViewModel = HomeViewModel(appService)
        orderDetailViewModel = OrderDetailViewModel(appService)
        socketHandler = SocketHandler(context!!)
        socketHandler?.socketListener = (this)
        rxPermissions = RxPermissions(this)
        if (orderDetail?.orderStatus == "Accepted" || orderDetail?.orderStatus == "Placed") {
            btnConfirm.visibility = View.VISIBLE
        } else {
            btnConfirm.visibility = View.GONE
        }
        /*onClickView()
        setUpToolbar()
        getSingleOrderDetail()
        initMethod()
        observeViewModel()*/
    }

   /* private fun observeViewModel() {
        orderDetailViewModel.singleOrderDetailArrayList.observe(
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                (getActivity() as MainActivity).hideProgress()
                orderDetail = it
                setUpData()
            })

        orderDetailViewModel.errorMessage.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (getActivity() as MainActivity).hideProgress()
        })
    }*/

    /*private fun confirmOrder() {
        //order_id, order_status, user_id, customer_id
        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {
                jsonObject.put(
                    SocketConstants.KeyOrderId, orderDetail?.orderId
                )
                jsonObject.put(
                    SocketConstants.KeyOrderStatus, orderDetail?.orderStatus
                )

                jsonObject.put(
                    SocketConstants.KeyUserId, (SharedPreferenceUtils.getModelPreferences(
                        KEY_USER,
                        User::class.java
                    ) as User).userId
                )
                jsonObject.put(
                    SocketConstants.KeyCustomerId, orderDetail?.customerDetail?.userId
                )

                SocketConstants.socketIOClient!!.emit(
                    SocketConstants.SocketUpdateOrderStatus,
                    jsonObject, Ack {
                        try {
                            val messageJson = JSONObject(it[0].toString())
                            val responseStatus = messageJson.getString("status").toInt()
                            val data = messageJson.getJSONObject("data")
                            activity.runOnUiThread(Runnable {
                                if (responseStatus == 1) {
                                    //listener?.onOrderConfirmed()
                                    if (mCurrentFragment != null) {
                                        if (mCurrentFragment is CurrentOrderFragment) {
                                            val fragment = mCurrentFragment as CurrentOrderFragment
                                            fragment.notifyAdapter()
                                        } else if (mCurrentFragment is PastOrderFragment) {
                                            val fragment = mCurrentFragment as PastOrderFragment
                                            fragment.notifyAdapter()
                                        }
                                    }
                                } else {

                                }
                            })
                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }
                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }

    private fun getSingleOrderDetail() {
        (getActivity() as MainActivity).showProgress()
        orderDetailViewModel.getSingleOrderDetail(getOrderRequest())
    }

    private fun getOrderRequest(): SingleOrderRequest {
        return SingleOrderRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY, orderDetail?.orderId?.toInt()!!
        )
    }

    @SuppressLint("SetTextI18n")
    private fun setUpData() {
        if (orderDetail?.orderStatus == "Accepted" || orderDetail?.orderStatus == "Placed") {
            btnConfirm.visibility = View.VISIBLE
        } else {
            btnConfirm.visibility = View.GONE
        }
        tvDateOrder.text = orderDetail?.orderDate
        tvDUserName.text =
            orderDetail?.customerDetail?.firstName + " " + orderDetail?.customerDetail?.lastName
        tvDPhoneNum.text = orderDetail?.customerDetail?.phoneNumber
        userDRating.rating = orderDetail?.customerDetail?.rating?.toFloat()!!
        setUpBillingData()
        Glide.with(context!!).load(
            BuildConfig.BASE_URL + ImageConstant.USER_STORE + orderDetail?.customerDetail?.userImage
        ).circleCrop()
            .centerCrop().into(ivDUserImage)

        val map =
            childFragmentManager.findFragmentById(R.id.mapDetailsFragment) as SupportMapFragment
        map.getMapAsync { googleMap ->
            rideMapView = DriverMapView(
                map,
                googleMap,
                homeViewModel
            )
            rideMapView?.clearMap()
            rideMapView?.setPolyLines(orderDetail!!)
        }

    }
*/
   /* @SuppressLint("SetTextI18n")
    private fun setUpBillingData() {

        if (orderDetail?.billingDetail?.isManualStoreAvailable == 0) {
            txtNoteView.visibility = View.GONE
            txtNotes.visibility = View.GONE
        } else {
            txtNoteView.visibility = View.VISIBLE
            txtNotes.visibility = View.VISIBLE
        }

        if (orderDetail?.billingDetail?.orderDiscount?.toInt() == 0 && orderDetail?.billingDetail?.couponDiscount?.toInt() == 0) {
            billDivider.visibility = View.GONE
        } else {
            billDivider.visibility = View.VISIBLE
        }
        if (orderDetail?.billingDetail?.orderDiscount?.toInt() != 0) {
            txtOrderDiscount.text =
                CURRENCY + String.format("%.2f", orderDetail?.billingDetail?.orderDiscount)
        } else {
            txtOrderDiscount.visibility = View.GONE
            txtOrderDiscountView.visibility = View.GONE
        }
        if (orderDetail?.billingDetail?.couponDiscount?.toInt() != 0) {
            txtCouponDiscount.text =
                CURRENCY + String.format("%.2f", orderDetail?.billingDetail?.couponDiscount)
        } else {
            txtCouponDiscount.visibility = View.GONE
            txtCounponDiscountView.visibility = View.GONE
        }
        if (orderDetail?.billingDetail?.serviceCharge?.toInt() != 0) {
            txtServiceCharges.text =
                CURRENCY + String.format("%.2f", orderDetail?.billingDetail?.serviceCharge)
        } else {
            txtServiceCharges.text = getString(R.string.free)
        }
        if (orderDetail?.billingDetail?.shoppingFee?.toInt() != 0) {
            txtShoppingFee.text =
                CURRENCY + String.format("%.2f", orderDetail?.billingDetail?.shoppingFee)
        } else {
            txtShoppingFee.text = getString(R.string.free)
        }
        if (orderDetail?.billingDetail?.deliveryCharge?.toInt() != 0) {
            txtDeliveryFee.text =
                CURRENCY + String.format("%.2f", orderDetail?.billingDetail?.deliveryCharge)
        } else {
            txtDeliveryFee.text = getString(R.string.free)
        }
        if (orderDetail?.billingDetail?.totalPay?.toInt() != 0) {
            txtToPay.text = CURRENCY + String.format("%.2f", orderDetail?.billingDetail?.totalPay)
        } else {
            txtToPay.text = getString(R.string.free)
        }
        addRegisterdBillData()
        addManualBillData()
    }

    private fun addManualBillData() {
        rvManualStore.layoutManager = LinearLayoutManager(
            context!!,
            LinearLayoutManager.VERTICAL,
            false
        )
        val orderManualStoreAdapter =
            OrderManualStoreAdapter(orderDetail?.billingDetail?.manualStore!!)

        rvManualStore.adapter = orderManualStoreAdapter
        orderManualStoreAdapter.notifyDataSetChanged()
    }

    private fun addRegisterdBillData() {
        rvBillRegisteredDetails.layoutManager = LinearLayoutManager(
            context!!,
            LinearLayoutManager.VERTICAL,
            false
        )
        val orderRegisteredStoreAdapter =
            OrderRegisteredStoreAdapter(orderDetail?.billingDetail?.registeredStore!!)

        rvBillRegisteredDetails.adapter = orderRegisteredStoreAdapter
        orderRegisteredStoreAdapter.notifyDataSetChanged()
    }*/

    private fun initMethod() {
        /*rvOrderDetails.layoutManager = LinearLayoutManager(requireContext())
        val orderAdapter = OrderListAdapter()
        rvOrderDetails.adapter = CurrentOrderStoreListAdapter(
            true,
            context,
            orderDetail!!.storeDetail!!.toMutableList()
        )
        orderAdapter.notifyDataSetChanged()*/
    }

    /*private fun onClickView() {
        mapDetailsFragment.throttleClicks().subscribe {
            (context as MainActivity).navigateToFragment(
                DeliveryRouteFragment.newInstance(orderDetail!!)
            )
        }.autoDispose(compositeDisposable)

        btnConfirm.throttleClicks().subscribe {
            confirmOrder()
            (context as MainActivity).navigateToFragment(
                ConfirmedOrderDeliveryFragment.newInstance(orderDetail!!)
            )
        }.autoDispose(compositeDisposable)

    }*/

    /*private fun setUpToolbar() {
        tvTitle.text = resources.getString(R.string.order_details)
        ivBack.throttleClicks().subscribe {
            goBackToPreviousFragment()
        }.autoDispose(compositeDisposable)
    }

    private fun goBackToPreviousFragment() {
        val fm = getActivity()!!.supportFragmentManager
        if (fm.backStackEntryCount > 0) {
            fm.popBackStack()
        }
    }*/

    /*interface OrderConfirmedListener {
        fun onOrderConfirmed()
    }*/

    @SuppressLint("CheckResult")
    private fun requestStoragePermission() {
        rxPermissions
            .request(Manifest.permission.CAMERA, Manifest.permission.WRITE_EXTERNAL_STORAGE)
            .subscribe { granted ->
                if (granted) {
                    val kwikPicker = KwikPicker.Builder(
                        context!!,
                        imageProvider = { imageView, uri ->
                            Glide.with(this)
                                .load(uri)
                                .into(imageView)
                        },
                        onImageSelectedListener = { uri: Uri ->
                            UCrop.of(
                                uri,
                                Uri.fromFile(
                                    File(
                                        context!!.cacheDir,
                                        "QurDrop_" + System.currentTimeMillis() + ".jpg"
                                    )
                                )
                            )
                                .withAspectRatio(16f, 9f)
                                .withMaxResultSize(720, 720)
                                .start(context!!, orderDetailsFragment)
                            // val imageFilePath = getCompressedFilePath(this,uri.path.toString())

                        },
                        peekHeight = 1200
                    )
                        .create(context!!)
                    kwikPicker.show(getActivity()!!.supportFragmentManager)

                } else {
                    requestStoragePermission()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK && requestCode == UCrop.REQUEST_CROP) {
            val resultUri = UCrop.getOutput(data!!)
            setImageToRespectedField(resultUri, imagePosition)
        } else if (resultCode == UCrop.RESULT_ERROR) {
            val cropError = UCrop.getError(data!!)
        }
    }

    private fun setImageToRespectedField(resultUri: Uri?, imagePosition: Int) {
        resultUri?.let {
            when (imagePosition) {
                0 -> {
                    Glide.with(this).load(resultUri).into(ivLicense)
                    getMultiPartImage(resultUri.path!!)
                }
                1 -> {
                    Glide.with(this).load(resultUri).into(ivProfile)
                    getMultiPartImage(resultUri.path!!)
                }
                2 -> {
                    Glide.with(this).load(resultUri).into(ivRegProof)
                    getMultiPartImage(resultUri.path!!)
                }
                3 -> {
                    Glide.with(this).load(resultUri).into(ivAddNumberPlate)
                    getMultiPartImage(resultUri.path!!)
                }
            }
        }
    }

    private fun getMultiPartImage(path: String) {
        val file = File(path)
        val fileReqBody = RequestBody.create(MediaType.parse("image/*"), file)
        imageList[imagePosition] =
            MultipartBody.Part.createFormData(KEY_RECEIPT, file.name, fileReqBody)
    }

    private fun getStringRequestBody(value: String): RequestBody {
        return RequestBody.create(MediaType.parse("text/plain"), value)
    }

    private fun uploadReceipt(): UploadOrderReceipt {

        return UploadOrderReceipt(
            getStringRequestBody(orderDetail?.orderId!!),
            getStringRequestBody(orderDetail?.storeDetail!![0].orderStoreId.toString()),
            getStringRequestBody(SharedPreferenceUtils.getString(KEY_TOKEN)),
            getStringRequestBody(ACCESS_KEY),
            imageList[0] as MultipartBody.Part,
            getStringRequestBody(SharedPreferenceUtils.getInt(KEY_USERID).toString()),
            getStringRequestBody("0")
        )

    }
}
