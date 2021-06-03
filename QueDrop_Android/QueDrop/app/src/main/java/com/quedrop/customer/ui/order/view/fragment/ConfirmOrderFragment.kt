package com.quedrop.customer.ui.order.view.fragment

import android.annotation.SuppressLint
import android.app.Activity.RESULT_OK
import android.app.Dialog
import android.content.Intent
import android.os.Bundle
import android.util.Base64
import android.util.Log
import android.view.*
import android.widget.TextView
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.braintreepayments.api.BraintreeFragment
import com.braintreepayments.api.DataCollector
import com.braintreepayments.api.GooglePayment
import com.braintreepayments.api.exceptions.ErrorWithResponse
import com.braintreepayments.api.exceptions.InvalidArgumentException
import com.braintreepayments.api.interfaces.BraintreeCancelListener
import com.braintreepayments.api.interfaces.BraintreeErrorListener
import com.braintreepayments.api.interfaces.BraintreeResponseListener
import com.braintreepayments.api.models.GooglePaymentRequest
import com.bumptech.glide.Glide
import com.fuzzproductions.ratingbar.RatingBar
import com.google.android.gms.wallet.PaymentData
import com.google.gson.Gson
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.*
import com.quedrop.customer.socket.SocketConstants
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.order.view.adapter.ManualStoreAdapter
import com.quedrop.customer.ui.order.view.adapter.ReceiptAdapterPayment
import com.quedrop.customer.ui.order.view.adapter.RegisteredStoreAdapter
import com.quedrop.customer.ui.order.viewmodel.OrderViewModel
import com.quedrop.customer.utils.*
import io.socket.client.Ack
import kotlinx.android.synthetic.main.fragment_confirm_order.*
import org.json.JSONException
import org.json.JSONObject
import java.security.NoSuchAlgorithmException
import java.security.spec.InvalidKeySpecException
import java.security.spec.KeySpec
import java.text.SimpleDateFormat
import java.util.*
import javax.crypto.Cipher
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.PBEKeySpec
import javax.crypto.spec.SecretKeySpec


class ConfirmOrderFragment(var orderId: Int) : BaseFragment(),
    BraintreeCancelListener, BraintreeErrorListener {

    lateinit var orderViewModel: OrderViewModel
    var getOrderDetails: GetConfirmOrderDetails? = null
    var arrayConfirmOrderList: MutableList<GetConfirmOrderDetails>? = null
    var receiptAdapter: ReceiptAdapterPayment? = null
    var arrayRegisteredStoreList: MutableList<RegisteredStore>? = null
    var arrayManualStoreList: MutableList<ManualStore>? = null
    var arrayReceiptList: MutableList<String>? = null
    var registeredOrderAdapter: RegisteredStoreAdapter? = null
    var manualStoreAdapter: ManualStoreAdapter? = null
    var textFeedBackString: String? = null
    var textRateString: Float = 0f
    var flagManual: Boolean = true
    var tipText: String = "0.0"

    private var mBraintreeFragment: BraintreeFragment? = null
    var googlePaymentRequest: GooglePaymentRequest? = null
    var deviceData: String? = null
    var paymentToken: String? = ""
    var paymentNetwork: String? = ""
    var paymentMethod: String? = ""
    var billingAddress: String? = ""
    var postalCode: String? = ""
    var totalPay: Float? = 0.0F


    //encrypt
    private val pswdIterations = 10
    private val keySize = 128
    private val cypherInstance = "AES/CBC/PKCS5Padding"
    private val secretKeyInstance = "PBKDF2WithHmacSHA1"
    private val plainText = "sampleText"
    private val AESSalt = "exampleSalt"
    private val initializationVector = "8119745113154120"


    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_confirm_order, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        Utils.userId = SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)
        Utils.guestId = SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyGuestId, 0)
        Utils.seceretKey = SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.accessKey = SharedPrefsUtils.getStringPreference(activity, KeysUtils.keyAccessKey)!!
        Utils.selectAddressTitle = SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeySelectAddressName)!!
        Utils.selectAddress = SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeySelectAddress)!!
        Utils.selectAddressType = SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeySelectAddressType)!!
        Utils.keyLatitude = SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeyLatitude)!!
        Utils.keyLongitude = SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeyLongitude)!!

        orderViewModel = OrderViewModel(appService)


        initMethod()
        launchGooglePayment()
        onClickMethod()
        observeViewModel()
        getSingleOrderApi()
    }

    private fun launchGooglePayment() {
        try {
            mBraintreeFragment =
                BraintreeFragment.newInstance(this, "sandbox_9qs33bwz_jf8yv9rqtwpbjgxw")
        } catch (e: InvalidArgumentException) {
            e.printStackTrace()
        }
        GooglePayment.isReadyToPay(
            mBraintreeFragment
        ) { isReadyToPay ->
           // rlPayNow.isEnabled = isReadyToPay
        }
    }

    private fun initMethod() {
        rvReceiptConfirmed.layoutManager = LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false)
        arrayConfirmOrderList = mutableListOf()
        arrayReceiptList = mutableListOf()

        receiptAdapter = ReceiptAdapterPayment(activity, arrayReceiptList!!)
            .apply {
                receiptInvoke = { pos: Int, arrayCounterList: ArrayList<Int> ->
                    receiptInvokeMain(pos, arrayCounterList)
                }
            }

        rvReceiptConfirmed.adapter = receiptAdapter
        arrayRegisteredStoreList = mutableListOf()
        arrayManualStoreList = mutableListOf()

        rvRegisteredStore.layoutManager =
            LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false)
        registeredOrderAdapter = RegisteredStoreAdapter(activity, arrayRegisteredStoreList!!)
        rvRegisteredStore.adapter = registeredOrderAdapter
        rvManualStore.layoutManager =
            LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false)
        manualStoreAdapter = ManualStoreAdapter(
            activity, arrayManualStoreList!!
        ).apply {
            manualStoreInvoke = {
                clickManualStore(it)
            }
        }
        rvManualStore.adapter = manualStoreAdapter
    }

    private fun clickManualStore(isFlagManual: Boolean) {
        flagManual = isFlagManual
        if (!flagManual) {
            tvPayRsRv.text =
                resources.getString(R.string.pendingStatus)
        }
    }

    private fun receiptInvokeMain(pos: Int, arrayCounterList: ArrayList<Int>) {
        (getActivity() as CustomerMainActivity).navigateToFragment(
            ReceiptFragment.newInstance(
                arrayReceiptList?.get(pos)!!
                , arrayCounterList.get(pos)
            )
        )
    }

    fun onClickMethod() {
        ivBackConfirm.throttleClicks().subscribe {
            activity.onBackPressed()
        }.autoDispose(compositeDisposable)

        tvDriverRateConfirm.throttleClicks().subscribe() {
            dialogRating()
        }.autoDispose(compositeDisposable)

        tvHelp.throttleClicks().subscribe() {
            helpNavigation(orderId)
        }.autoDispose(compositeDisposable)

        /*rlPayNow.throttleClicks().subscribe {
            // Toast.makeText(activity, "Under Development", Toast.LENGTH_LONG).show()

            Log.e("TOTAL", "==>" + totalPay)

            //TODO Change value of total pay /currency code (NGN)/cuuntry code (NG )
            googlePaymentRequest = GooglePaymentRequest()
                .transactionInfo(
                    TransactionInfo.newBuilder()
                        .setTotalPrice("1.00")
                        .setTotalPriceStatus(WalletConstants.TOTAL_PRICE_STATUS_FINAL)
                        .setCurrencyCode("INR")
                        .build()
                )
                // We recommend collecting billing address information, at minimum
                // billing postal code, and passing that billing postal code with all
                // Google Pay card transactions as a best practice.
                .environment("TEST")
                .billingAddressRequired(true)
            // Optional in sandbox; if set in sandbox, this value must be a valid production Google Merchant ID
            //.googleMerchantId("jf8yv9rqtwpbjgxw");

            if (mBraintreeFragment != null && googlePaymentRequest != null) {
                GooglePayment.requestPayment(mBraintreeFragment, googlePaymentRequest!!)
            }

        }.autoDispose(compositeDisposable)*/

        tvPayNow.throttleClicks().subscribe {
            (activity as CustomerMainActivity).navigateToFragment(
                ISPaymentFragment.newInstance(
                    orderId,
                    tipText,
                    Gson().toJson(getOrderDetails)
                )
            )
        }.autoDispose(compositeDisposable)

        tvTip2.throttleClicks().subscribe()
        {
            setTipData("TIP_1")
        }.autoDispose(compositeDisposable)

        tvTip3.throttleClicks().subscribe()
        {
            setTipData("TIP_3")
        }.autoDispose(compositeDisposable)

        tvTip5.throttleClicks().subscribe()
        {
            setTipData("TIP_5")
        }.autoDispose(compositeDisposable)

        tvNoTip.throttleClicks().subscribe()
        {
            setTipData("NO_TIP")
        }.autoDispose(compositeDisposable)

    }

    private fun setTipData(txtId: String) {
        when (txtId) {
            "TIP_1" -> {
                tvTip2.setBackgroundResource(R.drawable.bg_gradiant_toobar)
                tvTip2.setTextColor(ContextCompat.getColor(activity, R.color.white))
                tvTip3.setBackgroundColor(ContextCompat.getColor(activity, R.color.white))
                tvTip3.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))
                tvTip5.setBackgroundColor(ContextCompat.getColor(activity, R.color.white))
                tvTip5.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))
                tvNoTip.setBackgroundResource(R.drawable.view_no_tip)
                tvNoTip.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))

                tipText = "2.0"
            }
            "TIP_3" -> {
                tvTip2.setBackgroundColor(ContextCompat.getColor(activity, R.color.white))
                tvTip2.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))
                tvTip3.setBackgroundResource(R.drawable.bg_gradiant_toobar)
                tvTip3.setTextColor(ContextCompat.getColor(activity, R.color.white))
                tvTip5.setBackgroundColor(ContextCompat.getColor(activity, R.color.white))
                tvTip5.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))
                tvNoTip.setBackgroundResource(R.drawable.view_no_tip)
                tvNoTip.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))

                tipText = "3.0"
            }
            "TIP_5" -> {
                tvTip2.setBackgroundColor(ContextCompat.getColor(activity, R.color.white))
                tvTip2.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))
                tvTip3.setBackgroundColor(ContextCompat.getColor(activity, R.color.white))
                tvTip3.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))
                tvTip5.setBackgroundResource(R.drawable.bg_gradiant_toobar)
                tvTip5.setTextColor(ContextCompat.getColor(activity, R.color.white))
                tvNoTip.setBackgroundResource(R.drawable.view_no_tip)
                tvNoTip.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))

                tipText = "5.0"
            }
            "NO_TIP" -> {
                tvTip2.setBackgroundColor(ContextCompat.getColor(activity, R.color.white))
                tvTip2.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))
                tvTip3.setBackgroundColor(ContextCompat.getColor(activity, R.color.white))
                tvTip3.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))
                tvTip5.setBackgroundColor(ContextCompat.getColor(activity, R.color.white))
                tvTip5.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))
                tvNoTip.setBackgroundResource(R.drawable.bg_gradient_btn)
                tvNoTip.setTextColor(ContextCompat.getColor(activity, R.color.white))

                tipText = "0.0"
            }
        }
    }

    companion object {
        fun newInstance(orderId: Int): ConfirmOrderFragment {
            return ConfirmOrderFragment(orderId)
        }
    }

    @SuppressLint("SetTextI18n")
    private fun setAllDetails() {

        if (getOrderDetails?.driver_detail?.first_name.isNullOrEmpty() ||
            getOrderDetails?.driver_detail?.last_name.isNullOrEmpty()
        ) {
        } else {
            tvDriverNameConfirm.text =
                getOrderDetails?.driver_detail?.first_name + " " + getOrderDetails?.driver_detail?.last_name
        }

        if (!getOrderDetails?.driver_detail?.user_image.isNullOrEmpty()) {

            if (ValidationUtils.isCheckUrlOrNot(getOrderDetails?.driver_detail?.user_image!!)) {
                Glide.with(activity).load(getOrderDetails?.driver_detail?.user_image)
                    .centerCrop()
                    .placeholder(R.drawable.customer_unpress)
                    .into(ivDriverImageConfirm)
            } else {

                Glide.with(activity)
                    .load(URLConstant.urlUser + getOrderDetails?.driver_detail?.user_image)
                    .centerCrop()
                    .placeholder(R.drawable.customer_unpress)
                    .into(ivDriverImageConfirm)
            }
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
        tvDeliveryFeeRs.text = "$" + String.format(
            "%.2f",
            getOrderDetails?.billing_detail?.delivery_charge!!.toFloat()
        )

        if (flagManual) {
            tvPayRsRv.text =
                "$" + String.format("%.2f", getOrderDetails?.billing_detail?.total_pay!!.toFloat())
        } else {
            tvPayRsRv.text = resources.getString(R.string.pendingStatus)
        }

        if (getOrderDetails?.billing_detail?.is_manual_store_available == "1") {
            noteConstraint.visibility = View.VISIBLE
            tvShoppingFee.visibility = View.VISIBLE
            tvShoppingRs.visibility = View.VISIBLE

        } else {
            noteConstraint.visibility = View.GONE
            tvShoppingFee.visibility = View.GONE
            tvShoppingRs.visibility = View.GONE
        }


        totalPay = addition(
            getOrderDetails?.billing_detail?.total_pay?.toFloat()!!,
            tipText.toFloat()
        )
        receiptAdapter?.notifyDataSetChanged()
    }

    private fun observeViewModel() {
        orderViewModel.orderBillingDetails.observe(
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                (getActivity() as CustomerMainActivity).hideProgress()

                if (Utils.userId == 0) {

                } else {
                    if (it != null) {
                        getOrderDetails = it
                        arrayReceiptList?.clear()
                        arrayRegisteredStoreList?.clear()
                        arrayManualStoreList?.clear()
                        if (!it.store_receipts.isNullOrEmpty()) {
                            if (it.store_receipts.size > 0) {
                                arrayReceiptList?.addAll(it.store_receipts)
                            }
                        }
                        arrayRegisteredStoreList?.addAll(it.billing_detail.registered_stores)
                        arrayManualStoreList?.addAll(it.billing_detail.manual_stores)
                        setAllDetails()
                    }
                }


                receiptAdapter?.notifyDataSetChanged()
                registeredOrderAdapter?.notifyDataSetChanged()
                manualStoreAdapter?.notifyDataSetChanged()
            })

        orderViewModel.errorMessage.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (getActivity() as CustomerMainActivity).hideProgress()
            receiptAdapter?.notifyDataSetChanged()
        })

        orderViewModel.rateReviewMessage.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (getActivity() as CustomerMainActivity).hideProgress()
            if (textRateString != 0f) {
                tvDriverRateConfirm.rating = textRateString
            }
            Toast.makeText(activity, it, Toast.LENGTH_SHORT).show()
        })

        orderViewModel.responseGooglePay.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (getActivity() as CustomerMainActivity).hideProgress()

            val df = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
            val date: String = df.format(Calendar.getInstance().time)

            getSocketGetUpdatedEstimatedTime(
                driverId = getOrderDetails?.driver_detail?.user_id.toString(),
                orderId = orderId.toString(),
                totalAmount = getOrderDetails?.billing_detail?.total_pay.toString(),
                token = encrypt(paymentToken!!)!!,
                paymentNetwork = encrypt(paymentNetwork!!)!!,
                paymentMethod = encrypt(paymentMethod!!)!!,
                paymentDate = date,
                billingAddress = encrypt(billingAddress!!)!!,
                tip = tipText,
                transactionId = it.transaction_id
            )
        })
    }


    private fun dialogRating() {
        try {
            val dialog = Dialog(activity)
            dialog.setContentView(R.layout.layout_dialog_rating)
            val lp = WindowManager.LayoutParams()
            lp.copyFrom(dialog.window?.attributes)
            lp.width = WindowManager.LayoutParams.MATCH_PARENT
            lp.height = WindowManager.LayoutParams.WRAP_CONTENT
            lp.gravity = Gravity.CENTER

            val tvDriverRateDialog: RatingBar = dialog.findViewById(R.id.tvDriverRateDialog)
            val tvCancelDialog = dialog.findViewById<TextView>(R.id.tvDialogCancel)
            val tvOkDialog = dialog.findViewById<TextView>(R.id.tvDialogOk)
            val editFeedBack = dialog.findViewById<TextView>(R.id.editFeedBack)

            tvDriverRateDialog.throttleClicks().subscribe() {

            }.autoDispose(compositeDisposable)

            tvOkDialog.throttleClicks().subscribe {
                textRateString = tvDriverRateDialog.rating
                textFeedBackString = editFeedBack.text.toString()

                if (!textFeedBackString.isNullOrEmpty() || !textRateString.toString()
                        .isNullOrEmpty()
                ) {
                    getRateReviewApi()
                }
                dialog.dismiss()
            }.autoDispose(compositeDisposable)

            tvCancelDialog.throttleClicks().subscribe {
                dialog.dismiss()
            }.autoDispose(compositeDisposable)


            dialog.show()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun helpNavigation(orderId: Int) {
        (getActivity() as CustomerMainActivity).navigateToFragment(
            CustomerSupportFragment.newInstance(
                orderId
            )
        )
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
        orderViewModel.getConfirmOrderApi(getSingleOrderDetails())
    }


    private fun getRateReview(): GetRateReview {
        return GetRateReview(
            Utils.seceretKey,
            Utils.accessKey,
            getOrderDetails?.driver_detail?.user_id!!,
            Utils.userId,
            textRateString.toString(),
            textFeedBackString.toString(),
            orderId
        )
    }

    private fun getRateReviewApi() {
        (activity as CustomerMainActivity).showProgress()
        orderViewModel.getRateReviewApi(getRateReview())
    }

    override fun onCancel(requestCode: Int) {
        // Use this to handle a canceled activity, if the given requestCode is important.
        // You may want to use this callback to hide loading indicators, and prepare your UI for input
        Log.e("onCancel", "==>")

    }

    override fun onError(error: java.lang.Exception?) {
        if (error is ErrorWithResponse) {
            val cardErrors = error.errorFor("creditCard")
            if (cardErrors != null) {
                // There is an issue with the credit card.
                val expirationMonthError = cardErrors.errorFor("expirationMonth")
                if (expirationMonthError != null) {
                    // There is an issue with the expiration month.
                    Toast.makeText(
                        activity, expirationMonthError.message,
                        Toast.LENGTH_LONG
                    ).show()
                }
            }
        }
    }

    private fun getSocketGetUpdatedEstimatedTime(
        driverId: String,
        orderId: String,
        totalAmount: String,
        token: String,
        paymentNetwork: String,
        paymentMethod: String,
        paymentDate: String,
        billingAddress: String,
        tip: String,
        transactionId: String
    ) {

        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {
                jsonObject.put(SocketConstants.KeyUserId, Utils.userId)
                jsonObject.put(SocketConstants.KeyDriverIds, driverId.toInt())
                jsonObject.put(SocketConstants.KeyOrderId, orderId.toInt())
                jsonObject.put(SocketConstants.KeyPaymentType, "Google Pay")
                jsonObject.put(SocketConstants.KeyTotalAmount, totalAmount.toString())
                jsonObject.put(SocketConstants.KeyTransactionToken, token)
                jsonObject.put(SocketConstants.KeyPaymentNetwork, paymentNetwork)
                jsonObject.put(SocketConstants.KeyPaymentMethod, paymentMethod)
                jsonObject.put(SocketConstants.KeyPaymentDate, paymentDate)
                jsonObject.put(SocketConstants.KeyBillingAddress, billingAddress)
                jsonObject.put(SocketConstants.KeyTip, tip.toString())
                jsonObject.put(SocketConstants.KeyTransactionId, transactionId)

                SocketConstants.socketIOClient!!.emit(SocketConstants.SocketCompleteOrder,
                    jsonObject, Ack {
                        try {
                            val messageJson = JSONObject(it[0].toString())
                            val responseStatus = messageJson.getString("status").toInt()
                            activity.runOnUiThread {
                                if (responseStatus == 1) {
                                    Toast.makeText(
                                        activity,
                                        "Payment successful",
                                        Toast.LENGTH_LONG
                                    ).show()
                                    goBackToPreviousFragment()
                                    RxBus.instance?.publish("refreshOrders")
                                }
                            }

                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }
                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        } else {
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (data != null) {
            if (resultCode == RESULT_OK) {
                val paymentData = PaymentData.getFromIntent(data)

                paymentToken = JSONObject(paymentData?.toJson()!!)
                    .getJSONObject("paymentMethodData")
                    .getJSONObject("tokenizationData")
                    .getString("token")

                paymentMethod = JSONObject(paymentData.toJson()!!)
                    .getJSONObject("paymentMethodData")
                    .getString("type")

                paymentNetwork = JSONObject(paymentData.toJson()!!)
                    .getJSONObject("paymentMethodData")
                    .getJSONObject("info")
                    .getString("cardNetwork")

                billingAddress = JSONObject(paymentData.toJson()!!)
                    .getJSONObject("paymentMethodData")
                    .getJSONObject("info")
                    .getString("billingAddress")

                postalCode = JSONObject(paymentData.toJson()!!)
                    .getJSONObject("paymentMethodData")
                    .getJSONObject("info")
                    .getJSONObject("billingAddress")
                    .getString("postalCode")

                val nonce = (JSONObject(paymentToken!!).getJSONArray("androidPayCards")
                    .get(0) as JSONObject).getString("nonce")

                DataCollector.collectDeviceData(mBraintreeFragment, BraintreeResponseListener {
                    deviceData = it
                })

                orderViewModel.getGooglePaymentCharge(
                    GooglePayRequest(
                        Utils.seceretKey,
                        Utils.accessKey,
                        Utils.userId,
                        orderId,
                        1.0F,
                        nonce.toString(),
                        deviceData!!,
                        postalCode
                    )
                )

            }
        }
    }

    @Throws(java.lang.Exception::class)
    fun encrypt(textToEncrypt: String): String? {
        val skeySpec =
            SecretKeySpec(getRaw(plainText, AESSalt), "AES")
        val cipher = Cipher.getInstance(cypherInstance)
        cipher.init(
            Cipher.ENCRYPT_MODE,
            skeySpec,
            IvParameterSpec(initializationVector.toByteArray())
        )
        val encrypted = cipher.doFinal(textToEncrypt.toByteArray())
        return Base64.encodeToString(encrypted, Base64.DEFAULT)
    }

    private fun getRaw(plainText: String, salt: String): ByteArray? {
        try {
            val factory: SecretKeyFactory = SecretKeyFactory.getInstance(secretKeyInstance)
            val spec: KeySpec =
                PBEKeySpec(plainText.toCharArray(), salt.toByteArray(), pswdIterations, keySize)
            return factory.generateSecret(spec).encoded
        } catch (e: InvalidKeySpecException) {
            e.printStackTrace()
        } catch (e: NoSuchAlgorithmException) {
            e.printStackTrace()
        }
        return ByteArray(0)
    }

    private fun addition(numa: Float, numb: Float): Float {
        return numa + numb
    }

    private fun goBackToPreviousFragment() {
        val fm = requireActivity().supportFragmentManager
        if (fm.backStackEntryCount > 0) {
            fm.popBackStack()
            fm.popBackStack()
            fm.popBackStack()
        }
    }
}