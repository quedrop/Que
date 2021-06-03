package com.quedrop.customer.ui.forgotpassword

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.lifecycle.Observer
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.hideKeyboard
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.ForgotPasswordRequest
import com.quedrop.customer.ui.register.viewModel.RegisterViewModel
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import com.quedrop.customer.utils.ValidationUtils
import kotlinx.android.synthetic.main.activity_forgot_password.*

class ForgotPasswordActivity : BaseActivity() {
    private lateinit var registerViewModel: RegisterViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_forgot_password)
        registerViewModel =
            RegisterViewModel(appService)

        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyGuestId,0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyAccessKey)!!
        Utils.keyLatitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLatitude)!!
        Utils.keyLongitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLongitude)!!
        observeViewModel()
        setUpToolbar()
        onClickView()
    }

    private fun observeViewModel() {
        registerViewModel.errorMessage.observe(this, Observer { error ->
            hideProgress()
            Toast.makeText(this, error, Toast.LENGTH_SHORT).show()
        })

        registerViewModel.forgotData.observe(this, Observer { error ->
            hideProgress()
            navigateToHome()
        })
    }

    private fun navigateToHome() {

        var intent = Intent()
        setResult(Activity.RESULT_OK, intent)
        finish()
    }

    private fun onClickView() {
        btnForgotPasswordNext.throttleClicks().subscribe {
            if (etEmailForgot.text!!.trim().isNotEmpty() && ValidationUtils.isEmailValid(
                    etEmailForgot.text!!.trim().toString()
                )
            ) {
                showProgress()
                registerViewModel.forgotPasswordApi(getForgotRequest())
            } else {
                Toast.makeText(this, "Enter Valid Email Address", Toast.LENGTH_SHORT).show()
            }
        }.autoDispose(compositeDisposable)
    }

    private fun getForgotRequest(): ForgotPasswordRequest {
        return ForgotPasswordRequest(
            etEmailForgot.text!!.trim().toString(),
            Utils.seceretKey,
            Utils.accessKey
        )
    }

    private fun setUpToolbar() {

        ivBackForgotPd.throttleClicks().subscribe {
            finish()
        }.autoDispose(compositeDisposable)
    }

    override fun onResume() {
        super.onResume()
        this.hideKeyboard()
    }
}
