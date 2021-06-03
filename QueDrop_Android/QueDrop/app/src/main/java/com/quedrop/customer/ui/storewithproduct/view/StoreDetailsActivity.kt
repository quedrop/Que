package com.quedrop.customer.ui.storewithproduct.view

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.GridLayoutManager
import com.bumptech.glide.Glide

import com.quedrop.customer.R
import com.quedrop.customer.ui.foodcategory.view.FoodCategoryActivity
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.*
import com.quedrop.customer.ui.login.view.LoginActivity
import com.quedrop.customer.ui.storewithproduct.viewmodel.StoreWithProductViewModel
import com.quedrop.customer.utils.*
import kotlinx.android.synthetic.main.activity_store_details.*


class StoreDetailsActivity : BaseActivity() {

    lateinit var storeWithProductViewModel: StoreWithProductViewModel
    var getStoreDetails: GetStoreDetails? = null
    var arrayStoreDetailsList: MutableList<FoodCategory>? = null
    var arrayFreshProduceStoreList: MutableList<FoodCategory>? = mutableListOf()
    var arrayCategoryStoreList: MutableList<FoodCategory>? = mutableListOf()
    var arraySliderImageList: MutableList<SliderImages>? = null
    var foodCategoryAdapter: CategoriesFoodAdapter? = null
    var sliderAdapter: SliderAdapter? = null

    var storeId: Int? = null
    var is_Favourite: Boolean = false
    var isFavourite: String? = "0"
    var currentDate: String? = null
    var currentTime: String? = null
    var currentTimeConvert: String? = null
    var currentDay: String? = null
    var openingTime: String? = null
    var closingTime: String? = null
    var checkTimeStatus: Boolean? = false
    var booleanSearch: Boolean = false
    var searchFlag: Boolean = false

    var freshProduceCateId: Int? = 0
    var fromFreshProduceCatId: Boolean? = false


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_store_details)

        storeId = intent.getIntExtra(KeysUtils.keyStoreId, 0)
        freshProduceCateId = intent.getIntExtra(KeysUtils.KeyFreshProduceCategoryId, 0)


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


        currentDate = Utils.getCurrentDate()
        currentTime = Utils.getCurrentTime()
        currentTimeConvert = Utils.convertTime(currentTime!!)
        currentDay = Utils.getCurrentDay()
        booleanSearch = false
        searchFlag = false

        storeWithProductViewModel = StoreWithProductViewModel(appService)

        initMethod()
        observeViewModel()
        onClickMethod()
        getStoreDetailsApi()

    }

    private fun initMethod() {
        rvStoreDetails.layoutManager = GridLayoutManager(
            applicationContext!!,
            2
        )

        arrayStoreDetailsList = mutableListOf()

        foodCategoryAdapter = CategoriesFoodAdapter(
            applicationContext!!,
            arrayStoreDetailsList
        ).apply {
            adItemClickFood = { position: Int, view: View ->
                itemAdapterClick(position, view)
            }
        }
        rvStoreDetails.adapter = foodCategoryAdapter



        arraySliderImageList = mutableListOf()

        sliderAdapter = SliderAdapter(
            applicationContext!!,
            arraySliderImageList
        )

        ivSlider.sliderAdapter = sliderAdapter

    }

    private fun onClickMethod() {
        ivBackStore.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        ivFavouriteStores.throttleClicks().subscribe {

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
                    ivFavouriteStores.setImageResource(R.drawable.heart)
                } else {
                    isFavourite = "1"
                    is_Favourite = true
                    ivFavouriteStores.setImageResource(R.drawable.heartpress)
                }

                getStoreFavouriteApi()
            }

        }.autoDispose(compositeDisposable)

        ivSearchCategories.throttleClicks().subscribe {
            if (booleanSearch) {
                if (arrayStoreDetailsList?.size!! > 0) {
                    searchClick(0)
                } else {
                    Toast.makeText(
                        applicationContext,
                        resources.getString(R.string.noCategoryAvailableStore),
                        Toast.LENGTH_SHORT
                    ).show()
                }
            }

        }.autoDispose(compositeDisposable)
    }

    private fun setAllDetails() {

        tvStoreName.text = getStoreDetails?.store_name
        tvStoreAddress.text = getStoreDetails?.store_address
//        tvStoreRating.text = getStoreDetails?.store_rating
        Glide.with(applicationContext)
            .load(URLConstant.nearByStoreUrl + getStoreDetails?.store_logo)
            .placeholder(R.drawable.placeholder_order_cart_product)
            .into(ivStoreImage)

        is_Favourite = getStoreDetails?.is_favourite!!
        foodCategoryAdapter?.notifyDataSetChanged()
        sliderAdapter?.notifyDataSetChanged()


        var openingConvertTime: String? = null
        var closingConvertTime: String? = null

        tvCurrentDayTime.visibility = View.GONE
        tvOpeningStatus.setTextColor(ContextCompat.getColor(this, R.color.colorRed))
        tvOpeningStatus.text = resources.getString(R.string.closed)


        for ((index, value) in getStoreDetails?.schedule?.withIndex()!!) {
            if (currentDay == getStoreDetails?.schedule?.get(index)!!.weekday) {
                openingTime = getStoreDetails?.schedule?.get(index)!!.opening_time
                closingTime = getStoreDetails?.schedule?.get(index)!!.closing_time

                if (openingTime == "" && closingTime == "") {

                    tvCurrentDayTime.visibility = View.GONE
                    tvOpeningStatus.setTextColor(ContextCompat.getColor(this, R.color.colorRed))
                    tvOpeningStatus.text = resources.getString(R.string.closed)
                } else {
                    tvCurrentDayTime.visibility = View.VISIBLE

                    openingConvertTime = Utils.convertTime(openingTime!!)
                    closingConvertTime = Utils.convertTime(closingTime!!)

                    checkTimeStatus = Utils.checkTimeStatus(
                        openingConvertTime,
                        closingConvertTime,
                        this.currentTimeConvert!!
                    )

                    if (this.checkTimeStatus!!) {
                        tvOpeningStatus.setTextColor(
                            ContextCompat.getColor(
                                this,
                                R.color.colorGreenStatus
                            )
                        )
                        tvOpeningStatus.text = resources.getString(R.string.openingNow)
                    } else {
                        tvOpeningStatus.setTextColor(ContextCompat.getColor(this, R.color.colorRed))
                        tvOpeningStatus.text = resources.getString(R.string.closed)
                    }

                    tvCurrentDayTime.text =
                        " - " + openingConvertTime + " - " + closingConvertTime + "(today)"
                }
            }
        }

        if (is_Favourite) {
            isFavourite = "1"
            is_Favourite = true
            ivFavouriteStores.setImageResource(R.drawable.heartpress)
        } else {
            isFavourite = "0"
            is_Favourite = false
            ivFavouriteStores.setImageResource(R.drawable.heart)
        }

        Utils.fetchRouteDistance(
            applicationContext,
            Utils.keyLatitude.toDouble(),
            Utils.keyLongitude.toDouble(),
            getStoreDetails?.latitude!!.toDouble(),
            getStoreDetails?.longitude!!.toDouble(),
            textDistance
        )
    }

    private fun observeViewModel() {

        storeWithProductViewModel.message.observe(this,
            Observer {
                hideProgress()
                RxBus.instance?.publish("refreshFavourite")
            })

        storeWithProductViewModel.store_detail.observe(this,
            Observer {
                hideProgress()
                getStoreDetails = it
                booleanSearch = true
                arrayStoreDetailsList?.clear()
                arraySliderImageList?.clear()
                arrayStoreDetailsList?.addAll(it.food_category)
                arraySliderImageList?.addAll(it.slider_images)
                filterStoreDetailArray()
                setAllDetails()

            })

        storeWithProductViewModel.errorMessage.observe(this,
            Observer {
                hideProgress()
            })

    }

    private fun filterStoreDetailArray() {
        for (i in arrayStoreDetailsList?.indices!!) {
            if (arrayStoreDetailsList?.get(i)?.fresh_produce_category_id != 0) {
                arrayFreshProduceStoreList?.add(arrayStoreDetailsList?.get(i)!!)
            } else {
                arrayCategoryStoreList?.add(arrayStoreDetailsList?.get(i)!!)
            }
        }

        if (arrayFreshProduceStoreList?.size!! > 0) {
            tvSlash.visibility = View.VISIBLE
            tvFreshProduce.visibility = View.VISIBLE
        } else {
            tvSlash.visibility = View.GONE
            tvFreshProduce.visibility = View.GONE
        }

        //firstTime
        tvCategories.setTextColor(ContextCompat.getColor(this, R.color.colorBlack))
        tvFreshProduce.setTextColor(ContextCompat.getColor(this, R.color.colorLightGray))
        foodCategoryAdapter?.arrayFoodCategoryList?.clear()
        foodCategoryAdapter?.arrayFoodCategoryList?.addAll(arrayCategoryStoreList!!)
        foodCategoryAdapter?.notifyDataSetChanged()

        tvCategories.throttleClicks().subscribe {
            fromFreshProduceCatId = false
            tvCategories.setTextColor(ContextCompat.getColor(this, R.color.colorBlack))
            tvFreshProduce.setTextColor(ContextCompat.getColor(this, R.color.colorLightGray))

            foodCategoryAdapter?.arrayFoodCategoryList?.clear()
            foodCategoryAdapter?.arrayFoodCategoryList?.addAll(arrayCategoryStoreList!!)
            foodCategoryAdapter?.notifyDataSetChanged()

        }.autoDispose(compositeDisposable)

        tvFreshProduce.throttleClicks().subscribe {
            fromFreshProduceCatId = true
            tvFreshProduce.setTextColor(ContextCompat.getColor(this, R.color.colorBlack))
            tvCategories.setTextColor(ContextCompat.getColor(this, R.color.colorLightGray))

            foodCategoryAdapter?.arrayFoodCategoryList?.clear()
            foodCategoryAdapter?.arrayFoodCategoryList?.addAll(arrayFreshProduceStoreList!!)
            foodCategoryAdapter?.notifyDataSetChanged()

        }.autoDispose(compositeDisposable)

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

    private fun getAddStoreDetails(): AddStoreDetails {
        return AddStoreDetails(
            Utils.seceretKey,
            Utils.accessKey,
            this.storeId!!,
            Utils.userId
        )
    }

    private fun getStoreDetailsApi() {
        showProgress()
        storeWithProductViewModel.getStoreWithProductDetailsApi(getAddStoreDetails())
    }

    private fun getStoreFavouriteApi() {
        showProgress()
        storeWithProductViewModel.getStoreFavouriteApi(getFavourite())
    }

    private fun itemAdapterClick(position: Int, view: View) {
        searchFlag = false

        val intent = Intent(applicationContext, FoodCategoryActivity::class.java)
        intent.putExtra(KeysUtils.keyStoreId, storeId)
        intent.putExtra(KeysUtils.keyStoreCategoryId, arrayStoreDetailsList?.get(position)?.store_category_id)
        intent.putExtra(KeysUtils.keySearch, searchFlag)
        intent.putExtra(KeysUtils.keyArrayFoodPosition, position)
        intent.putExtra(KeysUtils.keyPositionFoodCatrgories, arrayStoreDetailsList?.get(position)?.store_category_title)
        intent.putExtra(KeysUtils.KeyFreshProduceCategoryId, arrayStoreDetailsList?.get(position)?.fresh_produce_category_id)

        if (arrayStoreDetailsList?.get(position)?.fresh_produce_category_id == 0) {
            intent.putExtra(KeysUtils.KeyIsFromFreshProduceCat, false)
        } else {
            intent.putExtra(KeysUtils.KeyIsFromFreshProduceCat, true)
        }

        startActivityWithDefaultAnimations(intent)
    }

    private fun searchClick(position: Int) {
        searchFlag = true

        val intent = Intent(applicationContext, FoodCategoryActivity::class.java)
        intent.putExtra(KeysUtils.keyStoreId, storeId)
        intent.putExtra(KeysUtils.keyStoreCategoryId, arrayStoreDetailsList?.get(position)?.store_category_id)
        intent.putExtra(KeysUtils.keyArrayFoodPosition, position)
        intent.putExtra(KeysUtils.keySearch, searchFlag)
        intent.putExtra(KeysUtils.keyPositionFoodCatrgories, arrayStoreDetailsList?.get(position)?.store_category_title)
        intent.putExtra(KeysUtils.KeyFreshProduceCategoryId, arrayStoreDetailsList?.get(position)?.fresh_produce_category_id)
        intent.putExtra(KeysUtils.KeyIsFromFreshProduceCat, fromFreshProduceCatId)

        startActivityWithDefaultAnimations(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            ConstantUtils.FAV_LOGIN_REQUEST_CODE -> {


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
                        ivFavouriteStores.setImageResource(R.drawable.heart)
                    } else {
                        isFavourite = "1"
                        is_Favourite = true
                        ivFavouriteStores.setImageResource(R.drawable.heartpress)
                    }

                    getStoreFavouriteApi()
                }

            }
        }
    }
}


