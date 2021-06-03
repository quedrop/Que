package com.quedrop.driver.ui.confirmedOrderDelivery

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.widget.AppCompatButton
import androidx.appcompat.widget.AppCompatEditText
import com.bumptech.glide.Glide
import com.fuzzproductions.ratingbar.RatingBar
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.base.extentions.finishWithAnimation
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.OrderDetail
import com.quedrop.driver.service.model.ReceiverUser
import com.quedrop.driver.service.request.GiveRateRequest
import com.quedrop.driver.ui.chat.ChatActivity
import com.quedrop.driver.utils.*
import com.google.gson.Gson
import com.google.zxing.BarcodeFormat
import com.google.zxing.MultiFormatWriter
import com.google.zxing.WriterException
import com.google.zxing.common.BitMatrix
import com.journeyapps.barcodescanner.BarcodeEncoder
import kotlinx.android.synthetic.main.activity_confirmed_order_deliver.*
import kotlinx.android.synthetic.main.toolbar_normal.*

class ConfirmedOrderDeliveryActivity : BaseActivity() {

    private var orderDetail: OrderDetail? = null
    private lateinit var mContext: Activity
    private var profileImagePath: String = ""


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_confirmed_order_deliver)
        mContext = this
        val strOrderDetail = intent?.getStringExtra("orderDetail")
        orderDetail = Gson().fromJson(strOrderDetail, OrderDetail::class.java)
        initViews()
    }


    @SuppressLint("CheckResult")
    private fun initViews() {
        tvTitle.text = resources.getString(R.string.confirm_order_delivery)

        ivBack.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        btnGiveReview.throttleClicks().subscribe {
            sendFeedBack()
        }.autoDispose(compositeDisposable)

        btnChat.throttleClicks().subscribe {
            val customerDetails = orderDetail?.customerDetail
            val userName = customerDetails?.firstName + " " + customerDetails?.lastName
            customerDetails?.userId?.toIntOrNull()?.let {
                startActivityWithDefaultAnimations(
                    ChatActivity.getIntent(
                        applicationContext,
                        ReceiverUser(
                            it,
                            userName,
                            customerDetails.userImage,
                            orderDetail?.orderStatus!!,
                            orderDetail?.orderId!!.toInt()
                        )
                    )
                )
            }
        }.autoDispose(compositeDisposable)

        //SETUP DATA..
        setUpData()

        //OBSERVER...
        mainViewModel.ratingResponse.observe(this, androidx.lifecycle.Observer {
            hideProgress()
            showInfoMessage(this, it)
        })
    }


    @SuppressLint("SetTextI18n")
    private fun setUpData() {
        tvCUserName.text =
            orderDetail?.customerDetail?.firstName + " " + orderDetail?.customerDetail?.lastName
        tvCPhoneNum.text =
            "+" + orderDetail?.customerDetail?.countryCode.toString() + " " + orderDetail?.customerDetail?.phoneNumber
        userCRating.rating = orderDetail?.customerDetail?.rating?.toFloat()!!


        if (!isNetworkUrl(orderDetail!!.customerDetail!!.userImage!!)) {
            profileImagePath =
                BuildConfig.BASE_URL + ImageConstant.USER_STORE + orderDetail?.customerDetail?.userImage
        } else {
            profileImagePath = orderDetail!!.customerDetail!!.userImage!!
        }

        Glide.with(this)
            .load(profileImagePath)
            .placeholder(R.drawable.ic_user_placeholder)
            .circleCrop()
            .into(ivCUserImage)

        //generate QR code
        val text = orderDetail?.orderId.toString()
        val multiFormatWriter = MultiFormatWriter()
        try {
            val bitMatrix: BitMatrix =
                multiFormatWriter.encode(text, BarcodeFormat.QR_CODE, 700, 700)
            val barcodeEncoder = BarcodeEncoder()
            val bitmap: Bitmap = barcodeEncoder.createBitmap(bitMatrix)
            ivQRCode.setImageBitmap(bitmap)
        } catch (e: WriterException) {
            e.printStackTrace()
        }
    }


    private fun sendFeedBack() {
        val alertDialog: AlertDialog = AlertDialog.Builder(mContext).create()
        alertDialog.setCancelable(false)
        val dialogView = View.inflate(mContext, R.layout.review_dialog, null)

        if (alertDialog.window != null) {
            alertDialog.window!!.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        }

        val btnCancel = dialogView.findViewById(R.id.btnCancel) as AppCompatButton
        val btnSendReview = dialogView.findViewById(R.id.btnSendReview) as AppCompatButton
        val edxFeedBack = dialogView.findViewById(R.id.edxFeedBack) as AppCompatEditText
        val feedBackRating = dialogView.findViewById(R.id.feedBackRating) as RatingBar

        feedBackRating.rating = orderDetail?.customerDetail?.rating?.toFloat()!!

        btnSendReview.setOnClickListener {

            val review = edxFeedBack.text.toString().trim()
            val rate = feedBackRating.rating
            if (review != "") {
                if (Utility.isNetworkAvailable(this)) {
                    mainViewModel.giveRatingRequest(
                        giveRateRequest(
                            rate = rate,
                            review = review
                        )
                    )
                } else {
                    showAlertMessage(this, getString(R.string.no_internet_connection))
                }
                alertDialog.dismiss()
            } else {
                showInfoMessage(this, "Please add a review and rate")
            }
        }


        btnCancel.setOnClickListener {
            alertDialog.dismiss()
        }


        alertDialog.setView(dialogView)
        alertDialog.show()
    }


    private fun giveRateRequest(rate: Float, review: String): GiveRateRequest {
        return GiveRateRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            orderDetail?.customerDetail?.userId?.toInt()!!,
            SharedPreferenceUtils.getInt(KEY_USERID),
            rate,
            review,
            orderDetail?.orderId?.toInt()!!
        )
    }

    override fun onBackPressed() {
        super.onBackPressed()
        Log.e("onBackPressed", "==>")
        val returnIntent = Intent()
        setResult(Activity.RESULT_CANCELED, returnIntent)
        finishWithAnimation()
    }
}
