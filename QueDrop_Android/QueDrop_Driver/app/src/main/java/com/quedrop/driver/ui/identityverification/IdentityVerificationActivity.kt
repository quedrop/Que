package com.quedrop.driver.ui.identityverification

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import co.csadev.kwikpicker.KwikPicker
import com.bumptech.glide.Glide
import com.bumptech.glide.request.target.CustomTarget
import com.bumptech.glide.request.transition.Transition
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.DriverDetails
import com.quedrop.driver.service.model.UpdateIdentityModel
import com.quedrop.driver.service.model.User
import com.quedrop.driver.service.request.IdentityRequest
import com.quedrop.driver.ui.mainActivity.view.MainActivity
import com.quedrop.driver.ui.register.viewModel.RegisterViewModel
import com.quedrop.driver.utils.*
import com.google.gson.Gson
import com.tbruyelle.rxpermissions2.RxPermissions
import com.yalantis.ucrop.UCrop
import kotlinx.android.synthetic.main.activity_identity_verification.*
import kotlinx.android.synthetic.main.toolbar_normal.*
import okhttp3.MediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody
import java.io.File


class IdentityVerificationActivity : BaseActivity() {

    private lateinit var mContext: Context
    private var imagePosition = -1
    private var imageKeyName = ""
    private var vehicleType = ""
    private var imageList: ArrayList<Any> = arrayListOf(0, 0, 0, 0)
    private lateinit var registerViewModel: RegisterViewModel
    private lateinit var rxPermissions: RxPermissions
    private var user: User? = null

    private var fromEditIdentityScreen: Boolean = false
    private lateinit var identityDetail: DriverDetails
    private var updateIdentityList: MutableList<UpdateIdentityModel>? = null

    var isSelectedBycyle: Boolean = false


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_identity_verification)

        mContext = this

        registerViewModel = RegisterViewModel(appService)
        rxPermissions = RxPermissions(this)

        user = SharedPreferenceUtils.getModelPreferences(KEY_USER, User::class.java) as User?

        val identity = intent?.getStringExtra(KEY_EDIT_IDENTITY)
        if (identity != null) {

            identityDetail = Gson().fromJson(identity, DriverDetails::class.java)
            setUpData(identityDetail)


        }
        fromEditIdentityScreen = intent?.getBooleanExtra(KEY_FROM_EDIT_IDENTITY, false)!!

        initViews()
    }

    private fun initViews() {
        observeViewModel()
        setUpToolbar()
        onClickView()
        if (fromEditIdentityScreen) {
            btnDone.text = getString(R.string.save)
        } else {
            btnDone.text = getString(R.string.done)

        }
    }

    private fun loadBitmapGlide(updateIdentityModel: UpdateIdentityModel) {

        Glide.with(this)
            .asBitmap()
            .load(updateIdentityModel.imagePath)
            .into(object : CustomTarget<Bitmap>() {

                override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap>?) {
                    updateIdentityModel.imageView.setImageBitmap(resource)
                    val mPath = BitmapHelper.saveCompressImage(resource)

                    imageList[updateIdentityModel.position] = updateMultiPartImage(mPath)

                }

                override fun onLoadCleared(placeholder: Drawable?) {
                }
            })
    }

    private fun setUpData(it: DriverDetails) {
        //if this is from ic_edit_pen identity screen
        vehicleType = it.vehicleType!!

        val imageExtension: String = BuildConfig.BASE_URL + ImageConstant.DRIVER_DETAILS
        updateIdentityList = mutableListOf()

        updateIdentityList?.add(UpdateIdentityModel(0, imageExtension + it.licencePhoto, ivLicense))
        updateIdentityList?.add(UpdateIdentityModel(1, imageExtension + it.driverPhoto, ivProfile))
        updateIdentityList?.add(
            UpdateIdentityModel(
                2,
                imageExtension + it.registrationProof,
                ivRegProof
            )
        )
        updateIdentityList?.add(
            UpdateIdentityModel(
                3,
                imageExtension + it.numberPlate,
                ivAddNumberPlate
            )
        )

        for (i in 0 until updateIdentityList?.size!!) {
            loadBitmapGlide(updateIdentityList!![i])
        }

        when (it.vehicleType) {
            TYPE_CAR -> {
                whenCycle(false)
                isSelectedBycyle = false
                ivCar.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_car_selected
                    )
                )
                ivBike.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_scooter_normal
                    )
                )
                ivCycle.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_cycle_normal
                    )
                )
            }
            TYPE_BIKE -> {
                whenCycle(false)
                isSelectedBycyle = false
                ivCar.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_car_normal
                    )
                )
                ivBike.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_scooter_selected
                    )
                )
                ivCycle.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_cycle_normal
                    )
                )
            }
            TYPE_CYCLE -> {
                whenCycle(true)
                isSelectedBycyle = true
                ivCar.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_car_normal
                    )
                )
                ivBike.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_scooter_normal
                    )
                )
                ivCycle.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_cycle_selected
                    )
                )
            }
        }

    }


    private fun observeViewModel() {
        registerViewModel.identityData.observe(this, Observer { isVerify ->
            if (isVerify) {
                hideProgress()

                val user =
                    (SharedPreferenceUtils.getModelPreferences(KEY_USER, User::class.java)) as User?


                if (user != null) {
                    user.isDriverVerified = 0
                    user.isIdentityDetailUploaded = 1
                    SharedPreferenceUtils.setModelPreferences(KEY_USER, user)
                }

                startActivityWithDefaultAnimations(
                    Intent(
                        this,
                        MainActivity::class.java
                    )
                )
                finish()
            }
        })
    }

    private fun onClickView() {
        ivCar.throttleClicks().subscribe {
            isSelectedBycyle = false
            vehicleType = "Car"
            whenCycle(false)
            ivCar.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.ic_car_selected))
            ivBike.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.ic_scooter_normal))
            ivCycle.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.ic_cycle_normal))
        }.autoDispose(compositeDisposable)

        ivBike.throttleClicks().subscribe {
            isSelectedBycyle = false
            vehicleType = "Bike"
            whenCycle(false)
            ivCar.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.ic_car_normal))
            ivBike.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.ic_scooter_selected))
            ivCycle.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.ic_cycle_normal))
        }.autoDispose(compositeDisposable)

        ivCycle.throttleClicks().subscribe {
            isSelectedBycyle = true
            vehicleType = "Cycle"
            whenCycle(true)
            ivCar.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.ic_car_normal))
            ivBike.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.ic_scooter_normal))
            ivCycle.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.ic_cycle_selected))

        }.autoDispose(compositeDisposable)


        ivLicense.throttleClicks().subscribe {
            imagePosition = 0
            imageKeyName = KEY_LICENCE_PHOTO
            requestStoragePermission()
        }.autoDispose(compositeDisposable)

        ivProfile.throttleClicks().subscribe {
            imagePosition = 1
            imageKeyName = KEY_DRIVER_PHOTO
            requestStoragePermission()
        }.autoDispose(compositeDisposable)

        ivRegProof.throttleClicks().subscribe {
            imagePosition = 2
            imageKeyName = KEY_REGISTRATION_PROOF
            requestStoragePermission()
        }.autoDispose(compositeDisposable)

        ivAddNumberPlate.throttleClicks().subscribe {
            imagePosition = 3
            imageKeyName = KEY_NUMBER_PLATE
            requestStoragePermission()
        }.autoDispose(compositeDisposable)


        btnDone.throttleClicks().subscribe {
            if (validateInputs()) {
                showProgress()
                registerViewModel.updateIdentity(getIdentityRequest())
            }
        }.autoDispose(compositeDisposable)
    }

    private fun getIdentityRequest(): IdentityRequest {

        val emptyFile = RequestBody.create(MediaType.parse("text/plain"), "")
        val requestBody = MultipartBody.Part.createFormData(imageKeyName, "", emptyFile)

        if (isSelectedBycyle) {

            return IdentityRequest(
                getStringRequestBody(SharedPreferenceUtils.getString(KEY_TOKEN)),
                getStringRequestBody(ACCESS_KEY),
                getStringRequestBody(user!!.userId.toString()),
                getStringRequestBody(vehicleType),
                setEmptyImage(KEY_LICENCE_PHOTO),
                imageList[1] as MultipartBody.Part,
                setEmptyImage(KEY_REGISTRATION_PROOF),
                setEmptyImage(KEY_NUMBER_PLATE)
            )

        } else {

            if (imageList[0] != 0 && imageList[1] != 0 && imageList[2] != 0 && imageList[3] != 0) {

                return IdentityRequest(
                    getStringRequestBody(SharedPreferenceUtils.getString(KEY_TOKEN)),
                    getStringRequestBody(ACCESS_KEY),
                    getStringRequestBody(user!!.userId.toString()),
                    getStringRequestBody(vehicleType),
                    imageList[0] as MultipartBody.Part,
                    imageList[1] as MultipartBody.Part,
                    imageList[2] as MultipartBody.Part,
                    imageList[3] as MultipartBody.Part
                )
            } else {

                return IdentityRequest(
                    getStringRequestBody(SharedPreferenceUtils.getString(KEY_TOKEN)),
                    getStringRequestBody(ACCESS_KEY),
                    getStringRequestBody(user!!.userId.toString()),
                    getStringRequestBody(vehicleType),
                    setEmptyImage(KEY_LICENCE_PHOTO),
                    setEmptyImage(KEY_DRIVER_PHOTO),
                    setEmptyImage(KEY_REGISTRATION_PROOF),
                    setEmptyImage(KEY_NUMBER_PLATE)
                )

            }
        }
    }

    /*  private fun validateInputs(): Boolean {
        if (vehicleType.isEmpty()) {
            showInfoMessage(this, "Please Select Vehicle Type")
            return false
        }

        if (!isSelectedBycyle) {
            for (i in 0 until imageList.size) {
                if (imageList[i] == 0) {
                    showInfoMessage(this, "Please Upload All Images")
                    return false
                }
            }
        }
        return true

    }*/

    private fun validateInputs(): Boolean {

        if (imageList[0] == 0 && !isSelectedBycyle) {
            showInfoMessage(this, "Please Upload licence pic")
            return false
        } else if (imageList[1] == 0) {
            showInfoMessage(this, "Please Upload profile pic")
            return false
        } else if (vehicleType.isEmpty()) {
            showInfoMessage(this, "Please Select Vehicle Type")
            return false
        } else if (imageList[2] == 0 && !isSelectedBycyle) {
            showInfoMessage(this, "Please Upload Registration pic")
            return false
        } else if (imageList[3] == 0 && !isSelectedBycyle) {
            showInfoMessage(this, "Please Upload Numberplate")
            return false
        }
        return true
    }

    private fun setUpToolbar() {
        if (!fromEditIdentityScreen) {
            tvTitle.text = "Identity Verification"
        } else {
            tvTitle.text = "Edit Identity Details"
        }
        ivBack.throttleClicks().subscribe {
            finish()
        }.autoDispose(compositeDisposable)
    }


    @SuppressLint("CheckResult")
    private fun requestStoragePermission() {
        rxPermissions
            .request(Manifest.permission.CAMERA, Manifest.permission.WRITE_EXTERNAL_STORAGE)
            .subscribe { granted ->
                if (granted) {
                    val kwikPicker = KwikPicker.Builder(
                        this@IdentityVerificationActivity,
                        imageProvider = { imageView, uri ->
                            Glide.with(this)
                                .load(uri)
                                .into(imageView)
                        },
                        onImageSelectedListener = { uri: Uri ->
                            UCrop.of(
                                uri,
                                Uri.fromFile(
                                    File(
                                        cacheDir,
                                        "QueDrop_" + System.currentTimeMillis() + ".jpg"
                                    )
                                )
                            )
                                .withAspectRatio(16f, 9f)
                                .withMaxResultSize(720, 720)
                                .start(this)
                            // val imageFilePath = getCompressedFilePath(this,uri.path.toString())

                        },
                        peekHeight = 1200
                    )
                        .create(this)
                    kwikPicker.show(supportFragmentManager)

                } else {
                    requestStoragePermission()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK && requestCode == UCrop.REQUEST_CROP) {
            val resultUri = UCrop.getOutput(data!!)
            setImageToRespectedField(resultUri, imagePosition)
        } else if (resultCode == UCrop.RESULT_ERROR) {
            val cropError = UCrop.getError(data!!)
        }
    }

    private fun setImageToRespectedField(resultUri: Uri?, imagePosition: Int) {
        resultUri?.let {
            when (imagePosition) {
                0 -> {
                    Glide.with(this).load(resultUri).placeholder(R.drawable.placeholder_identity)
                        .into(ivLicense)
                    getMultiPartImage(resultUri.path!!)
                }
                1 -> {
                    Glide.with(this).load(resultUri).placeholder(R.drawable.placeholder_identity)
                        .into(ivProfile)
                    getMultiPartImage(resultUri.path!!)
                }
                2 -> {
                    Glide.with(this).load(resultUri).placeholder(R.drawable.placeholder_identity)
                        .into(ivRegProof)
                    getMultiPartImage(resultUri.path!!)
                }
                3 -> {
                    Glide.with(this).load(resultUri).placeholder(R.drawable.placeholder_identity)
                        .into(ivAddNumberPlate)
                    getMultiPartImage(resultUri.path!!)
                }
            }
        }
    }


    private fun getMultiPartImage(path: String) {
        val file = File(path)
        val fileReqBody = RequestBody.create(MediaType.parse("image/*"), file)
        imageList[imagePosition] =
            MultipartBody.Part.createFormData(imageKeyName, file.name, fileReqBody)
    }

    private fun setEmptyImage(keyName:String): MultipartBody.Part {
        val emptyFile = RequestBody.create(MediaType.parse("text/plain"), "")
        val requestBody = MultipartBody.Part.createFormData(keyName, "", emptyFile)
        return requestBody
    }

    private fun updateMultiPartImage(path: String): MultipartBody.Part {
        val file = File(path)
        val fileReqBody = RequestBody.create(MediaType.parse("image/*"), file)
        return MultipartBody.Part.createFormData(imageKeyName, file.name, fileReqBody)
    }

    private fun getStringRequestBody(value: String): RequestBody {
        return RequestBody.create(MediaType.parse("text/plain"), value)
    }

    fun whenCycle(hide: Boolean) {
        if (hide) {
            tvAddLicense.visibility = View.GONE
            ivLicense.visibility = View.GONE
            tvAddRegProof.visibility = View.GONE
            ivRegProof.visibility = View.GONE
            tvAddNumberPlate.visibility = View.GONE
            ivAddNumberPlate.visibility = View.GONE
        } else {
            tvAddLicense.visibility = View.VISIBLE
            ivLicense.visibility = View.VISIBLE
            tvAddRegProof.visibility = View.VISIBLE
            ivRegProof.visibility = View.VISIBLE
            tvAddNumberPlate.visibility = View.VISIBLE
            ivAddNumberPlate.visibility = View.VISIBLE
        }
    }

}
