package com.quedrop.customer.ui.profile.view

import android.Manifest
import android.app.Activity
import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.GetUserProfileDetailRequest
import com.quedrop.customer.model.SendOTPRequest
import com.quedrop.customer.model.User
import com.quedrop.customer.ui.enterphonenumber.EnterPhoneNumberActivity
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.customer.ui.register.viewModel.RegisterViewModel
import com.quedrop.customer.utils.*
import kotlinx.android.synthetic.main.fragment_edit_profile_customer.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody
import java.io.ByteArrayOutputStream
import java.io.File

class EditProfileFragment : BaseFragment() {

    private var errorMessage = ""
    var imageUri: Uri? = null
    var imagePath: String? = null
    private var countryCode = "0"
    lateinit var profileViewModel: ProfileViewModel
    var checkPhoneNumber: String? = null
    var checkFirstName: String? = null
    var checkLastName: String? = null
    var checkUserName: String? = null
    var checkUserImage: String = ""
    var checkEmail: String? = null
    private var phoneNo = "0"
    var flagImageCheck: Boolean = false
    private lateinit var registerViewModel: RegisterViewModel
    private var permissions = arrayOf<String>(

        Manifest.permission.CAMERA,
        Manifest.permission.WRITE_EXTERNAL_STORAGE
    )

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        return inflater.inflate(
            R.layout.fragment_edit_profile_customer,
            container, false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyGuestId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keyAccessKey)!!
        profileViewModel =
            ProfileViewModel(appService)
        registerViewModel =
            RegisterViewModel(appService)



        observeViewModel()
        onClickMethod()
        getUserProfileApi()


        if (ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.RECEIVE_SMS
            ) == PackageManager.PERMISSION_DENIED
        ) {
            ActivityCompat.requestPermissions(
                activity, arrayOf(Manifest.permission.RECEIVE_SMS),
                ConstantUtils.PERMISSION_RECEIVE_SMS
            )
        }
    }

    companion object {
        fun newInstance(): EditProfileFragment {
            return EditProfileFragment()
        }
    }

    fun onPageSelected(position: Int) {

    }

    private fun onClickMethod() {

        ivBackEditProfile.throttleClicks().subscribe {

            activity.onBackPressed()

        }.autoDispose(compositeDisposable)

        pickImageIv.throttleClicks().subscribe() {
            dialogChoosePic()
        }.autoDispose(compositeDisposable)

        phoneNumAddEdit.throttleClicks().subscribe() {
            navigateToPhoneNumberActivity()
        }.autoDispose(compositeDisposable)

        btnSaveEditProfile.throttleClicks().subscribe() {
            if (validateInputs()) {
//

                if (etFirstNameProfile.text.toString() == checkFirstName &&
                    etLastNameProfile.text.toString() == checkLastName &&
                    etUserNameEditProfile.text.toString() == checkUserName &&
                    !flagImageCheck &&
                    etUserNameEditProfile.text.toString() == checkPhoneNumber
                ) {
                    onBackPress(Activity.RESULT_CANCELED)
                } else {
                    editProfileApi()
                }

            }

        }.autoDispose(compositeDisposable)

    }

    private fun observeViewModel() {
        profileViewModel.user.observe(viewLifecycleOwner, Observer {
            (activity as CustomerMainActivity).hideProgress()
            setAllUserDetails(it)

        })

        profileViewModel.errorMessage.observe(viewLifecycleOwner, Observer { error ->
            (activity as CustomerMainActivity).hideProgress()
            Toast.makeText(activity, error, Toast.LENGTH_SHORT).show()
        })

        profileViewModel.editProfileMessage.observe(viewLifecycleOwner, Observer {
            (activity as CustomerMainActivity).hideProgress()
            Toast.makeText(activity, it, Toast.LENGTH_SHORT).show()
            onBackPress(Activity.RESULT_OK)
        })

    }

    private fun getUserProfileApi() {
        (activity as CustomerMainActivity).showProgress()
        profileViewModel.getUserProfileApi(
            GetUserProfileDetailRequest(
                Utils.seceretKey,
                Utils.accessKey,
                Utils.userId
            )
        )
    }

    private fun setAllUserDetails(user: User) {
        etUserNameEditProfile.setText(user.user_name)
        etEmailEditProfile.setText(user.email)
        etMobileEditProfile.setText(user.phone_number)
        checkPhoneNumber = user.phone_number
        checkFirstName = user.first_name
        checkLastName = user.last_name
        checkUserName = user.user_name
        checkEmail = user.email
        if (!user.user_image.isEmpty()) {

            checkUserImage = user.user_image

            if (ValidationUtils.isCheckUrlOrNot(user.user_image)) {
                Glide.with(activity).load(user.user_image)
                    .centerCrop()
                    .placeholder(R.drawable.customer_unpress)
                    .into(ivProfileEditImage)
            } else {

                Glide.with(activity).load(
                    URLConstant.urlUser
                            + user.user_image
                ).centerCrop()
                    .placeholder(R.drawable.customer_unpress)
                    .into(ivProfileEditImage)
            }

        }
        etFirstNameProfile.setText(user.first_name)
        etLastNameProfile.setText(user.last_name)
        countryCode = user.country_code
        countryCodeSpinner.setCountryForPhoneCode(user.country_code.toInt())

        if (!etEmailEditProfile.text.isNullOrEmpty()) {
            etEmailEditProfile.isFocusable = false
            etEmailEditProfile.isEnabled = false
            etEmailEditProfile.isCursorVisible = false
            etEmailEditProfile.keyListener = null
        }

        if (etMobileEditProfile.text.toString().isEmpty()) {
            phoneNumAddEdit.text = getString(R.string.addPhoneNumber)
        } else {
            phoneNumAddEdit.text = getString(R.string.changePhoneNumber)
        }

    }


    private fun validateInputs(): Boolean {
        if (etFirstNameProfile.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.firstNameVal)
            showErrorMessage()
            return false
        } else if (etUserNameEditProfile.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.userNameVal)
            showErrorMessage()
            return false
        } else if (!ValidationUtils.isEmailValid(etEmailEditProfile.text!!.trim().toString())) {
            errorMessage = resources.getString(R.string.validEmailAddressVal)
            showErrorMessage()
            return false
        } else {
            errorMessage = ""
            return true
        }
    }

    private fun navigateToPhoneNumberActivity() {
        val intent = Intent(activity, EnterPhoneNumberActivity::class.java)
        startActivityForResultWithDefaultAnimations(
            intent,
            ConstantUtils.LOGIN_ENTER_PHONE_REQUEST_CODE
        )
    }


    private fun showErrorMessage() {
        Toast.makeText(activity, errorMessage, Toast.LENGTH_SHORT).show()
    }

    private fun dialogChoosePic() {

        val dialog = Dialog(activity)
        dialog.setContentView(R.layout.layout_dialog_choosepic)

        val ivCamera = dialog.findViewById<ImageView>(R.id.ivCamera)
        val ivGallery = dialog.findViewById<ImageView>(R.id.ivGallery)

        ivCamera.setOnClickListener {


            if (checkPermissions()) {
                choosePicCamera()
            } else {
                checkPermissions()
            }
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
            result = ContextCompat.checkSelfPermission(activity, p)
            if (result != PackageManager.PERMISSION_GRANTED) {
                listPermissionsNeeded.add(p)
            }
        }
        if (listPermissionsNeeded.isNotEmpty()) {
            requestPermissions(
                listPermissionsNeeded.toTypedArray(),
                ConstantUtils.MULTIPLE_PERMISSIONS
            )
            return false
        }
        return true
    }


    private fun checkPermissionReadMethod() {

        if (ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.READ_EXTERNAL_STORAGE
            )
            == PackageManager.PERMISSION_DENIED
        ) {
            requestPermissions(
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
                }
                return
            }

            ConstantUtils.MULTIPLE_PERMISSIONS -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    choosePicCamera()
//                    Toast.makeText(applicationContext, "Permission is Granted ", Toast.LENGTH_SHORT)
//                        .show()
                    // permissions granted.
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
        val directory =
            File(
                Environment.getExternalStorageDirectory().absolutePath + "/" + resources.getString(
                    R.string.app_name
                )
            )

        if (directory.exists()) {

        } else {
            directory.mkdir()
        }
        Log.e("check camera click", "click1")
        val intent = Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE)
        startActivityForResult(intent, ConstantUtils.REQUEST_CAMERA)

    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == ConstantUtils.REQUEST_PICK_IMAGE && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                flagImageCheck = true
                val selectedImageUri = data.data

                var bitmap =
                    MediaStore.Images.Media.getBitmap(
                        activity.contentResolver,
                        selectedImageUri
                    )
//                var path = saveImage(bitmap)
                val path =
                    Utils.getRealPathFromURI(activity, selectedImageUri!!)
                imageUri = null
                imagePath = null
                imageUri = selectedImageUri
                imagePath = path
                ivProfileEditImage.setImageURI(imageUri)
//                ivProfileImage.setImageURI(imageUri)


            }
        } else if (requestCode == ConstantUtils.REQUEST_CAMERA && resultCode == Activity.RESULT_OK) {
            if (data != null) {

                flagImageCheck = true
                Log.e("check camera click", "click")

//                var uri: Uri? = data.data
                val thumbnail: Bitmap = data.extras?.get("data") as Bitmap
                val uri: Uri = getImageUri(activity, thumbnail)
                val path = Utils.getRealPathFromURI(activity, uri)
//                var path = getRealPathFromURI(uri!!)
                imageUri = null
                imagePath = null
                imageUri = uri
                imagePath = path
                ivProfileEditImage.setImageURI(imageUri)
//                ivProfileImage.setImageURI(imageUri)

            }
        } else if (requestCode == ConstantUtils.LOGIN_ENTER_PHONE_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            if (data != null) {

                getUserProfileApi()
                phoneNumAddEdit.text = getString(R.string.changePhoneNumber)
            }
        }
    }

    private fun editProfileApi() {
        (activity as CustomerMainActivity).showProgress()

        if (etMobileEditProfile.text.toString().isEmpty()) {
            etMobileEditProfile.text = ""
        } else if (etLastNameProfile.text.toString().isEmpty()) {
            etLastNameProfile.setText("")
        }

        val userIdRequest: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            Utils.userId.toString()
        )
        val userNameRequest: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            etUserNameEditProfile.text.toString()
        )
        val secretKeyRequest: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            Utils.seceretKey
        )
        val accessKeyRequest: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            Utils.accessKey
        )
        var imageProfileRequest: MultipartBody.Part? = null

        imageProfileRequest = null
        imageProfileRequest = if (imageUri != null) {
            prepareFilePart(
                "user_image", imageUri!!

            )

        } else {
            prepareFilePart(
                "user_image", Uri.parse("")

            )
        }
        val firstNameRequest: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(), etFirstNameProfile.text.toString()
        )
        val lastNameRequest: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            etLastNameProfile.text.toString()
        )
        val loginAsRequest: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            "Customer"
        )
        val countryCodeRequest: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            countryCode
        )

        val phoneNumberRequest: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            etMobileEditProfile.text.toString()
        )


        val userEmailRequest: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(), etEmailEditProfile.text.toString()
        )

        (activity as CustomerMainActivity).showProgress()
        profileViewModel.editEmailProfileApi(
            userIdRequest,
            userNameRequest,
            secretKeyRequest,
            accessKeyRequest,
            imageProfileRequest,
            firstNameRequest,
            lastNameRequest,
            loginAsRequest,
            countryCodeRequest,
            phoneNumberRequest,
            userEmailRequest
        )


    }


    private fun getImageUri(inContext: Context, inImage: Bitmap): Uri {
        val bytes = ByteArrayOutputStream()
        inImage.compress(Bitmap.CompressFormat.JPEG, 100, bytes)
        val path: String = MediaStore.Images.Media.insertImage(
            inContext.contentResolver,
            inImage,
            "Title",
            null
        )
        return Uri.parse(path)
    }

    private fun getSendOTPRequest(): SendOTPRequest {
        return SendOTPRequest(
            countryCode,
            phoneNo,
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId,
            Utils.guestId
        )

    }

    private fun checkVerifyProfileApi() {


        if (etMobileEditProfile.text!!.trim().isNotEmpty() && etMobileEditProfile.text!!.trim().toString().length > 6 && etMobileEditProfile.text!!.trim().toString().length <= 13) {
            phoneNo = etMobileEditProfile.text!!.trim().toString()
            (activity as CustomerMainActivity).showProgress()
            registerViewModel.sendOTP(getSendOTPRequest())
        } else {
            Toast.makeText(
                activity,
                resources.getString(R.string.enterPhoneNum),
                Toast.LENGTH_SHORT
            ).show()
        }
    }


    private fun prepareFilePart(partName: String, uri: Uri): MultipartBody.Part {


        if (uri.toString().isEmpty()) {

            val requestBody =
                RequestBody.create("".toMediaTypeOrNull(), "")


            return MultipartBody.Part.createFormData(partName, "", requestBody)
        } else {
            val file: File = File(Utils.getRealPathFromURI(activity, uri))
            val requestBody =
                RequestBody.create(
                    activity.contentResolver.getType(uri)?.toMediaTypeOrNull(),
                    file
                )


            return MultipartBody.Part.createFormData(partName, file.name, requestBody)
        }

    }

    private fun onBackPress(resultCode: Int) {
        targetFragment?.onActivityResult(targetRequestCode, resultCode, null)
        parentFragmentManager.popBackStack()
    }
}
