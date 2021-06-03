package com.quedrop.customer.ui.verifyphone

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.SpannableStringBuilder
import android.text.TextWatcher
import android.text.method.LinkMovementMethod
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.hideKeyboard
import com.quedrop.customer.base.glide.makeClickSpannable
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.User
import com.quedrop.customer.model.VerifyOTPRequest
import com.quedrop.customer.ui.register.viewModel.RegisterViewModel
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import com.quedrop.customer.utils.smsHelper.MySMSBroadcastReceiver
import kotlinx.android.synthetic.main.activity_verify_phone.*
import kotlinx.android.synthetic.main.activity_verify_phone.tvInstruction

class VerifyPhoneActivity : BaseActivity() {
    private var mobileNo = ""
    private var countryCode = ""
    private var user: User? = null
    private var smsReceiver: MySMSBroadcastReceiver? = null

    private lateinit var registerViewModel: RegisterViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_verify_phone)

        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyGuestId, 0)
        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyUserId, 0)

        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyAccessKey)!!
        intent.extras?.let {
            mobileNo = intent.getStringExtra("phone")!!
            countryCode = intent.getStringExtra("countryCode")!!
        }

        user = SharedPrefsUtils.getModelPreferences(
            applicationContext,
            KeysUtils.keyUser,
            User::class.java
        ) as User?
        registerViewModel = RegisterViewModel(appService)

        // This code requires one time to get Hash keys do comment and share key
        /* val appSignature = AppSignatureHelper(this)
         Log.e("AppSignature", appSignature.appSignatures.toString())
         startSMSListener()
 */
        observeViewModel()
        setSpanToInstruction()
        setInputListenerForOTP()

        onClickView()
//        if (ContextCompat.checkSelfPermission(
//                this,
//                Manifest.permission.RECEIVE_SMS
//            ) == PackageManager.PERMISSION_GRANTED
//        ) {
//
//            VerifyOtpReceiver.bindListener(object : OTPListener {
//                override fun onOTPReceived(otp: String) {
//
//                    val displayOtp = otp.trim()
//
//                    etPassFirst.setText(displayOtp[0].toString())
//                    etPassSecond.setText(displayOtp[1].toString())
//                    etPassThird.setText(displayOtp[2].toString())
//                    etPassFourth.setText(displayOtp[3].toString())
//                }
//            })
//        }
    }

    private fun observeViewModel() {
        registerViewModel.errorMessage.observe(this, Observer { error ->
            hideProgress()
//            onBackPressed()
            Toast.makeText(this, error, Toast.LENGTH_SHORT).show()
        })

        registerViewModel.userData.observe(this, Observer { user ->
//            if (isVerify) {
            hideProgress()
            user?.is_phone_verified = "1"
            SharedPrefsUtils.setModelPreferences(
                applicationContext,
                KeysUtils.keyUser,
                user!!
            )
            SharedPrefsUtils.setIntegerPreference(
                applicationContext,
                KeysUtils.keyUserId,
                user.user_id
            )
            SharedPrefsUtils.setIntegerPreference(
                applicationContext,
                KeysUtils.keyGuestId,
                0
            )
            navigateToBack()
//            }
        })
    }

    private fun navigateToBack() {
        val intent = Intent()
        setResult(Activity.RESULT_OK, intent)
        finish()
    }


    private fun onClickView() {

        ivBackVerifyPhone.throttleClicks().subscribe {
            finish()
        }.autoDispose(compositeDisposable)

        btnVerify.throttleClicks().subscribe {
            if (validateInput()) {
                showProgress()
                registerViewModel.verifyOTP(getVerifyOTPRequest())
            }
        }.autoDispose(compositeDisposable)
    }

    private fun getVerifyOTPRequest(): VerifyOTPRequest {
        return VerifyOTPRequest(
            countryCode,
            mobileNo,
            Utils.seceretKey,
            Utils.accessKey,
            getEnteredOTP(),
            Utils.userId,
            Utils.guestId
        )

    }

    private fun getEnteredOTP(): String {
        return etPassFirst.text!!.trim().toString() + etPassSecond.text!!.trim()
            .toString() + etPassThird.text!!.trim().toString() + etPassFourth.text!!.trim()
            .toString()

    }

    private fun validateInput(): Boolean {
        if (etPassFirst.text!!.trim().toString().isEmpty() ||
            etPassSecond.text!!.trim().toString().isEmpty() ||
            etPassThird.text!!.trim().toString().isEmpty() ||
            etPassFourth.text!!.trim().toString().isEmpty()
        ) {
            Toast.makeText(this, "Enter OTP First", Toast.LENGTH_SHORT).show()
            return false
        }
        return true
    }

    /* private fun startSMSListener() {
         try {
             smsReceiver = MySMSBroadcastReceiver()
             smsReceiver!!.initOTPListener(this)

             val intentFilter = IntentFilter()
             intentFilter.addAction(SmsRetriever.SMS_RETRIEVED_ACTION)
             this.registerReceiver(smsReceiver, intentFilter)

             val client = SmsRetriever.getClient(this)

             val task = client.startSmsRetriever()
             task.addOnSuccessListener {
                 // API successfully started
                 showToastLong("API successfully started ")
                 if (it != null) {
                     Log.e("api sent OTP: ", "===> " + it.toString())
                 }
             }

             task.addOnFailureListener {
                 // Fail to start API
                 showToastLong("API Fail started ")
                 if (it != null) {
                     Log.e("api failed OTP: ", "===> " + it.toString())
                 }

             }
         } catch (e: Exception) {
             showToastLong("Exception" + e.toString())
             e.printStackTrace()
         }

     }
 */
    private fun setInputListenerForOTP() {
        etPassFirst.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(p0: Editable?) {
                if (etPassFirst.text!!.trim().toString().isNotEmpty()) {
                    etPassFirst.background =
                        ContextCompat.getDrawable(
                            this@VerifyPhoneActivity,
                            R.drawable.bg_gradient_btn
                        )
                    etPassFirst.setTextColor(
                        ContextCompat.getColor(
                            this@VerifyPhoneActivity,
                            R.color.colorWhite
                        )
                    )
                    etPassSecond.requestFocus()
                } else {
                    etPassFirst.background =
                        ContextCompat.getDrawable(this@VerifyPhoneActivity, R.drawable.bg_otp)
                    etPassFirst.setTextColor(
                        ContextCompat.getColor(
                            this@VerifyPhoneActivity,
                            R.color.colorBlack
                        )
                    )
                }

            }

            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }

            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }
        })
        etPassSecond.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(p0: Editable?) {
                if (etPassSecond.text!!.trim().toString().length == 1) {
                    etPassSecond.background =
                        ContextCompat.getDrawable(
                            this@VerifyPhoneActivity,
                            R.drawable.bg_gradient_btn
                        )
                    etPassSecond.setTextColor(
                        ContextCompat.getColor(
                            this@VerifyPhoneActivity,
                            R.color.colorWhite
                        )
                    )
                    etPassThird.requestFocus()
                } else {
                    etPassSecond.background =
                        ContextCompat.getDrawable(this@VerifyPhoneActivity, R.drawable.bg_otp)
                    etPassSecond.setTextColor(
                        ContextCompat.getColor(
                            this@VerifyPhoneActivity,
                            R.color.colorBlack
                        )
                    )
                    etPassFirst.requestFocus()
                }
            }

            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }

            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }
        })
        etPassThird.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(p0: Editable?) {
                if (etPassThird.text!!.trim().toString().length == 1) {
                    etPassThird.background =
                        ContextCompat.getDrawable(
                            this@VerifyPhoneActivity,
                            R.drawable.bg_gradient_btn
                        )
                    etPassThird.setTextColor(
                        ContextCompat.getColor(
                            this@VerifyPhoneActivity,
                            R.color.colorWhite
                        )
                    )
                    etPassFourth.requestFocus()
                } else {
                    etPassThird.background =
                        ContextCompat.getDrawable(this@VerifyPhoneActivity, R.drawable.bg_otp)
                    etPassThird.setTextColor(
                        ContextCompat.getColor(
                            this@VerifyPhoneActivity,
                            R.color.colorBlack
                        )
                    )
                    etPassSecond.requestFocus()
                }

            }

            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }

            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }
        })
        etPassFourth.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(p0: Editable?) {
                if (etPassFourth.text!!.trim().toString().length == 1) {
                    etPassFourth.background =
                        ContextCompat.getDrawable(
                            this@VerifyPhoneActivity,
                            R.drawable.bg_gradient_btn
                        )
                    etPassFourth.setTextColor(
                        ContextCompat.getColor(
                            this@VerifyPhoneActivity,
                            R.color.colorWhite
                        )
                    )
                    this@VerifyPhoneActivity.hideKeyboard()
                } else {
                    etPassFourth.background =
                        ContextCompat.getDrawable(this@VerifyPhoneActivity, R.drawable.bg_otp)
                    etPassFourth.setTextColor(
                        ContextCompat.getColor(
                            this@VerifyPhoneActivity,
                            R.color.colorBlack
                        )
                    )
                    etPassThird.requestFocus()
                }

            }

            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }

            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }
        })
    }

    private fun setSpanToInstruction() {
        val instructionSpan = SpannableStringBuilder()
        instructionSpan.append(resources.getString(R.string.instructionVerify) + countryCode + mobileNo)
        instructionSpan.append(getInstructionSpan())
        tvInstruction.text = instructionSpan
        tvInstruction.movementMethod = LinkMovementMethod.getInstance()
    }

    private fun getInstructionSpan() = getString(R.string.wrongNumber).makeClickSpannable(
        {
            try {
                finish()
                // val myIntent = Intent(Intent.ACTION_VIEW, Uri.parse( configuration.configurations.settingsMenuItems[2].data ))
                // startActivity(myIntent)
            } catch (e: ActivityNotFoundException) {
                e.printStackTrace()
            }
        },
        ContextCompat.getColor(this, R.color.colorOrange),
        false,
        false,
        resources.getString(R.string.wrongNumber)
    )

    //    override fun onDestroy() {
//        //VerifyOtpReceiver.unbindListener()
//        super.onDestroy()
//    }
    /* override fun onOTPReceived(otp: String) {
         Log.e("OTP Verification", "==>" + otp)
         val displayOtp = otp.trim()

         etPassFirst.setText(displayOtp[0].toString())
         etPassSecond.setText(displayOtp[1].toString())
         etPassThird.setText(displayOtp[2].toString())
         etPassFourth.setText(displayOtp[3].toString())

         if (smsReceiver != null) {
             LocalBroadcastManager.getInstance(this).unregisterReceiver(smsReceiver!!)
         }
     }

     override fun onOTPTimeOut() {
         Log.e("OTP Verification", "==> Time out")
     }*/

    override fun onStop() {
        super.onStop()
        if (smsReceiver != null) {
            LocalBroadcastManager.getInstance(this).unregisterReceiver(smsReceiver!!)
        }
    }
}
