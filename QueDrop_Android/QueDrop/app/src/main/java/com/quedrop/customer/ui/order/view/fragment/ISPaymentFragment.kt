package com.quedrop.customer.ui.order.view.fragment

import android.annotation.SuppressLint
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Toast
import com.google.gson.Gson
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.GetConfirmOrderDetails
import com.quedrop.customer.socket.SocketConstants
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.RxBus
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import io.socket.client.Ack
import kotlinx.android.synthetic.main.fragment_i_s_payment.*
import org.json.JSONException
import org.json.JSONObject

class ISPaymentFragment(var orderId: Int, var tip: String, var tempOrderDetails: String) : BaseFragment() {

    private var orderDetails: GetConfirmOrderDetails? = null

    var bankCode: String = ""
    var paymentReference: String = ""
    var retrievalReferenceNumber: String = ""
    var merchantReference: String = ""
    var cardNumber: String = ""
    var transactionDate: String = ""
    var responseCode: String = ""
    var responseDesc: String = ""

    companion object {
        fun newInstance(
            orderId: Int,
            tip: String,
            orderDetails: String
        ): ISPaymentFragment {
            return ISPaymentFragment(orderId, tip, orderDetails)
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_i_s_payment, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        orderDetails = Gson().fromJson(tempOrderDetails, GetConfirmOrderDetails::class.java)
        Utils.userId = SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)

        initViews()
    }

    private fun initViews() {
        onClickView()
        loadPaymentIndiaUrl()
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun loadPaymentIndiaUrl() {
        val BASE_URL = "http://34.204.81.189/quedrop/API/PaymentConfirmation.php?";
        val ORDER_ID = "orderId"
        val USER_ID = "userId"
        val TIP = "tip"
        val TEST_DATA = "TestData"

        val builtUri = Uri.parse(BASE_URL)
            .buildUpon()
            .appendQueryParameter(ORDER_ID, 7.toString())
            .appendQueryParameter(USER_ID, "12")
            .appendQueryParameter(TIP, tip)
            .appendQueryParameter(TEST_DATA, "1")
            .build()

        isPayment.clearCache(true)
        isPayment.clearHistory()
        isPayment.settings.javaScriptEnabled = true
        isPayment.settings.javaScriptCanOpenWindowsAutomatically = true

        isPayment.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                view?.loadUrl(url)
                return true
            }

            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                if (url?.contains("http://34.204.81.189/quedrop/API/PaymentSuccess.php?")!!) {
                    val uri: Uri = Uri.parse(url)
                    responseCode = uri.getQueryParameter("ResponseCode")!!
                    responseDesc = uri.getQueryParameter("ResponseDescription")!!

                    if (responseCode == "00") {
                        bankCode = uri.getQueryParameter("BankCode")!!
                        paymentReference = uri.getQueryParameter("PaymentReference")!!
                        retrievalReferenceNumber = uri.getQueryParameter("RetrievalReferenceNumber")!!
                        merchantReference = uri.getQueryParameter("MerchantReference")!!
                        cardNumber = uri.getQueryParameter("CardNumber")!!
                        transactionDate = uri.getQueryParameter("TransactionDate")!!

                        completeOrder()

                    } else {
                        Toast.makeText(activity, responseDesc, Toast.LENGTH_SHORT).show()
                        goBackToPreviousFragment()
                    }

                    Log.e("orderId", "==>" + orderId)
                    Log.e("KeyUserId", "==>" + Utils.userId)
                    Log.e("bank_code", "==>" + bankCode)
                    Log.e("payment_reference", "==>" + paymentReference)
                    Log.e("retrieval_reference", "==>" + retrievalReferenceNumber)
                    Log.e("merchant_reference", "==>" + merchantReference)
                    Log.e("card_number", "==>" + cardNumber)
                    Log.e("transaction_date", "==>" + transactionDate)
                    Log.e("transaction_date", "==>" + transactionDate)
                    Log.e("tip", "==>" + tip)
                    Log.e("response_code", "==>" + responseCode)
                    Log.e("response_desc", "==>" + responseDesc)

                }
            }
        }
        isPayment.loadUrl(builtUri.toString())
    }

    private fun onClickView() {
        ivBackPayment.throttleClicks().subscribe {
            goBackToPreviousFragment()
        }.autoDispose(compositeDisposable)
    }

    private fun completeOrder() {
        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {
                jsonObject.put(SocketConstants.KeyOrderId, orderId)
                jsonObject.put(SocketConstants.KeyUserId, Utils.userId)
                jsonObject.put(SocketConstants.keyBankCode, bankCode)
                jsonObject.put(SocketConstants.KeyPaymentReference, paymentReference)
                jsonObject.put(SocketConstants.KeyRetrievalReferenceNumber, retrievalReferenceNumber)
                jsonObject.put(SocketConstants.KeyMerchantReference, merchantReference)
                jsonObject.put(SocketConstants.KeyCardNumber, cardNumber)
                jsonObject.put(SocketConstants.KeyTransactionDate, transactionDate)
                jsonObject.put(SocketConstants.KeyDriverIds, orderDetails?.driver_detail?.user_id)
                jsonObject.put(SocketConstants.KeyTip, tip)
                jsonObject.put(SocketConstants.KeyTransactionAmount, orderDetails?.billing_detail?.total_pay)
                jsonObject.put(SocketConstants.KeyResponseCode, responseCode)
                jsonObject.put(SocketConstants.KeyResponseDesc, responseDesc)

                SocketConstants.socketIOClient!!.emit(
                    SocketConstants.SocketCompleteOrder,
                    jsonObject, Ack {
                        try {
                            val messageJson = JSONObject(it[0].toString())
                            val responseStatus = messageJson.getString("status").toInt()
                            activity.runOnUiThread {
                                if (responseStatus == 1) {
                                    Toast.makeText(activity, "Payment successful", Toast.LENGTH_LONG).show()
                                    goBackToOrderFragment()
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
        }
    }

    private fun goBackToOrderFragment() {
        val fm = requireActivity().supportFragmentManager
        if (fm.backStackEntryCount > 0) {
            fm.popBackStack()
            fm.popBackStack()
            fm.popBackStack()
            fm.popBackStack()
        }
    }

    private fun goBackToPreviousFragment() {
        val fm = requireActivity().supportFragmentManager
        if (fm.backStackEntryCount > 0) {
            fm.popBackStack()
        }
    }
}

