package com.quedrop.customer.ui.supplier.suppliercreatestore

import android.content.Intent
import android.os.Bundle
import com.bumptech.glide.Glide
import com.google.gson.JsonObject
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.RuntimePermissionActivity
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.customer.ui.supplier.store.adapter.DaysAdapter
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.PspDialogUtils.Companion.INTENT_PICK_CAMERA
import com.quedrop.customer.utils.PspDialogUtils.Companion.INTENT_PICK_GALLERY
import com.quedrop.customer.utils.PspFileUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_store_detail.*
import kotlinx.android.synthetic.main.activity_supplier_create_store.*
import timber.log.Timber

class SupplierCreateStoreActivity : RuntimePermissionActivity() {

    private lateinit var profileViewModel: ProfileViewModel
    private var dayAdapter: DaysAdapter? = null

    override fun onPermissionsGranted(requestCode: Int, isGranted: Boolean) {
        if (requestCode == ARRAY_PERMISSION_CODE && isGranted) {
            pspDialogUtils?.openCameraGalleryDialog()
        } else {
            showAlert("Please allow storage permission")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_supplier_create_store)

        profileViewModel = ProfileViewModel(apiService = appService)

        Utils.Supplier.supplierUserId = SharedPrefsUtils.getIntegerPreference(this, KeysUtils.KeyUserSupplierId, 0)
        Utils.Supplier.supplierAccessKey = SharedPrefsUtils.getStringPreference(this, KeysUtils.KeySupplierAccessKey)!!
        Utils.seceretKey = SharedPrefsUtils.getStringPreference(this, KeysUtils.keySecretKey)!!

        initViews()
    }

    private fun initViews() {
        setAdapter()
        callGetStoreDetails()
        onClickViews()
    }

    private fun setAdapter() {
        if (dayAdapter == null) {
            dayAdapter = DaysAdapter(this, tvDaysEmptyView, false)
            rvCreateStoreDay.adapter = dayAdapter
        }
    }

    private fun onClickViews() {

        icUploadStoreImage.throttleClicks().subscribe {
            if (hasPermissions(this)) {
                pspDialogUtils?.openCameraGalleryDialog()
            } else {
                requestAppPermissions(ARRAY_PERMISSIONS, R.string.app_name, ARRAY_PERMISSION_CODE)
            }
        }.autoDispose(compositeDisposable)
    }

    private fun callGetStoreDetails() {
        val jsonObject = JsonObject()
        jsonObject.addProperty("store_id", Utils.Supplier.supplierStoreID)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)

        profileViewModel.getStoreDetails(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({
                if (it.status) {
                    profileViewModel.storeDetail.value = it.data?.get("store_detail")
                } else {
                    Timber.e(it.message)
                }
            }, {
                Timber.e(it.localizedMessage)
            }).autoDispose(compositeDisposable)
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == INTENT_PICK_CAMERA && resultCode == RESULT_OK) {
            if (pspDialogUtils?.getCurrentImageUri != null) {
                val path = PspFileUtils.getPath(this, pspDialogUtils?.getCurrentImageUri)
                Timber.e(path)
                Glide.with(this)
                    .load(path)
                    .into(ivProfileImage)

            }
        } else if (requestCode == INTENT_PICK_GALLERY && resultCode == RESULT_OK) {
            if (data?.data != null) {
                val path = PspFileUtils.getPath(this, data.data)
                Timber.e(path)
                Glide.with(this)
                    .load(path)
                    .into(ivProfileImage)
            }
        }
    }
}