package com.quedrop.driver.ui.register.view

import android.Manifest
import android.app.Activity
import android.app.Dialog
import android.content.ActivityNotFoundException
import android.content.Context
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
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.bumptech.glide.Glide
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.base.extentions.hideKeyboard
import com.quedrop.driver.base.extentions.makeClickSpannable
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.request.CheckForValidReferralCodeRequest
import com.quedrop.driver.service.request.RegisterRequest
import com.quedrop.driver.ui.enterphonenumber.EnterPhoneNumberActivity
import com.quedrop.driver.ui.register.viewModel.RegisterViewModel
import com.quedrop.driver.utils.*
import kotlinx.android.synthetic.main.activity_edit_profile.*
import kotlinx.android.synthetic.main.activity_register.*
import kotlinx.android.synthetic.main.activity_register.ivProfileImage
import kotlinx.android.synthetic.main.toolbar_normal.*
import okhttp3.MediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody
import java.io.ByteArrayOutputStream
import java.io.File


class RegisterActivity : BaseActivity() {
    private var errorMessage = ""
    var imagePath: String = ""
    private lateinit var registerViewModel: RegisterViewModel

    val MULTIPLE_PERMISSIONS = 10
    val PERMISSION_READ_EXTERNAL_STORAGE = 12
    var REQUEST_PICK_IMAGE = 200
    var REQUEST_CAMERA = 201

    private var permissions = arrayOf<String>(

        Manifest.permission.CAMERA,
        Manifest.permission.WRITE_EXTERNAL_STORAGE
    )


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_register)
        registerViewModel = RegisterViewModel(appService)
        observeViewModel()
        getTokenIfBlank()
        setUpToolbar()
        setSpanToPolicyText()
        onClickView()

        etReferral.addTextChangedListener(object : TextWatcher {
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

    private fun getTokenIfBlank() {
        if (SharedPreferenceUtils.getString(KEY_TOKEN).isEmpty()) {
            registerViewModel.getNewToken()

        }
    }

    private fun observeViewModel() {
        registerViewModel.tokenData.observe(this, Observer { newToken ->
            SharedPreferenceUtils.setString(KEY_TOKEN, newToken)
        })

        registerViewModel.errorMessage.observe(this, Observer { error ->
            hideProgress()
            showAlertMessage(this, error)
        })

        registerViewModel.userData.observe(this, Observer { user ->
            hideProgress()
            SharedPreferenceUtils.setModelPreferences(KEY_USER, user)
            SharedPreferenceUtils.setInt(KEY_USERID, user.userId!!)
            SharedPreferenceUtils.setString(KEY_LATITUDE, user.latitude)
            SharedPreferenceUtils.setString(KEY_LONGITUDE, user.longitude)
            navigateToPhoneNumberActivity()

        })

        mainViewModel.referralCodeResponse.observe(this, Observer {
            showInfoMessage(this, it)
        })
    }

    private fun setUpToolbar() {
        tvTitle.text = "Register"
    }

    private fun onClickView() {

        ivPickProfile.throttleClicks().subscribe {
            dialogChoosePic()
        }.autoDispose(compositeDisposable)

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

        ivShowConfirmPass.throttleClicks().subscribe {
            if (ivShowConfirmPass.contentDescription == "Hide") {
                etConfirmPassword.transformationMethod =
                    HideReturnsTransformationMethod.getInstance()
                ivShowConfirmPass.contentDescription = "Show"
                ivShowConfirmPass.setImageDrawable(
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.ic_eye_visible
                    )
                )
            } else {
                etConfirmPassword.transformationMethod = PasswordTransformationMethod.getInstance()
                ivShowConfirmPass.contentDescription = "Hide"
                ivShowConfirmPass.setImageDrawable(
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.ic_eye_hide
                    )
                )
            }

        }.autoDispose(compositeDisposable)

        ivBack.throttleClicks().subscribe {
            finish()
        }.autoDispose(compositeDisposable)

        btnNext.throttleClicks().subscribe {
            if (validateInputs()) {
                if (Utility.isNetworkAvailable(this)) {
                    showProgress()
                    registerViewModel.registerUser(getRegisterRequest())
                } else {
                    hideProgress()
                    showAlertMessage(this, getString(R.string.no_internet_connection))
                }

            }
        }.autoDispose(compositeDisposable)
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

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        when (requestCode) {
            PERMISSION_READ_EXTERNAL_STORAGE -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    choosePicGallery()
                } else {
                    // no permissions granted.
                }
                return
            }

            MULTIPLE_PERMISSIONS -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    choosePicCamera()
                } else {
                    // no permissions granted.
                }
                return
            }
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
        if (requestCode == REQUEST_PICK_IMAGE && resultCode == Activity.RESULT_OK) {
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

    private fun getImageUri(inContext: Context, inImage: Bitmap): Uri {
        var bytes = ByteArrayOutputStream()
        inImage.compress(Bitmap.CompressFormat.JPEG, 100, bytes)
        var path: String = MediaStore.Images.Media.insertImage(
            inContext.contentResolver,
            inImage,
            "Title",
            null
        )
        return Uri.parse(path)
    }

    private fun getRegisterRequest(): RegisterRequest {
        return RegisterRequest(
            getStringRequestBody(SharedPreferenceUtils.getString(KEY_TOKEN)),
            getStringRequestBody(ACCESS_KEY),
            updateMultiPartImage(imagePath),
            getStringRequestBody(etFirstName.text!!.trim().toString()),
            getStringRequestBody(etLastName.text!!.trim().toString()),
            getStringRequestBody(etPassword.text!!.trim().toString()),
            getStringRequestBody(KEY_LOGIN_AS.toString()),
            getStringRequestBody(etReferral.text!!.trim().toString()),
            getStringRequestBody(etEmail.text!!.trim().toString()),
            getStringRequestBody(DEVICE_TYPE.toString()),
            getStringRequestBody(SharedPreferenceUtils.getString(DEVICE_TOKEN)),
            getStringRequestBody(getTimeZone()),
            getStringRequestBody(SharedPreferenceUtils.getString(KEY_LATITUDE)),
            getStringRequestBody(SharedPreferenceUtils.getString(KEY_LONGITUDE)),
            getStringRequestBody(getAddress(this))
        )
    }

    private fun updateMultiPartImage(path: String): MultipartBody.Part {
        if (path.isNullOrEmpty()) {
            val emptyFile = RequestBody.create(MediaType.parse("text/plain"), "")
            return MultipartBody.Part.createFormData("user_image", "", emptyFile)
        } else {
            val file = File(path)
            val fileReqBody = RequestBody.create(MediaType.parse("image/*"), file)
            return MultipartBody.Part.createFormData("user_image", file.name, fileReqBody)
        }
    }

    private fun getStringRequestBody(value: String): RequestBody {
        return RequestBody.create(MediaType.parse("text/plain"), value)
    }

    private fun navigateToPhoneNumberActivity() {
        startActivityWithDefaultAnimations(Intent(this, EnterPhoneNumberActivity::class.java))
        finish()
    }


    private fun validateInputs(): Boolean {
        if (etFirstName.text!!.trim().isEmpty()) {
            errorMessage = "Enter First Name"
            showErrorMessage()
            return false
        } else if (etLastName.text!!.trim().isEmpty()) {
            errorMessage = "Enter Last Name"
            showErrorMessage()
            return false
        } else if (etEmail.text!!.trim().isEmpty()) {
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
        } else if (etPassword.text!!.trim().toString().length < 6) {
            errorMessage = "Password must least 6 digit long"
            showErrorMessage()
            return false
        } else if (etConfirmPassword.text!!.trim().isEmpty()) {
            errorMessage = "Enter Confirm Password"
            showErrorMessage()
            return false
        } else if (etConfirmPassword.text!!.trim().toString() != etPassword.text!!.trim()
                .toString()
        ) {
            errorMessage = "Password not matched"
            showErrorMessage()
            return false
        } else if (!policyCheck.isChecked) {
            errorMessage = "Please check Condition Box"
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
        tvPolicy.text = agreementSpan
        tvPolicy.movementMethod = LinkMovementMethod.getInstance()
    }

    private fun getTermSpan() = getString(R.string.termsConditions).makeClickSpannable(
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
        spanBold = false,
        spanUnderLine = false,
        args = resources.getString(R.string.termsConditions)
    )

    private fun showErrorMessage() {
        showInfoMessage(this, errorMessage)
    }

    fun afterTextChanged(text: Editable) {
        if (etReferral.length() == 8) {

        }

    }

    fun checkForValidReferralCode(referralCode: String) {
        if (Utility.isNetworkAvailable(this)) {
            mainViewModel.checkForValidReferralCode(
                CheckForValidReferralCodeRequest(
                    SharedPreferenceUtils.getString(KEY_TOKEN),
                    ACCESS_KEY,
                    "Driver",
                    referralCode
                )
            )
        } else {
            showAlertMessage(this, getString(R.string.no_internet_connection))
        }
    }

    override fun onResume() {
        super.onResume()
        this.hideKeyboard()
    }

}
