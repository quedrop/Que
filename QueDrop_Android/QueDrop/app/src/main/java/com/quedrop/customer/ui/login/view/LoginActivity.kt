package com.quedrop.customer.ui.login.view

import android.annotation.SuppressLint
import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Bundle
import android.text.SpannableStringBuilder
import android.text.method.HideReturnsTransformationMethod
import android.text.method.LinkMovementMethod
import android.text.method.PasswordTransformationMethod
import android.util.Log
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.facebook.CallbackManager
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.GraphRequest
import com.facebook.login.LoginManager
import com.facebook.login.LoginResult
import com.quedrop.customer.R
import com.quedrop.customer.api.authentication.LoggedInUserCache
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.QueDropApplication
import com.quedrop.customer.base.extentions.hideKeyboard
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.glide.makeClickSpannable
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.LoginRequest
import com.quedrop.customer.model.SocialRegisterRequest
import com.quedrop.customer.model.User
import com.quedrop.customer.socket.chat.ChatRepository
import com.quedrop.customer.ui.enterphonenumber.EnterPhoneNumberActivity
import com.quedrop.customer.ui.forgotpassword.ForgotPasswordActivity
import com.quedrop.customer.ui.login.viewModel.LoginViewModel
import com.quedrop.customer.ui.register.view.RegisterActivity
import com.quedrop.customer.ui.register.view.SocialRegisterEmailActivity
import com.quedrop.customer.ui.register.view.WebViewActivity
import com.quedrop.customer.utils.*
import com.quedrop.customer.utils.URLConstant.PRIVACY_URL
import com.quedrop.customer.utils.URLConstant.TEMS_AND_CONDI_URL
import com.quedrop.customer.utils.Utils.getTimeZone
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.tasks.Task
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import kotlinx.android.synthetic.main.activity_login.*
import javax.inject.Inject


class LoginActivity : BaseActivity() {
    private lateinit var loginViewModel: LoginViewModel
    private var errorMessage = ""
    private lateinit var mGoogleSignInClient: GoogleSignInClient
    private var callbackManager: CallbackManager? = null
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
        setContentView(R.layout.activity_login)
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyGuestId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyAccessKey)!!
        Utils.keyLatitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLatitude)!!
        Utils.keyLongitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLongitude)!!
        Utils.isPlaceOrderBoolean =
            SharedPrefsUtils.getBooleanPreference(
                applicationContext,
                KeysUtils.keyCheckVerify,
                false
            )

        checkUserForLogin()

    }


    private fun checkUserForLogin() {

        val userData = (SharedPrefsUtils.getModelPreferences(
            applicationContext,
            KeysUtils.keyUser,
            User::class.java
        )) as User?
        if (userData != null) {


//            if (userData.is_phone_verified == "0") {
////                if (Utils.isPlaceOrderBoolean) {
//                navigateToPhoneNumberActivity()
////                } else {
////                    navigateToHome()
////                }
//            } else {
            navigateToHome()
//            }
        } else {
            loginViewModel = LoginViewModel(appService, loggedInUserCache, chatRepository)
            observeViewModel()
            initializeGoogleSignInClient()
            setSpanToAgreementText()
            onClickView()
        }

    }

    private fun initializeGoogleSignInClient() {
        val gso =
            GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)//.requestIdToken("")
                .requestEmail()
                .build()
        mGoogleSignInClient = GoogleSignIn.getClient(this, gso)
    }


    private fun observeViewModel() {
        loginViewModel.userAvailableStatus.observe(this, Observer { isUserAvailable ->
            hideProgress()
            if (!isUserAvailable) {
                navigateToEmailActivity()
            }
        })

        loginViewModel.errorMessage.observe(this, Observer { error ->
            hideProgress()
            Toast.makeText(this, error, Toast.LENGTH_SHORT).show()
        })

        loginViewModel.userData.observe(this, Observer { user ->

            //zp changes
            socketHandler?.connectToSocket()

            hideProgress()
            SharedPrefsUtils.setIntegerPreference(
                applicationContext,
                KeysUtils.keyUserType,
                ConstantUtils.USER_TYPE_CUSTOMER
            )
            SharedPrefsUtils.setModelPreferences(applicationContext, KeysUtils.keyUser, user)
            SharedPrefsUtils.setIntegerPreference(
                applicationContext,
                KeysUtils.keyUserId,
                user?.user_id!!
            )
            SharedPrefsUtils.setIntegerPreference(applicationContext, KeysUtils.keyGuestId, 0)
            //SharedPrefsUtils.setIntegerPreference(applicationContext, KeysUtils.keySupplierStoreId, user.store_id)
//            if (user.is_phone_verified == "0") {
////                if (Utils.isPlaceOrderBoolean) {
//                navigateToPhoneNumberActivity()
////                } else {
////                    navigateToHome()
////                }
//            } else {
            navigateToHome()
//            }
        })

    }

    private fun googleLogin() {
        val signInIntent = mGoogleSignInClient.signInIntent
        Log.e("client", mGoogleSignInClient.toString())
        startActivityForResult(signInIntent, ConstantUtils.GOOGLE_LOGIN_REQUEST_CODE)
    }

    private fun fbLogin() {
        callbackManager = CallbackManager.Factory.create()

        LoginManager.getInstance().logInWithReadPermissions(
            this, listOf("email", "public_profile")
        )

        LoginManager.getInstance().registerCallback(callbackManager,
            object : FacebookCallback<LoginResult> {
                override fun onSuccess(loginResult: LoginResult) {
                    val request = GraphRequest.newMeRequest(
                        loginResult.accessToken
                    ) { data, _ ->
                        mGoogleSignInClient.signOut()
                        accountProfile = ""
//                        val email = data?.getString("email") ?: ""
                        accountId = data?.getString("id") ?: ""
                        accountName = data?.getString("name") ?: ""
                        if (data?.has("picture")!!) {
                            accountProfile =
                                data.getJSONObject("picture").getJSONObject("data").getString("url")
                        }
                        loginType = ConstantUtils.LOGIN_TYPE_FB
                        registerSocialUser(
                            accountId,
                            accountName,
                            accountEmail,
                            accountProfile,
                            ConstantUtils.LOGIN_TYPE_FB
                        )

                        Log.e("FB Login", accountName)

                    }

                    val bundle = Bundle()
                    bundle.putString("fields", "id,name,email,gender,birthday,picture.type(large)")
                    request.parameters = bundle
                    request.executeAsync()
                }

                override fun onCancel() {
                    //      Log.d("LoginActivity", "Facebook onCancel.")
                }

                override fun onError(error: FacebookException) {
                    Log.d("LoginActivity", error.toString())
                }
            })

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
            Utils.keyLatitude,
            "",
            Utils.getCompleteAddressString(
                this,
                Utils.keyLatitude.toDouble(),
                Utils.keyLongitude.toDouble()
            ),
            Utils.keyLongitude,
            Utils.seceretKey,
            getTimeZone(),
            Utils.accessKey
        )
    }


    private fun navigateToHome() {

//        val intent = Intent()
//        intent.flags =
//            Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
//        setResult(Activity.RESULT_OK, intent)
//        finish()

        val intent = Intent(this, CustomerMainActivity::class.java)

        intent.flags =
            Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        startActivityWithDefaultAnimations(intent)
        finish()
    }


    private fun navigateToPhoneNumberActivity() {
        val intent = Intent(this, EnterPhoneNumberActivity::class.java)
        startActivityForResultWithDefaultAnimations(
            intent,
            ConstantUtils.LOGIN_ENTER_PHONE_REQUEST_CODE
        )
    }


    @SuppressLint("NewApi")
    private fun onClickView() {

        ivCustomerBackClick.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        ivShowPassLogin.throttleClicks().subscribe {
            if (ivShowPassLogin.contentDescription == "Hide") {
                etPasswordLogin.transformationMethod = HideReturnsTransformationMethod.getInstance()
                ivShowPassLogin.contentDescription = "Show"
                ivShowPassLogin.setImageDrawable(
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.ic_eye_visible
                    )
                )
            } else {
                etPasswordLogin.transformationMethod = PasswordTransformationMethod.getInstance()
                ivShowPassLogin.contentDescription = "Hide"
                ivShowPassLogin.setImageDrawable(
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.ic_eye_hide
                    )
                )
            }

        }.autoDispose(compositeDisposable)

        btnLogin.throttleClicks().subscribe {

        }.autoDispose(compositeDisposable)

        btnLogin.throttleClicks().subscribe {
            if (validateInputs()) {
                showProgress()
                if (rememberCheckLogin.isChecked) {
                    SharedPrefsUtils.setStringPreference(
                        applicationContext,
                        KeysUtils.keyEmail,
                        etEmailLogin.text!!.trim().toString()
                    )
                    SharedPrefsUtils.setStringPreference(
                        applicationContext,
                        KeysUtils.keyPassword,
                        etPasswordLogin.text!!.trim().toString()
                    )

                } else {
                    SharedPrefsUtils.setStringPreference(
                        applicationContext,
                        KeysUtils.keyEmail, ""
                    )
                    SharedPrefsUtils.setStringPreference(
                        applicationContext,
                        KeysUtils.keyPassword,
                        ""
                    )
                }
                loginViewModel.loginUser(getLoginRequest())

            }
        }.autoDispose(compositeDisposable)

        tvForgotPassLogin.throttleClicks().subscribe {

            startActivityForResultWithDefaultAnimations(
                (Intent(this, ForgotPasswordActivity::class.java)),
                ConstantUtils.LOGIN_FORGOT_PASS_REQUEST_CODE
            )
        }.autoDispose(compositeDisposable)

        tvGoogleLogin.throttleClicks().subscribe {
            googleLogin()
        }.autoDispose(compositeDisposable)

        tvFbLogin.throttleClicks().subscribe {
            fbLogin()
        }.autoDispose(compositeDisposable)

        if (SharedPrefsUtils.getStringPreference(
                applicationContext,
                KeysUtils.keyEmail
            )!!.isNotEmpty() && SharedPrefsUtils.getStringPreference(
                applicationContext,
                KeysUtils.keyPassword
            )!!.isNotEmpty()
        ) {
            rememberCheckLogin.isChecked = true
            etEmailLogin.setText(
                SharedPrefsUtils.getStringPreference(
                    applicationContext,
                    KeysUtils.keyEmail
                )
            )
            etPasswordLogin.setText(
                SharedPrefsUtils.getStringPreference(
                    applicationContext,
                    KeysUtils.keyPassword
                )
            )
        }

    }


    private fun getLoginRequest(): LoginRequest {
        return LoginRequest(
            Utils.seceretKey,
            Utils.accessKey,
            etPasswordLogin.text!!.trim().toString(),
            etEmailLogin.text!!.trim().toString(),
            ConstantUtils.DEVICE_TYPE,
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyDeviceToken)!!,
            getTimeZone(),
            Utils.guestId,
            ConstantUtils.KEY_LOGIN_AS
        )

    }


    private fun validateInputs(): Boolean {
        if (etEmailLogin.text!!.trim().isEmpty()) {
            errorMessage = "Enter Email Address"
            showErrorMessage()
            return false
        } else if (!ValidationUtils.isEmailValid(etEmailLogin.text!!.trim().toString())) {
            errorMessage = "Enter Valid Email Address"
            showErrorMessage()
            return false
        } else if (etPasswordLogin.text!!.trim().isEmpty()) {
            errorMessage = "Enter Password"
            showErrorMessage()
            return false
        } else {
            errorMessage = ""
            return true
        }
    }

    private fun showErrorMessage() {
        Toast.makeText(this, errorMessage, Toast.LENGTH_SHORT).show()
    }

    private fun setSpanToAgreementText() {

        val agreementSpan = SpannableStringBuilder()
        agreementSpan.append(resources.getString(R.string.continueLogin) + "\n")
        agreementSpan.append(getTermSpan())
        agreementSpan.append(resources.getString(R.string.and))
        agreementSpan.append(getPrivacySpan())

        tvTermsLogin.text = agreementSpan
        tvTermsLogin.movementMethod = LinkMovementMethod.getInstance()

        val registerSpan = SpannableStringBuilder()
        registerSpan.append(resources.getString(R.string.notAccount))
        registerSpan.append(" ")
        registerSpan.append(getRegisterSpan())

        tvNotAccountLogin.text = registerSpan
        tvNotAccountLogin.movementMethod = LinkMovementMethod.getInstance()


    }

    private fun getPrivacySpan() = getString(R.string.policyLogin).makeClickSpannable(
        {
            try {
                val myIntent = Intent(applicationContext, WebViewActivity::class.java)
                myIntent.putExtra(KeysUtils.keyLink, PRIVACY_URL)
                myIntent.putExtra(KeysUtils.isPrivacyPolicy, true)
                myIntent.putExtra(KeysUtils.isTermsAndCondition, false)
                startActivityWithDefaultAnimations(myIntent)
            } catch (e: ActivityNotFoundException) {
                e.printStackTrace()
            }
        },
        ContextCompat.getColor(this, R.color.colorBlueText),
        false,
        false,
        resources.getString(R.string.policyLogin),
        null
    )


    private fun getTermSpan() = getString(R.string.termsOfUse).makeClickSpannable(
        {
            try {
                // val myIntent = Intent(Intent.ACTION_VIEW, Uri.parse( configuration.configurations.settingsMenuItems[2].data ))
                // startActivity(myIntent)
                val myIntent = Intent(applicationContext, WebViewActivity::class.java)
                myIntent.putExtra(
                    KeysUtils.keyLink,
                    TEMS_AND_CONDI_URL
                )

                myIntent.putExtra(KeysUtils.isPrivacyPolicy, false)
                myIntent.putExtra(KeysUtils.isTermsAndCondition, true)
                startActivity(myIntent)
            } catch (e: ActivityNotFoundException) {

                e.printStackTrace()
            }
        },
        ContextCompat.getColor(this, R.color.colorBlueText),
        false,
        false,
        resources.getString(R.string.termsOfUse)
    )

    private fun getRegisterSpan() = getString(R.string.register).makeClickSpannable(
        {
            try {
                val intent = Intent(this, RegisterActivity::class.java)
                startActivityForResultWithDefaultAnimations(
                    intent,
                    ConstantUtils.LOGIN_REGISTER_REQUEST_CODE
                )
                intent.putExtra("fromSupplierLogin", true)
            } catch (e: ActivityNotFoundException) {
                e.printStackTrace()
            }
        },
        ContextCompat.getColor(this, R.color.colorBlueText),
        true,
        false,
        resources.getString(R.string.register),
        null
    )

    private fun handleSignInResult(completedTask: Task<GoogleSignInAccount>) {
        try {
            val result = completedTask.getResult(ApiException::class.java)
            result?.let { account ->
                accountId = account.id ?: ""
                accountEmail = account.email ?: ""
                accountName = account.displayName ?: ""
                accountProfile = account.photoUrl?.toString() ?: ""
                loginType = ConstantUtils.LOGIN_TYPE_GOOGLE
                registerSocialUser(
                    accountId,
                    accountName,
                    accountEmail,
                    accountProfile,
                    ConstantUtils.LOGIN_TYPE_GOOGLE
                )
//               navigateToEmailActivity(accountId,email,name,profileImage,ConstantUtils.LOGIN_TYPE_GOOGLE)

            }
        } catch (e: ApiException) {
            Log.e("GOOGLE", "signInResult:failed code=" + e.statusCode)
        }
    }

    private fun navigateToEmailActivity() {

        var bundle = Bundle()
        var intent = Intent(this, SocialRegisterEmailActivity::class.java)
        bundle.putString(KeysUtils.keyAccountId, accountId)
        bundle.putString(KeysUtils.keyAccountEmail, accountEmail)
        bundle.putString(KeysUtils.keyAccountName, accountName)
        bundle.putString(KeysUtils.keyAccountProfile, accountProfile)
        bundle.putInt(KeysUtils.keyAccountLoginType, loginType)
        intent.putExtras(bundle)
        startActivityForResultWithDefaultAnimations(intent, ConstantUtils.LOGIN_SOCIAL_REQUEST_CODE)

    }


    override fun onResume() {
        super.onResume()
        parentScroll.smoothScrollTo(0, 0)
        this.hideKeyboard()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            ConstantUtils.GOOGLE_LOGIN_REQUEST_CODE -> {
                val task = GoogleSignIn.getSignedInAccountFromIntent(data)
                handleSignInResult(task)
            }

            ConstantUtils.LOGIN_ENTER_PHONE_REQUEST_CODE -> {
                if (data != null) {
                    navigateToHome()
                }
            }
            ConstantUtils.LOGIN_REGISTER_REQUEST_CODE -> {
                if (data != null) {
                    navigateToHome()
                }

            }
            ConstantUtils.LOGIN_SOCIAL_REQUEST_CODE -> {
                if (data != null) {
                    navigateToHome()
                }
            }
            ConstantUtils.LOGIN_FORGOT_PASS_REQUEST_CODE -> {
                if (data != null) {

                }
            }

            else -> {
                callbackManager?.onActivityResult(requestCode, resultCode, data)

            }
        }
    }


    override fun onBackPressed() {
        finish()
    }
}
