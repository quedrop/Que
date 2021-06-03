package com.quedrop.customer.ui.storewithoutproduct.view

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
import android.view.View
import android.widget.ImageView
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.*
import com.quedrop.customer.ui.cart.view.CartActivity
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.login.view.LoginActivity
import com.quedrop.customer.ui.storewithoutproduct.viewmodel.StoreWithoutProductViewModel
import com.quedrop.customer.ui.storewithproduct.view.SliderAdapter
import com.quedrop.customer.utils.*
import kotlinx.android.synthetic.main.activity_store_without_product.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.io.File


class StoreWithoutProductActivity : BaseActivity() {

    var storeId: Int? = null
    var getStoreDetails: GetStoreDetails? = null
    var userProductResponse: UserProductResponse? = null
    var arrayUserAddProductList: MutableList<AddOrder>? = null
    var arrayProductsList: JSONArray? = null
    var arraySliderImageList: MutableList<SliderImages>? = null
    var addProductAdapter: AddUserProductAdapter? = null
    var sliderAdapter: SliderAdapter? = null
    var is_Favourite: Boolean = false
    var isFavourite: String? = "0"
    var currentDate: String? = null
    var currentTime: String? = null
    var currentTimeConvert: String? = null
    var currentDay: String? = null
    var openingTime: String? = null
    var closingTime: String? = null
    var checkTimeStatus: Boolean? = false
    var progressDialog1: Dialog? = null
    var booleanSearch: Boolean = false
    var searchFlag: Boolean = false
    var IMAGE_DIRECTORY: String? = null
    var textClick: Boolean = false
    var imagesPathList: ArrayList<MultipartBody.Part>? = null
    var arrayDeleteProductId: ArrayList<Int>? = null
    var positionImageSetClick: Int = 0
    var flagUserAddStore = false
    var flagAlreadyAdded = false
    var is_user_added_store: String = "0"
    var user_store_id: Int = 0
    lateinit var storeWithoutProductViewModel: StoreWithoutProductViewModel
    var continueFlag: Boolean = false
    var addIemCart: Boolean = false
    var version: String = "v2"
    var deletePtoductIdFinal: String = ""
    var positionAdapter: Int = 0
    private var permissions = arrayOf<String>(

        Manifest.permission.CAMERA,
        Manifest.permission.WRITE_EXTERNAL_STORAGE
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_store_without_product)

        flagAlreadyAdded = false
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyGuestId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyAccessKey)!!
        Utils.keyLatitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLatitude)!!
        Utils.keyLongitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLongitude)!!

//        Toast.makeText(applicationContext, userId, Toast.LENGTH_SHORT).show()
        flagUserAddStore = SharedPrefsUtils.getBooleanPreference(
            applicationContext,
            KeysUtils.keyAddStoreFlag,
            false
        )

        currentDate = Utils.getCurrentDate()
        currentTime = Utils.getCurrentTime()
        currentTimeConvert = Utils.convertTime(currentTime!!)
        currentDay = Utils.getCurrentDay()
        booleanSearch = false
        searchFlag = false

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

        storeWithoutProductViewModel = StoreWithoutProductViewModel(appService)
        initMethod()
        observeViewModel()
        onClickMethod()



        if (flagUserAddStore) {
            is_user_added_store = "1"
            val addUserStore =
                intent.getSerializableExtra(KeysUtils.keyUserAddStore) as AddUserStore
            setAllDetailsWithoutApi(addUserStore)
        } else {
            storeId = intent.getIntExtra(KeysUtils.keyStoreId, 0)
            is_user_added_store = "0"
            user_store_id = 0
            getStoreDetailsApi()
            getUserAddedStoreProductsFromCartApi()
        }
    }

    private fun checkPermissions(): Boolean {
        var result: Int
        val listPermissionsNeeded = ArrayList<String>()
        for (p in permissions) {
            result = ContextCompat.checkSelfPermission(applicationContext, p)
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
            choosePicGallery(positionAdapter)
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
                    choosePicGallery(positionAdapter)
//                    Toast.makeText(applicationContext, "Permission is Granted ", Toast.LENGTH_SHORT)
//                        .show()
                    // permissions granted.
                }
                return
            }

            ConstantUtils.MULTIPLE_PERMISSIONS -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    choosePicCamera(positionAdapter)
//                    Toast.makeText(applicationContext, "Permission is Granted ", Toast.LENGTH_SHORT)
//                        .show()
                    // permissions granted.
                }
                return
            }
        }
    }


    private fun initMethod() {
        arraySliderImageList = mutableListOf()

        sliderAdapter = SliderAdapter(
            applicationContext!!,
            arraySliderImageList
        )

        ivSliderWithoutProduct.sliderAdapter = sliderAdapter

        rvStoreDetailsWithoutProduct!!.setHasFixedSize(true)

        rvStoreDetailsWithoutProduct.layoutManager = LinearLayoutManager(
            applicationContext!!,
            LinearLayoutManager.VERTICAL,
            false
        )

        arrayUserAddProductList = mutableListOf()
        arrayDeleteProductId = ArrayList<Int>()


        addProductAdapter = AddUserProductAdapter(
            applicationContext!!,
            arrayUserAddProductList,
            arrayDeleteProductId
        ).apply {
            addNewItemInvoke = {
                addNewItem()
            }
            dialogChoosePicInvoke = {
                dialogChoosePic(it)
            }
            deleteListInvoke = { arrayDeleteList: ArrayList<Int>, pos: Int ->
                changeDeleteList(arrayDeleteList)
            }
        }

        rvStoreDetailsWithoutProduct.adapter = addProductAdapter


    }

    private fun onClickMethod() {
        ivBackStoreWithoutProduct.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        ivFavouriteStoresWithoutProduct.throttleClicks().subscribe {

            if (Utils.userId == 0) {
                val intent = Intent(applicationContext, LoginActivity::class.java)
                startActivityForResultWithDefaultAnimations(
                    intent,
                    ConstantUtils.FAV_LOGIN_REQUEST_CODE
                )
            } else {
                if (is_Favourite) {
                    isFavourite = "0"
                    is_Favourite = false
                    ivFavouriteStoresWithoutProduct.setImageResource(R.drawable.heart)
                } else {
                    isFavourite = "1"
                    is_Favourite = true
                    ivFavouriteStoresWithoutProduct.setImageResource(R.drawable.heartpress)
                }

                getStoreFavouriteApi()
            }
        }.autoDispose(compositeDisposable)

        btnAddCartWithoutProductWithoutProduct.throttleClicks().subscribe {

            try {

                addIemCart = false
                if (arrayUserAddProductList?.size!! > 0) {
                    for ((i, v) in arrayUserAddProductList!!.withIndex()) {

                        if (v.product_name.isEmpty() && v.qty.isNotEmpty()) {
                            addIemCart = true
                            Toast.makeText(
                                applicationContext,
                                resources.getString(R.string.productNameToast),
                                Toast.LENGTH_SHORT
                            )
                                .show()
                            break
                        } else if (v.qty.isEmpty() && v.product_name.isNotEmpty()) {
                            addIemCart = true
                            Toast.makeText(
                                applicationContext,
                                resources.getString(R.string.productQuantityToast),
                                Toast.LENGTH_SHORT
                            )
                                .show()
                            break
                        } else if (v.qty == "0") {
                            addIemCart = true
                            Toast.makeText(
                                applicationContext,
                                resources.getString(R.string.validQty),
                                Toast.LENGTH_SHORT
                            )
                                .show()
                            break
                        } else if (v.product_name.isEmpty() && v.qty.isEmpty()) {
                            addIemCart = false
                            arrayUserAddProductList?.removeAt(i)
                            arrayDeleteProductId?.add(v.user_product_id)
                            addProductAdapter?.notifyDataSetChanged()
                            changeDeleteList(arrayDeleteProductId!!)
                        }
                    }
                    if (!addIemCart) {
                        getAddProductCartApi()
                    }
                }
            } catch (e: Exception) {

            }
        }.autoDispose(compositeDisposable)

        btnContinueWithoutProduct.throttleClicks().subscribe {

            addIemCart = false
            if (arrayUserAddProductList?.size!! > 0) {
                for ((i, v) in arrayUserAddProductList!!.withIndex()) {

                    if (v.product_name.isEmpty() && v.qty.isNotEmpty()) {
                        addIemCart = true
                        Toast.makeText(
                            applicationContext,
                            resources.getString(R.string.productNameToast),
                            Toast.LENGTH_SHORT
                        )
                            .show()
                        break
                    } else if (v.qty.isEmpty() && v.product_name.isNotEmpty()) {
                        addIemCart = true
                        Toast.makeText(
                            applicationContext,
                            resources.getString(R.string.productQuantityToast),
                            Toast.LENGTH_SHORT
                        )
                            .show()
                        break
                    } else if (v.qty == "0") {
                        addIemCart = true
                        Toast.makeText(
                            applicationContext,
                            resources.getString(R.string.validQty),
                            Toast.LENGTH_SHORT
                        )
                            .show()
                        break
                    } else if (v.product_name.isEmpty() && v.qty.isEmpty()) {
                        addIemCart = false
                        arrayUserAddProductList?.removeAt(i)
                        arrayDeleteProductId?.add(v.user_product_id)
                        addProductAdapter?.notifyDataSetChanged()
                        changeDeleteList(arrayDeleteProductId!!)
                    }
                }
                if (!addIemCart) {
                    getAddProductCartApi()
                }
            }

        }.autoDispose(compositeDisposable)

    }


    private fun prepareFilePart(partName: String, uri: Uri): MultipartBody.Part {

        val file: File = File(Utils.getRealPathFromURI(applicationContext, uri)!!)
        val requestBody =
            RequestBody.create(contentResolver.getType(uri)?.toMediaTypeOrNull(), file)

        return MultipartBody.Part.createFormData(partName, file.name, requestBody)
    }


    private fun setAllDetailsWithoutApi(addUserStore: AddUserStore) {

        ivFavouriteStoresWithoutProduct.visibility = View.GONE

        user_store_id = addUserStore.user_store_id
        storeId = 0
        tvStoreNameWithoutProduct.text = addUserStore.store_name
        tvStoreAddressWithoutProduct.text = addUserStore.store_address
        Glide.with(applicationContext)
            .load(URLConstant.nearByStoreUrl + addUserStore.store_logo)
            .placeholder(R.drawable.placeholder_order_cart_product)
            .into(ivStoreImageWithoutProduct)


        Utils.fetchRouteDistance(
            applicationContext,
            Utils.keyLatitude.toDouble(),
            Utils.keyLongitude.toDouble(),
            addUserStore.latitude.toDouble(),
            addUserStore.longitude.toDouble(),
            textDistanceWithoutProduct
        )

        tvCurrentDayTimeWithoutProduct.visibility = View.GONE
        tvOpeningStatusWithoutProduct.visibility = View.GONE
        addNewItem()

    }


    private fun setAllDetails() {

        ivFavouriteStoresWithoutProduct.visibility = View.VISIBLE
        tvStoreNameWithoutProduct.text = getStoreDetails?.store_name
        tvStoreAddressWithoutProduct.text = getStoreDetails?.store_address
        Glide.with(applicationContext)
            .load(URLConstant.nearByStoreUrl+ getStoreDetails?.store_logo)
            .into(ivStoreImageWithoutProduct)
        is_Favourite = getStoreDetails?.is_favourite!!

        sliderAdapter?.notifyDataSetChanged()
        var openingConvertTime: String? = null
        var closingConvertTime: String? = null

        tvCurrentDayTimeWithoutProduct.visibility = View.GONE
        tvOpeningStatusWithoutProduct.setTextColor(ContextCompat.getColor(this,R.color.colorRed))
        tvOpeningStatusWithoutProduct.text = resources.getString(R.string.closed)


        for ((index, value) in getStoreDetails?.schedule?.withIndex()!!) {
            if (currentDay == getStoreDetails?.schedule?.get(index)!!.weekday) {
                openingTime = getStoreDetails?.schedule?.get(index)!!.opening_time
                closingTime = getStoreDetails?.schedule?.get(index)!!.closing_time

                if (openingTime == "" && closingTime == "") {

                    tvCurrentDayTimeWithoutProduct.visibility = View.GONE
                    tvOpeningStatusWithoutProduct.setTextColor(ContextCompat.getColor(this,R.color.colorRed))
                    tvOpeningStatusWithoutProduct.text = resources.getString(R.string.closed)
                } else {
                    tvCurrentDayTimeWithoutProduct.visibility = View.VISIBLE


                    openingConvertTime = Utils.convertTime(openingTime!!)
                    closingConvertTime = Utils.convertTime(closingTime!!)

                    checkTimeStatus = Utils.checkTimeStatus(
                        openingConvertTime,
                        closingConvertTime,
                        this.currentTimeConvert!!
                    )

                    if (this.checkTimeStatus!!) {
                        tvOpeningStatusWithoutProduct.setTextColor(ContextCompat.getColor(this,R.color.colorGreenStatus))
                        tvOpeningStatusWithoutProduct.text =
                            resources.getString(R.string.openingNow)
                    } else {
                        tvOpeningStatusWithoutProduct.setTextColor(ContextCompat.getColor(this,R.color.colorRed))
                        tvOpeningStatusWithoutProduct.text = resources.getString(R.string.closed)
                    }

                    tvCurrentDayTimeWithoutProduct.text =
                        " - " + openingConvertTime + " - " + closingConvertTime + "(today)"
                }
            }
        }


        if (is_Favourite) {
            isFavourite = "1"
            is_Favourite = true
            ivFavouriteStoresWithoutProduct.setImageResource(R.drawable.heartpress)
        } else {
            isFavourite = "0"
            is_Favourite = false
            ivFavouriteStoresWithoutProduct.setImageResource(R.drawable.heart)
        }

        Utils.fetchRouteDistance(
            applicationContext,
            Utils.keyLatitude.toDouble(),
            Utils.keyLongitude.toDouble(),
            getStoreDetails?.latitude!!.toDouble(),
            getStoreDetails?.longitude!!.toDouble(),
            textDistanceWithoutProduct
        )
    }

    private fun choosePicGallery(positionImageClick: Int) {
        positionImageSetClick = positionImageClick
        val intent = Intent(Intent.ACTION_PICK)
        intent.type = "image/*"
        val mimeTypes = arrayOf("image/jpeg", "image/png")
        intent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes)

        startActivityForResult(intent, ConstantUtils.REQUEST_PICK_IMAGE)
    }

    private fun choosePicCamera(positionImageClick: Int) {
        positionImageSetClick = positionImageClick
        val intent = Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE)
        startActivityForResult(intent, ConstantUtils.REQUEST_CAMERA)

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == ConstantUtils.REQUEST_PICK_IMAGE && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                val selectedImageUri = data.data
                val bitmap =
                    MediaStore.Images.Media.getBitmap(this.getContentResolver(), selectedImageUri)
//                var path = saveImage(bitmap)
                val path =
                    Utils.getRealPathFromURI(applicationContext, selectedImageUri!!)
                addProductAdapter?.setImage(
                    bitmap,
                    path!!,
                    selectedImageUri,
                    positionImageSetClick
                )

            }
        } else if (requestCode == ConstantUtils.REQUEST_CAMERA && resultCode == Activity.RESULT_OK) {
            if (data != null) {

//                var uri: Uri? = data.data
                val thumbnail: Bitmap = data.extras?.get("data") as Bitmap
                val uri: Uri = getImageUri(applicationContext, thumbnail)
                val path = Utils.getRealPathFromURI(applicationContext, uri)
//                var path = getRealPathFromURI(uri!!)

                addProductAdapter?.setImage(thumbnail, path!!, uri, positionImageSetClick)
            }
        } else if (requestCode == ConstantUtils.FAV_LOGIN_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                Utils.userId = SharedPrefsUtils.getIntegerPreference(
                    applicationContext,
                    KeysUtils.keyUserId,
                    0
                )
                Utils.guestId = SharedPrefsUtils.getIntegerPreference(
                    applicationContext,
                    KeysUtils.keyGuestId,
                    0
                )

                if (is_Favourite) {
                    isFavourite = "0"
                    is_Favourite = false
                    ivFavouriteStoresWithoutProduct.setImageResource(R.drawable.heart)
                } else {
                    isFavourite = "1"
                    is_Favourite = true
                    ivFavouriteStoresWithoutProduct.setImageResource(R.drawable.heartpress)
                }

                getStoreFavouriteApi()
            }

        } else if (requestCode == ConstantUtils.ADD_PRODUCT_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            flagAlreadyAdded = true
            getUserAddedStoreProductsFromCartApi()
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


    private fun addNewItem() {

        if(flagAlreadyAdded){
            if(arrayUserAddProductList?.size!!<1){
                val addOrder = AddOrder("", "", "", "", Uri.parse(""), 0, false)
                arrayUserAddProductList?.add(addOrder)
                addProductAdapter?.notifyDataSetChanged()
            }
            flagAlreadyAdded = false

        }else{
            val addOrder = AddOrder("", "", "", "", Uri.parse(""), 0, false)
            arrayUserAddProductList?.add(addOrder)
            addProductAdapter?.notifyDataSetChanged()
        }
    }

    private fun changeDeleteList(deleteArrayList: ArrayList<Int>) {

        arrayDeleteProductId = deleteArrayList

    }

    private fun observeViewModel() {
        storeWithoutProductViewModel.noUserAddedProduct.observe(this, androidx.lifecycle.Observer {
            hideProgress()
            addNewItem()
        })
        storeWithoutProductViewModel.user_products.observe(this,
            androidx.lifecycle.Observer {
                hideProgress()

                arrayUserAddProductList?.clear()

                userProductResponse = it

                for ((i, v) in userProductResponse?.products?.withIndex()!!) {

                    val productName = v.product_name
                    val quantity = v.quantity
                    val image_name = ""
                    val image_path = URLConstant.urlProduct + v.product_image
                    var imageUri = ""
                    val user_product_id = v.user_product_id
                    val productFlag = true


                    val addOrder = AddOrder(
                        productName,
                        quantity,
                        image_name,
                        image_path,
                        Uri.parse(""),
                        user_product_id,
                        productFlag
                    )

                    arrayUserAddProductList?.add(addOrder)

                }
                addNewItem()
            })

        storeWithoutProductViewModel.message.observe(this,
            androidx.lifecycle.Observer {
                hideProgress()
                RxBus.instance?.publish("refreshFavourite")
            })

        storeWithoutProductViewModel.messageAddProduct.observe(this,
            androidx.lifecycle.Observer {
                hideProgress()
                if (continueFlag) {
                    val intent = Intent(this, CustomerMainActivity::class.java)
                    intent.flags =
                        Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    startActivityWithDefaultAnimations(intent)
                    finish()
                } else {
                    val intent = Intent(applicationContext, CartActivity::class.java)
                    intent.putExtra(
                        KeysUtils.keyUserProductId,
                        resources.getString(R.string.titleCart)
                    )
                    startActivityForResultWithDefaultAnimations(
                        intent,
                        ConstantUtils.ADD_PRODUCT_REQUEST_CODE
                    )
                }
            })

        storeWithoutProductViewModel.store_detail.observe(this,
            androidx.lifecycle.Observer {
                hideProgress()
                getStoreDetails = it
                booleanSearch = true
                arraySliderImageList?.clear()
                arraySliderImageList?.addAll(it.slider_images)
                setAllDetails()


            })
        storeWithoutProductViewModel.errorMessage.observe(this,
            androidx.lifecycle.Observer {
                hideProgress()
            })

    }

    private fun getFavourite(): SetFavourite {
        return SetFavourite(
            Utils.seceretKey,
            Utils.accessKey,
            storeId!!,
            Utils.userId,
            isFavourite.toString()
        )
    }

    private fun getStoreDetails(): AddStoreDetails {
        return AddStoreDetails(
            Utils.seceretKey,
            Utils.accessKey,
            this.storeId!!,
            Utils.userId
        )
    }

    private fun getUserProductFromCart(): AddUserProductFromCartRequest {
        return AddUserProductFromCartRequest(
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId,
            user_store_id,
            this.storeId!!
        )
    }

    private fun getStoreDetailsApi() {

        showProgress()
        storeWithoutProductViewModel.getStoreWithProductDetailsApi(getStoreDetails())

    }

    private fun getUserAddedStoreProductsFromCartApi() {

        showProgress()
        storeWithoutProductViewModel.getUserAddedStoreProductsFromCartApi(getUserProductFromCart())

    }

    private fun getStoreFavouriteApi() {
        showProgress()
        storeWithoutProductViewModel.getStoreFavouriteApi(getFavourite())
    }

    private fun getAddProductCartApi() {
        showProgress()

        val is_user_added_store_request: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            is_user_added_store
        )
        val store_id_request: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            storeId.toString()
        )
        val user_store_id: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            user_store_id.toString()
        )
        val user_id_request: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            Utils.userId.toString()
        )
        val guest_id_request: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            Utils.guestId.toString()
        )
        val product_description_request: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            " "
        )
        val secret_key_request: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            Utils.seceretKey
        )
        val access_key_request: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            Utils.accessKey
        )

        imagesPathList = ArrayList<MultipartBody.Part>()
        arrayProductsList = JSONArray()


        //MultipartBody.Part body = MultipartBody.Part.createFormData("image", "image.jpg", requestFile);

        for ((item, value) in arrayUserAddProductList?.withIndex()!!) {


            val products = JSONObject()

            products.put("user_product_id", arrayUserAddProductList?.get(item)!!.user_product_id)
            products.put("product_name", arrayUserAddProductList?.get(item)!!.product_name)
            products.put("qty", arrayUserAddProductList?.get(item)!!.qty)
            if (arrayUserAddProductList?.get(item)!!.image_name.isNullOrBlank()) {
                products.put("image_name", "")
            } else {
                products.put("image_name", arrayUserAddProductList?.get(item)!!.image_name)
            }

            arrayProductsList?.put(products)

            if (value.image_uri.toString().isNullOrBlank()) {


            } else {
                imagesPathList?.add(
                    prepareFilePart(
                        "product_image[" + item + "]",
                        arrayUserAddProductList?.get(item)!!.image_uri
                    )
                )
            }

        }

        val version_request: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            version
        )

        if (arrayDeleteProductId?.size!! > 0) {
            deletePtoductIdFinal = toConvertString(arrayDeleteProductId!!)
            Log.e("deleteProductString", deletePtoductIdFinal)
        }

        val arrayDeleteProductRequest = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            deletePtoductIdFinal
        )

        val products_request: RequestBody = RequestBody.create(
            "text/plain".toMediaTypeOrNull(),
            arrayProductsList.toString()
        )

        storeWithoutProductViewModel.addProductCategoryApi(
            is_user_added_store_request,
            store_id_request,
            user_store_id,
            user_id_request,
            guest_id_request,
            product_description_request,
            secret_key_request,
            access_key_request,
            products_request,
            imagesPathList!!,
            version_request,
            arrayDeleteProductRequest
        )

    }

    private fun toConvertString(arrayDeleted: ArrayList<Int>): String {
        var result = ""

        if (arrayDeleted.size > 0) {
            val sb = StringBuilder()

            for (s in arrayDeleted) {
                sb.append(s).append(",")
            }

            result = sb.deleteCharAt(sb.length - 1).toString()
        }
        return result
    }


    private fun dialogChoosePic(adapterPosition: Int) {

        val dialog = Dialog(this)
        dialog.setContentView(R.layout.layout_dialog_choosepic)

        val ivCamera = dialog.findViewById<ImageView>(R.id.ivCamera)
        val ivGallery = dialog.findViewById<ImageView>(R.id.ivGallery)

        ivCamera.setOnClickListener {

            positionAdapter = adapterPosition

            if (checkPermissions()) {
                choosePicCamera(positionAdapter)
            } else {
                checkPermissions()
            }
            dialog.dismiss()
        }

        ivGallery.setOnClickListener {

            positionAdapter = adapterPosition

            checkPermissionReadMethod()
            dialog.dismiss()
        }

        dialog.show()
    }

}
