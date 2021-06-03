package com.quedrop.customer.ui.register.view

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Bundle
import android.text.SpannableStringBuilder
import android.text.method.LinkMovementMethod
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.quedrop.customer.R
import com.quedrop.customer.api.authentication.LoggedInUserCache
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.QueDropApplication
import com.quedrop.customer.base.extentions.hideKeyboard
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.glide.makeClickSpannable
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.SocialRegisterRequest
import com.quedrop.customer.socket.chat.ChatRepository
import com.quedrop.customer.ui.enterphonenumber.EnterPhoneNumberActivity
import com.quedrop.customer.ui.login.viewModel.LoginViewModel
import com.quedrop.customer.utils.*
import com.quedrop.customer.utils.Utils.getTimeZone
import com.quedrop.customer.utils.Utils.keyLatitude
import kotlinx.android.synthetic.main.activity_register.policyCheckRegister
import kotlinx.android.synthetic.main.activity_social_email.*
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
        QueDropApplication.component.inject(this)
        setContentView(R.layout.activity_social_email)
        loginViewModel = LoginViewModel(appService, loggedInUserCache, chatRepository)

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

        accountId = intent.getStringExtra(KeysUtils.keyAccountId)
        accountEmail = intent.getStringExtra(KeysUtils.keyAccountEmail)
        accountName = intent.getStringExtra(KeysUtils.keyAccountName)
        accountProfile = intent.getStringExtra(KeysUtils.keyAccountProfile)
        loginType = intent.getIntExtra(KeysUtils.keyAccountLoginType, 1)

        if (accountEmail.isEmpty()) {

        } else {

            etEmailEmail.setText(accountEmail)
        }

        observeViewModel()
        setSpanToPolicyText()
        onClickView()
    }

    private fun registerSocialUser(
        accountId: String,
        name: String,
        email: String,
        profileImage: String,
        loginType: Int
    ) {
        loginViewModel.registerSocialUser(
            getSocialRegisterRequest(
                accountId,
                name,
                email,
                profileImage,
                loginType
            )
        )

    }

    private fun getSocialRegisterRequest(
        accountId: String,
        name: String,
        email: String,
        profileImage: String,
        loginType: Int
    ): SocialRegisterRequest {
        return SocialRegisterRequest(
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyDeviceToken)!!,
            name,
            ConstantUtils.KEY_LOGIN_AS,
            ConstantUtils.DEVICE_TYPE,
            email,
            profileImage,
            loginType.toString(),
            accountId,
            keyLatitude,
            "",
            Utils.getCompleteAddressString(
                this,
                keyLatitude.toDouble(),
                Utils.keyLongitude.toDouble()
            ),
            Utils.keyLongitude,
            Utils.seceretKey,
            getTimeZone(),
            Utils.accessKey
        )
    }

    private fun observeViewModel() {

        loginViewModel.errorMessage.observe(this, Observer { error ->
            hideProgress()
            Toast.makeText(this, error, Toast.LENGTH_SHORT).show()
        })

        loginViewModel.userData.observe(this, Observer { user ->
            SharedPrefsUtils.setModelPreferences(applicationContext, KeysUtils.keyUser, user)
            SharedPrefsUtils.setIntegerPreference(
                applicationContext,
                KeysUtils.keyUserId,
                user?.user_id!!
            )
            SharedPrefsUtils.setIntegerPreference(applicationContext, KeysUtils.keyGuestId, 0)

            if (user.is_phone_verified == "0") {
                navigateToPhoneNumberActivity()
            } else {
                navigateToHome()
            }

        })
    }

    private fun navigateToHome() {
        val intent = Intent()
        setResult(Activity.RESULT_OK, intent)
        finish()
    }


    private fun navigateToPhoneNumberActivity() {
        startActivityForResultWithDefaultAnimations(
            (Intent(this, EnterPhoneNumberActivity::class.java))
            , ConstantUtils.EMAIL_PHONE_NUMBER_REQUEST_CODE
        )
    }

    private fun onClickView() {


        ivBackEmail.throttleClicks().subscribe {
            finish()
        }.autoDispose(compositeDisposable)

        btnNextEmail.throttleClicks().subscribe {
            if (validateInputs()) {
                showProgress()
                registerSocialUser(
                    accountId,
                    accountName,
                    accountEmail,
                    accountProfile,
                    loginType
                )
            }
        }.autoDispose(compositeDisposable)
    }


    private fun validateInputs(): Boolean {
        if(etEmailEmail.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.emailAddressVal)
            showErrorMessage()
            return false
        } else {
            errorMessage = ""
            return true
        }
    }


    private fun setSpanToPolicyText() {
        val agreementSpan = SpannableStringBuilder()
        agreementSpan.append(resources.getString(R.string.clickingRegister) + "\n")
        agreementSpan.append(getTermSpan())
        agreementSpan.append(resources.getString(R.string.forApp))
        policyCheckRegister.text = agreementSpan
        policyCheckRegister.movementMethod = LinkMovementMethod.getInstance()
    }

    private fun getTermSpan() = getString(R.string.termsConditions).makeClickSpannable(
        {
            try {
                // val myIntent = Intent(Intent.ACTION_VIEW, Uri.parse( configuration.configurations.settingsMenuItems[2].data ))
                // startActivity(myIntent)
            } catch (e: ActivityNotFoundException) {
                e.printStackTrace()
            }
        },
        ContextCompat.getColor(this, R.color.colorBlue),
        false,
        false,
        resources.getString(R.string.termsConditions)
    )

    private fun showErrorMessage() {
        Toast.makeText(this, errorMessage, Toast.LENGTH_SHORT).show()
    }


    override fun onResume() {
        super.onResume()
        this.hideKeyboard()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            ConstantUtils.EMAIL_PHONE_NUMBER_REQUEST_CODE -> {
                if (data != null) {
                    navigateToHome()
                } else {
                    onBackPressed()
                }

            }
        }
    }
}