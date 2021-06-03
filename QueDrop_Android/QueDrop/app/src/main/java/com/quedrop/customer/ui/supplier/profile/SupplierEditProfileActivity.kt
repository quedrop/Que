package com.quedrop.customer.ui.supplier.profile

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
import android.view.View
import android.widget.AdapterView
import android.widget.ImageView
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.GetUserProfileDetailRequest
import com.quedrop.customer.model.SendOTPRequest
import com.quedrop.customer.model.User
import com.quedrop.customer.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.customer.ui.register.viewModel.RegisterViewModel
import com.quedrop.customer.ui.supplier.supplierverifyphone.SupplierEnterPhoneNumberActivity
import com.quedrop.customer.ui.supplier.supplierverifyphone.SupplierVerifyPhoneActivity
import com.quedrop.customer.utils.*
import kotlinx.android.synthetic.main.activity_supplier_edit_profile.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.ByteArrayOutputStream
import java.io.File

class SupplierEditProfileActivity : BaseActivity(), AdapterView.OnItemSelectedListener {

    private var errorMessage = ""
    var imageUri: Uri? = null
    var imagePath: String? = null
    lateinit var profileViewModel: ProfileViewModel
    var checkPhoneNumber: String? = null
    var checkFirstName: String? = null
    var checkLastName: String? = null
    var checkUserName: String? = null
    var checkEmail: String? = null
    private lateinit var registerViewModel: RegisterViewModel
    private var countryCode = "0"
    private var phoneNo = "0"
    private lateinit var user: User
    private var permissions = arrayOf<String>(

        Manifest.permission.CAMERA,
        Manifest.permission.WRITE_EXTERNAL_STORAGE
    )


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_supplier_edit_profile)

        Utils.Supplier.supplierUserId =
            SharedPrefsUtils.getIntegerPreference(this, KeysUtils.KeyUserSupplierId, 0)

        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(this, KeysUtils.keySecretKey)!!
        Utils.Supplier.supplierAccessKey =
            SharedPrefsUtils.getStringPreference(this, KeysUtils.KeySupplierAccessKey)!!
        profileViewModel =
            ProfileViewModel(appService)
        registerViewModel =
            RegisterViewModel(appService)

        observeViewModel()
        onClickMethod()
        getUserProfileApi()


        countryCodeSpinner.setOnCountryChangeListener {
            countryCode = "+${countryCodeSpinner.selectedCountryCode}"
        }
    }

    private fun onClickMethod() {

        ivBackEditProfile.throttleClicks().subscribe {

            onBackPressed()

        }.autoDispose(compositeDisposable)

        pickImageIv.throttleClicks().subscribe() {
            dialogChoosePic()
        }.autoDispose(compositeDisposable)

        btnChangePhn.throttleClicks().subscribe {
            var intent = Intent(this, SupplierEnterPhoneNumberActivity::class.java)
                .putExtra("PhoneNumber", etMobileProfile.text.toString())
                .putExtra("CountryCode", user.country_code)
            startActivityForResultWithDefaultAnimations(
                intent,
                ConstantUtils.LOGIN_ENTER_PHONE_REQUEST_CODE
            )

        }.autoDispose(compositeDisposable)

        btnSaveEditProfile.throttleClicks().subscribe() {

            if (validateInputs()) {
                if (etMobileProfile.text.toString() == checkPhoneNumber) {

                    if (etFirstNameProfile.text.toString() == checkFirstName &&
                        etLastNameProfile.text.toString() == checkLastName &&
                        etUserNameProfile.text.toString() == checkUserName
                    ) {
                        this.onBackPressed()
                    } else {

                        editProfileApi()
                    }

                } else {
                    checkVerifyProfileApi()
                }
            }
//            if (validateInputs()) {
//                editProfileApi()
//            }
        }.autoDispose(compositeDisposable)

    }

    private fun observeViewModel() {
        profileViewModel.user.observe(this, Observer {
            hideProgress()
            user = it
            setAllUserDetails(it)
        })

        profileViewModel.errorMessage.observe(this, Observer { error ->
            Toast.makeText(this, error + error, Toast.LENGTH_SHORT).show()
        })

        profileViewModel.editProfileMessage.observe(this, Observer {
            hideProgress()
            Toast.makeText(this, it, Toast.LENGTH_SHORT).show()
            RxBus.instance?.publish("refreshSupplierProfile")
            onBackPressed()
        })

        registerViewModel.otpSendData.observe(this, Observer { isOTPSent ->
            if (isOTPSent) {
                hideProgress()
                navigateToVerificationActivity()
            }
        })

    }

    private fun getUserProfileApi() {
        showProgress()
        profileViewModel.getUserProfileApi(
            GetUserProfileDetailRequest(
                Utils.seceretKey,
                Utils.Supplier.supplierAccessKey,
                Utils.Supplier.supplierUserId
            )
        )
    }

    private fun setAllUserDetails(user: User) {
        etUserNameProfile.setText(user.user_name)
        etEmailProfile.setText(user.email)
        etMobileProfile.setText(user.phone_number)

        checkPhoneNumber = user.phone_number
        checkFirstName = user.first_name
        checkLastName = user.last_name
        checkUserName = user.user_name
        checkEmail = user.email
        if (!user.user_image.isNullOrEmpty()) {

            if (ValidationUtils.isCheckUrlOrNot(user.user_image)) {
                Glide.with(applicationContext).load(
                    user.user_image
                ).centerCrop().into(ivProfileEditImage)
            } else {

                Glide.with(applicationContext).load(
                    URLConstant.urlUser
                            + user.user_image
                ).centerCrop().into(ivProfileEditImage)
            }

        }
        etFirstNameProfile.setText(user.first_name)
        etLastNameProfile.setText(user.last_name)
        countryCodeSpinner.setCountryForPhoneCode(user.country_code.toInt())
        if (!etEmailProfile.text.isNullOrEmpty()) {
            etEmailProfile.isFocusable = false
            etEmailProfile.isEnabled = false
            etEmailProfile.isCursorVisible = false
            etEmailProfile.keyListener = null
        }
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
        } else if (!ValidationUtils.isEmailValid(etEmailProfile.text!!.trim().toString())) {
            errorMessage = resources.getString(R.string.validEmailAddressVal)
            showErrorMessage()
            return false
        } else if (!ValidationUtils.isValidMobile(etMobileProfile.text!!.trim().toString())) {
            errorMessage = resources.getString(R.string.enterPhoneNum)
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

    private fun dialogChoosePic() {

        var dialog = Dialog(this)
        dialog.setContentView(R.layout.layout_dialog_choosepic)

        var ivCamera = dialog.findViewById<ImageView>(R.id.ivCamera)
        var ivGallery = dialog.findViewById<ImageView>(R.id.ivGallery)

        ivCamera.setOnClickListener {

            checkPermissions()
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
                ConstantUtils.MULTIPLE_PERMISSIONS
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
                    ConstantUtils.PERMISSION_READ_EXTERNAL_STORAGE
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
            ConstantUtils.PERMISSION_READ_EXTERNAL_STORAGE -> {
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

            ConstantUtils.MULTIPLE_PERMISSIONS -> {
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

        startActivityForResult(intent, ConstantUtils.REQUEST_PICK_IMAGE)
    }

    private fun choosePicCamera() {

        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        startActivityForResult(intent, ConstantUtils.REQUEST_CAMERA)

    }

//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        super.onActivityResult(requestCode, resultCode, data)
//        if (requestCode == ConstantUtils.REQUEST_PICK_IMAGE && resultCode == Activity.RESULT_OK) {
//            if (data != null) {
//                var selectedImageUri = data.data
//
//                var bitmap =
//                    MediaStore.Images.Media.getBitmap(contentResolver, selectedImageUri)
////                var path = saveImage(bitmap)
//                var path =
//                    Utils.getRealPathFromURI(this, selectedImageUri!!)
//                imageUri= null
//                imagePath = null
//                imageUri = selectedImageUri
//                imagePath = path
//                ivProfileEditImage.setImageURI(imageUri)
////                ivProfileEditImage.setImageURI(imageUri)
//
//
//            }
//        } else if (requestCode == ConstantUtils.REQUEST_CAMERA && resultCode == Activity.RESULT_OK) {
//            if (data != null) {
//
////                var uri: Uri? = data.data
//                var thumbnail: Bitmap = data.extras?.get("data") as Bitmap
//                var uri: Uri = getImageUri(this, thumbnail)
//                var path = Utils.getRealPathFromURI(this, uri)
////                var path = getRealPathFromURI(uri!!)
//                imageUri= null
//                imagePath=null
//                imageUri = uri
//                imagePath = path
//                ivProfileEditImage.setImageURI(imageUri)
////                ivProfileEditImage.setImageURI(imageUri)
//
//            }
//        }
//    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == ConstantUtils.REQUEST_PICK_IMAGE && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                val selectedImageUri = data.data
                imagePath =
                    Utils.getRealPathFromURI(applicationContext, selectedImageUri!!)

                Glide.with(this).load(selectedImageUri)
                    .override(800, 400)
                    .centerCrop()
                    .into(ivProfileEditImage)
            }

        } else if (requestCode == ConstantUtils.REQUEST_CAMERA && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                val thumbnail: Bitmap = data.extras?.get("data") as Bitmap
                val selectedImageUri: Uri = getImageUri(applicationContext, thumbnail)
                imagePath = Utils.getRealPathFromURI(applicationContext, selectedImageUri)
                Glide.with(this).load(selectedImageUri)
                    .override(800, 400)
                    .centerCrop()
                    .into(ivProfileEditImage)
            }
        } else if (requestCode == ConstantUtils.ENTER_PHONE_VERIFY_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                editProfileApi()

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

    private fun editProfileApi() {

        showProgress()

        var body: MultipartBody.Part? = null
        imagePath?.let {
            val fileToUpload = File(imagePath)
            val requestBody: RequestBody =
                fileToUpload.asRequestBody(contentType = "image/*".toMediaType())
            body = MultipartBody.Part.createFormData(
                "user_image",
                fileToUpload.name, requestBody
            )
        }

        profileViewModel.editProfileApi(
            Utils.Supplier.supplierUserId.toString().toRequestBody(),
            etUserNameProfile.text.toString().toRequestBody(),
            Utils.seceretKey.toRequestBody(),
            Utils.Supplier.supplierAccessKey.toRequestBody(),
            body,
            etFirstNameProfile.text.toString().toRequestBody(),
            etLastNameProfile.text.toString().toRequestBody(),
            "Supplier".toRequestBody(),
            countryCode.toRequestBody(),
            etMobileProfile.text.toString().toRequestBody()
        )
    }

    private fun getSendOTPRequest(): SendOTPRequest {
        return SendOTPRequest(
            countryCode,
            phoneNo,
            Utils.seceretKey,
            Utils.Supplier.supplierAccessKey,
            Utils.userId,
            Utils.guestId
        )

    }

    private fun checkVerifyProfileApi() {

        if (etMobileProfile.text!!.trim().isNotEmpty() &&
            etMobileProfile.text!!.trim().toString().length > 6
            && etMobileProfile.text!!.trim().toString().length <= 13
        ) {
            phoneNo = etMobileProfile.text!!.trim().toString()
            showProgress()
            registerViewModel.sendOTP(getSendOTPRequest())
        } else {
            Toast.makeText(
                applicationContext,
                resources.getString(R.string.enterPhoneNum),
                Toast.LENGTH_SHORT
            ).show()
        }
    }

    private fun navigateToVerificationActivity() {
        val intent = Intent(applicationContext, SupplierVerifyPhoneActivity::class.java)
        intent.putExtra("countryCode", countryCode)
        intent.putExtra("phone", etMobileProfile.text!!.trim().toString())
        startActivityForResultWithDefaultAnimations(
            intent,
            ConstantUtils.ENTER_PHONE_VERIFY_REQUEST_CODE
        )
    }

    override fun onNothingSelected(p0: AdapterView<*>?) {

    }

    override fun onItemSelected(p0: AdapterView<*>?, p1: View?, position: Int, p3: Long) {
        countryCode = Utils.countryCodeList[position]

    }
}
