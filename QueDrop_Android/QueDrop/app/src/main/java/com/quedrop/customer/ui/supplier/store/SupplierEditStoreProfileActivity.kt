package com.quedrop.customer.ui.supplier.store

import android.app.Activity
import android.app.Dialog
import android.app.TimePickerDialog
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.view.Window
import android.widget.*
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.quedrop.customer.R
import com.quedrop.customer.base.RuntimePermissionActivity
import com.quedrop.customer.base.extentions.getDateInFormatOf
import com.quedrop.customer.base.extentions.getStoreSlideImage
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.*
import com.quedrop.customer.ui.home.viewmodel.HomeCustomerViewModel
import com.quedrop.customer.ui.storeadd.view.PlaceAutoCompleteSearchActivity
import com.quedrop.customer.ui.supplier.HomeSupplierActivity
import com.quedrop.customer.ui.supplier.store.adapter.DaysAdapter
import com.quedrop.customer.ui.supplier.store.adapter.EditStoreImagesAdapter
import com.quedrop.customer.ui.supplier.store.adapter.ServiceCategoryAdapter
import com.quedrop.customer.ui.supplier.store.viewmodel.EditStoreDetailViewModel
import com.quedrop.customer.utils.*
import com.zfdang.multiple_images_selector.ImagesSelectorActivity
import com.zfdang.multiple_images_selector.SelectorSettings
import io.reactivex.android.schedulers.AndroidSchedulers
import kotlinx.android.synthetic.main.activity_supplier_edit_store_profile.*
import kotlinx.android.synthetic.main.activity_supplier_edit_store_profile.btnStoreSave
import kotlinx.android.synthetic.main.activity_supplier_edit_store_profile.clAddStore
import kotlinx.android.synthetic.main.activity_supplier_edit_store_profile.etStoreAddress
import kotlinx.android.synthetic.main.activity_supplier_edit_store_profile.etStoreName
import kotlinx.android.synthetic.main.activity_supplier_edit_store_profile.icUploadStoreImage
import kotlinx.android.synthetic.main.activity_supplier_edit_store_profile.ivBackCreateStore
import kotlinx.android.synthetic.main.activity_supplier_edit_store_profile.ivStoreNoImage
import kotlinx.android.synthetic.main.activity_supplier_edit_store_profile.rvCreateStoreDay
import kotlinx.android.synthetic.main.activity_supplier_edit_store_profile.rvStoreSliderImages
import kotlinx.android.synthetic.main.activity_supplier_edit_store_profile.tvDaysEmptyView
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import timber.log.Timber
import java.io.File
import java.util.*
import kotlin.collections.ArrayList


class SupplierEditStoreProfileActivity : RuntimePermissionActivity() {

    private lateinit var editStoreDetailViewModel: EditStoreDetailViewModel
    private lateinit var homeCustomerViewModel: HomeCustomerViewModel

    private lateinit var profileImagesAdapter: EditStoreImagesAdapter
    private lateinit var serviceCategoryAdapter: ServiceCategoryAdapter
    var adapter: DaysAdapter? = null


    private var storeDetail: SupplierStoreDetail? = null

    private var mResults: ArrayList<String> = ArrayList()
    private var mDeletedImages: ArrayList<String> = ArrayList()
    private var mServiceCategoryList: MutableList<Categories> = mutableListOf()

    lateinit var deleteSliderArray: String
    private val dateDisplayFormat = "HH:mm:ss"
    val REQUEST_CODE = 100
    var imageProfilePath: String = ""
    var latitude: String = "0.0"
    var longitude: String = "0.0"
    var serviceCategoryId: Int? = null


    override fun onPermissionsGranted(requestCode: Int, isGranted: Boolean) {
        if (requestCode == ARRAY_PERMISSION_CODE && isGranted) {
            pspDialogUtils?.openCameraGalleryDialog()
        } else {
            showAlert("Please allow storage permission")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_supplier_edit_store_profile)

        Utils.seceretKey = SharedPrefsUtils.getStringPreference(this, KeysUtils.keySecretKey)!!
        Utils.Supplier.supplierAccessKey =
            SharedPrefsUtils.getStringPreference(this, KeysUtils.KeySupplierAccessKey)!!
        Utils.Supplier.supplierUserId =
            SharedPrefsUtils.getIntegerPreference(this, KeysUtils.KeyUserSupplierId, 0)
        Utils.Supplier.supplierStoredCreated = SharedPrefsUtils.getBooleanPreference(
            applicationContext,
            KeysUtils.KeyStoreCreated,
            false
        )

        editStoreDetailViewModel = EditStoreDetailViewModel(appService)
        homeCustomerViewModel = HomeCustomerViewModel(appService)

        initViews()
    }

    private fun initViews() {

        setUpAdapter()
        onClickViews()
        getAllCategoriesApi()
        observeViewModel()

        if (Utils.Supplier.supplierStoredCreated) {
            txtCreateStoreTitle.text = getString(R.string.create_store)
            //days images
            val arrWeekDay = arrayOf<String>(
                "Sunday",
                "Monday",
                "Tuesday",
                "Wednesday",
                "Thursday",
                "Friday",
                "Saturday"
            )
            for (strWeekDay in arrWeekDay) {
                val obj = StoreSchedule(
                    0,
                    "00:00:00",
                    "23:59:59",
                    strWeekDay,
                    0
                )
                adapter?.dayList?.add(obj)
            }
            storeDetail?.schedule = adapter?.dayList as ArrayList<StoreSchedule>

            //slider images
//            mResults.add(R.drawable.addstore.toString())
//            rvStoreSliderImages.visibility = View.VISIBLE
            ivStoreNoImage.visibility = View.VISIBLE
//            profileImagesAdapter.updateImages(mResults)

        } else {
            txtCreateStoreTitle.text = getString(R.string.edit_store_profile)
            if (intent.hasExtra("storeDetail")) {
                storeDetail = intent.getSerializableExtra("storeDetail") as SupplierStoreDetail
            }
            setData()
        }
    }

    private fun observeViewModel() {

        editStoreDetailViewModel.errorMessage.observe(this, androidx.lifecycle.Observer {
            hideProgress()
            Toast.makeText(this, it, Toast.LENGTH_SHORT).show()
        })


        editStoreDetailViewModel.message.observe(this, androidx.lifecycle.Observer {
            hideProgress()
            Toast.makeText(this, it, Toast.LENGTH_SHORT).show()
        })

        editStoreDetailViewModel.storeDetail.observe(this, androidx.lifecycle.Observer {
            hideProgress()
            if (Utils.Supplier.supplierStoredCreated) {
                SharedPrefsUtils.setBooleanPreference(
                    applicationContext,
                    KeysUtils.KeyStoreCreated,
                    false
                )
                SharedPrefsUtils.setIntegerPreference(
                    applicationContext,
                    KeysUtils.keySupplierStoreId,
                    it.store_id
                )

                val intent = Intent(this, HomeSupplierActivity::class.java)
                intent.flags =
                    Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                startActivityWithDefaultAnimations(intent)
                finish()
            } else {
                RxBus.instance?.publish(it)
                onBackPressed()
            }
        })

        homeCustomerViewModel.errorMessage.observe(this,
            androidx.lifecycle.Observer {
                hideProgress()
            })

        homeCustomerViewModel.categoriesList.observe(this,
            androidx.lifecycle.Observer {
                hideProgress()
                mServiceCategoryList = it.toMutableList()
            })
    }


    private fun onClickViews() {

        etServiceCategory.throttleClicks().subscribe {
            openServiceCategoryChooserDialog()
        }.autoDispose(compositeDisposable)

        icUploadStoreImage.throttleClicks().subscribe {
            if (hasPermissions(this)) {
                pspDialogUtils?.openCameraGalleryDialog()
            } else {
                requestAppPermissions(ARRAY_PERMISSIONS, R.string.app_name, ARRAY_PERMISSION_CODE)
            }
        }.autoDispose(compositeDisposable)

        ivBackCreateStore.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        btnStoreSave.throttleClicks().subscribe {
            mResults.remove(R.drawable.addstore.toString())

            val mAllImages = ArrayList<String>()
            mAllImages.addAll(mResults)
            mResults.clear()
            for (i in 0 until mAllImages.size) {
                if (isLocalPath(mAllImages.get(i))) {
                    mResults.add(mAllImages[i])
                }
            }
            if (validateAddStore()) {
                getAddProductCartApi()
            }

        }.autoDispose(compositeDisposable)

        etStoreAddress.throttleClicks().subscribe {
            val intent = Intent(this, PlaceAutoCompleteSearchActivity::class.java)
            startActivityForResult(intent, ConstantUtils.REQUEST_PLACE_ADD)
        }.autoDispose(compositeDisposable)

        clAddStore.throttleClicks().subscribe {
            val intent = Intent(this, ImagesSelectorActivity::class.java)
            intent.putExtra(SelectorSettings.SELECTOR_MAX_IMAGE_NUMBER, 100)
            intent.putExtra(SelectorSettings.SELECTOR_MIN_IMAGE_SIZE, 100000)
            intent.putExtra(SelectorSettings.SELECTOR_SHOW_CAMERA, true)
            intent.putStringArrayListExtra(
                SelectorSettings.SELECTOR_INITIAL_SELECTED_LIST,
                mResults
            )
            startActivityForResult(intent, REQUEST_CODE)
        }.autoDispose(compositeDisposable)

    }

    private fun setUpAdapter() {
        //days adapter
        if (adapter == null) {
            adapter = DaysAdapter(
                this,
                tvDaysEmptyView,
                true
            ).apply {
                onClick = { position, clickType, dayList ->
                    if (clickType == 0 || clickType == 1) {
                        openTimePicker(Calendar.getInstance(), position, clickType, dayList)
                    }
                }
                onSwitchClickListener = { pos, dayList, isClosed ->
//                    if (isClosed == 0) {
//                        storeDetail?.schedule?.get(pos)!!.is_closed = 1
//                        adapter?.dayList = storeDetail?.schedule!!
//                        adapter?.notifyDataSetChanged()
//                    } else {
//                        storeDetail?.schedule?.get(pos)!!.is_closed = 0
//                        storeDetail?.schedule?.get(pos)!!.opening_time = "00:00:00"
//                        storeDetail?.schedule?.get(pos)!!.closing_time = "23:59:59"
//                        adapter?.dayList = storeDetail?.schedule!!
//                        adapter?.notifyDataSetChanged()
//                    }

                    if (isClosed == 0) {
                        dayList[pos].is_closed = 1
                        adapter?.dayList = dayList
                        adapter?.notifyDataSetChanged()
                    } else {
                        dayList[pos].is_closed = 0
                        dayList[pos].opening_time = "00:00:00"
                        dayList[pos].closing_time = "23:59:59"
                        adapter?.dayList = dayList
                        adapter?.notifyDataSetChanged()
                    }
                }
            }
            rvCreateStoreDay.layoutManager = LinearLayoutManager(this)
            rvCreateStoreDay.adapter = adapter
        }


        //slider Image
        rvStoreSliderImages.layoutManager = GridLayoutManager(this, 3)

        profileImagesAdapter = EditStoreImagesAdapter()
        rvStoreSliderImages.adapter = profileImagesAdapter

        compositeDisposable.add(
            profileImagesAdapter.getCategoryClickObservable()
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe { triple ->
                    when (triple.first) {
                        EditStoreImagesAdapter.TYPE_CANCEL -> {
                            if (!isLocalPath(mResults[triple.second])) {
                                mDeletedImages.add(
                                    "" + storeDetail?.slider_images?.get(
                                        triple
                                            .second
                                    )?.slider_image_id
                                )
                            }
                            if (triple.third.size > 2) {
                                rvStoreSliderImages.visibility = View.VISIBLE
                                ivStoreNoImage.visibility = View.GONE
                                mResults.removeAt(triple.second)
                                profileImagesAdapter.updateImages(mResults)
                            } else {
                                mResults.clear()
                                rvStoreSliderImages.visibility = View.GONE
                                ivStoreNoImage.visibility = View.VISIBLE
                            }
                        }
                        EditStoreImagesAdapter.TYPE_SELECT -> {
                            if (triple.third[mResults.lastIndex] == R.drawable.addstore.toString()) {
                                mResults.removeAt(triple.third.lastIndex)
                                val intent = Intent(this, ImagesSelectorActivity::class.java)
                                intent.putExtra(SelectorSettings.SELECTOR_MAX_IMAGE_NUMBER, 100)
                                intent.putExtra(SelectorSettings.SELECTOR_MIN_IMAGE_SIZE, 100000)
                                intent.putExtra(SelectorSettings.SELECTOR_SHOW_CAMERA, true)
                                intent.putStringArrayListExtra(
                                    SelectorSettings.SELECTOR_INITIAL_SELECTED_LIST,
                                    mResults
                                )
                                startActivityForResult(intent, REQUEST_CODE)
                            }
                        }
                    }
                }
        )
    }


    private fun isLocalPath(path: String): Boolean {
        return !(path.startsWith("http") || path.startsWith("https"))
    }

    private fun setData() {

        Glide.with(this)
            .load(URLConstant.nearByStoreUrl + storeDetail?.store_logo)
            .placeholder(R.drawable.placeholder_order_cart_product)
            .diskCacheStrategy(DiskCacheStrategy.ALL)
            .into(ivStoreProfileImage)

        etStoreName.setText(storeDetail?.store_name)
        etStoreAddress.setText(storeDetail?.store_address)
        etServiceCategory.text = storeDetail?.service_category_name
        serviceCategoryId = storeDetail?.service_category_id

        adapter?.dayList = storeDetail?.schedule!!
        // adapter?.notifyDataSetChanged()

        for (i in 0 until storeDetail?.slider_images?.size!!) {
            mResults.add(getStoreSlideImage(storeDetail?.slider_images?.get(i)!!.slider_image))
        }
        mResults.add(R.drawable.addstore.toString())
        rvStoreSliderImages.visibility = View.VISIBLE
        ivStoreNoImage.visibility = View.GONE
        profileImagesAdapter.updateImages(mResults)

    }

    private fun openTimePicker(
        cal: Calendar,
        position: Int,
        clickType: Int,
        dayList: MutableList<StoreSchedule>
    ) {
        val tpd = TimePickerDialog(
            this,
            R.style.SlyCalendarTimeDialogTheme,
            TimePickerDialog.OnTimeSetListener { view, hour, minute ->
                cal.set(Calendar.HOUR_OF_DAY, hour)
                cal.set(Calendar.MINUTE, minute)

                val selectedDate = cal.getDateInFormatOf(dateDisplayFormat)
                if (clickType == 0) {
                    dayList[position].opening_time = selectedDate
                } else if (clickType == 1) {
                    dayList[position].closing_time = selectedDate
                }

                adapter?.dayList = dayList
                adapter?.notifyDataSetChanged()

            },
            cal.get(Calendar.HOUR_OF_DAY),
            cal.get(Calendar.MINUTE),
            false
        )
        tpd.show()
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == RESULT_OK) {
            if (requestCode == REQUEST_CODE) {
                mResults = data?.getStringArrayListExtra(SelectorSettings.SELECTOR_RESULTS)!!
                if (mResults.size > 0) {
                    mResults.add(R.drawable.addstore.toString())
                    rvStoreSliderImages.visibility = View.VISIBLE
                    ivStoreNoImage.visibility = View.GONE
                    profileImagesAdapter.updateImages(mResults)
                } else {
                    rvStoreSliderImages.visibility = View.GONE
                    ivStoreNoImage.visibility = View.VISIBLE
                }
            }
        } else {
            if (mResults.size > 0) {
                mResults.add(R.drawable.addstore.toString())
                rvStoreSliderImages.visibility = View.VISIBLE
                ivStoreNoImage.visibility = View.GONE
                profileImagesAdapter.updateImages(mResults)
            } else {
                rvStoreSliderImages.visibility = View.GONE
                ivStoreNoImage.visibility = View.VISIBLE
            }
        }
        if (requestCode == ConstantUtils.REQUEST_PLACE_ADD && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                val placeAddressTitle = data.getStringExtra(KeysUtils.keyPlaceTitle)
                val placeAddressAddress = data.getStringExtra(KeysUtils.keyPlaceAddress)
                etStoreAddress.setText(placeAddressAddress)

                if (Utils.Supplier.supplierStoredCreated) {
                    latitude = data.getDoubleExtra(KeysUtils.keyPlaceLongitude, 0.0).toString()
                    longitude = data.getDoubleExtra(KeysUtils.keyPlaceLongitude, 0.0).toString()
                } else {
                    storeDetail?.latitude =
                        data.getDoubleExtra(KeysUtils.keyPlaceLongitude, 0.0).toString()
                    storeDetail?.latitude =
                        data.getDoubleExtra(KeysUtils.keyPlaceLongitude, 0.0).toString()
                }
            }
        }

        if (requestCode == PspDialogUtils.INTENT_PICK_CAMERA && resultCode == RESULT_OK) {
            if (pspDialogUtils?.getCurrentImageUri != null) {
                imageProfilePath = PspFileUtils.getPath(this, pspDialogUtils?.getCurrentImageUri)
                Timber.e(imageProfilePath)
                Glide.with(this)
                    .load(imageProfilePath)
                    .diskCacheStrategy(DiskCacheStrategy.ALL)
                    .into(ivStoreProfileImage)

            }
        } else if (requestCode == PspDialogUtils.INTENT_PICK_GALLERY && resultCode == RESULT_OK) {
            if (data?.data != null) {
                imageProfilePath = PspFileUtils.getPath(this, data.data)
                Timber.e(imageProfilePath)
                Glide.with(this)
                    .load(imageProfilePath)
                    .diskCacheStrategy(DiskCacheStrategy.ALL)
                    .into(ivStoreProfileImage)
            }
        }
    }

    private fun getAddProductCartApi() {
        showProgress()
        val sliderImageList: ArrayList<MultipartBody.Part> = ArrayList()
        if (mResults.size > 0) {
            for (i in 0 until mResults.size) {
                val file = File(mResults[i])  // Get File From Local File path
                val fileReqBody = file.asRequestBody("image/*".toMediaType())
                val profileImage =
                    MultipartBody.Part.createFormData("slider_image[$i]", file.name, fileReqBody)
                sliderImageList.add(profileImage)
            }
        }

        val jsonArraySchedule = JSONArray()
        adapter?.dayList?.forEach {
            val jsonObj = JSONObject()
            jsonObj.put("schedule_id", it.schedule_id)
            jsonObj.put("opening_time", it.opening_time)
            jsonObj.put("closing_time", it.closing_time)
            jsonObj.put("weekday", it.weekday)
            jsonObj.put("is_closed", it.is_closed)
            jsonArraySchedule.put(jsonObj)
        }

        if (Utils.Supplier.supplierStoredCreated) {
            editStoreDetailViewModel.createStoreDetailList(
                getStringRequestBody(etStoreName.text.toString()),
                getStringRequestBody(etStoreAddress.text.toString()),
                getStringRequestBody(latitude),
                getStringRequestBody(longitude),
                jsonArraySchedule.toString().toRequestBody(MultipartBody.FORM),
                sliderImageList,
                getStringRequestBody(Utils.seceretKey),
                getStringRequestBody(Utils.Supplier.supplierAccessKey),
                getStringRequestBody(Utils.Supplier.supplierUserId.toString()),
                updateMultiPartImage(imageProfilePath),
                getStringRequestBody(serviceCategoryId.toString())

            )
        } else {
            editStoreDetailViewModel.editStoreDetailList(
                getStringRequestBody(storeDetail?.store_id.toString()),
                getStringRequestBody(etStoreName.text.toString()),
                getStringRequestBody(etStoreAddress.text.toString()),
                getStringRequestBody(storeDetail?.latitude!!),
                getStringRequestBody(storeDetail?.longitude!!),
                jsonArraySchedule.toString().toRequestBody(MultipartBody.FORM),
                sliderImageList,
                getStringRequestBody(TextUtils.join(",", mDeletedImages)),
                getStringRequestBody(Utils.seceretKey),
                getStringRequestBody(Utils.Supplier.supplierAccessKey),
                getStringRequestBody(Utils.Supplier.supplierUserId.toString()),
                updateMultiPartImage(imageProfilePath),
                getStringRequestBody(serviceCategoryId.toString())
            )
        }

    }

    private fun updateMultiPartImage(path: String): MultipartBody.Part {
        if (path.isNullOrEmpty()) {
            val emptyFile = "".toRequestBody("text/plain".toMediaTypeOrNull())
            return MultipartBody.Part.createFormData("store_logo", "", emptyFile)
        } else {
            val file = File(path)
            val fileReqBody = file.asRequestBody("image/*".toMediaTypeOrNull())
            return MultipartBody.Part.createFormData("store_logo", file.name, fileReqBody)
        }
    }

    private fun getStringRequestBody(value: String): RequestBody {
        return value.toRequestBody("text/plain".toMediaTypeOrNull())
    }

    private fun getAllCategoriesApi() {
        showProgress()
        val allCategories = AllCategories(Utils.seceretKey, Utils.accessKey)
        homeCustomerViewModel.getAllCategoriesApi(allCategories)

    }

    private fun validateAddStore(): Boolean {

        if (!etStoreName.text?.trim().isNullOrEmpty()) {
            // if (!etServiceCategory.) {
            if (!etStoreAddress.text?.trim().isNullOrEmpty()) {
                if (Utils.Supplier.supplierStoredCreated) {
                    if (imageProfilePath.isNotEmpty()) {
                        return true
                    } else {
                        showAlert("Please select store logo")
                        return false
                    }
                } else {
                    return true
                }
            } else {
                etStoreAddress.error = "Enter store address"
                return false
            }
//            } else {
//                showAlert("Please select category")
//                return false
//            }
        } else {
            etStoreName.error = "Enter store name"
            return false
        }
    }


    override fun onBackPressed() {
        super.onBackPressed()
        finish()
    }

    private fun openServiceCategoryChooserDialog() {
        val dialog = Dialog(this)
        dialog.apply {
            setContentView(R.layout.layout_dialog_item_select)
            window?.addFlags(Window.FEATURE_NO_TITLE)
            window?.setBackgroundDrawableResource(android.R.color.transparent)
            window?.setLayout(
                (Utils.getDeviceWidth(context) * 0.90).toInt(),
                (Utils.getDeviceHeight(context) * 0.80).toInt()
            )
        }

        val imgCancel: ImageView = dialog.findViewById(R.id.img_cancel)
        val btn_next: Button = dialog.findViewById(R.id.btn_next)
        val tvTitle: TextView = dialog.findViewById(R.id.tvTitle)
        val et_search: EditText = dialog.findViewById(R.id.et_search)

        et_search.visibility = View.GONE

        tvTitle.text = "Select Service Category"
        val recyclerview: RecyclerView = dialog.findViewById(R.id.recyclerView)
        recyclerview.layoutManager = LinearLayoutManager(this)

        serviceCategoryAdapter = ServiceCategoryAdapter(this)
        recyclerview.adapter = serviceCategoryAdapter

        serviceCategoryAdapter.categoriesList = mServiceCategoryList.toMutableList()
        serviceCategoryAdapter.notifyDataSetChanged()

        imgCancel.setOnClickListener { dialog.dismiss() }
        btn_next.setOnClickListener { dialog.dismiss() }
        dialog.show()

        serviceCategoryAdapter.apply {
            onItemClick = { id, name ->
                serviceCategoryId = id
                etServiceCategory.text = name
                dialog.dismiss()
            }
        }
    }
}
