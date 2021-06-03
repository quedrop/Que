package com.quedrop.customer.ui.storeadd.view

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.ui.storeadd.viewmodel.AddStoreViewModel
import com.quedrop.customer.ui.storewithoutproduct.view.StoreWithoutProductActivity
import com.quedrop.customer.utils.*
import kotlinx.android.synthetic.main.activity_add_store.*
import kotlinx.android.synthetic.main.activity_toolbar.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody
import java.io.File

class AddStoreActivity : BaseActivity() {

    var placeAddressId: String? = null
    var placeAddressTitle: String? = null
    var placeAddressAddress: String? = null
    var placeAddressLatitude: Double? = null
    var placeAddressLongitude: Double? = null
    var imageUri: Uri? = null
    var flagAddStore = false
    var path: String? = null
    lateinit var addStoreViewModel: AddStoreViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_store)

        imageUri = null
        path = null

        flagAddStore = true
        SharedPrefsUtils.setBooleanPreference(
            applicationContext,
            KeysUtils.keyAddStoreFlag,
            flagAddStore
        )
        Utils.guestId = SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyGuestId, 0)
        Utils.userId = SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyUserId, 0)

        addStoreViewModel = AddStoreViewModel(appService)
        observeViewModel()
        onClickMethod()
    }

    private fun onClickMethod() {

        ivBackAddStore.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        tvStoreMapsAddStore.throttleClicks().subscribe {

            val intent = Intent(this, AddAddressStoreMapActivity::class.java)
            startActivityForResultWithDefaultAnimations(intent, ConstantUtils.REQUEST_TV_PLACE_ADD)
        }.autoDispose(compositeDisposable)

        addStoreImage.throttleClicks().subscribe {

            checkPermissionMethod()

        }.autoDispose(compositeDisposable)

        btnAddStore.throttleClicks().subscribe {
            getAddStoreApi()
        }.autoDispose(compositeDisposable)

    }

    private fun checkPermissionMethod() {

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

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == ConstantUtils.REQUEST_PICK_IMAGE && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                imageUri = data.data
                val bitmap =
                    MediaStore.Images.Media.getBitmap(this.contentResolver, imageUri)
//                var path = saveImage(bitmap)
                path =
                    Utils.getRealPathFromURI(applicationContext, imageUri!!)
                addStoreImage.setImageBitmap(bitmap)

            }
        } else if (requestCode == ConstantUtils.REQUEST_TV_PLACE_ADD && resultCode == Activity.RESULT_OK) {
            if (data != null) {

                placeAddressId = data.getStringExtra(KeysUtils.keyPlaceId)
                placeAddressTitle = data.getStringExtra(KeysUtils.keyPlaceTitle)
                placeAddressAddress = data.getStringExtra(KeysUtils.keyPlaceAddress)
                placeAddressLatitude = data.getDoubleExtra(KeysUtils.keyPlaceLatitude, 0.0)
                placeAddressLongitude = data.getDoubleExtra(KeysUtils.keyPlaceLongitude, 0.0)

                tvStoreMapsAddStore.text = placeAddressTitle

            }
        }
    }

    private fun observeViewModel() {
        addStoreViewModel.user_store.observe(this,
            Observer {
                hideProgress()
                val addUserStore = it

                val intent =
                    Intent(applicationContext, StoreWithoutProductActivity::class.java)
                intent.putExtra(KeysUtils.keyUserAddStore, addUserStore)
                startActivityWithDefaultAnimations(intent)
                finish()
            })
        addStoreViewModel.errorMessage.observe(this,
            Observer {
                hideProgress()
            })
    }

    private fun getAddStoreApi() {
        when {
            editStoreNameAddStore.text.toString().isBlank() -> {
                Toast.makeText(
                    applicationContext,
                    resources.getString(R.string.storeNameToast),
                    Toast.LENGTH_SHORT
                ).show()

            }
            placeAddressAddress.isNullOrBlank() -> {
                Toast.makeText(
                    applicationContext,
                    resources.getString(R.string.storeLocationToast),
                    Toast.LENGTH_SHORT
                ).show()
            }
            else -> {
                showProgress()
                val userIdRequest: RequestBody = RequestBody.create(
                    "text/plain".toMediaTypeOrNull(),
                    Utils.userId.toString()
                )

                val guestIdRequest: RequestBody = RequestBody.create(
                    "text/plain".toMediaTypeOrNull(),
                    Utils.guestId.toString()
                )

                val storeNameRequest: RequestBody = RequestBody.create(
                    "text/plain".toMediaTypeOrNull(),
                    editStoreNameAddStore.text.toString()
                )

                val storeAddressRequest: RequestBody = RequestBody.create(
                    "text/plain".toMediaTypeOrNull(),
                    placeAddressAddress!!
                )

                val storeDescriptionRequest: RequestBody = RequestBody.create(
                    "text/plain".toMediaTypeOrNull(),
                    editDescriptionAddStore.text.toString()
                )

                val storeLatitudeRequest: RequestBody = RequestBody.create(
                    "text/plain".toMediaTypeOrNull(),
                    placeAddressLatitude.toString()
                )

                val storeLongitudeRequest: RequestBody = RequestBody.create(
                    "text/plain".toMediaTypeOrNull(),
                    placeAddressLongitude.toString()
                )
                val secretKeyRequest: RequestBody = RequestBody.create(
                    "text/plain".toMediaTypeOrNull(),
                    Utils.seceretKey
                )

                val accessKeyRequest: RequestBody = RequestBody.create(
                    "text/plain".toMediaTypeOrNull(),
                    Utils.accessKey
                )

                var storeLogoRequest: MultipartBody.Part? = null



                storeLogoRequest = null
                storeLogoRequest = if (path.isNullOrBlank()) {

                    prepareFilePart(
                        "store_image", Uri.parse("")

                    )
                } else {

                    prepareFilePart(
                        "store_image", imageUri!!

                    )

                }

                addStoreViewModel.addStoreApi(
                    userIdRequest,
                    guestIdRequest,
                    storeNameRequest,
                    storeAddressRequest,
                    storeDescriptionRequest,
                    storeLatitudeRequest,
                    storeLongitudeRequest,
                    secretKeyRequest,
                    accessKeyRequest,
                    storeLogoRequest
                )
            }
        }
    }

    private fun prepareFilePart(partName: String, uri: Uri): MultipartBody.Part {


        return if (uri.toString().isEmpty()) {

            val requestBody =
                RequestBody.create("".toMediaTypeOrNull(), "")


            MultipartBody.Part.createFormData(partName, "", requestBody)
        } else {
            val file: File = File(Utils.getRealPathFromURI(applicationContext, uri))
            val requestBody =
                RequestBody.create(contentResolver.getType(uri)?.toMediaTypeOrNull(), file)
            MultipartBody.Part.createFormData(partName, file.name, requestBody)
        }

    }
}
