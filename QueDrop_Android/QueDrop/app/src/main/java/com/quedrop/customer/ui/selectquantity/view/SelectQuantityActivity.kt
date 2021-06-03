package com.quedrop.customer.ui.selectquantity.view

import android.os.Bundle
import android.view.View
import com.quedrop.customer.R
import com.quedrop.customer.model.*
import kotlinx.android.synthetic.main.activity_select_quantity.*
import java.lang.StringBuilder
import android.app.Activity
import android.content.Intent
import android.util.Log
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.bumptech.glide.Glide
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.login.view.LoginActivity
import com.quedrop.customer.ui.selectquantity.viewmodel.SelectQuantityViewModel
import com.quedrop.customer.ui.storewithproduct.view.SliderAdapter
import com.quedrop.customer.ui.storewithproduct.viewmodel.StoreWithProductViewModel
import com.quedrop.customer.utils.*
import kotlinx.android.synthetic.main.activity_store_details.*


class SelectQuantityActivity : BaseActivity() {

    private var arrayAddOnsList: MutableList<AddOns>? = null
    var arrayProductOptionList: MutableList<ProductOption>? = null
    var storeId: Int? = null
    var productId: Int? = null
    var userStoreId: Int = 0
    var userProductId: Int = 0
    var getStoreDetails: GetStoreDetails? = null
    var arrayStoreDetailsList: MutableList<FoodCategory>? = null
    var arraySliderImageList: MutableList<SliderImages>? = null
    var sliderAdapter: SliderAdapter? = null
    var currentDate: String? = null
    var currentTime: String? = null
    var currentTimeConvert: String? = null
    var currentDay: String? = null
    var openingTime: String? = null
    var closingTime: String? = null
    var checkTimeStatus: Boolean? = false
    var productName: String? = null
    var amount: String = "0"
    var quantitySum: String = "1"
    var totalAmount: Float? = 0f
    private var categoryTitle: String? = null
    var booleanCustomise: Boolean = true
    var hasAddOns: String = "0"
    var posOption: Int = 0
    var productOptionId: Int = 0
    var productOptionName: String = ""
    private lateinit var selectQuantityViewModel: SelectQuantityViewModel
    private var is_Favourite: Boolean = false
    var isFavourite: String? = "0"

    lateinit var storeWithProductViewModel: StoreWithProductViewModel


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_select_quantity)

        selectQuantityViewModel = SelectQuantityViewModel(appService)
        storeWithProductViewModel = StoreWithProductViewModel(appService)

        hasAddOns = intent.getStringExtra(KeysUtils.keyAddOns)
        storeId = intent.getIntExtra(KeysUtils.keyStoreId, 0)
        productId = intent.getIntExtra(KeysUtils.keyProductId, 0)
        productName = intent.getStringExtra(KeysUtils.keyProductName)
        amount = intent.getStringExtra(KeysUtils.keyRs)

        Log.e("Rs.........", "==" + amount)

        categoryTitle = intent.getStringExtra(KeysUtils.keyProductCategory)
        categoryTitle = intent.getStringExtra(KeysUtils.keyProductCategory)
        quantitySum = intent.getStringExtra(KeysUtils.keyItem)
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyGuestId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyAccessKey)!!
        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyUserId, 0)
        Utils.keyLatitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLatitude)!!
        Utils.keyLongitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLongitude)!!

        arrayAddOnsList = mutableListOf()
        arrayProductOptionList = mutableListOf()

        arrayAddOnsList!!.clear()
        arrayProductOptionList!!.clear()

        arrayAddOnsList = SharedPrefsUtils.getObjectList<AddOns>(
            applicationContext,
            KeysUtils.keyListAddOns,
            AddOns::class.java
        )

        posOption = intent.getIntExtra(KeysUtils.keyProductOptionPos, 0)


        arrayProductOptionList = SharedPrefsUtils.getObjectList<ProductOption>(
            applicationContext,
            KeysUtils.keyListProductOption,
            ProductOption::class.java
        )
        currentDate = Utils.getCurrentDate()
        currentTime = Utils.getCurrentTime()
        currentTimeConvert = Utils.convertTime(currentTime!!)
        currentDay = Utils.getCurrentDay()

        initMethod()
        observeViewModel()
        getStoreDetailsApi()
        onClickMethodApi()


    }

    private fun initMethod() {

        tvProductNameQuantity.text = productName


        var sb = StringBuilder()
        for ((i, v) in arrayProductOptionList?.toMutableList()!!.withIndex()) {


            productOptionId = arrayProductOptionList?.get(i)!!.option_id
            productOptionName = arrayProductOptionList?.get(i)!!.option_name
            if (productOptionName == "Default") {

            } else {
                sb = sb.append(productOptionName)
            }


        }

        if (arrayAddOnsList?.size!! > 0) {
            if (productOptionName == "Default") {

            } else {
                sb = sb.append(",")
            }
        }

        for ((item, value) in arrayAddOnsList?.toMutableList()!!.withIndex()) {

            sb = sb.append(value.addon_name)

            if (item == ((arrayAddOnsList?.size)!! - 1)) {
                break
            }
            sb.append(",")
        }

        if (sb.isNullOrBlank()) {
            tvPAddOnsQuantity.visibility = View.GONE
        } else {
            tvPAddOnsQuantity.visibility = View.VISIBLE
            tvPAddOnsQuantity.text = sb
        }

        tvProductPriceQuantity.text =
            resources.getString(R.string.rs) + (amount.toFloat() * quantitySum.toFloat()).toString()
        totalAmount = (amount.toFloat() * quantitySum.toFloat())
        tvAmountQuantity.text =
            resources.getString(R.string.itemTotal) + " | " + resources.getString(R.string.rs) +
                    totalAmount

        if (hasAddOns == "0") {

            tvCustomiseQuantity.visibility = View.GONE
        } else {
            tvCustomiseQuantity.visibility = View.VISIBLE
        }

        minusSymbol()


        tvQuantity.text = quantitySum.toString()


        arraySliderImageList = mutableListOf()

        sliderAdapter = SliderAdapter(
            applicationContext!!,
            arraySliderImageList
        )

        ivSliderQuantity.sliderAdapter = sliderAdapter


    }

    private fun onClickMethodApi() {

        ivBackStoreQuantity.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        tvAddItemQuantity.throttleClicks().subscribe {
            getAddItemToCartApi()
        }.autoDispose(compositeDisposable)

        plusCart.throttleClicks().subscribe {
            quantitySum = (quantitySum.toInt().plus(1)).toString()
            totalAmount = totalAmount!!.toFloat().plus(amount.toFloat())

            minusSymbol()

            tvQuantity.text = quantitySum.toString()
            tvProductPriceQuantity.text = resources.getString(R.string.rs) + totalAmount.toString()
            tvAmountQuantity.text =
                resources.getString(R.string.itemTotal) + " | " + resources.getString(R.string.rs) +
                        totalAmount.toString()
        }.autoDispose(compositeDisposable)

        binCart.throttleClicks().subscribe {
            onBackPressed()

        }.autoDispose(compositeDisposable)


        minusCart.throttleClicks().subscribe {
            if (quantitySum <= "1") {
                minusCart.visibility = View.GONE
                binCart.visibility = View.VISIBLE
                finish()

            } else {

                quantitySum = (quantitySum.toInt().minus(1)).toString()
                totalAmount = totalAmount!!.toFloat().minus(amount.toFloat())

                tvQuantity.text = quantitySum.toString()
                tvProductPriceQuantity.text =
                    resources.getString(R.string.rs) + totalAmount.toString()
                tvAmountQuantity.text =
                    resources.getString(R.string.itemTotal) + " | " + resources.getString(R.string.rs) +
                            totalAmount.toString()

                minusSymbol()
            }

        }.autoDispose(compositeDisposable)


        tvCustomiseQuantity.throttleClicks().subscribe {
            val intent = intent
            booleanCustomise = true

            intent.putExtra(KeysUtils.keyItem, quantitySum.toString())
            intent.putExtra(KeysUtils.keyRs, totalAmount.toString())
            intent.putExtra(KeysUtils.keyQuantityCustomise, booleanCustomise)
            intent.putExtra(KeysUtils.keyProductId, productId)
            setResult(Activity.RESULT_OK, intent)
            finish()
        }.autoDispose(compositeDisposable)

        ivFavouriteStoresQuantity.throttleClicks().subscribe {
            //TODO zp chnage
//            navigateToOrderScreenActivity()

            if(Utils.userId ==0){
                val intent = Intent(applicationContext, LoginActivity::class.java)
                startActivityForResultWithDefaultAnimations(intent, ConstantUtils.FAV_LOGIN_REQUEST_CODE)
            }else{
                if (is_Favourite) {
                    isFavourite = "0"
                    is_Favourite = false
                    ivFavouriteStoresQuantity.setImageResource(R.drawable.heart)
                } else {
                    isFavourite = "1"
                    is_Favourite = true
                    ivFavouriteStoresQuantity.setImageResource(R.drawable.heartpress)
                }

                getStoreFavouriteApi()
            }

        }.autoDispose(compositeDisposable)
    }

    private fun getStoreFavouriteApi() {
        showProgress()
        storeWithProductViewModel.getStoreFavouriteApi(getFavourite())
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


    private fun navigateToOrderScreenActivity() {

        val intent = Intent(this, CustomerMainActivity::class.java)
        intent.flags =
            Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        intent.putExtra(KeysUtils.keyCustomer, resources.getString(R.string.favouriteScreen))
        startActivity(intent)
        finish()
    }

    private fun observeViewModel() {

        selectQuantityViewModel.message.observe(this,
            Observer {
                hideProgress()
                booleanCustomise = false
                val intent = intent
                intent.putExtra(KeysUtils.keyItem, quantitySum.toString())
                intent.putExtra(KeysUtils.keyRs, totalAmount.toString())
                intent.putExtra(KeysUtils.keyQuantityCustomise, booleanCustomise)
                intent.putExtra(KeysUtils.keyProductId, productId)
                setResult(Activity.RESULT_OK, intent)
                finish()
            })

        selectQuantityViewModel.store_detail.observe(this,
            Observer {
                hideProgress()
                getStoreDetails = it
                arrayStoreDetailsList?.clear()
                arraySliderImageList?.clear()
                arrayStoreDetailsList?.addAll(it.food_category)
                arraySliderImageList?.addAll(it.slider_images)
                setAllDetails()
            })
        selectQuantityViewModel.errorMessage.observe(this,
            Observer {
                hideProgress()
            })

        storeWithProductViewModel.errorMessage.observe(this,
            Observer {
                hideProgress()
            })

        storeWithProductViewModel.message.observe(this,
            Observer {
                hideProgress()
            })

    }


    private fun getAddStoreDetails(): AddStoreDetails {
        return AddStoreDetails(
            Utils.seceretKey,
            Utils.accessKey,
            this.storeId!!,
            Utils.userId
        )
    }

    private fun getAddItemCart(): AddItemCart {
        return AddItemCart(
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId,
            this.storeId!!,
            userStoreId,
            this.productId!!,
            userProductId,
            this.quantitySum,
            this.arrayAddOnsList!!,
            productOptionId,
            Utils.guestId
        )
    }

    private fun getStoreDetailsApi() {
        showProgress()
        selectQuantityViewModel.getStoreWithProductDetailsApi(getAddStoreDetails())
    }

    private fun getAddItemToCartApi() {
        showProgress()
        selectQuantityViewModel.getAddItemCartApi(getAddItemCart())
    }

    private fun setAllDetails() {

        tvStoreNameQuantity.text = getStoreDetails?.store_name
        tvStoreAddressQuantity.text = getStoreDetails?.store_address
//        tvStoreRatingQuantity.text = getStoreDetails?.store_rating
        Glide.with(applicationContext)
            .load(URLConstant.nearByStoreUrl + getStoreDetails?.store_logo)
            .placeholder(R.drawable.placeholder_store_in_category)
            .into(ivStoreImageQuantity)
//        is_Favourite = getStoreDetails?.is_favourite!!
//        foodCategoryAdapter?.notifyDataSetChanged()
        is_Favourite = getStoreDetails?.is_favourite!!
        sliderAdapter?.notifyDataSetChanged()
        var openingConvertTime: String? = null
        var closingConvertTime: String? = null

        for ((index, value) in getStoreDetails?.schedule?.withIndex()!!) {
            if (currentDay == getStoreDetails?.schedule?.get(index)!!.weekday) {
                openingTime = getStoreDetails?.schedule?.get(index)!!.opening_time
                closingTime = getStoreDetails?.schedule?.get(index)!!.closing_time


                openingConvertTime = Utils.convertTime(openingTime!!)
                closingConvertTime = Utils.convertTime(closingTime!!)

                checkTimeStatus = Utils.checkTimeStatus(
                    openingConvertTime,
                    closingConvertTime,
                    this.currentTimeConvert!!
                )

            }
        }

        if (this.checkTimeStatus!!) {
            tvOpeningStatusQuantity.setTextColor(
                ContextCompat.getColor(
                    this,
                    R.color.colorGreenStatus
                )
            )
            tvOpeningStatusQuantity.text = resources.getString(R.string.openingNow)
        } else {
            tvOpeningStatusQuantity.setTextColor(ContextCompat.getColor(this, R.color.colorRed))
            tvOpeningStatusQuantity.text = resources.getString(R.string.closed)
        }

        tvCurrentDayTimeQuantity.text =
            " " + openingConvertTime + " - " + closingConvertTime + "(today)"

        if (is_Favourite) {
            isFavourite = "1"
            is_Favourite = true
            ivFavouriteStoresQuantity.setImageResource(R.drawable.heartpress)
        } else {
            isFavourite = "0"
            is_Favourite = false
            ivFavouriteStoresQuantity.setImageResource(R.drawable.heart)
        }

//        ValidationUtils.fetchRouteDistance(
//            applicationContext,
//            keyLaititude!!.toDouble(),
//            keyLongitude!!.toDouble(),
//            getStoreDetails?.latitude!!.toDouble(),
//            getStoreDetails?.longitude!!.toDouble(),
//            textDistanceQuantity
//        )
    }

    private fun minusSymbol() {
        if (quantitySum <= "1") {
            binCart.visibility = View.VISIBLE
            minusCart.visibility = View.GONE
        } else {
            minusCart.visibility = View.VISIBLE
            binCart.visibility = View.GONE
        }
    }

    override fun onBackPressed() {
        finish()
    }
}
