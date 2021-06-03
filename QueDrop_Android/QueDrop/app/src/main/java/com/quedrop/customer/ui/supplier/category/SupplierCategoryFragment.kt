package com.quedrop.customer.ui.supplier.category

import android.app.Activity
import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.*
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.widget.PopupMenu
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.request.RequestOptions
import com.google.gson.JsonObject
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.extentions.getCategoryImage
import com.quedrop.customer.base.extentions.showToast
import com.quedrop.customer.base.extentions.startActivityWithAnimation
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.FoodCategory
import com.quedrop.customer.model.FreshProduce
import com.quedrop.customer.ui.supplier.myorders.adapter.FreshProduceCategoryAdapter
import com.quedrop.customer.ui.supplier.product.SupplierProductActivity
import com.quedrop.customer.utils.*
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.layout_deletedialog.*
import kotlinx.android.synthetic.main.list_item_supplier_category.view.*
import kotlinx.android.synthetic.main.supplier_category_fragment.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.*

class SupplierCategoryFragment : BaseFragment() {

    companion object {
        fun newInstance() = SupplierCategoryFragment()
    }

    private var freshProduceCatAdapter: FreshProduceCategoryAdapter? = null
    private lateinit var viewModel: SupplierCategoryViewModel
    private var adapter: CustomAdapter? = null
    var dialogImage: ImageView? = null
    var category_img_path: String? = null

    var isFreshProduce: Boolean = false
    var freshProduceList: MutableList<FreshProduce> = mutableListOf()
    var freshProduceCategoryList: MutableList<FoodCategory> = mutableListOf()


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.supplier_category_fragment, container, false)
    }


    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        init()

        tvCategory.setOnClickListener {
            isFreshProduce = false
            tvCategory.setBackgroundResource(R.drawable.view_tab_order_press)
            tvCategory.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))

            tvFreshProduce.setTextColor(ContextCompat.getColor(activity, R.color.colorWhite))
            tvFreshProduce.background = null

            getCategoriesAPi()
        }

        tvFreshProduce.setOnClickListener {
            isFreshProduce = true
            tvFreshProduce.setBackgroundResource(R.drawable.view_tab_order_press)
            tvFreshProduce.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))

            tvCategory.setTextColor(ContextCompat.getColor(activity, R.color.colorWhite))
            tvCategory.background = null

            getFreshProduceCategoryApi()

        }

        Utils.Supplier.supplierUserId =
            SharedPrefsUtils.getIntegerPreference(
                this.requireContext(),
                KeysUtils.KeyUserSupplierId,
                0
            )

        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(this.requireContext(), KeysUtils.keySecretKey)!!
        Utils.Supplier.supplierAccessKey =
            SharedPrefsUtils.getStringPreference(
                this.requireContext(),
                KeysUtils.KeySupplierAccessKey
            )!!

        viewModel.categories.observe(viewLifecycleOwner, Observer {
            swipeRefreshLayout.isRefreshing = false
            textNoCategory.visibility = View.GONE
            if (adapter == null) {
                adapter = CustomAdapter(this.activity, it).apply {
                    onActionMenuClick = { position, view ->
                        run {
                            showPopupMenu(view, position, isFreshProduce)
                        }
                    }
                }
                recyclerview.adapter = adapter
            } else {
                adapter?.categoryList = it
                adapter?.notifyDataSetChanged()
            }
        })

        viewModel.freshProduceCategories.observe(viewLifecycleOwner, Observer {
            freshProduceCategoryList = it
            swipeRefreshLayout.isRefreshing = false
            textNoCategory.visibility = View.GONE
            if (adapter == null) {
                adapter = CustomAdapter(this.activity, it).apply {
                    onActionMenuClick = { position, view ->
                        run {
                            showPopupMenu(view, position, isFreshProduce)
                        }
                    }
                }
                recyclerview.adapter = adapter
            } else {
                adapter?.categoryList = it
                adapter?.notifyDataSetChanged()
            }
        })

        viewModel.freshProduceList.observe(viewLifecycleOwner, Observer {
            Log.e("FreshProduceList", "==>" + it)
            swipeRefreshLayout.isRefreshing = false
            freshProduceList = it

        })

        viewModel.message.observe(viewLifecycleOwner, Observer {
            swipeRefreshLayout.isRefreshing = false
            adapter?.categoryList = emptyList()
            adapter?.notifyDataSetChanged()
            textNoCategory.visibility = View.VISIBLE
            textNoCategory.text = it
        })

        getCategoriesAPi()
        getFreshProduceApi()
    }

    private fun filterFreshProduceList(it: MutableList<FreshProduce>): MutableList<FreshProduce> {
        val tempFreshProduceList: MutableList<FreshProduce> = mutableListOf()

        for (i in it.indices) {
            var found = false
            for (j in freshProduceCategoryList.indices) {
                if (freshProduceCategoryList[j].fresh_produce_category_id == it[i].fresh_category_id) {
                    found = true
                }
            }
            if (!found) {
                tempFreshProduceList.add(it[i])
            }
        }

        return tempFreshProduceList
    }

    private fun init() {
        viewModel = SupplierCategoryViewModel(appService)
        recyclerview.layoutManager = LinearLayoutManager(activity)

        swipeRefreshLayout.setOnRefreshListener {
            if (isFreshProduce) {
                getFreshProduceCategoryApi()
            } else {
                getCategoriesAPi()
            }
        }

        fab_add_category.setOnClickListener {
            if (isFreshProduce) {
                openFreshProduceChooserDialog()
            } else {
                if (hasPermissions(activity)) {
                    dialogAddCategory()
                } else {
                    requestAppPermissions(
                        ARRAY_PERMISSIONS,
                        R.string.app_name,
                        ARRAY_PERMISSION_CODE
                    )
                }
            }
        }

        imgSearch.setOnClickListener {
            if (rl_search.visibility == View.VISIBLE) {
                editSearch.setText("")
                rl_search.visibility = View.GONE
            } else {
                rl_search.visibility = View.VISIBLE
            }
        }

        editSearch.addTextChangedListener(object : TextWatcher {
            private var searchFor = ""
            override fun afterTextChanged(p0: Editable?) {}

            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}

            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
                val searchText = p0.toString().trim()
                if (searchText == searchFor)
                    return

                searchFor = searchText

                val filterList = viewModel.categories.value?.filter {
                    it.store_category_title.toLowerCase(Locale.getDefault())
                        .contains(searchFor.toLowerCase(Locale.getDefault()))
                }
                if (filterList != null) {
                    adapter?.categoryList = filterList
                    adapter?.notifyDataSetChanged()
                }
            }
        })
    }

    private fun getCategoriesAPi() {
        val jsonObject = JsonObject()
        jsonObject.addProperty("user_id", Utils.Supplier.supplierUserId)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        jsonObject.addProperty("store_id", Utils.Supplier.supplierStoreID)
        viewModel.getSupplierCategories(jsonObject)
    }

    private fun getFreshProduceCategoryApi() {
        val jsonObject = JsonObject()
        jsonObject.addProperty("user_id", Utils.Supplier.supplierUserId)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        jsonObject.addProperty("store_id", Utils.Supplier.supplierStoreID)
        viewModel.getSupplierFreshProduceCategory(jsonObject)
    }

    private fun getFreshProduceApi() {
        val jsonObject = JsonObject()
        jsonObject.addProperty("user_id", Utils.Supplier.supplierUserId)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        jsonObject.addProperty("store_id", Utils.Supplier.supplierStoreID)
        viewModel.getFreshProduces(jsonObject)
    }

    private fun addFreshProduceCategoryApi(freshProduceCatId: Int) {
        val jsonObject = JsonObject()
        jsonObject.addProperty("user_id", Utils.Supplier.supplierUserId)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        jsonObject.addProperty("store_id", Utils.Supplier.supplierStoreID)
        jsonObject.addProperty("fresh_produce_category_id", freshProduceCatId)
        viewModel.addFreshProduceCategory(jsonObject)
    }

    inner class CustomAdapter(
        val context: Context,
        category_list: List<FoodCategory>
    ) :
        RecyclerView.Adapter<CustomAdapter.Viewholder>() {
        var categoryList = category_list

        var onActionMenuClick: ((Int, View) -> Unit)? = null

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): Viewholder {
            val view =
                LayoutInflater.from(context)
                    .inflate(R.layout.list_item_supplier_category, parent, false)
            return Viewholder(view)
        }

        override fun getItemCount(): Int {
            return categoryList.size
        }

        override fun onBindViewHolder(holder: Viewholder, position: Int) {
            holder.bindData(position)
        }

        inner class Viewholder(itemView: View) : RecyclerView.ViewHolder(itemView) {
            init {
                itemView.iv_action.setOnClickListener {
                    onActionMenuClick?.invoke(adapterPosition, it)
                }
                itemView.setOnClickListener {
                    activity.startActivityWithAnimation<SupplierProductActivity> {
                        putExtra("categoryId", categoryList[adapterPosition].store_category_id)
                    }
                }
            }

            fun bindData(position: Int) {
                itemView.tvCategoryName.text = categoryList[position].store_category_title
                Glide.with(context)
                    .load(context.getCategoryImage(categoryList[position].store_category_image))
                    .placeholder(R.drawable.placeholder_offer_supplier)
                    .into(itemView.ivCategoryImage)
            }
        }
    }

    private fun showPopupMenu(view: View, position: Int, isFromFreshProduce: Boolean) {
        val popup = PopupMenu(activity, view, Gravity.BOTTOM)

        if (isFromFreshProduce) {
            popup.menuInflater.inflate(R.menu.supplier_fresh_category_menu, popup.menu)
        } else {
            popup.menuInflater.inflate(R.menu.supplier_category_menu, popup.menu)
        }

        popup.setOnMenuItemClickListener {
            when (it.itemId) {
                R.id.action_edit -> {
                    dialogEditCategory(
                        adapter?.categoryList?.get(position)?.store_category_title!!,
                        adapter?.categoryList?.get(position)?.store_category_image!!,
                        adapter?.categoryList?.get(position)?.store_category_id ?: 0
                    )
                }
                R.id.action_delete -> {
                    dialogDelete(adapter?.categoryList?.get(position)?.store_category_id ?: 0)
                }
            }
            false
        }

        popup.show()
    }

    private fun dialogDelete(id: Int) {

        val dialog = Dialog(activity)
        dialog.setContentView(R.layout.layout_deletedialog)
        dialog.textTitleDelete.setText(getString(R.string.deleteCategory))
        val textOk = dialog.findViewById<TextView>(R.id.dialog_ok)
        val textCancel = dialog.findViewById<TextView>(R.id.dialog_cancel)

        textOk.setOnClickListener {
            dialog.dismiss()
            callDeleteCategoryApi(id)
        }

        textCancel.setOnClickListener {
            dialog.dismiss()
        }

        dialog.show()

    }

    private fun dialogAddCategory() {

        val dialog = Dialog(activity)
        dialog.setContentView(R.layout.layout_dialog_add_category)
        val textOk = dialog.findViewById<TextView>(R.id.dialog_ok)
        val textCancel = dialog.findViewById<TextView>(R.id.dialog_cancel)
        val editCategory = dialog.findViewById<EditText>(R.id.editCategory)
        val dialog_image = dialog.findViewById<ImageView>(R.id.dialog_image)
        dialogImage = dialog_image
        dialog_image.setOnClickListener {
            dialogChoosePic()
        }
        textOk.setOnClickListener {
            if (!category_img_path.isNullOrEmpty()) {
                if (editCategory.text.toString().isNotEmpty()) {
                    dialog.dismiss()
                    callAddCategoryApi(editCategory.text.toString())
                } else {
                    editCategory.error = "category name required"
                }
            } else {
                activity.showToast("Please choose category image")
            }
        }

        textCancel.setOnClickListener {
            dialog.dismiss()
        }

        dialog.show()

    }

    private fun dialogEditCategory(category: String, img: String, store_category_id: Int) {

        val dialog = Dialog(activity)
        dialog.setContentView(R.layout.layout_dialog_add_category)
        val textOk = dialog.findViewById<TextView>(R.id.dialog_ok)
        val textCancel = dialog.findViewById<TextView>(R.id.dialog_cancel)
        val editCategory = dialog.findViewById<EditText>(R.id.editCategory)
        val dialog_image = dialog.findViewById<ImageView>(R.id.dialog_image)
        dialogImage = dialog_image

        editCategory.setText(category)
        Glide.with(activity).load(activity.getCategoryImage(img))
            .override(300, 300)
            .centerCrop()
            .placeholder(R.drawable.placeholder_offer_supplier)
            .apply(RequestOptions.circleCropTransform())
            .into(dialog_image)
        dialog_image.setOnClickListener {
            dialogChoosePic()
        }
        textOk.setOnClickListener {
            if (editCategory.text.toString().isNotEmpty()) {
                dialog.dismiss()
                callEditCategoryApi(editCategory.text.toString(), store_category_id)
            } else {
                editCategory.error = "category name required"
            }
        }

        textCancel.setOnClickListener {
            dialog.dismiss()
        }

        dialog.show()

    }

    private fun dialogChoosePic() {

        val dialog = Dialog(activity)
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

                val bitmap =
                    MediaStore.Images.Media.getBitmap(activity.contentResolver, selectedImageUri)
                category_img_path =
                    Utils.getRealPathFromURI(activity.applicationContext, selectedImageUri!!)

                dialogImage?.let {
                    Glide.with(activity).load(selectedImageUri)
                        .override(300, 300)
                        .centerCrop()
                        .apply(RequestOptions.circleCropTransform()).into(it)
                }

            }
        } else if (requestCode == ConstantUtils.REQUEST_CAMERA && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                val thumbnail: Bitmap = data.extras?.get("data") as Bitmap
                val selectedImageUri: Uri = getImageUri(activity.applicationContext, thumbnail)
                category_img_path =
                    Utils.getRealPathFromURI(activity.applicationContext, selectedImageUri)
                dialogImage?.let {
                    Glide.with(activity).load(selectedImageUri)
                        .override(300, 300)
                        .centerCrop()
                        .apply(RequestOptions.circleCropTransform())
                        .into(it)
                }
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

    private fun callAddCategoryApi(name: String) {
        val fileToUpload = File(category_img_path!!)
        val requestBody: RequestBody =
            fileToUpload.asRequestBody(contentType = "image/*".toMediaType())
        val body = MultipartBody.Part.createFormData(
            "category_image",
            fileToUpload.name, requestBody
        )
        viewModel.addCategoryApi(
            Utils.Supplier.supplierStoreID.toString().toRequestBody(MultipartBody.FORM),
            Utils.Supplier.supplierUserId.toString().toRequestBody(MultipartBody.FORM),
            name.toRequestBody(MultipartBody.FORM),
            body,
            Utils.seceretKey.toRequestBody(MultipartBody.FORM),
            Utils.Supplier.supplierAccessKey.toRequestBody(MultipartBody.FORM)
        )
    }

    private fun callDeleteCategoryApi(catId: Int) {
        var dialog: Dialog? = null
        val jsonObject = JsonObject()
        jsonObject.addProperty("store_id", Utils.Supplier.supplierStoreID)
        jsonObject.addProperty("store_category_id", catId)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        viewModel.deleteCategory(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe { dialog = DialogCaller.showProgressDialog(activity) }
            .doAfterTerminate { dialog?.dismiss() }
            .subscribe({ response ->
                //activity.showToast(response.message)
                if (response.status) {
                    if (isFreshProduce) {
                        val obj =
                            viewModel.freshProduceCategories.value?.first { it.store_category_id == catId }
                        viewModel.freshProduceCategories.value?.remove(obj)
                        viewModel.freshProduceCategories.postValue(viewModel.freshProduceCategories.value)
                    } else {
                        val obj =
                            viewModel.categories.value?.first { it.store_category_id == catId }
                        viewModel.categories.value?.remove(obj)
                        viewModel.categories.postValue(viewModel.categories.value)
                    }

                }
            }, {
                //activity.showToast(it.localizedMessage ?: "")
                Log.e("MESSAGE", "==>" + it.localizedMessage)
            }).autoDispose(compositeDisposable)
    }

    private fun callEditCategoryApi(name: String, store_category_id: Int) {
        var dialog: Dialog? = null
        var body: MultipartBody.Part? = null
        if (!category_img_path.isNullOrEmpty()) {
            val fileToUpload = File(category_img_path!!)
            val requestBody: RequestBody =
                fileToUpload.asRequestBody(contentType = "image/*".toMediaType())
            body = MultipartBody.Part.createFormData(
                "category_image",
                fileToUpload.name, requestBody
            )
        }
        viewModel.editCategoryApi(
            store_category_id.toString().toRequestBody(MultipartBody.FORM),
            name.toRequestBody(MultipartBody.FORM),
            body,
            Utils.seceretKey.toRequestBody(MultipartBody.FORM),
            Utils.Supplier.supplierAccessKey.toRequestBody(MultipartBody.FORM)
        ).observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe { dialog = DialogCaller.showProgressDialog(activity) }
            .doAfterTerminate { dialog?.dismiss() }
            .subscribe({
                if (it != null && it.status) {
                    val obj = it.data?.get("categories")
                    viewModel.categories.value?.forEachIndexed { index, catobj ->
                        if (catobj.store_category_id == obj?.store_category_id) {
                            viewModel.categories.value!![index] = obj
                            viewModel.categories.postValue(viewModel.categories.value)
                        }
                    }
                }
            }, {}).autoDispose(compositeDisposable)
    }


    private fun openFreshProduceChooserDialog() {
        val dialog = Dialog(activity)
        dialog.setCanceledOnTouchOutside(true)

        dialog.apply {
            setContentView(R.layout.layout_dialog_fresh_produce_list)
            window?.addFlags(Window.FEATURE_NO_TITLE)
            window?.setBackgroundDrawableResource(android.R.color.transparent)
            window?.setLayout(
                (Utils.getDeviceWidth(context) * 0.90).toInt(),
                (Utils.getDeviceHeight(context) * 0.80).toInt()
            )
        }

        val recyclerview: RecyclerView = dialog.findViewById(R.id.recyclerView)
        recyclerview.layoutManager = LinearLayoutManager(activity)
        freshProduceCatAdapter = FreshProduceCategoryAdapter(activity)
        recyclerview.adapter = freshProduceCatAdapter
        freshProduceCatAdapter?.freshProduceList = filterFreshProduceList(freshProduceList)
        freshProduceCatAdapter?.notifyDataSetChanged()

        if (filterFreshProduceList(freshProduceList).size > 0) {
            dialog.show()
        } else {
            activity.showToast("No fresh produce category found")
        }


        freshProduceCatAdapter?.apply {
            onItemClick = { id, name ->
                addFreshProduceCategoryApi(id)
                dialog.dismiss()
            }
        }
    }


    override fun onDestroyView() {
        super.onDestroyView()
        adapter = null
    }


    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String?>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        var permissionCheck = PackageManager.PERMISSION_GRANTED
        for (permission in grantResults) {
            permissionCheck += permission
        }
        if (grantResults.isNotEmpty() && permissionCheck == PackageManager.PERMISSION_GRANTED) {
            dialogAddCategory()
        } else {
            Utility.toastLong(activity, "Please allow storage permission")
        }
    }
}
