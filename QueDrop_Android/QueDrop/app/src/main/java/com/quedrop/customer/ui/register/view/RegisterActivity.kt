package com.quedrop.customer.ui.register.view

import android.Manifest
import android.app.Activity
import android.app.Dialog
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.text.Editable
import android.text.SpannableStringBuilder
import android.text.TextWatcher
import android.text.method.HideReturnsTransformationMethod
import android.text.method.LinkMovementMethod
import android.text.method.PasswordTransformationMethod
import android.widget.ImageView
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.api.authentication.LoggedInUserCache
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.QueDropApplication
import com.quedrop.customer.base.extentions.hideKeyboard
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.glide.makeClickSpannable
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.CheckForValidReferralCodeRequest
import com.quedrop.customer.model.Register
import com.quedrop.customer.socket.chat.ChatRepository
import com.quedrop.customer.ui.enterphonenumber.EnterPhoneNumberActivity
import com.quedrop.customer.ui.register.viewModel.RegisterViewModel
import com.quedrop.customer.ui.supplier.supplierverifyphone.SupplierEnterPhoneNumberActivity
import com.quedrop.customer.utils.*
import com.quedrop.customer.utils.BitmapHelper.getImageUri
import com.quedrop.customer.utils.URLConstant.TEMS_AND_CONDI_URL
import com.quedrop.customer.utils.Utils.getRealPathFromURI
import com.quedrop.customer.utils.Utils.getTimeZone
import kotlinx.android.synthetic.main.activity_register.*
import kotlinx.android.synthetic.main.activity_toolbar.*
import okhttp3.MediaType
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.File
import javax.inject.Inject

class RegisterActivity : BaseActivity() {
    private var errorMessage = ""
    private lateinit var registerViewModel: RegisterViewModel

    @Inject
    lateinit var loggedInUserCache: LoggedInUserCache

    @Inject
    lateinit var chatRepository: ChatRepository

    var imagePath: String = ""
    val MULTIPLE_PERMISSIONS = 10
    val PERMISSION_READ_EXTERNAL_STORAGE = 12
    var REQUEST_PICK_IMAGE = 200
    var REQUEST_CAMERA = 201

    var fromSupplierRegister: Boolean = false


    private var permissions = arrayOf<String>(

        Manifest.permission.CAMERA,
        Manifest.permission.WRITE_EXTERNAL_STORAGE
    )


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        QueDropApplication.component.inject(this)
        setContentView(R.layout.activity_register)
        registerViewModel = RegisterViewModel(appService, loggedInUserCache, chatRepository)

        if (intent.hasExtra("fromSupplierRegister")) {
            fromSupplierRegister = intent.getBooleanExtra("fromSupplierRegister", false)
        }

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

        setUpToolbar()
        observeViewModel()
        setSpanToPolicyText()
        onClickView()

        etReferralRegister.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(p0: Editable?) {
            }

            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
            }

            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
                if (p0?.length?.equals(8)!!) {
                    checkForValidReferralCode(p0.toString())
                }
            }
        })
    }

    private fun setUpToolbar() {
        tvTitle.text = getString(R.string.register)

        ivBack.throttleClicks().subscribe {
            finish()
        }.autoDispose(compositeDisposable)
    }


    private fun observeViewModel() {

        registerViewModel.errorMessage.observe(this, Observer { error ->
            hideProgress()
            Toast.makeText(this, error, Toast.LENGTH_SHORT).show()
        })

        registerViewModel.userData.observe(this, Observer { user ->
            hideProgress()
            if (fromSupplierRegister) {
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

                SharedPrefsUtils.setBooleanPreference(
                    applicationContext,
                    KeysUtils.KeyStoreCreated,
                    true
                )

            } else {
                SharedPrefsUtils.setModelPreferences(applicationContext, KeysUtils.keyUser, user)
                SharedPrefsUtils.setIntegerPreference(
                    applicationContext,
                    KeysUtils.keyUserId,
                    user?.user_id!!
                )
                SharedPrefsUtils.setIntegerPreference(applicationContext, KeysUtils.keyGuestId, 0)
            }

            navigateToPhoneNumberActivity()

        })

        registerViewModel.referralCodeResponse.observe(this, Observer {
            hideProgress()
            Toast.makeText(this, it, Toast.LENGTH_SHORT).show()
        })
    }


    private fun onClickView() {

        ivPickProfile.throttleClicks().subscribe {
            dialogChoosePic()
        }.autoDispose(compositeDisposable)

        ivShowPassRegister.throttleClicks().subscribe {
            if (ivShowPassRegister.contentDescription == "Hide") {
                etPasswordRegister.transformationMethod =
                    HideReturnsTransformationMethod.getInstance()
                ivShowPassRegister.contentDescription = "Show"
                ivShowPassRegister.setImageDrawable(
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.ic_eye_visible
                    )
                )
            } else {
                etPasswordRegister.transformationMethod = PasswordTransformationMethod.getInstance()
                ivShowPassRegister.contentDescription = "Hide"
                ivShowPassRegister.setImageDrawable(
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.ic_eye_hide
                    )
                )
            }

        }.autoDispose(compositeDisposable)

        ivShowConfirmPassRegister.throttleClicks().subscribe {
            if (ivShowConfirmPassRegister.contentDescription == "Hide") {
                etConfirmPasswordRegister.transformationMethod =
                    HideReturnsTransformationMethod.getInstance()
                ivShowConfirmPassRegister.contentDescription = "Show"
                ivShowConfirmPassRegister.setImageDrawable(
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.ic_eye_visible
                    )
                )
            } else {
                etConfirmPasswordRegister.transformationMethod =
                    PasswordTransformationMethod.getInstance()
                ivShowConfirmPassRegister.contentDescription = "Hide"
                ivShowConfirmPassRegister.setImageDrawable(
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.ic_eye_hide
                    )
                )
            }

        }.autoDispose(compositeDisposable)

        btnNextRegister.throttleClicks().subscribe {
            if (validateInputs()) {
                showProgress()
                registerViewModel.registerUser(getRegisterRequest())
            }
        }.autoDispose(compositeDisposable)
    }

    private fun getRegisterRequest(): Register {
        if (fromSupplierRegister) {
            Utils.guestId = 0
        }
        return Register(
            getStringRequestBody(Utils.seceretKey),
            getStringRequestBody(Utils.accessKey),
            updateMultiPartImage(imagePath),
            getStringRequestBody(Utils.guestId.toString()),
            getStringRequestBody(etFirstNameRegister.text!!.trim().toString()),
            getStringRequestBody(etLastNameRegister.text!!.trim().toString()),
            getStringRequestBody(etPasswordRegister.text!!.trim().toString()),
            getStringRequestBody(ConstantUtils.KEY_LOGIN_AS),
            getStringRequestBody(etReferralRegister.text!!.trim().toString()),
            getStringRequestBody(etEmailRegister.text!!.trim().toString()),
            getStringRequestBody(ConstantUtils.DEVICE_TYPE.toString()),
            getStringRequestBody(
                SharedPrefsUtils.getStringPreference(
                    applicationContext,
                    KeysUtils.keyDeviceToken
                )!!
            ),
            getStringRequestBody(getTimeZone()),
            getStringRequestBody(Utils.keyLatitude),
            getStringRequestBody(Utils.keyLongitude),
            getStringRequestBody(
                Utils.getCompleteAddressString(
                    applicationContext,
                    Utils.keyLatitude.toDouble(),
                    Utils.keyLongitude.toDouble()
                )
            )
        )
    }

    fun checkForValidReferralCode(referralCode: String) {
        registerViewModel.checkForValidReferralCode(
            CheckForValidReferralCodeRequest(
                Utils.seceretKey,
                Utils.accessKey,
                "Customer",
                referralCode
            )
        )
    }


    private fun navigateToPhoneNumberActivity() {

        if (fromSupplierRegister) {

            startActivityForResultWithDefaultAnimations(
                (Intent(this, SupplierEnterPhoneNumberActivity::class.java)),
                ConstantUtils.REGISTER_ENTER_PHONE_REQUEST_CODE
            )
        } else {

            startActivityForResultWithDefaultAnimations(
                (Intent(this, EnterPhoneNumberActivity::class.java)),
                ConstantUtils.REGISTER_ENTER_PHONE_REQUEST_CODE
            )
        }
    }

    private fun validateInputs(): Boolean {
        if (etFirstNameRegister.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.firstNameVal)
            showErrorMessage()
            return false
        } else if (etLastNameRegister.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.lastNameVal)
            showErrorMessage()
            return false
        } else if (etEmailRegister.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.emailAddressVal)
            showErrorMessage()
            return false
        } else if (etPasswordRegister.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.passwordVal)
            showErrorMessage()
            return false
        } else if (etConfirmPasswordRegister.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.confirmPasswordVal)
            showErrorMessage()
            return false
        } else if (!ValidationUtils.isEmailValid(etEmailRegister.text!!.trim().toString())) {
            errorMessage = resources.getString(R.string.validEmailAddressVal)
            showErrorMessage()
            return false
        } else if (etPasswordRegister.text!!.trim().toString().length < 6) {
            errorMessage = resources.getString(R.string.passwordDigitVal)
            showErrorMessage()
            return false
        }
//        else if (!ValidationUtils.isValidPassword(etPasswordRegister.text!!.trim().toString())) {
//            errorMessage = resources.getString(R.string.validPasswordVal)
//            showErrorMessage()
//            return false
//        }  else if (!ValidationUtils.isValidPassword(etConfirmPasswordRegister.text!!.trim().toString())) {
//            errorMessage = resources.getString(R.string.validPasswordVal)
//            showErrorMessage()
//            return false
//        }
        else if (etConfirmPasswordRegister.text!!.trim()
                .toString() != etPasswordRegister.text!!.trim().toString()
        ) {
            errorMessage = resources.getString(R.string.passwordNotMatchVal)
            showErrorMessage()
            return false
        } else if (!policyCheckRegister.isChecked) {
            errorMessage = resources.getString(R.string.checkConditionVal)
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
        tvTermsRegister.text = agreementSpan
        tvTermsRegister.movementMethod = LinkMovementMethod.getInstance()
    }

    private fun getTermSpan() = getString(R.string.termsConditions).makeClickSpannable(
        {
            try {
                // val myIntent = Intent(Intent.ACTION_VIEW, Uri.parse( configuration.configurations.settingsMenuItems[2].data ))
                // startActivity(myIntent)

                val myIntent = Intent(applicationContext, WebViewActivity::class.java)
                myIntent.putExtra(KeysUtils.keyLink, TEMS_AND_CONDI_URL)
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
        resources.getString(R.string.termsConditions)
    )

    private fun showErrorMessage() {
        Toast.makeText(this, errorMessage, Toast.LENGTH_SHORT).show()
    }


    override fun onResume() {
        super.onResume()
        this.hideKeyboard()
    }

//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        super.onActivityResult(requestCode, resultCode, data)
//        when (requestCode) {
//            ConstantUtils.REGISTER_ENTER_PHONE_REQUEST_CODE -> {
//                if (data != null) {
//                    navigateToBack()
//                } else {
////                    onBackPressed()
//                }
//
//            }
//        }
//
//    }

    private fun navigateToBack() {

        val intent = Intent()
        setResult(Activity.RESULT_OK, intent)
        finish()
    }

    private fun dialogChoosePic() {

        var dialog = Dialog(this)
        dialog.setContentView(R.layout.layout_dialog_choosepic)

        var ivCamera = dialog.findViewById<ImageView>(R.id.ivCamera)
        var ivGallery = dialog.findViewById<ImageView>(R.id.ivGallery)

        ivCamera.setOnClickListener {

            checkPermissions()
            choosePicCamera()
            dialog.dismiss()
        }

        ivGallery.setOnClickListener {

            checkPermissionReadMethod()
            dialog.dismiss()
        }

        dialog.show()
    }

    private fun checkPermissions(): Boolean {
        var result: Int
        val listPermissionsNeeded = ArrayList<String>()
        for (p in permissions) {
            result = ContextCompat.checkSelfPermission(this, p)
            if (result != PackageManager.PERMISSION_GRANTED) {
                listPermissionsNeeded.add(p)
            }
        }
        if (listPermissionsNeeded.isNotEmpty()) {
            ActivityCompat.requestPermissions(
                this,
                listPermissionsNeeded.toTypedArray(),
                MULTIPLE_PERMISSIONS
            )
            return false
        }
        return true
    }

    private fun checkPermissionReadMethod() {

        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_EXTERNAL_STORAGE
            )
            == PackageManager.PERMISSION_DENIED
        ) {
            ActivityCompat
                .requestPermissions(
                    this,
                    arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
                    PERMISSION_READ_EXTERNAL_STORAGE
                )
        } else {
            choosePicGallery()
        }

    }

    private fun choosePicGallery() {

        val intent = Intent(Intent.ACTION_PICK)
        intent.type = "image/*"
        val mimeTypes = arrayOf("image/jpeg", "image/png")
        intent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes)

        startActivityForResult(intent, REQUEST_PICK_IMAGE)
    }

    private fun choosePicCamera() {
        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        startActivityForResult(intent, REQUEST_CAMERA)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == ConstantUtils.REGISTER_ENTER_PHONE_REQUEST_CODE) {
            if (data != null) {
                navigateToBack()
            } else {
//                    onBackPressed()
            }

        } else if (requestCode == REQUEST_PICK_IMAGE && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                val selectedImageUri = data.data
                if (selectedImageUri != null) {
                    imagePath = getRealPathFromURI(applicationContext, selectedImageUri)!!
                } else {
                    imagePath = ""
                }

                Glide.with(this).load(selectedImageUri)
                    .override(800, 400)
                    .circleCrop()
                    .into(ivProfileImage)
            }

        } else if (requestCode == REQUEST_CAMERA && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                val thumbnail: Bitmap = data.extras?.get("data") as Bitmap
                val selectedImageUri: Uri = getImageUri(applicationContext, thumbnail)
                imagePath = getRealPathFromURI(applicationContext, selectedImageUri)!!
                Glide.with(this).load(selectedImageUri)
                    .override(800, 400)
                    .circleCrop()
                    .into(ivProfileImage)
            }
        }
    }

    private fun updateMultiPartImage(path: String): MultipartBody.Part {
        if (path.isNullOrEmpty()) {
            val emptyFile = "".toRequestBody("text/plain".toMediaTypeOrNull())
            return MultipartBody.Part.createFormData("user_image", "", emptyFile)
        } else {
            val file = File(path)
            val fileReqBody = file.asRequestBody("image/*".toMediaTypeOrNull())
            return MultipartBody.Part.createFormData("user_image", file.name, fileReqBody)
        }
    }

    private fun getStringRequestBody(value: String): RequestBody {
        return value.toRequestBody("text/plain".toMediaTypeOrNull())
    }
}
