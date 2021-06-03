package com.quedrop.driver.ui.profile.view

import android.Manifest
import android.app.Activity
import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.widget.ImageView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.bumptech.glide.Glide
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.base.extentions.finishWithAnimation
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.User
import com.quedrop.driver.service.request.EditProfileRequest
import com.quedrop.driver.ui.enterphonenumber.EnterPhoneNumberActivity
import com.quedrop.driver.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.driver.ui.register.viewModel.RegisterViewModel
import com.quedrop.driver.utils.*
import com.google.gson.Gson
import com.hbb20.CountryCodePicker
import kotlinx.android.synthetic.main.activity_edit_profile.*
import kotlinx.android.synthetic.main.toolbar_normal.*
import okhttp3.MediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody
import java.io.ByteArrayOutputStream
import java.io.File

class EditProfileActivity : BaseActivity() {

    private var errorMessage = ""
    var imageUri: Uri? = null
    var imagePath: String = ""
    lateinit var profileViewModel: ProfileViewModel
    private lateinit var registerViewModel: RegisterViewModel
    private var countryCode = "0"
    private var phoneNo = "0"

    val MULTIPLE_PERMISSIONS = 10
    val PERMISSION_READ_EXTERNAL_STORAGE = 12
    var REQUEST_PICK_IMAGE = 200
    var REQUEST_CAMERA = 201
    var ENTER_PHONE_VERIFY_REQUEST_CODE = 211

    private lateinit var user: User
    private lateinit var mContext: Context
    private var profileImagePath: String = ""


    private var permissions = arrayOf<String>(

        Manifest.permission.CAMERA,
        Manifest.permission.WRITE_EXTERNAL_STORAGE
    )


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_edit_profile)

        mContext = this
        profileViewModel = ProfileViewModel(appService)
        registerViewModel = RegisterViewModel(appService)

        val userData = intent?.getStringExtra(KEY_EDIT_IDENTITY)
        user = Gson().fromJson(userData, User::class.java)

        setUpToolBar()
        observeViewModel()
        onClickMethod()

        setAllUserDetails(user)
        //getUserProfileApi()
    }


    private fun setUpToolBar() {

        tvTitle.text = resources.getString(R.string.edit_profile)
        ivBack.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)
    }

    private fun onClickMethod() {

        pickImageIv.throttleClicks().subscribe {

            dialogChoosePic()

        }.autoDispose(compositeDisposable)

        phoneNumAddEdit.throttleClicks().subscribe() {
            val ccp = findViewById<CountryCodePicker>(R.id.countryEditSpinner)
            countryCode = "+${ccp.selectedCountryCode}"

            startActivityWithDefaultAnimations(
                Intent(this, EnterPhoneNumberActivity::class.java)
                    .putExtra("PhoneNumber", etMobileProfile.text.toString())
                    .putExtra("CountryCode", ccp.selectedCountryCode)
                    .putExtra("isFromProfile", true)
            )

        }.autoDispose(compositeDisposable)

        btnSaveEditProfile.throttleClicks().subscribe {
            if (validateInputs()) {
                val ccp = findViewById<CountryCodePicker>(R.id.countryEditSpinner)
                countryCode = "+${ccp.selectedCountryCode}"

                if (Utility.isNetworkAvailable(this)) {
                    profileViewModel.editProfileApi(editProfileRequest(countryCode))
                } else {
                    showAlertMessage(this, getString(R.string.no_internet_connection))
                }

            }
        }.autoDispose(compositeDisposable)

    }


    private fun observeViewModel() {
        profileViewModel.userData.observe(this, Observer {
            //            setAllUserDetails(it)
            onBackPressed()

        })

        profileViewModel.errorMessage.observe(this, Observer { error ->
            showAlertMessage(this, error)
        })

        profileViewModel.editProfileMessage.observe(this, Observer {
            onBackPressed()
        })

//        registerViewModel.otpSendData.observe(this, Observer { isOTPSent ->
//            if (isOTPSent) {
//                hideProgress()
//                val intent = Intent(applicationContext, VerifyPhoneActivity::class.java)
//                intent.putExtra("countryCode", countryCode)
//                intent.putExtra("phone", etMobileProfile.text!!.trim().toString())
//                intent.putExtra("isFromProfile",true)
//                startActivityForResultWithDefaultAnimations(
//                    intent,
//                    ENTER_PHONE_VERIFY_REQUEST_CODE
//                )
//            }
//        })
    }

    private fun setAllUserDetails(user: User) {
        etFirstNameProfile.setText(user.firstName)
        etLastNameProfile.setText(user.lastName)
        etUserNameProfile.setText(user.userName)
        etEmailProfile.setText(user.email)
        etMobileProfile.setText(user.phoneNumber)
        if (!user.userImage.isNullOrEmpty()) {
            if (!isNetworkUrl(user.userImage!!)) {
                profileImagePath =
                    BuildConfig.BASE_URL + ImageConstant.PROFILE_DATA + user.userImage
            } else {
                profileImagePath = user.userImage!!
            }

            Glide.with(this)
                .load(profileImagePath)
                .placeholder(R.drawable.ic_user_placeholder)
                .circleCrop()
                .into(ivProfileImage)
        }
        countryEditSpinner.setCountryForPhoneCode(user.countryCode!!)

    }

    private fun validateInputs(): Boolean {
        if (etFirstNameProfile.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.firstNameVal)
            showErrorMessage()
            return false
        } else if (etLastNameProfile.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.lastNameVal)
            showErrorMessage()
            return false
        } else if (etUserNameProfile.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.userNameVal)
            showErrorMessage()
            return false
        } else if (etEmailProfile.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.emailAddressVal)
            showErrorMessage()
            return false
        } else if (etMobileProfile.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.enterPhoneNum)
            showErrorMessage()
            return false
        } else if (!isEmailValid(etEmailProfile.text!!.trim().toString())) {
            errorMessage = resources.getString(R.string.validEmailAddressVal)
            showErrorMessage()
            return false
        } else if (!isValidMobile(etMobileProfile.text!!.trim().toString())) {
            errorMessage = resources.getString(R.string.enterPhoneNum)
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
//                    Toast.makeText(applicationContext, "Permission is Granted ", Toast.LENGTH_SHORT)
//                        .show()
                    // permissions granted.
                } else {
                    // no permissions granted.
                }
                return
            }

            MULTIPLE_PERMISSIONS -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    choosePicCamera()
//                    Toast.makeText(applicationContext, "Permission is Granted ", Toast.LENGTH_SHORT)
//                        .show()
                    // permissions granted.
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
                    imagePath = getRealPathFromURI(
                        applicationContext, selectedImageUri!!
                    )!!
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

    private fun editProfileRequest(countryCode: String): EditProfileRequest {
        return EditProfileRequest(
            getStringRequestBody(SharedPreferenceUtils.getInt(KEY_USERID).toString()),
            getStringRequestBody(etUserNameProfile.text.toString()),
            getStringRequestBody(SharedPreferenceUtils.getString(KEY_TOKEN)),
            getStringRequestBody(ACCESS_KEY),
            updateMultiPartImage(imagePath!!),
            getStringRequestBody("Driver"),
            getStringRequestBody(etFirstNameProfile.text.toString()),
            getStringRequestBody(etLastNameProfile.text.toString()),
            getStringRequestBody(countryCode),
            getStringRequestBody(etMobileProfile.text.toString()),
            getStringRequestBody("v2")
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

    override fun onBackPressed() {
        super.onBackPressed()
        finishWithAnimation()
    }

}
