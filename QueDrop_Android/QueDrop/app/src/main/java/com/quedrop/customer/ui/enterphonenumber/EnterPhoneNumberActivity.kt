package com.quedrop.customer.ui.enterphonenumber

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.SendOTPRequest
import com.quedrop.customer.ui.register.viewModel.RegisterViewModel
import com.quedrop.customer.ui.verifyphone.VerifyPhoneActivity
import com.quedrop.customer.utils.ConstantUtils
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import com.hbb20.CountryCodePicker
import kotlinx.android.synthetic.main.activity_enter_phone_number.*

class EnterPhoneNumberActivity : BaseActivity(), AdapterView.OnItemSelectedListener {

    private var countryCode = ""
    private var phoneNo = "0"
    private lateinit var registerViewModel: RegisterViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_enter_phone_number)
        registerViewModel = RegisterViewModel(appService)

        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyGuestId, 0)
        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyUserId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyAccessKey)!!

        observeViewModel()

        val ccp = findViewById<CountryCodePicker>(R.id.countryCodeSpinner)
        ccp.setOnCountryChangeListener {
            countryCode = "+${ccp.selectedCountryCode}"
        }

        onClickView()

        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.RECEIVE_SMS
            ) == PackageManager.PERMISSION_DENIED
        ) {
            ActivityCompat.requestPermissions(
                this, arrayOf(Manifest.permission.RECEIVE_SMS),
                ConstantUtils.PERMISSION_RECEIVE_SMS
            )
        }

    }

    private fun observeViewModel() {

        registerViewModel.errorMessage.observe(this, Observer { error ->
            hideProgress()
            Toast.makeText(this, error, Toast.LENGTH_SHORT).show()
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
        startActivityForResultWithDefaultAnimations(
            intent,
            ConstantUtils.ENTER_PHONE_VERIFY_REQUEST_CODE
        )
    }


    private fun onClickView() {
        btnEnterPhoneNext.throttleClicks().subscribe {
            if (countryCode.isEmpty()) {
                Toast.makeText(
                    this,
                    resources.getString(R.string.countryCodeEnter),
                    Toast.LENGTH_SHORT
                ).show()
            } else if (etMobile.text!!.trim().isNotEmpty() &&
                etMobile.text!!.trim().toString().length > 6 &&
                etMobile.text!!.trim().toString().length <= 13

            ) {
                phoneNo = etMobile.text!!.trim().toString()
                showProgress()
                registerViewModel.sendOTP(getSendOTPRequest())
            } else {
                Toast.makeText(
                    this,
                    resources.getString(R.string.enterPhoneNum),
                    Toast.LENGTH_SHORT
                ).show()
            }
        }.autoDispose(compositeDisposable)

        ivPhoneNumberBack.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)
    }

    private fun getSendOTPRequest(): SendOTPRequest {
        return SendOTPRequest(
            countryCode,
            phoneNo,
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId,
            Utils.guestId
        )

    }

    override fun onNothingSelected(p0: AdapterView<*>?) {

    }

    override fun onItemSelected(p0: AdapterView<*>?, p1: View?, position: Int, p3: Long) {
        countryCode = Utils.countryCodeList[position]

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            ConstantUtils.ENTER_PHONE_VERIFY_REQUEST_CODE -> {
                if (data != null) {
                    navigateToBack()
                }

            }
        }

    }

    private fun navigateToBack() {
        val intent = Intent()
        setResult(Activity.RESULT_OK, intent)
        finish()
    }

}
