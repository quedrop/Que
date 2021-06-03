package com.quedrop.driver.ui.login.view

import android.annotation.SuppressLint
import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Bundle
import android.text.SpannableStringBuilder
import android.text.method.HideReturnsTransformationMethod
import android.text.method.LinkMovementMethod
import android.text.method.PasswordTransformationMethod
import android.util.Log
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.facebook.CallbackManager
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.GraphRequest
import com.facebook.login.LoginManager
import com.facebook.login.LoginResult
import com.quedrop.driver.R
import com.quedrop.driver.api.authentication.LoggedInUserCache
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.base.QueDropDriverApplication
import com.quedrop.driver.base.extentions.hideKeyboard
import com.quedrop.driver.base.extentions.makeClickSpannable
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.User
import com.quedrop.driver.service.request.LoginRequest
import com.quedrop.driver.service.request.SocialRegisterRequest
import com.quedrop.driver.socket.chat.ChatRepository
import com.quedrop.driver.ui.enterphonenumber.EnterPhoneNumberActivity
import com.quedrop.driver.ui.forgotpassword.ForgotPasswordActivity
import com.quedrop.driver.ui.identityverification.IdentityVerificationActivity
import com.quedrop.driver.ui.login.viewModel.LoginViewModel
import com.quedrop.driver.ui.mainActivity.view.MainActivity
import com.quedrop.driver.ui.register.view.RegisterActivity
import com.quedrop.driver.ui.register.view.SocialRegisterEmailActivity
import com.quedrop.driver.ui.register.view.WebViewActivity
import com.quedrop.driver.utils.*
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.tasks.Task
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

    var remoteMessage: String? = ""
    @Inject
    lateinit var loggedInUserCache: LoggedInUserCache
    @Inject
    lateinit var chatRepository: ChatRepository

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        QueDropDriverApplication.component.inject(this)
        setContentView(R.layout.activity_login)

        if (intent != null) {
            remoteMessage = intent.getStringExtra("remote_message")
        }

        checkUserForLogin()
    }

    private fun checkUserForLogin() {
        val userData =
            (SharedPreferenceUtils.getModelPreferences(KEY_USER, User::class.java)) as User?
        if (userData != null) {
            globalUserId = userData.userId!!
            if (userData.isPhoneVerified == 0) {
                navigateToPhoneNumberActivity()
            } else if (userData.isIdentityDetailUploaded == 0) {
                navigateToIdentityScreen()
            } else {
                navigateToHome()
            }
        } else {
            loginViewModel = LoginViewModel(appService, loggedInUserCache, chatRepository)
            observeViewModel()
            getTokenIfBlank()
            initializeGoogleSignInClient()
            setSpanToAgreementText()
            onClickView()
        }

    }

    private fun initializeGoogleSignInClient() {
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .build()
        mGoogleSignInClient = GoogleSignIn.getClient(this, gso)
    }


    private fun observeViewModel() {
        loginViewModel.userAvailableStatus.observe(this, Observer { isUserAvailable ->
            hideProgress()
            if (!isUserAvailable) {
                navigateToAdditionalDetails()
            }
        })

        loginViewModel.tokenData.observe(this, Observer { newToken ->
            SharedPreferenceUtils.setString(KEY_TOKEN, newToken)
        })

        loginViewModel.errorMessage.observe(this, Observer { error ->
            hideProgress()
            showAlertMessage(this, error)
        })

        loginViewModel.userData.observe(this, Observer { user ->
            hideProgress()
            globalUserId = user.userId!!
            SharedPreferenceUtils.setModelPreferences(KEY_USER, user)
            SharedPreferenceUtils.setInt(KEY_USERID, user.userId!!)
            SharedPreferenceUtils.setString(KEY_LATITUDE, user.latitude)
            SharedPreferenceUtils.setString(KEY_LONGITUDE, user.longitude)
            if (user.isPhoneVerified == 0) {
                navigateToPhoneNumberActivity()
            } else if (user.isIdentityDetailUploaded == 0) {
                navigateToIdentityScreen()
            } else {
                navigateToHome()
            }
        })
    }

    private fun navigateToAdditionalDetails() {

        val additionalIntent = Intent(this, SocialRegisterEmailActivity::class.java)
        additionalIntent.putExtra("accountId", accountId)
        additionalIntent.putExtra("accountEmail", accountEmail)
        additionalIntent.putExtra("accountName", accountName)
        additionalIntent.putExtra("accountProfile", accountProfile)
        additionalIntent.putExtra("loginType", loginType)

        startActivityWithDefaultAnimations(additionalIntent)

    }

    private fun googleLogin() {
        val signInIntent = mGoogleSignInClient.signInIntent
        startActivityForResult(signInIntent, GOOGLE_LOGIN_REQUEST_CODE)
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
                        var profileImage = ""
                        val email = data?.getString("email") ?: ""
                        val id = data?.getString("id") ?: ""
                        val name = data?.getString("name") ?: ""
                        if (data?.has("picture")!!) {
                            profileImage =
                                data.getJSONObject("picture").getJSONObject("data").getString("url")
                        }

                        accountId = id
                        accountEmail = email
                        accountName = name
                        accountProfile = profileImage
                        loginType = LOGIN_TYPE_FB
                        registerSocialUser(id, name, email, profileImage, LOGIN_TYPE_FB)
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


    private fun navigateToHome() {

        val intent = Intent(this, MainActivity::class.java)
        intent.putExtra("remote_message", remoteMessage)
        startActivityWithDefaultAnimations(intent)

        finish()
    }

    private fun navigateToIdentityScreen() {
        val intent = Intent(this, IdentityVerificationActivity::class.java)
        startActivityWithDefaultAnimations(intent)

        finish()
    }


    private fun navigateToPhoneNumberActivity() {
        startActivityWithDefaultAnimations(Intent(this, EnterPhoneNumberActivity::class.java))
        finish()
    }

    private fun getTokenIfBlank() {
        if (SharedPreferenceUtils.getString(KEY_TOKEN).isEmpty()) {
            loginViewModel.getNewToken()
        }
    }

    @SuppressLint("NewApi")
    private fun onClickView() {

        ivShowPass.throttleClicks().subscribe {
            if (ivShowPass.contentDescription == "Hide") {
                etPassword.transformationMethod = HideReturnsTransformationMethod.getInstance()
                ivShowPass.contentDescription = "Show"
                ivShowPass.setImageDrawable(
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.ic_eye_visible
                    )
                )
            } else {
                etPassword.transformationMethod = PasswordTransformationMethod.getInstance()
                ivShowPass.contentDescription = "Hide"
                ivShowPass.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.ic_eye_hide))
            }

        }.autoDispose(compositeDisposable)


        btnLogin.throttleClicks().subscribe {
            if (validateInputs()) {
                showProgress()
                if (rememberCheck.isChecked) {
                    SharedPreferenceUtils.setString(KEY_EMAIL, etEmail.text!!.trim().toString())
                    SharedPreferenceUtils.setString(
                        KEY_PASSWORD,
                        etPassword.text!!.trim().toString()
                    )
                } else {
                    SharedPreferenceUtils.setString(KEY_EMAIL, "")
                    SharedPreferenceUtils.setString(KEY_PASSWORD, "")
                }
                if (Utility.isNetworkAvailable(this)) {
                    loginViewModel.loginUser(getLoginRequest())
                } else {
                    hideProgress()
                    showAlertMessage(this, getString(R.string.no_internet_connection))
                }

            }
        }.autoDispose(compositeDisposable)

        tvForgotPass.throttleClicks().subscribe {
            startActivityWithDefaultAnimations(Intent(this, ForgotPasswordActivity::class.java))
        }.autoDispose(compositeDisposable)

        tvGoogleLogin.throttleClicks().subscribe {
            googleLogin()
        }.autoDispose(compositeDisposable)

        tvFbLogin.throttleClicks().subscribe {
            fbLogin()
        }.autoDispose(compositeDisposable)

        if (SharedPreferenceUtils.getString(KEY_EMAIL).isNotEmpty() && SharedPreferenceUtils.getString(
                KEY_PASSWORD
            ).isNotEmpty()
        ) {
            etEmail.setText(SharedPreferenceUtils.getString(KEY_EMAIL))
            etPassword.setText(SharedPreferenceUtils.getString(KEY_PASSWORD))
            rememberCheck.isChecked = true
        }

    }

    private fun getLoginRequest(): LoginRequest {
        return LoginRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            etPassword.text!!.trim().toString(),
            etEmail.text!!.trim().toString(),
            DEVICE_TYPE,
            KEY_LOGIN_TYPE_AS,
            SharedPreferenceUtils.getString(DEVICE_TOKEN),
            getTimeZone()
        )

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
        } else if (etPassword.text!!.trim().isEmpty()) {
            errorMessage = "Enter Password"
            showErrorMessage()
            return false
        } else {
            errorMessage = ""
            return true
        }
    }

    private fun showErrorMessage() {
        showInfoMessage(this, errorMessage)
    }

    private fun setSpanToAgreementText() {

        val agreementSpan = SpannableStringBuilder()
        agreementSpan.append(resources.getString(R.string.continueLogin) + "\n")
        agreementSpan.append(getTermSpan())
        agreementSpan.append(resources.getString(R.string.and))
        agreementSpan.append(getPrivacySpan())

        tvTerms.text = agreementSpan
        tvTerms.movementMethod = LinkMovementMethod.getInstance()

        val registerSpan = SpannableStringBuilder()
        registerSpan.append(resources.getString(R.string.notAccount))
        registerSpan.append(" ")
        registerSpan.append(getRegisterSpan())

        tvRegister.text = registerSpan
        tvRegister.movementMethod = LinkMovementMethod.getInstance()


    }

    private fun getPrivacySpan() = getString(R.string.policyLogin).makeClickSpannable(
        {
            try {
                val myIntent = Intent(applicationContext, WebViewActivity::class.java)
                myIntent.putExtra("Link", URLConstant.PROVACY_URL)
                myIntent.putExtra("isPrivacyPolicy", true)
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
                val myIntent = Intent(applicationContext, WebViewActivity::class.java)
                myIntent.putExtra("Link", URLConstant.TEMS_AND_CONDI_URL)
                startActivityWithDefaultAnimations(myIntent)
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
                startActivityWithDefaultAnimations(intent)
            } catch (e: ActivityNotFoundException) {
                e.printStackTrace()
            }
        },
        ContextCompat.getColor(this, R.color.colorBlueText),
        true,
        false,
        "Register",
        null
    )

    private fun handleSignInResult(completedTask: Task<GoogleSignInAccount>) {
        try {
            val result = completedTask.getResult(ApiException::class.java)
            result?.let { account ->
                val id = account.id ?: ""
                val email = account.email ?: ""
                val name = account.displayName ?: ""
                val profileImage = account.photoUrl?.toString() ?: ""

                accountId = id
                accountEmail = email
                accountName = name
                accountProfile = profileImage
                loginType = LOGIN_TYPE_GOOGLE
                registerSocialUser(id, name, email, profileImage, LOGIN_TYPE_GOOGLE)

            }
        } catch (e: ApiException) {
            Log.e("GOOGLE", "signInResult:failed code=" + e.statusCode)
        }
    }

    private fun registerSocialUser(
        accountId: String,
        name: String,
        email: String,
        profileImage: String,
        loginType: Int
    ) {
        showProgress()
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
            "",
            1
        )
    }

    override fun onResume() {
        super.onResume()
        parentScroll.smoothScrollTo(0, 0)
        this.hideKeyboard()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            GOOGLE_LOGIN_REQUEST_CODE -> {
                val task = GoogleSignIn.getSignedInAccountFromIntent(data)
                handleSignInResult(task)
            }
            else -> {
                callbackManager?.onActivityResult(requestCode, resultCode, data)

            }
        }
    }


}
