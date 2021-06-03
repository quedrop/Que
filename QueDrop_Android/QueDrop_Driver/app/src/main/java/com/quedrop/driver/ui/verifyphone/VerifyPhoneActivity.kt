package com.quedrop.driver.ui.verifyphone

import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.SpannableStringBuilder
import android.text.TextWatcher
import android.text.method.LinkMovementMethod
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.base.extentions.hideKeyboard
import com.quedrop.driver.base.extentions.makeClickSpannable
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.User
import com.quedrop.driver.service.request.VerifyOTPRequest
import com.quedrop.driver.ui.identityverification.IdentityVerificationActivity
import com.quedrop.driver.ui.mainActivity.view.MainActivity
import com.quedrop.driver.ui.register.viewModel.RegisterViewModel
import com.quedrop.driver.utils.*
import kotlinx.android.synthetic.main.activity_verify_phone.*
import kotlinx.android.synthetic.main.toolbar_normal.*

class VerifyPhoneActivity : BaseActivity() {
    private var mobileNo = ""
    private var countryCode = ""
    private var user: User? = null
    private var isFromProfile: Boolean = false

    private lateinit var registerViewModel: RegisterViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_verify_phone)

        intent.extras?.let {
            mobileNo = intent.getStringExtra("phone")!!
            countryCode = intent.getStringExtra("countryCode")!!
            isFromProfile = intent.getBooleanExtra("isFromProfile", false)

        }

        user = SharedPreferenceUtils.getModelPreferences(KEY_USER, User::class.java) as User?
        registerViewModel =
            RegisterViewModel(appService)
        observeViewModel()
        setUpToolbar()
        setSpanToInstruction()
        setInputListenerForOTP()
        onClickView()
    }

    private fun observeViewModel() {
        registerViewModel.errorMessage.observe(this, Observer { error ->
            hideProgress()
            showAlertMessage(this, error)
        })

        registerViewModel.verifyData.observe(this, Observer { isVerify ->
            if (isVerify) {
                hideProgress()
                user?.isPhoneVerified = 1
                user?.phoneNumber = "$countryCode $mobileNo"
                SharedPreferenceUtils.setModelPreferences(KEY_USER, user!!)

                if (!isFromProfile) {
                    if (user?.isIdentityDetailUploaded == 0) {
                        val intent = Intent(this, IdentityVerificationActivity::class.java)
                        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivityWithDefaultAnimations(
                            Intent(
                                this,
                                IdentityVerificationActivity::class.java
                            )
                        )
                        finish()
                    } else {
                        startActivityWithDefaultAnimations(
                            Intent(
                                this,
                                MainActivity::class.java
                            )
                        )
                        finish()
                    }
                } else {
                    finish()
                }
            }
        })
    }

    private fun setUpToolbar() {
        tvTitle.text = resources.getString(R.string.verification_code)
        ivBack.throttleClicks().subscribe {
            finish()
        }.autoDispose(compositeDisposable)
    }

    private fun onClickView() {
        btnVerify.throttleClicks().subscribe {
            if (validateInput()) {
                showProgress()
                registerViewModel.verifyOTP(getVerifyOTPRequest())
            }
        }.autoDispose(compositeDisposable)
    }

    private fun getVerifyOTPRequest(): VerifyOTPRequest {
        return VerifyOTPRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            countryCode,
            mobileNo,
            getEnteredOTP(),
            user?.userId!!
        )

    }

    private fun getEnteredOTP(): String {
        return etPassFirst.text!!.trim().toString() + etPassSecond.text!!.trim().toString() + etPassThird.text!!.trim().toString() + etPassFourth.text!!.trim().toString()

    }

    private fun validateInput(): Boolean {
        if (etPassFirst.text!!.trim().toString().isEmpty() ||
            etPassSecond.text!!.trim().toString().isEmpty() ||
            etPassThird.text!!.trim().toString().isEmpty() ||
            etPassFourth.text!!.trim().toString().isEmpty()
        ) {
            showInfoMessage(this, "Enter OTP First")
            return false
        }
        return true
    }

    private fun setInputListenerForOTP() {
        etPassFirst.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(p0: Editable?) {
                if (etPassFirst.text!!.trim().toString().isNotEmpty()) {
                    etPassFirst.background =
                        ContextCompat.getDrawable(this@VerifyPhoneActivity, R.drawable.bg_gradient_btn)
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
                            R.color.colorGray100
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
                        ContextCompat.getDrawable(this@VerifyPhoneActivity, R.drawable.bg_gradient_btn)
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
                            R.color.colorGray100
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
                        ContextCompat.getDrawable(this@VerifyPhoneActivity, R.drawable.bg_gradient_btn)
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
                            R.color.colorGray100
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
                        ContextCompat.getDrawable(this@VerifyPhoneActivity, R.drawable.bg_gradient_btn)
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
                            R.color.colorGray100
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
        instructionSpan.append("Waiting for Automatically detect and SMS\nsend to $countryCode $mobileNo ")
        instructionSpan.append(getInstructionSpan())
        tvInstruction.text = instructionSpan
        tvInstruction.movementMethod = LinkMovementMethod.getInstance()
    }

    private fun getInstructionSpan() = getString(R.string.wrong_number).makeClickSpannable(
        {
            try {
                finish()
            } catch (e: ActivityNotFoundException) {
                e.printStackTrace()
            }
        },
        ContextCompat.getColor(this, R.color.colorOrange),
        false,
        false,
        "Wrong number?"
    )
}
