package com.quedrop.customer.ui.supplier.offers

import android.app.DatePickerDialog
import android.app.Dialog
import android.app.TimePickerDialog
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.Window
import android.widget.Button
import android.widget.EditText
import android.widget.ImageView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.getCalenderDate
import com.quedrop.customer.base.extentions.getDateInFormatOf
import com.quedrop.customer.base.extentions.showToast
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.FoodCategory
import com.quedrop.customer.model.SupplierProductOffer
import com.quedrop.customer.ui.supplier.offers.adapters.OfferCategoryAdapter
import com.quedrop.customer.ui.supplier.offers.adapters.OfferProductAdapter
import com.quedrop.customer.ui.supplier.offers.viewmodels.AddEditOfferViewModel
import com.quedrop.customer.utils.*
import com.google.gson.JsonObject
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_add_edit_offer.*
import kotlinx.android.synthetic.main.activity_add_edit_offer.btnAdd
import kotlinx.android.synthetic.main.activity_add_edit_offer.etAdditionalInfo
import kotlinx.android.synthetic.main.activity_add_edit_offer.etProductName
import kotlinx.android.synthetic.main.activity_add_edit_offer.ivBack
import kotlinx.android.synthetic.main.activity_add_edit_offer.switchActive
import kotlinx.android.synthetic.main.activity_add_edit_offer.tvTitle
import timber.log.Timber
import java.util.*

class AddEditOfferActivity : BaseActivity() {

    private var offerCategoryAdapter: OfferCategoryAdapter? = null
    private var offerProductAdapter: OfferProductAdapter? = null
    private lateinit var viewModel: AddEditOfferViewModel
    private var selectedCategory = 0
    private var selectedProduct = 0
    private var startCalender: Calendar = Calendar.getInstance()
    private var endCalender: Calendar = Calendar.getInstance()
    private lateinit var offerDetail:SupplierProductOffer
    private val dateDisplayFormat = "dd-MM-yyyy hh:mm a"
    private var isEditMode: Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_edit_offer)
        isEditMode = intent.hasExtra("isEditMode")

        Utils.Supplier.supplierUserId =
            SharedPrefsUtils.getIntegerPreference(this, KeysUtils.KeyUserSupplierId, 0)
        Utils.Supplier.supplierStoreID =
            SharedPrefsUtils.getIntegerPreference(this, KeysUtils.keySupplierStoreId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(this, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(this, KeysUtils.KeySupplierAccessKey)!!

        init()
        getCategories()
        if(isEditMode){
            offerDetail = intent.getSerializableExtra("offer") as SupplierProductOffer
            tvTitle.text = "Edit Offer"
            btnAdd.text = "Save"
            setData()
        }

    }

    private fun init() {
        viewModel = AddEditOfferViewModel(appService)
        etStartDate.setOnClickListener {
            openDatePicker(true)
        }

        etEndDate.setOnClickListener {
            openDatePicker(false)
        }

        etCategory.setOnClickListener {
            openCategoryPicker()
        }

        etProductName.setOnClickListener {
            if (selectedCategory == 0) {
                etCategory.error = "choose a category"
                showToast("please select category first")
            } else {
                openProductPicker()
            }
        }

        ivBack.setOnClickListener {
            onBackPressed()
        }

        btnAdd.setOnClickListener {
            if (validateData()) {
                addEditProductOfferApi()
            }
        }

        viewModel.categories.observe(this, androidx.lifecycle.Observer {
            if (offerCategoryAdapter != null) {
                offerCategoryAdapter?.categoryList = it
                offerCategoryAdapter?.notifyDataSetChanged()
            }
        })

        viewModel.productList.observe(this, androidx.lifecycle.Observer {
            if (offerProductAdapter != null) {
                offerProductAdapter?.productList = it
                offerProductAdapter?.notifyDataSetChanged()
            }
        })
    }

    private fun setData() {
        val dateFormat = "yyyy-MM-dd HH:mm:ss"
        startCalender = (offerDetail.start_date + " " + offerDetail.start_time)
            .getCalenderDate(dateFormat)
        endCalender = (offerDetail.expiration_date + " " + offerDetail.expiration_time)
            .getCalenderDate(dateFormat)
        selectedCategory = offerDetail.store_category_id
        selectedProduct = offerDetail.product_id

        etCategory.setText(offerDetail.store_category_title)
        etProductName.setText(offerDetail.product_name)
        etPercentage.setText(offerDetail.offer_percentage)
        etOfferCode.setText(offerDetail.offer_code)
        etStartDate.setText(startCalender.getDateInFormatOf(dateDisplayFormat))
        etEndDate.setText(endCalender.getDateInFormatOf(dateDisplayFormat))
        etAdditionalInfo.setText(offerDetail.additional_info)
    }

    private fun validateData(): Boolean {
        if (selectedCategory != 0) {
            if (selectedProduct != 0) {
                if (etPercentage.text.toString().isNotEmpty()) {
                    if (etOfferCode.text.toString().isNotEmpty()) {
                        if (etStartDate.text.toString().isNotEmpty()) {
                            if (etEndDate.text.toString().isNotEmpty()) {
                                if (etAdditionalInfo.text.toString().isNotEmpty()) {
                                    return true
                                } else {
                                    etAdditionalInfo.error = "add additional information"
                                }
                            } else {
                                etEndDate.error = "choose expire date"
                            }
                        } else {
                            etStartDate.error = "choose start date"
                        }
                    } else {
                        etOfferCode.error = "enter offer code"
                    }
                } else {
                    etPercentage.error = "enter offer percentage"
                }
            } else {
                etProductName.error = "select a product"
            }
        } else {
            etCategory.error = "select a category"
        }
        return false
    }

    private fun openDatePicker(isStartDate: Boolean) {
        var cal: Calendar = if (isStartDate) {
            startCalender
        } else {
            endCalender
        }
        val year = cal.get(Calendar.YEAR)
        val month = cal.get(Calendar.MONTH)
        val day = cal.get(Calendar.DAY_OF_MONTH)

        val dpd = DatePickerDialog(
            this,
            R.style.SlyCalendarTimeDialogTheme,
            DatePickerDialog.OnDateSetListener { view, y0, monthOfYear, dayOfMonth ->
                // val cal: Calendar = Calendar.getInstance()
                cal.set(Calendar.DAY_OF_MONTH, dayOfMonth)
                cal.set(Calendar.MONTH, monthOfYear)
                cal.set(Calendar.YEAR, y0)

                openTimePicker(cal,isStartDate)
                //selectedDate = cal.getDateInFormatOf("yyyy-MM-dd")
                //etStartDate.setText(selectedDate)
                // Log.e("selected date", selectedDate)

            },
            year,
            month,
            day
        )

        dpd.show()
    }

    private fun openTimePicker(cal: Calendar, startDate: Boolean) {
//        val hourOfDay = cal.get(Calendar.HOUR_OF_DAY)
//        val minute = cal.get(Calendar.MINUTE)
        val tpd = TimePickerDialog(
            this,
            R.style.SlyCalendarTimeDialogTheme,
            TimePickerDialog.OnTimeSetListener { view, hour, minute ->
                cal.set(Calendar.HOUR_OF_DAY, hour)
                cal.set(Calendar.MINUTE, minute)

                val selectedDate = cal.getDateInFormatOf(dateDisplayFormat)
                if(startDate){
                    etStartDate.error = null
                    etStartDate.setText(selectedDate)
                }else{
                    etEndDate.error = null
                    etEndDate.setText(selectedDate)
                }

                // Log.e("selected date", selectedDate)

            },
            cal.get(Calendar.HOUR_OF_DAY),
            cal.get(Calendar.MINUTE),
            false
        )
        tpd.show()
    }

    private fun openCategoryPicker() {
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
        val recyclerview: RecyclerView = dialog.findViewById(R.id.recyclerView)
        recyclerview.layoutManager = LinearLayoutManager(this)
        offerCategoryAdapter = OfferCategoryAdapter(this)
        recyclerview.adapter = offerCategoryAdapter
        viewModel.categories.value?.let {
            offerCategoryAdapter?.categoryList = it
            offerCategoryAdapter?.notifyDataSetChanged()
        }

        imgCancel.setOnClickListener { dialog.dismiss() }
        btn_next.setOnClickListener { dialog.dismiss() }
        dialog.show()
        val etSearch: EditText = dialog.findViewById(R.id.et_search)
        etSearch.addTextChangedListener(object : TextWatcher {
            private var searchFor = ""
            override fun afterTextChanged(p0: Editable?) {

            }

            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }

            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
                val searchText = p0.toString().trim()
                if (searchText == searchFor)
                    return

                searchFor = searchText

                val filterList = viewModel.categories.value?.filter {
                    it.store_category_title.toLowerCase().contains(searchFor.toLowerCase())
                }
                offerCategoryAdapter?.categoryList = filterList as MutableList<FoodCategory>
                offerCategoryAdapter?.notifyDataSetChanged()
            }
        })

        offerCategoryAdapter?.apply {
            onItemClick = { id, name ->
                etCategory.error = null
                etCategory.setText(name)
                selectedCategory = id
                dialog.dismiss()
                etProductName.setText("") //reset if previously added
                selectedProduct = 0 //reset if previously added
                getProducts(id)
            }
        }
    }

    private fun openProductPicker() {
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
        val recyclerview: RecyclerView = dialog.findViewById(R.id.recyclerView)
        recyclerview.layoutManager = LinearLayoutManager(this)
        offerProductAdapter = OfferProductAdapter(this)
        recyclerview.adapter = offerProductAdapter
        viewModel.productList.value?.let {
            offerProductAdapter?.productList = it
            offerProductAdapter?.notifyDataSetChanged()
        }

        imgCancel.setOnClickListener { dialog.dismiss() }
        btn_next.setOnClickListener { dialog.dismiss() }
        dialog.show()
        val etSearch: EditText = dialog.findViewById(R.id.et_search)
        etSearch.addTextChangedListener(object : TextWatcher {
            private var searchFor = ""
            override fun afterTextChanged(p0: Editable?) {

            }

            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {

            }

            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
                val searchText = p0.toString().trim()
                if (searchText == searchFor)
                    return

                searchFor = searchText
                //todo debounce remaining
                callSearchProductApi(searchFor)
            }
        })

        offerProductAdapter?.apply {
            onItemClick = { id, name ->
                etProductName.error = null
                etProductName.setText(name)
                selectedProduct = id
                dialog.dismiss()
            }
        }
    }

    private fun getCategories() {

        val jsonObject = JsonObject()
        jsonObject.addProperty("user_id", Utils.Supplier.supplierUserId)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        jsonObject.addProperty("store_id", Utils.Supplier.supplierStoreID)

        viewModel.getSupplierCategories(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({
                viewModel.categories.value = it.data?.get("categories")
            }, {
                Timber.e(it.localizedMessage)
                showToast(it.localizedMessage ?: "")
            }).autoDispose(compositeDisposable)

    }

    private fun getProducts(categoryId: Int) {
        val jsonObject = JsonObject()
        jsonObject.addProperty("store_category_id", categoryId)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        viewModel.getSupplierProducts(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({
                viewModel.productList.value = it.data?.get("products")
            }, {
                Timber.e(it.localizedMessage)
                showToast(it.localizedMessage ?: "")
            }).autoDispose(compositeDisposable)
    }

    private fun callSearchProductApi(searchtext: String) {
        val jsonObject = JsonObject()
        jsonObject.addProperty("store_category_id", selectedCategory)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        jsonObject.addProperty("searchText", searchtext)
        jsonObject.addProperty("page_num", 0)
        viewModel.searchSupplierProducts(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe {}
            .doAfterTerminate {}
            .subscribe({
                if (it != null && it.status) {
                    val products = it.data?.get("products")
                    viewModel.productList.value = products

                } else {
                    showToast(it.message)
                }
            }, {
                showToast(it.localizedMessage ?: "")
            }).autoDispose(compositeDisposable)
    }

    private fun addEditProductOfferApi() {
        var dialog: Dialog? = null
        val dateformat = "yyyy-MM-dd"
        val timeformat = "HH:mm:ss"
        val startDate = startCalender.getDateInFormatOf(dateformat)
        val endDate = endCalender.getDateInFormatOf(dateformat)
        val startTime = startCalender.getDateInFormatOf(timeformat)
        val endTime = endCalender.getDateInFormatOf(timeformat)
        val isProductActive = if (switchActive.isChecked) 1 else 0
        val jsonObject = JsonObject()
        if(isEditMode){
            jsonObject.addProperty("product_offer_id", offerDetail.product_offer_id)
        }
        jsonObject.addProperty("store_id", Utils.Supplier.supplierStoreID)
        jsonObject.addProperty("store_category_id", selectedCategory)
        jsonObject.addProperty("product_id", selectedProduct)
        jsonObject.addProperty("offer_percentage", etPercentage.text.toString())
        jsonObject.addProperty("offer_code", etOfferCode.text.toString())
        jsonObject.addProperty("start_date", startDate)
        jsonObject.addProperty("start_time", startTime)
        jsonObject.addProperty("expiration_date", endDate)
        jsonObject.addProperty("expiration_time", endTime)
        jsonObject.addProperty("additional_info", etAdditionalInfo.text.toString())
        jsonObject.addProperty("is_active", isProductActive)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        //Timber.e("request : $jsonObject")

        if(isEditMode){
            viewModel.editProductOfferApi(jsonObject)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .doOnSubscribe { dialog = DialogCaller.showProgressDialog(this) }
                .doAfterTerminate { dialog?.dismiss() }
                .subscribe({
                    if (it.status){
                        applicationContext.showToast(it.message)
                        RxBus.instance?.publish("refreshOffer")
                        finish()
                    }
                }, {
                    Timber.e(it.localizedMessage)
                    showToast(it.localizedMessage ?: "")
                }).autoDispose(compositeDisposable)

        }else{
            viewModel.addProductOfferApi(jsonObject)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .doOnSubscribe { dialog = DialogCaller.showProgressDialog(this) }
                .doAfterTerminate { dialog?.dismiss() }
                .subscribe({
                    if (it.status){
                        applicationContext.showToast(it.message)
                        RxBus.instance?.publish("refreshOffer")
                        finish()
                    }
                }, {
                    Timber.e(it.localizedMessage)
                    showToast(it.localizedMessage ?: "")
                }).autoDispose(compositeDisposable)
        }
    }
}
