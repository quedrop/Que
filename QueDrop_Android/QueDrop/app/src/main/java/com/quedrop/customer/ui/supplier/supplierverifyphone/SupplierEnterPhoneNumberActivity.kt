package com.quedrop.customer.ui.supplier.supplierverifyphone

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
import com.quedrop.customer.utils.ConstantUtils
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import com.hbb20.CountryCodePicker
import kotlinx.android.synthetic.main.activity_enter_phone_number.*
import kotlinx.android.synthetic.main.activity_toolbar.*

class SupplierEnterPhoneNumberActivity : BaseActivity(), AdapterView.OnItemSelectedListener {

    private var countryCode = ""
    private var phoneNo = ""
    private lateinit var registerViewModel: RegisterViewModel
    var access_key = ""
    var secret_key = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_enter_phone_number)

        registerViewModel = RegisterViewModel(appService)

        Utils.seceretKey = SharedPrefsUtils.getStringPreference(this, KeysUtils.keySecretKey)!!
        Utils.Supplier.supplierAccessKey = SharedPrefsUtils.getStringPreference(this, KeysUtils.KeySupplierAccessKey)!!
        Utils.Supplier.supplierUserId = SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.KeyUserSupplierId, 0)
        Utils.Supplier.supplierStoredCreated = SharedPrefsUtils.getBooleanPreference(applicationContext, KeysUtils.KeyStoreCreated, false)

        setUpToolbar()
        observeViewModel()

        val ccp = findViewById<CountryCodePicker>(R.id.countryCodeSpinner)

        if (intent.hasExtra("PhoneNumber")) {
            phoneNo = intent.getStringExtra("PhoneNumber")!!
        }

        if (intent.hasExtra("CountryCode")) {
            countryCode = intent.getStringExtra("CountryCode")!!

            if (countryCode == "" || countryCode == "0") {
                countryCode = "+${ccp.defaultCountryCode}"
            }

        } else {
            countryCode = "+${ccp.defaultCountryCode}"
        }

        if (phoneNo != null && phoneNo != "") {
            etMobile.setText(phoneNo)
        }

        countryCodeSpinner.setCountryForPhoneCode(countryCode.toInt())


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

    private fun setUpToolbar() {
        tvTitle.text = getString(R.string.phoneNumberTitle)

        ivBack.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)
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
        val intent = Intent(this, SupplierVerifyPhoneActivity::class.java)
        intent.putExtra("countryCode", countryCode)
        intent.putExtra("phone", etMobile.text!!.trim().toString())
        startActivityForResultWithDefaultAnimations(
            intent,
            ConstantUtils.ENTER_PHONE_VERIFY_REQUEST_CODE
        )
    }


    private fun onClickView() {

        btnEnterPhoneNext.throttleClicks().subscribe {
            if (etMobile.text!!.trim().isNotEmpty() && etMobile.text!!.trim()
                    .toString().length > 6 && etMobile.text!!.trim().toString().length <= 13
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
    }

    private fun getSendOTPRequest(): SendOTPRequest {

        return SendOTPRequest(
            countryCode,
            phoneNo,
            Utils.seceretKey,
            Utils.Supplier.supplierAccessKey,
            Utils.Supplier.supplierUserId,
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
                } else {
                    //this.onBackPressed()
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
