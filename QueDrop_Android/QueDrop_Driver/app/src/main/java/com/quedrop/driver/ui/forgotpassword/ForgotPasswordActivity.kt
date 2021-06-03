package com.quedrop.driver.ui.forgotpassword

import android.os.Bundle
import androidx.lifecycle.Observer
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.base.extentions.hideKeyboard
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.request.ForgotPasswordRequest
import com.quedrop.driver.ui.register.viewModel.RegisterViewModel
import com.quedrop.driver.utils.*
import kotlinx.android.synthetic.main.activity_forgot_password.*
import kotlinx.android.synthetic.main.toolbar_normal.*

class ForgotPasswordActivity : BaseActivity() {
    private lateinit var registerViewModel: RegisterViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_forgot_password)
        registerViewModel = RegisterViewModel(appService)
        observeViewModel()
        setUpToolbar()
        onClickView()
    }

    private fun observeViewModel() {
        registerViewModel.errorMessage.observe(this, Observer { error ->
            hideProgress()
            showAlertMessage(this, error)
        })
    }

    private fun onClickView() {
        btnSend.throttleClicks().subscribe {
            if (etEmailForgot.text!!.trim().isNotEmpty() && isEmailValid(etEmailForgot.text!!.trim().toString())) {

                if (Utility.isNetworkAvailable(this)) {
                    showProgress()
                    registerViewModel.forgotPassword(getForgotRequest())
                } else {
                    hideProgress()
                    showAlertMessage(this, getString(R.string.no_internet_connection))
                }

            } else {
                showInfoMessage(this, "Enter Valid Email Address")
            }
        }.autoDispose(compositeDisposable)
    }

    private fun getForgotRequest(): ForgotPasswordRequest {
        return ForgotPasswordRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            etEmailForgot.text!!.trim().toString()
        )
    }

    private fun setUpToolbar() {
        tvTitle.text = "Forgot Password"
        ivBack.throttleClicks().subscribe {
            finish()
        }.autoDispose(compositeDisposable)
    }

    override fun onResume() {
        super.onResume()
        this.hideKeyboard()
    }
}
