package com.quedrop.customer.ui.supplier.product

import android.app.Activity
import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.widget.ImageView
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.getProductImage
import com.quedrop.customer.base.extentions.showToast
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.SupplierAddOn
import com.quedrop.customer.model.SupplierProduct
import com.quedrop.customer.model.SupplierProductOptions
import com.quedrop.customer.ui.supplier.product.adapters.CustomAddOnAdapter
import com.quedrop.customer.ui.supplier.product.adapters.CustomPriceAdapter
import com.quedrop.customer.ui.supplier.product.viewmodel.AddProductViewModel
import com.quedrop.customer.utils.*
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_add_product.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import timber.log.Timber
import java.io.ByteArrayOutputStream
import java.io.File

class AddProductActivity : BaseActivity() {

    private lateinit var viewModel: AddProductViewModel
    private var productImagePath: String? = null
    private val productOptionList: MutableList<SupplierProductOptions> = mutableListOf()
    private val addOnList: MutableList<SupplierAddOn> = mutableListOf()
    private lateinit var product: SupplierProduct
    private var priceOptionsAdapter: CustomPriceAdapter? = null
    private var addOnAdapter: CustomAddOnAdapter? = null
    private var storeCategoryId: Int = 0
    private var isEditMode: Boolean = false
    private var deletedOptions: String = ""
    private var deletedAddons: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_product)
        init()
        if (isEditMode) {
            tvCategoryAddOns.text = getString(R.string.edit_product)
            btnAdd.text = getString(R.string.btnSave)
            product = intent.getSerializableExtra("product") as SupplierProduct
            storeCategoryId = Integer.parseInt(product.store_category_id)
            setProductDetails()
        }
    }

    private fun init() {

        Utils.Supplier.supplierUserId =
            SharedPrefsUtils.getIntegerPreference(this, KeysUtils.KeyUserSupplierId, 0)
        Utils.Supplier.supplierStoreID =
            SharedPrefsUtils.getIntegerPreference(this, KeysUtils.keySupplierStoreId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(this, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(this, KeysUtils.KeySupplierAccessKey)!!

        viewModel = AddProductViewModel(appService)
        storeCategoryId = intent.getIntExtra("categoryId", 0)
        isEditMode = intent.hasExtra("isEditMode")

        if (priceOptionsAdapter == null) {
            priceOptionsAdapter = CustomPriceAdapter(this).apply {
                onDeleteClick = { position, view ->
                    deletedOptions =
                        deletedOptions.plus(productOptionList[position].option_id + ",")
                    productOptionList.removeAt(position)
                    _productOptionList = productOptionList
                    notifyDataSetChanged()
                }

                onRadioClick = { position, view ->
                    productOptionList.forEach { if (it.is_default == 1) it.is_default = 0 }
                    productOptionList[position].is_default = 1
                    _productOptionList = productOptionList
                    notifyDataSetChanged()
                }
            }
            rvPriceOption.layoutManager = LinearLayoutManager(this)
            rvPriceOption.adapter = priceOptionsAdapter
        }

        if (addOnAdapter == null) {
            addOnAdapter = CustomAddOnAdapter(this).apply {
                onDeleteClick = { position, view ->
                    deletedAddons = deletedAddons.plus(addOnList[position].addon_id + ",")
                    addOnList.removeAt(position)
                    _addOnList = addOnList
                    notifyDataSetChanged()
                }
            }
            rvAddOns.layoutManager = LinearLayoutManager(this)
            rvAddOns.adapter = addOnAdapter
        }

        ivBackAddOns.setOnClickListener {
            onBackPressed()
        }

        imgProduct.setOnClickListener {
            dialogChoosePic()
        }

        tvAddOption.setOnClickListener {
            addProductOption()
        }

        tvAddNewAddOn.setOnClickListener {
            addNewAddOn()
        }

        btnAdd.setOnClickListener {
            if (validateData()) {
                callAddEditProductApi()
            }
        }
    }

    private fun setProductDetails() {
        Glide.with(this)
            .load(getProductImage(product.product_image))
            .placeholder(R.drawable.add_picture)
            .into(imgProduct)

        etProductName.setText(product.product_name)
        etAdditionalInfo.setText(product.product_description)
        etExtraFee.setText(product.extra_fees)
        switchActive.isChecked = product.is_active == 1

        if (product.product_option.size > 0) {
            productOptionList.addAll(product.product_option)
            priceOptionsAdapter?._productOptionList = productOptionList
            priceOptionsAdapter?.notifyDataSetChanged()
        }

        if (product.addons.size > 0) {
            addOnList.addAll(product.addons)
            addOnAdapter?._addOnList = addOnList
            addOnAdapter?.notifyDataSetChanged()
        }
    }

    private fun dialogChoosePic() {

        val dialog = Dialog(this)
        dialog.setContentView(R.layout.layout_dialog_choosepic)
        val ivCamera = dialog.findViewById<ImageView>(R.id.ivCamera)
        val ivGallery = dialog.findViewById<ImageView>(R.id.ivGallery)

        ivCamera.setOnClickListener {
            choosePicCamera()
            dialog.dismiss()
        }

        ivGallery.setOnClickListener {
            choosePicGallery()
            dialog.dismiss()
        }
        dialog.show()
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

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == ConstantUtils.REQUEST_PICK_IMAGE && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                val selectedImageUri = data.data
                productImagePath =
                    Utils.getRealPathFromURI(applicationContext, selectedImageUri!!)

                Glide.with(this).load(selectedImageUri)
                    .override(800, 400)
                    .centerCrop()
                    .into(imgProduct)
            }

        } else if (requestCode == ConstantUtils.REQUEST_CAMERA && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                val thumbnail: Bitmap = data.extras?.get("data") as Bitmap
                val selectedImageUri: Uri = getImageUri(applicationContext, thumbnail)
                productImagePath = Utils.getRealPathFromURI(applicationContext, selectedImageUri)
                Glide.with(this).load(selectedImageUri)
                    .override(800, 400)
                    .centerCrop()
                    .into(imgProduct)
            }
        }
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

    private fun addProductOption() {
        var isDefault = 0
        if (productOptionList.size == 0) {
            isDefault = 1
        }
        val obj = SupplierProductOptions("0", "", "0", isDefault)
        productOptionList.add(obj)
        priceOptionsAdapter?._productOptionList = productOptionList
        priceOptionsAdapter?.notifyDataSetChanged()
    }

    private fun addNewAddOn() {
        val obj = SupplierAddOn("0", "", "0")
        addOnList.add(obj)
        addOnAdapter?._addOnList = addOnList
        addOnAdapter?.notifyDataSetChanged()

    }

    private fun validateData(): Boolean {
        if (etProductName.text.toString().isNotEmpty()) {
            if (etAdditionalInfo.text.toString().isNotEmpty()) {
                if (etExtraFee.text.toString().isNotEmpty()) {
                    if (validateOptionsAddon()) {
                        if (!isEditMode) {
                            if (!productImagePath.isNullOrEmpty()) {
                                return true
                            } else {
                                showToast("select product image")
                            }
                        }
                        return true
                    }
                } else {
                    etExtraFee.error = "Enter Extra fee"
                }
            } else {
                etAdditionalInfo.error = "Enter additional information"
            }
        } else {
            etProductName.error = "Enter product name"
        }
        return false
    }

    private fun validateOptionsAddon(): Boolean {
        if (priceOptionsAdapter!!._productOptionList.size > 0) {
            if (priceOptionsAdapter!!._productOptionList.none { it.option_name.isEmpty() || it.price.isEmpty() }) {
                if (addOnAdapter!!._addOnList.size == 0) {
                    return true
                } else {
                    if (addOnAdapter!!._addOnList.none { it.addon_name.isEmpty() || it.addon_price.isEmpty() }) {
                        return true
                    } else {
                        DialogCaller.showAlertDialog(
                            this,
                            message = "addon value should not blank.Please add or remove addon record"
                        )
                    }
                }
            } else {
                DialogCaller.showAlertDialog(
                    this,
                    message = "Price Option value should not blank.Please add or remove product Option"
                )
            }
        } else {
            showToast("Add product price option ")
        }
        return false
    }

    private fun callAddEditProductApi() {
        val jsonArrayOption = JSONArray()
        priceOptionsAdapter?._productOptionList?.forEach {
            val jsonObj = JSONObject()
            jsonObj.put("option_id", it.option_id)
            jsonObj.put("option_name", it.option_name)
            jsonObj.put("price", it.price)
            jsonObj.put("is_default", it.is_default)
            jsonArrayOption.put(jsonObj)
        }

        val jsonArrayAddon = JSONArray()
        addOnAdapter?._addOnList?.forEach {
            val jsonObj = JSONObject()
            jsonObj.put("addon_id", it.addon_id)
            jsonObj.put("addon_name", it.addon_name)
            jsonObj.put("addon_price", it.addon_price)
            jsonArrayAddon.put(jsonObj)
        }

        var body: MultipartBody.Part? = null
        productImagePath?.let {
            val fileToUpload = File(productImagePath)
            val requestBody: RequestBody =
                fileToUpload.asRequestBody(contentType = "image/*".toMediaType())
            body = MultipartBody.Part.createFormData(
                "product_image",
                fileToUpload.name, requestBody
            )
        }


        val isProductActive = if (switchActive.isChecked) 1 else 0
        var dialog: Dialog? = null
        if (isEditMode) {

            if (deletedAddons.length > 1) {
                deletedAddons = deletedAddons.substring(0, deletedAddons.length - 1)
            }

            if (deletedOptions.length > 1) {
                deletedOptions = deletedOptions.substring(0, deletedOptions.length - 1)
            }

            viewModel.editProductApi(
                product.product_id.toRequestBody(MultipartBody.FORM),
                storeCategoryId.toString().toRequestBody(MultipartBody.FORM),
                Utils.Supplier.supplierUserId.toString().toRequestBody(MultipartBody.FORM),
                etProductName.text.toString().toRequestBody(MultipartBody.FORM),
                "0".toRequestBody(MultipartBody.FORM), //todo ask for value
                etAdditionalInfo.text.toString().toRequestBody(MultipartBody.FORM),
                body,
                jsonArrayAddon.toString().toRequestBody(MultipartBody.FORM),
                "1".toRequestBody(MultipartBody.FORM), //todo ask for value
                jsonArrayOption.toString().toRequestBody(MultipartBody.FORM),
                etExtraFee.text.toString().toRequestBody(MultipartBody.FORM),
                isProductActive.toString().toRequestBody(MultipartBody.FORM),
                deletedAddons.toRequestBody(MultipartBody.FORM),
                deletedOptions.toRequestBody(MultipartBody.FORM),
                Utils.seceretKey.toRequestBody(MultipartBody.FORM),
                Utils.Supplier.supplierAccessKey.toRequestBody(MultipartBody.FORM)
            )
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .doOnSubscribe { dialog = DialogCaller.showProgressDialog(this) }
                .doAfterTerminate { dialog?.dismiss() }
                .subscribe({
                    if (it.status) {
                        showToast(it.message)
                        RxBus.instance?.publish("refreshProduct")
                        finish()
                    }
                }, {
                    Timber.e(it.localizedMessage)
                    showToast(it.localizedMessage ?: "")
                }).autoDispose(compositeDisposable)
        } else {

            viewModel.addProductApi(
                storeCategoryId.toString().toRequestBody(MultipartBody.FORM),
                Utils.Supplier.supplierUserId.toString().toRequestBody(MultipartBody.FORM),
                etProductName.text.toString().toRequestBody(MultipartBody.FORM),
                "0".toRequestBody(MultipartBody.FORM), //todo ask for value
                etAdditionalInfo.text.toString().toRequestBody(MultipartBody.FORM),
                body,
                jsonArrayAddon.toString().toRequestBody(MultipartBody.FORM),
                "1".toRequestBody(MultipartBody.FORM), //todo ask for value
                jsonArrayOption.toString().toRequestBody(MultipartBody.FORM),
                etExtraFee.text.toString().toRequestBody(MultipartBody.FORM),
                isProductActive.toString().toRequestBody(MultipartBody.FORM),
                Utils.seceretKey.toRequestBody(MultipartBody.FORM),
                Utils.Supplier.supplierAccessKey.toRequestBody(MultipartBody.FORM)
            )
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .doOnSubscribe { dialog = DialogCaller.showProgressDialog(this) }
                .doAfterTerminate { dialog?.dismiss() }
                .subscribe({
                    if (it.status) {
                        applicationContext.showToast(it.message)
                        RxBus.instance?.publish("refreshProduct")
                        finish()
                    }
                }, {
                    Timber.e(it.localizedMessage)
                    showToast(it.localizedMessage ?: "")
                }).autoDispose(compositeDisposable)
        }

    }
}
