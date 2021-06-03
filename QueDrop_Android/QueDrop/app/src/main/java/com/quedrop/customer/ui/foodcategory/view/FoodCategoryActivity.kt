package com.quedrop.customer.ui.foodcategory.view

import android.app.Dialog
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.widget.Toast
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.RecyclerView.SimpleOnItemTouchListener
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.*
import com.quedrop.customer.ui.addons.view.AddOnsActivity
import com.quedrop.customer.ui.cart.view.CartActivity
import com.quedrop.customer.ui.foodcategory.viewmodel.FoodCategoryViewModel
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.selectquantity.view.SelectQuantityActivity
import com.quedrop.customer.utils.ConstantUtils
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.activity_food_category.*


class FoodCategoryActivity : BaseActivity() {

    var titleFoodCatrgory: String? = null
    var storeId: Int? = null
    var getStoreDetails: GetStoreDetails? = null
    var foodTitleAdapter: FoodTitleAdapter? = null
    var arrayFoodTitleList: MutableList<StoreCategoryProduct>? = null
    var arrayFoodProductList: MutableList<ProductDetails>? = null
    var foodProductAdapter: FoodProductAdapter? = null
    var position: Int? = null
    var filterFlag: Boolean = false
    var storeCategoryId: Int? = null
    var templist: MutableList<StoreCategoryProduct>? = null
    var searchProductFlag: Boolean = false
    var arrayProductOptionList: MutableList<ProductOption>? = null
    lateinit var foodCategoryViewModel: FoodCategoryViewModel

    var freshProduceCateId: Int? = 0


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_food_category)

        storeId = intent.getIntExtra(KeysUtils.keyStoreId, 0)
        searchProductFlag = intent.getBooleanExtra(KeysUtils.keySearch, false)
        titleFoodCatrgory = intent.getStringExtra(KeysUtils.keyPositionFoodCatrgories)
        position = intent.getIntExtra(KeysUtils.keyArrayFoodPosition, 1)
        storeCategoryId = intent.getIntExtra(KeysUtils.keyStoreCategoryId, 0)
        freshProduceCateId = intent.getIntExtra(KeysUtils.KeyFreshProduceCategoryId, 0)

        foodCategoryViewModel = FoodCategoryViewModel(appService)

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

        initMethod()
        observeViewModel()
        onClickMethod()
        getStoreCategoryWithProductApi()

    }

    private fun initMethod() {

        constraintFood.visibility = View.GONE
        if (searchProductFlag) {
            searchConstraintFood.visibility = View.VISIBLE
        } else {
            searchConstraintFood.visibility = View.GONE
        }

        if (titleFoodCatrgory != null) {
            tvCategoryFood.text = titleFoodCatrgory
        }

        rvCategoryFood.layoutManager = LinearLayoutManager(
            applicationContext!!,
            LinearLayoutManager.HORIZONTAL,
            false
        )
        arrayFoodTitleList = mutableListOf()
        arrayProductOptionList = mutableListOf()

        foodTitleAdapter = FoodTitleAdapter(
            applicationContext!!,
            arrayFoodTitleList, this.position!!
        ).apply {
            itemClickIvoke = {
                itemClick(it)
            }
        }
        rvCategoryFood.adapter = foodTitleAdapter

        rvItemFood.layoutManager = LinearLayoutManager(
            applicationContext!!,
            LinearLayoutManager.VERTICAL,
            false
        )
        arrayFoodProductList = mutableListOf()

        foodProductAdapter = FoodProductAdapter(
            applicationContext!!,
            arrayFoodProductList, filterFlag
        ).apply {
            dialogNoFeesInvoke = { arrayFoodList: MutableList<ProductDetails>?, pos: Int ->
                dialogNoFees(arrayFoodList, pos)
            }
            addNewActivityInvoke = { pos: Int, arrayFoodList: MutableList<ProductDetails>? ->
                addNewActivity(pos, arrayFoodList!!)
            }
            addQuantityActivityInvoke = { pos: Int, arrayFoodList: MutableList<ProductDetails>? ->
                addQuantityActivity(pos, arrayFoodList!!)
            }
        }
        rvItemFood.adapter = foodProductAdapter

        rvItemFood.addOnItemTouchListener(object : SimpleOnItemTouchListener() {
            override fun onInterceptTouchEvent(
                rv: RecyclerView,
                e: MotionEvent
            ): Boolean {

                var posmain = 0

                val pos =
                    (rv.layoutManager as LinearLayoutManager).findFirstCompletelyVisibleItemPosition()

                for ((index, value) in arrayFoodTitleList?.withIndex()!!) {
                    if (arrayFoodProductList!![pos].store_category_id == value.store_category_id) {
                        posmain = index
                    }
                }
                foodTitleAdapter?.setPosMain(posmain)
                return false
            }
        })

    }

    private fun onClickMethod() {
        ivBackFood.throttleClicks().subscribe {

            onBackPressed()
        }.autoDispose(compositeDisposable)

        ivSearchFood.throttleClicks().subscribe {

            searchConstraintFood.visibility = View.VISIBLE
//            editFood.isCursorVisible=true
//            showKeyboard()
        }.autoDispose(compositeDisposable)

        ivHomeFood.throttleClicks().subscribe() {
            val intent = Intent(this, CustomerMainActivity::class.java)
            intent.putExtra(KeysUtils.keyCustomer, "")
            intent.putExtra(KeysUtils.keyDriverId, "")
            intent.putExtra(KeysUtils.keyDriverAccepted, false)
            intent.flags =
                Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            startActivityWithDefaultAnimations(intent)
            finish()
        }.autoDispose(compositeDisposable)

        tvViewCartCategory.throttleClicks().subscribe {

            val intent = Intent(applicationContext, CartActivity::class.java)
            intent.putExtra(KeysUtils.keyUserProductId, "")
            startActivityForResultWithDefaultAnimations(
                intent,
                ConstantUtils.REQUEST_CART_FOOD_CATEGORY
            )
        }.autoDispose(compositeDisposable)

        editFood.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                if (s != null) {
                    filter(s.toString())
                } else {
                    filterFlag = false
                    foodProductAdapter?.filterFlag()
                    setAllResponse()
                }
            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

            }
        })

        clearTextFood.throttleClicks().subscribe {
            editFood.text.clear()
            searchConstraintFood.visibility = View.GONE

            filterFlag = false
            foodProductAdapter?.filterFlag()

            setAllResponse()

            if (Utils.isKeyboardShown(applicationContext, constraintMainFood)) {

            } else {
            }

        }.autoDispose(compositeDisposable)


    }

    private fun setAllResponse() {
        arrayFoodTitleList?.clear()
        arrayFoodProductList?.clear()

        val tempProductList = arrayListOf<ProductDetails>()

        var prevId = 0

        for (item in templist!!) {

            if (item.store_category_id != prevId) {
                item.products[0].header = true
                prevId = item.store_category_id
            } else {
                tempProductList.addAll(item.products)
                item.products[0].header = false
            }

            for (product in item.products) {
                product.store_category_title = item.store_category_title
                product.store_category_image = item.store_category_image
                tempProductList.add(product)
            }
        }

        arrayFoodTitleList?.addAll(templist?.toMutableList()!!)
        arrayFoodProductList?.addAll(tempProductList)
        foodProductAdapter?.filterFlag()
        foodTitleAdapter?.notifyDataSetChanged()
        foodProductAdapter?.notifyDataSetChanged()
        itemClick(storeCategoryId!!)
    }

    private fun observeViewModel() {
        foodCategoryViewModel.storeCategoryProductList.observe(this, androidx.lifecycle.Observer {

            filterFlag = false
            hideProgress()
            templist?.clear()
            templist = it.toMutableList()
            Log.e("checkItem", "check")
            arrayFoodProductList = mutableListOf()

            foodProductAdapter = FoodProductAdapter(
                applicationContext!!,
                arrayFoodProductList, filterFlag
            ).apply {
                dialogNoFeesInvoke = { arrayFoodList: MutableList<ProductDetails>?, pos: Int ->
                    dialogNoFees(arrayFoodList, pos)
                }
                addNewActivityInvoke = { pos: Int, arrayFoodList: MutableList<ProductDetails>? ->
                    addNewActivity(pos, arrayFoodList!!)
                }
                addQuantityActivityInvoke =
                    { pos: Int, arrayFoodList: MutableList<ProductDetails>? ->
                        addQuantityActivity(pos, arrayFoodList!!)
                    }
            }
            rvItemFood.adapter = foodProductAdapter
            setAllResponse()
        })

        foodCategoryViewModel.otherDetails.observe(this, androidx.lifecycle.Observer {

            hideProgress()
            if (it.total_items == "0") {
                constraintFood.visibility = View.GONE
            } else {
                constraintFood.visibility = View.VISIBLE

                tvAmountCategory.text =
                    it.total_items + " " + resources.getString(R.string.itemTotalRs) + " | " + resources.getString(
                        R.string.rs
                    ) + it.total_price

            }
        })
        foodCategoryViewModel.errorMessage.observe(this, androidx.lifecycle.Observer {
            hideProgress()
            Toast.makeText(applicationContext, it, Toast.LENGTH_SHORT).show()
        })
    }

    private fun getStoreCategoryWithProduct(): AddStoreCategoriesItem {
        val isFreshProduced: Int

        isFreshProduced = if (freshProduceCateId == 0) {
            0
        } else {
            1
        }

        return AddStoreCategoriesItem(
            Utils.seceretKey,
            Utils.accessKey,
            this.storeId!!,
            Utils.userId,
            Utils.guestId,
            isFreshProduced
        )
    }

    private fun getStoreCategoryWithProductApi() {
        showProgress()
        foodCategoryViewModel.getStoreCategoryWithProductApi(getStoreCategoryWithProduct())

    }

    private fun addNewActivity(pos: Int, arrayAdapterList: MutableList<ProductDetails>) {

        Utils.flagCartCustomise = false

        SharedPrefsUtils.removeSharedPreference(applicationContext, KeysUtils.keyListAddOns)
        SharedPrefsUtils.removeSharedPreference(applicationContext, KeysUtils.keyListProductOption)
        val intent = Intent(this, AddOnsActivity::class.java)
        intent.putExtra(
            KeysUtils.keyProductCategory,
            arrayAdapterList.get(pos).store_category_title
        )
        SharedPrefsUtils.setBooleanPreference(
            applicationContext,
            KeysUtils.keyFlagCart,
            Utils.flagCartCustomise
        )
        intent.putExtra(KeysUtils.keyProductId, arrayAdapterList.get(pos).product_id)
        intent.putExtra(KeysUtils.keyStoreId, storeId)
        intent.putExtra(KeysUtils.keyAddOns, arrayAdapterList.get(pos).has_addons)
        intent.putExtra(KeysUtils.keyProductPrice, arrayAdapterList.get(pos).product_price)
        intent.putExtra(KeysUtils.keyProductOptionId, "0")
        startActivityForResultWithDefaultAnimations(intent, ConstantUtils.REQUEST_CODE_ADDITEM)

    }

    private fun addQuantityActivity(pos: Int, arrayAdapterList: MutableList<ProductDetails>) {

        arrayProductOptionList = arrayAdapterList.get(pos).product_option

        SharedPrefsUtils.removeSharedPreference(applicationContext, KeysUtils.keyListAddOns)
        SharedPrefsUtils.removeSharedPreference(applicationContext, KeysUtils.keyListProductOption)
        val intent = Intent(this, SelectQuantityActivity::class.java)
        intent.putExtra(
            KeysUtils.keyProductCategory,
            arrayAdapterList.get(pos).store_category_title
        )

        intent.putExtra(KeysUtils.keyProductName, arrayAdapterList.get(pos).product_name)
        intent.putExtra(KeysUtils.keyRs, arrayAdapterList.get(pos).product_price)
        intent.putExtra(KeysUtils.keyProductId, arrayAdapterList.get(pos).product_id)
        intent.putExtra(KeysUtils.keyStoreId, storeId)
        intent.putExtra(KeysUtils.keyItem, "1")
        intent.putExtra(KeysUtils.keyAddOns, arrayAdapterList.get(pos).has_addons)
        SharedPrefsUtils.setListPreference(
            applicationContext, KeysUtils.keyListProductOption,
            arrayProductOptionList?.toMutableList()!!
        )
        startActivityForResultWithDefaultAnimations(intent, ConstantUtils.REQUEST_CODE_ADDITEM)

    }

    private fun filter(text: String) {

        Log.e("check", "check")

        var arrayFilteredTitleList: MutableList<StoreCategoryProduct>? = null
        var filteredList: MutableList<ProductDetails>? = null

        filteredList = mutableListOf()
        arrayFilteredTitleList = mutableListOf()
        for ((item, value) in this.arrayFoodProductList!!.withIndex()) {
            value.header = false
            if (value.product_name.toLowerCase().contains(text.toLowerCase())) {

                filteredList.add(value)

                for ((item1, value1) in this.arrayFoodTitleList!!.withIndex()) {
                    if (value.store_category_title.toLowerCase() == value1.store_category_title.toLowerCase()) {

                        if (!arrayFilteredTitleList.contains(value1)) {
                            position = item1
                            value.header = true
                            arrayFilteredTitleList.add(value1)
                        }
                    }
                }
            }
        }
        filterFlag = true
        foodTitleAdapter?.filterList(arrayFilteredTitleList)
        foodProductAdapter?.filterList(filteredList)
    }


    private fun itemClick(store_cat_id: Int) {
        //        var scrollPoasition = -1

        for ((index, value) in arrayFoodProductList?.withIndex()!!) {
            if (value.store_category_id == store_cat_id) {
                rvItemFood.smoothScrollToPosition(index)
                foodProductAdapter?.notifyDataSetChanged()
                foodTitleAdapter?.notifyDataSetChanged()
                break
            }
        }
    }

    private fun dialogNoFees(arrayFoodList: MutableList<ProductDetails>?, id: Int?) {

        val dialog = Dialog(this)
        dialog.setContentView(R.layout.layout_tag_price_dialog)

        dialog.show()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)


        if (requestCode == ConstantUtils.REQUEST_CODE_ADDITEM) {
            if (resultCode == RESULT_OK) {
                if (data != null) {

                    editFood.text.clear()
                    searchConstraintFood.visibility = View.GONE
                    filterFlag = false


                    getStoreCategoryWithProductApi()

                    if (Utils.isKeyboardShown(applicationContext, constraintMainFood)) {

                    } else {
                    }
                }
            }
        } else if (requestCode == ConstantUtils.REQUEST_CART_FOOD_CATEGORY) {
            if (resultCode == RESULT_OK) {
                editFood.text.clear()
                searchConstraintFood.visibility = View.GONE
                filterFlag = false


                if (Utils.isKeyboardShown(applicationContext, constraintMainFood)) {

                } else {
                }
                getStoreCategoryWithProductApi()

            }
        }

    }

    override fun onBackPressed() {
        if (Utils.isKeyboardShown(applicationContext, constraintMainFood)) {

        } else {
            finish()
        }
    }


}
