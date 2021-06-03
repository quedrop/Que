package com.quedrop.customer.ui.supplier.suppplierLogin

import android.annotation.SuppressLint
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
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.tasks.Task
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
import com.quedrop.customer.model.TokenRequest
import com.quedrop.customer.model.User
import com.quedrop.customer.socket.chat.ChatRepository
import com.quedrop.customer.ui.forgotpassword.ForgotPasswordActivity
import com.quedrop.customer.ui.login.viewModel.LoginViewModel
import com.quedrop.customer.ui.register.view.RegisterActivity
import com.quedrop.customer.ui.register.view.WebViewActivity
import com.quedrop.customer.ui.supplier.HomeSupplierActivity
import com.quedrop.customer.ui.supplier.store.SupplierEditStoreProfileActivity
import com.quedrop.customer.ui.supplier.supplierverifyphone.SupplierEnterPhoneNumberActivity
import com.quedrop.customer.utils.*
import com.quedrop.customer.utils.URLConstant.PRIVACY_URL
import com.quedrop.customer.utils.URLConstant.TEMS_AND_CONDI_URL
import com.quedrop.customer.utils.Utils.getTimeZone
import kotlinx.android.synthetic.main.activity_login.btnLogin
import kotlinx.android.synthetic.main.activity_login.etEmailLogin
import kotlinx.android.synthetic.main.activity_login.etPasswordLogin
import kotlinx.android.synthetic.main.activity_login.ivShowPassLogin
import kotlinx.android.synthetic.main.activity_login.parentScroll
import kotlinx.android.synthetic.main.activity_login.rememberCheckLogin
import kotlinx.android.synthetic.main.activity_login.tvForgotPassLogin
import kotlinx.android.synthetic.main.activity_login.tvTermsLogin
import kotlinx.android.synthetic.main.activity_supplier_login.*
import javax.inject.Inject

class SupplierLoginActivity : BaseActivity() {

    @Inject
    lateinit var loggedInUserCache: LoggedInUserCache

    @Inject
    lateinit var chatRepository: ChatRepository


    // private lateinit var supplierLoginViewModel: SupplierLoginViewModel
    private lateinit var loginViewModel: LoginViewModel

    private var errorMessage = ""
    var accountId: String = ""
    var accountEmail: String = ""
    var accountName: String = ""
    var accountProfile: String = ""
    var loginType: Int = 1
    var isFromLocalEarningNotification = false

    private var remoteMessage: String? = null
    private lateinit var mGoogleSignInClient: GoogleSignInClient
    private var callbackManager: CallbackManager? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_supplier_login)

        QueDropApplication.component.inject(this)

        //zp changes
        SharedPrefsUtils.setIntegerPreference(
            mcontext,
            KeysUtils.PREF_KEY_IS_REVOKE,
            0
        )

        intent.getStringExtra(KeysUtils.KeyRemoteMessage).let {
            if (it != null) {
                remoteMessage = it
            }
        }
        intent.getBooleanExtra(KeysUtils.isSuplplierWeeklyEarning, false).let {
            isFromLocalEarningNotification = it
        }


        Utils.seceretKey = SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keySecretKey)!!
        Utils.Supplier.supplierAccessKey = SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyAccessKey)!!
        Utils.Supplier.supplierStoredCreated = SharedPrefsUtils.getBooleanPreference(applicationContext, KeysUtils.KeyStoreCreated, false)

        initializeGoogleSignInClient()
        checkUserForLogin()

    }

    private fun initializeGoogleSignInClient() {
        val gso =
            GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)//.requestIdToken("")
                .requestEmail()
                .build()
        mGoogleSignInClient = GoogleSignIn.getClient(this, gso)
    }


    private fun checkUserForLogin() {

        val userData = (SharedPrefsUtils.getModelPreferences(applicationContext, KeysUtils.KeySupplierUser, User::class.java)) as User?

        if (userData != null) {

            when {
                userData.is_phone_verified == "0" -> {
                    navigateToPhoneNumberActivity()
                }
                Utils.Supplier.supplierStoredCreated -> {
                    navigateToCreateStoreActivity()
                }
                else -> {
                    navigateToHome()
                }
            }
        } else {
            // supplierLoginViewModel = SupplierLoginViewModel(appService)
            loginViewModel = LoginViewModel(appService, loggedInUserCache, chatRepository)

            observeViewModel()
            getTokenIfBlank()
            setSpanToAgreementText()
            onClickView()
        }

    }


    private fun observeViewModel() {

//        supplierLoginViewModel.tokenData.observe(this, Observer { newToken ->
//            SharedPrefsUtils.setStringPreference(
//                applicationContext,
//                KeysUtils.keySecretKey,
//                newToken
//            )
//        })

        loginViewModel.errorMessage.observe(this, Observer { error ->
            hideProgress()
            Toast.makeText(this, error, Toast.LENGTH_SHORT).show()
        })

        loginViewModel.userData.observe(this, Observer { user ->

            hideProgress()
            SharedPrefsUtils.setModelPreferences(
                applicationContext,
                KeysUtils.KeySupplierUser,
                user
            )
            SharedPrefsUtils.setIntegerPreference(
                applicationContext,
                KeysUtils.KeyUserSupplierId,
                user?.user_id!!
            )
            SharedPrefsUtils.setIntegerPreference(
                applicationContext,
                KeysUtils.keySupplierStoreId,
                user.store_id
            )

            SharedPrefsUtils.setIntegerPreference(
                applicationContext,
                KeysUtils.keyUserType,
                ConstantUtils.USER_TYPE_SUPPLIER
            )

            //if (user.is_phone_verified == "0") {
//                navigateToPhoneNumberActivity()
            // } else {
            navigateToHome()
            // }
        })

    }


    private fun navigateToHome() {
        var intent = Intent(this, HomeSupplierActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP
        //setResult(Activity.RESULT_OK, intent)
        intent.putExtra(KeysUtils.KeyRemoteMessage, remoteMessage)
        intent.putExtra(KeysUtils.isSuplplierWeeklyEarning, isFromLocalEarningNotification)
        startActivityWithDefaultAnimations(intent)
        finish()
    }


    private fun navigateToPhoneNumberActivity() {
        var intent = Intent(this, SupplierEnterPhoneNumberActivity::class.java)
        startActivityForResultWithDefaultAnimations(
            intent,
            ConstantUtils.LOGIN_ENTER_PHONE_REQUEST_CODE
        )
    }

    private fun navigateToCreateStoreActivity() {
        var intent = Intent(this, SupplierEditStoreProfileActivity::class.java)
        startActivityForResultWithDefaultAnimations(
            intent,
            ConstantUtils.LOGIN_ENTER_PHONE_REQUEST_CODE
        )
    }

    private fun getTokenRequest(): TokenRequest {
        return TokenRequest(Utils.accessKey)
    }

    private fun getTokenIfBlank() {
        if (SharedPrefsUtils.getStringPreference(
                applicationContext,
                KeysUtils.KeySupplierAccessKey
            )!!.isEmpty()
        ) {
            loginViewModel.getNewTokenRequestApi(getTokenRequest())
        }
    }

    @SuppressLint("NewApi")
    private fun onClickView() {

        tvGoogleSupplierLogin.throttleClicks().subscribe {
            googleLogin()
        }.autoDispose(compositeDisposable)

        tvFbSupplierLogin.throttleClicks().subscribe {
            fbLogin()
        }.autoDispose(compositeDisposable)

        ivSupplierBackClick.throttleClicks().subscribe {
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

            startActivityWithDefaultAnimations(Intent(this, SupplierLoginActivity::class.java))
            if (validateInputs()) {
                showProgress()
                if (rememberCheckLogin.isChecked) {
                    SharedPrefsUtils.setStringPreference(
                        applicationContext,
                        KeysUtils.KeySupplierEmail,
                        etEmailLogin.text!!.trim().toString()
                    )
                    SharedPrefsUtils.setStringPreference(
                        applicationContext,
                        KeysUtils.KeySupplierPassword,
                        etPasswordLogin.text!!.trim().toString()
                    )

                } else {
                    SharedPrefsUtils.setStringPreference(
                        applicationContext,
                        KeysUtils.KeySupplierEmail,
                        ""
                    )
                    SharedPrefsUtils.setStringPreference(
                        applicationContext,
                        KeysUtils.KeySupplierPassword,
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

        if (SharedPrefsUtils.getStringPreference(
                applicationContext,
                KeysUtils.KeySupplierEmail
            )!!.isNotEmpty() && SharedPrefsUtils.getStringPreference(
                applicationContext,
                KeysUtils.KeySupplierPassword
            )!!.isNotEmpty()
        ) {
            rememberCheckLogin.isChecked = true
            etEmailLogin.setText(
                SharedPrefsUtils.getStringPreference(
                    applicationContext,
                    KeysUtils.KeySupplierEmail
                )
            )
            etPasswordLogin.setText(
                SharedPrefsUtils.getStringPreference(
                    applicationContext,
                    KeysUtils.KeySupplierPassword
                )
            )
        }


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


    private fun getLoginRequest(): LoginRequest {
        return LoginRequest(
            Utils.seceretKey,
            Utils.Supplier.supplierAccessKey,
            etPasswordLogin.text!!.trim().toString(),
            etEmailLogin.text!!.trim().toString(),
            ConstantUtils.DEVICE_TYPE,
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyDeviceToken)!!,
            getTimeZone(),
            0,
            ConstantUtils.KEY_LOGIN_AS_SUPPLIER
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

        tvNotAccountSupplierLogin.text = registerSpan
        tvNotAccountSupplierLogin.movementMethod = LinkMovementMethod.getInstance()

    }


    private fun getPrivacySpan() = getString(R.string.policyLogin).makeClickSpannable(
        {
            try {
                //  val myIntent = Intent(Intent.ACTION_VIEW, Uri.parse( configuration.configurations.settingsMenuItems[3].data ))
                //  startActivity(myIntent)
                val myIntent = Intent(applicationContext, WebViewActivity::class.java)
                myIntent.putExtra(KeysUtils.keyLink, PRIVACY_URL)
                myIntent.putExtra(KeysUtils.isPrivacyPolicy, true)
                myIntent.putExtra(KeysUtils.isTermsAndCondition, false)
                startActivity(myIntent)
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

    private fun getRegisterSpan() = getString(R.string.register).makeClickSpannable(
        {
            try {
                val intent = Intent(this, RegisterActivity::class.java)
                intent.putExtra("fromSupplierRegister", true)
                startActivityForResultWithDefaultAnimations(
                    intent,
                    ConstantUtils.LOGIN_REGISTER_REQUEST_CODE
                )
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


    override fun onResume() {
        super.onResume()
        parentScroll.smoothScrollTo(0, 0)
        this.hideKeyboard()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {

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
            ConstantUtils.GOOGLE_LOGIN_REQUEST_CODE -> {
                val task = GoogleSignIn.getSignedInAccountFromIntent(data)
                handleSignInResult(task)
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

