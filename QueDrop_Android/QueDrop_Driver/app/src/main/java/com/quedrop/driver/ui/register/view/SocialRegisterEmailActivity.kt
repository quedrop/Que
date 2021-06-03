package com.quedrop.driver.ui.register.view

import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Bundle
import android.text.SpannableStringBuilder
import android.text.method.LinkMovementMethod
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.quedrop.driver.R
import com.quedrop.driver.api.authentication.LoggedInUserCache
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.base.QueDropDriverApplication
import com.quedrop.driver.base.extentions.makeClickSpannable
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.request.SocialRegisterRequest
import com.quedrop.driver.socket.chat.ChatRepository
import com.quedrop.driver.ui.enterphonenumber.EnterPhoneNumberActivity
import com.quedrop.driver.ui.login.viewModel.LoginViewModel
import com.quedrop.driver.ui.mainActivity.view.MainActivity
import com.quedrop.driver.utils.*
import kotlinx.android.synthetic.main.activity_social_register_email.*
import kotlinx.android.synthetic.main.activity_social_register_email.etEmail
import kotlinx.android.synthetic.main.activity_social_register_email.etReferral
import kotlinx.android.synthetic.main.activity_social_register_email.policyCheck
import kotlinx.android.synthetic.main.activity_social_register_email.tvPolicy
import kotlinx.android.synthetic.main.toolbar_normal.*
import javax.inject.Inject

class SocialRegisterEmailActivity : BaseActivity() {

    private var errorMessage = ""
    private lateinit var loginViewModel: LoginViewModel
    var accountId: String = ""
    var accountEmail: String = ""
    var accountName: String = ""
    var accountProfile: String = ""
    var loginType: Int = 1

    @Inject
    lateinit var loggedInUserCache: LoggedInUserCache

    @Inject
    lateinit var chatRepository: ChatRepository

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        QueDropDriverApplication.component.inject(this)
        setContentView(R.layout.activity_social_register_email)
        loginViewModel =
            LoginViewModel(appService, loggedInUserCache, chatRepository)


        intent.extras?.let {
            accountId = intent.getStringExtra("accountId")!!
            accountEmail = intent.getStringExtra("accountEmail")!!
            accountName = intent.getStringExtra("accountName")!!
            accountProfile = intent.getStringExtra("accountProfile")!!
            loginType = intent.getIntExtra("loginType", 1)
        }

        if (accountEmail.isNotEmpty()) {
            etEmail.setText(accountEmail)
            etEmail.isClickable = false
            etEmail.isFocusable = false
        }
        setUpToolbar()
        observeViewModel()
        setSpanToPolicyText()
        onClickView()

    }

    private fun setUpToolbar() {
        tvTitle.text = resources.getString(R.string.additional_details)
    }


    private fun onClickView() {
        btnSave.throttleClicks().subscribe {
            if (validateInputs()) {
                showProgress()
                val socialRequest = getSocialRegisterRequest(
                    accountId,
                    accountName,
                    etEmail.text!!.trim().toString(),
                    accountProfile,
                    loginType,
                    etReferral.text!!.trim().toString()
                )
                loginViewModel.registerSocialUser(socialRequest)
            }
        }.autoDispose(compositeDisposable)

        ivBack.throttleClicks().subscribe {
            finish()
        }.autoDispose(compositeDisposable)

    }

    private fun validateInputs(): Boolean {
        if (etEmail.text!!.trim().isEmpty()) {
            errorMessage = "Enter Email Address"
            showErrorMessage()
            return false
        } else if (!isEmailValid(etEmail.text!!.trim().toString())) {
            errorMessage = "Enter Valid Email Address"
            showErrorMessage()
            return false
        } else if (!policyCheck.isChecked) {
            errorMessage = "Please check Condition Box"
            showErrorMessage()
            return false
        } else return true
    }

    private fun observeViewModel() {
        loginViewModel.errorMessage.observe(this, Observer { error ->
            hideProgress()
            showAlertMessage(this,error)
        })

        loginViewModel.userData.observe(this, Observer { user ->
            hideProgress()
            SharedPreferenceUtils.setModelPreferences(KEY_USER, user)
            if (user.isPhoneVerified == 0) {
                navigateToPhoneNumberActivity()
            } else {
                navigateToHome()
            }
        })

    }

    private fun navigateToHome() {
        startActivityWithDefaultAnimations(Intent(this, MainActivity::class.java))
        finish()
    }

    private fun navigateToPhoneNumberActivity() {
        startActivityWithDefaultAnimations(Intent(this, EnterPhoneNumberActivity::class.java))
        finish()
    }

    private fun setSpanToPolicyText() {
        val agreementSpan = SpannableStringBuilder()
        agreementSpan.append("By Clicking this box I have read the\n")
        agreementSpan.append(getTermSpan())
        agreementSpan.append("  for this app ")
        tvPolicy.text = agreementSpan
        tvPolicy.movementMethod = LinkMovementMethod.getInstance()
    }

    private fun getTermSpan() = getString(R.string.terms_conditions).makeClickSpannable(
        {
            try {
            } catch (e: ActivityNotFoundException) {
                e.printStackTrace()
            }
        },
        ContextCompat.getColor(this, R.color.colorBlue),
        false,
        false,
        "Terms & Conditions"
    )

    private fun getSocialRegisterRequest(
        accountId: String,
        name: String,
        email: String,
        profileImage: String,
        loginType: Int,
        referralCode: String
    ): SocialRegisterRequest {
        return SocialRegisterRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            name,
            "",
            loginType,
            KEY_LOGIN_AS,
            accountId,
            email,
            DEVICE_TYPE,
            SharedPreferenceUtils.getString(DEVICE_TOKEN),
            getTimeZone(),
            SharedPreferenceUtils.getString(KEY_LATITUDE),
            SharedPreferenceUtils.getString(KEY_LONGITUDE),
            getAddress(this),
            profileImage,
            referralCode,
            0
        )
    }

    private fun showErrorMessage() {
        showInfoMessage(this,errorMessage)
    }

}
