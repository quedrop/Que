package com.quedrop.driver.ui.enterphonenumber

import android.content.Intent
import android.os.Bundle
import androidx.lifecycle.Observer
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.User
import com.quedrop.driver.service.request.SendOTPRequest
import com.quedrop.driver.ui.register.viewModel.RegisterViewModel
import com.quedrop.driver.ui.verifyphone.VerifyPhoneActivity
import com.quedrop.driver.utils.*
import com.hbb20.CountryCodePicker
import kotlinx.android.synthetic.main.activity_enter_phone_number.*
import kotlinx.android.synthetic.main.toolbar_normal.*


class EnterPhoneNumberActivity : BaseActivity() {

    private var countryCode = "0"
    private var phoneNo = "0"
    private var isFromProfile: Boolean = false
    private lateinit var registerViewModel: RegisterViewModel
    var userData:User?=null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_enter_phone_number)
        registerViewModel = RegisterViewModel(appService)

        userData=
            (SharedPreferenceUtils.getModelPreferences(KEY_USER, User::class.java)) as User?


        if(intent.hasExtra("PhoneNumber")) {
            phoneNo = intent.getStringExtra("PhoneNumber")!!
        }
        if(intent.hasExtra("CountryCode")) {
            countryCode = intent.getIntExtra("CountryCode", 0).toString()
        }
        if(intent.hasExtra("isFromProfile")) {
            isFromProfile = intent.getBooleanExtra("isFromProfile", false)
        }

        if (phoneNo != null && phoneNo != "") {
            if(phoneNo=="0") {
                etMobile.setText("")
            }else{
                etMobile.setText(phoneNo)
            }
        }
        countryCodeSpinner.setCountryForPhoneCode(countryCode.toInt())

        setUpToolbar()
        observeViewModel()
        onClickView()


    }

    private fun observeViewModel() {

        registerViewModel.errorMessage.observe(this, Observer { error ->
            hideProgress()
            showAlertMessage(this,error)
        })

        registerViewModel.otpSendData.observe(this, Observer { isOTPSent ->
            if (isOTPSent) {
                hideProgress()
                navigateToVerificationActivity()
            }
        })
    }

    private fun navigateToVerificationActivity() {
        val intent = Intent(this, VerifyPhoneActivity::class.java)
        intent.putExtra("countryCode", countryCode)
        intent.putExtra("phone", etMobile.text!!.trim().toString())
        intent.putExtra("isFromProfile", false)
        startActivityWithDefaultAnimations(intent)
    }

    private fun setUpToolbar() {
        tvTitle.text = resources.getString(R.string.phone_number)

        ivBack.throttleClicks().subscribe {
            finish()
        }.autoDispose(compositeDisposable)
    }

    private fun onClickView() {

        btnNext.setOnClickListener {
            if (etMobile.text!!.trim().isNotEmpty() && etMobile.text!!.trim().toString().length == 10) {
                phoneNo = etMobile.text!!.trim().toString()
                if (Utility.isNetworkAvailable(this)) {
                    showProgress()
                    registerViewModel.sendOTP(getSendOTPRequest())
                } else {
                    hideProgress()
                    showAlertMessage(this, getString(R.string.no_internet_connection))
                }
            } else {
                showInfoMessage(this,"Enter Valid Mobile Number")
            }
        }

        val ccp = findViewById<CountryCodePicker>(R.id.countryCodeSpinner)
        ccp.setOnCountryChangeListener {
            countryCode = "+${ccp.selectedCountryCode}"
        }
    }


    private fun getSendOTPRequest(): SendOTPRequest {
        return SendOTPRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            countryCode,
            phoneNo,
            userData?.userId!!
        )

    }
}
