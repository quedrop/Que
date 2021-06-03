package com.quedrop.customer.ui.addons.view

import android.app.Activity
import android.app.Dialog
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.*
import com.quedrop.customer.ui.addons.viewmodel.AddOnsViewModel
import com.quedrop.customer.ui.selectquantity.view.SelectQuantityActivity
import com.quedrop.customer.utils.ConstantUtils
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import com.quedrop.customer.model.ProductAddOns
import kotlinx.android.synthetic.main.activity_add_ons.*
import kotlinx.android.synthetic.main.activity_add_ons.constraint2
import kotlinx.android.synthetic.main.activity_add_ons.rvAddOnItems
import kotlinx.android.synthetic.main.activity_add_ons.tvAddItem
import kotlinx.android.synthetic.main.activity_add_ons.tvAmount
import kotlinx.android.synthetic.main.activity_add_ons.tvProductName
import kotlinx.android.synthetic.main.activity_add_ons.tvProductPrice


class AddOnsActivity : BaseActivity() {

    private var productId: Int? = null
    private var carrProductId: Int? = 0
    private var categoryTitle: String? = null
    var productInfo: ProductAddOns? = null
    private var arrayCheckItemList: MutableList<AddOns>? = null
    private var arrayProductOptionList: MutableList<ProductOption>? = null
    private var arrayProductCheckList: MutableList<ProductOption>? = null
    var addAddOnsAdapter: AddOnsAdapter? = null
    var addProductOptionAdapter: ProductOptionAdapter? = null
    var sum: Float = 0f
    var storeId: Int? = null
    var finalAmount: Float? = null
    var selectedPrize: Float? = null
    var arrayAddOnsList: MutableList<AddOns>? = null
    var selectQuantity: String = "1"
    var progressDialog: Dialog? = null
    var hasAddONS: String? = null
    var spinnerItemS: String? = null
    var posOption: Int = 0
    var productPrice: String = "0"
    var posOptionId: Int = 0
    lateinit var addOnsViewModel: AddOnsViewModel
    var couponCode: String = ""
    var booleanCustomise: Boolean = false
    var deliverOption: String = ""


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_ons)

        addOnsViewModel = AddOnsViewModel(appService)
        productId = intent.getIntExtra(KeysUtils.keyProductId, 0)
        hasAddONS = intent.getStringExtra(KeysUtils.keyAddOns)
        categoryTitle = intent.getStringExtra(KeysUtils.keyProductCategory)
        productPrice = intent.getStringExtra(KeysUtils.keyProductPrice)
        storeId = intent.getIntExtra(KeysUtils.keyStoreId, 0)
        carrProductId = intent.getIntExtra(KeysUtils.keyCartProductId, 0)
        posOptionId = intent.getIntExtra(KeysUtils.keyProductOptionId, 0)
        if(intent.hasExtra(KeysUtils.keyDeliveryOption)) {
            deliverOption = intent.getStringExtra(KeysUtils.keyDeliveryOption)
        }
        Utils.flagCartCustomise =
            SharedPrefsUtils.getBooleanPreference(applicationContext, KeysUtils.keyFlagCart, false)

        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyGuestId, 0)
        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyUserId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyAccessKey)!!
        Utils.keyLatitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLatitude)!!
        Utils.keyLongitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLongitude)!!

        initMethod()
        observeViewModel()
        onClickMethod()
        getProductAddOnsApi()
    }

    private fun initMethod() {

        if (Utils.flagCartCustomise) {
            tvCategoryAddOns.text = resources.getString(R.string.customiseItem)
            tvAddItem.text = resources.getString(R.string.updateItem)
        } else {

            tvCategoryAddOns.text = categoryTitle
            tvAddItem.text = resources.getString(R.string.addItem)
        }

        rvAddOnItems.layoutManager = LinearLayoutManager(
            applicationContext!!,
            LinearLayoutManager.VERTICAL,
            false
        )

        rvSizeDescription.layoutManager = LinearLayoutManager(
            applicationContext!!,
            LinearLayoutManager.VERTICAL,
            false
        )
        arrayCheckItemList = mutableListOf()
        arrayAddOnsList = mutableListOf()
        arrayProductOptionList = mutableListOf()
        arrayProductCheckList = mutableListOf()
        arrayAddOnsList?.clear()
        arrayProductCheckList?.clear()

        arrayAddOnsList = SharedPrefsUtils.getObjectList<AddOns>(
            applicationContext,
            KeysUtils.keyListAddOns,
            AddOns::class.java
        )

        addAddOnsAdapter = AddOnsAdapter(
            applicationContext!!,
            arrayCheckItemList
        ).apply {
            sumOfTwo = { addValue: Float, position: Int ->
                sumOfTwo(addValue, position)
            }
            minusOfTwo = { addValue: Float, position: Int ->
                minusOfTwo(addValue, position)
            }
        }
        rvAddOnItems.adapter = addAddOnsAdapter



        SharedPrefsUtils.removeSharedPreference(applicationContext, KeysUtils.keyListProductOption)
        arrayProductCheckList = SharedPrefsUtils.getObjectList<ProductOption>(
            applicationContext,
            KeysUtils.keyListAddOns,
            ProductOption::class.java
        )

        addProductOptionAdapter = ProductOptionAdapter(
            applicationContext!!,
            arrayProductOptionList
        ).apply {
            size = { pos: Int, view: View ->
                setSizeProduct(pos)
            }
        }
        rvSizeDescription.adapter = addProductOptionAdapter

        addProductOptionAdapter?.checkList(arrayProductCheckList)
        addProductOptionAdapter?.notifyDataSetChanged()

    }

    private fun onClickMethod() {
        ivBackAddOns.throttleClicks().subscribe {
            this.onBackPressed()
        }.autoDispose(compositeDisposable)

        tvAddItem.throttleClicks().subscribe {
            newActivity()
        }.autoDispose(compositeDisposable)
    }

    var sb = StringBuilder()
    private fun setAllProductInfo() {


        tvProductName.text = productInfo?.product_name
        tvProductDescription.text = productInfo?.product_description

        addAddOnsAdapter?.notifyDataSetChanged()

        selectedPrize = productInfo?.product_price!!.toFloat()


        if (Utils.flagCartCustomise) {

            for ((i, v) in arrayProductOptionList?.withIndex()!!) {
                if (v.option_id == posOptionId) {
                    posOption = i
                }
            }

        } else {
            for ((i, v) in arrayProductOptionList?.withIndex()!!) {
                if (v.price == productPrice) {
                    posOption = i
                }
            }

        }
        if (arrayProductOptionList?.get(posOption)?.option_name == resources.getString(R.string.defaultSize)) {
            if (arrayProductOptionList?.size!! > ConstantUtils.ONE) {
                constraint2.visibility = View.VISIBLE
            } else {
                constraint2.visibility = View.GONE
            }

        } else {
            constraint2.visibility = View.VISIBLE
        }
        selectedPrize = arrayProductOptionList?.get(posOption)?.price!!.toFloat()
        arrayProductCheckList?.add(arrayProductOptionList?.get(posOption)!!)


        setSizePlus()

        addProductOptionAdapter?.setPrice(selectedPrize!!, posOption)
        addProductOptionAdapter?.notifyDataSetChanged()
    }

    private fun newActivity() {

        if (Utils.flagCartCustomise) {
            showProgress()
            val customiseCart = CustomiseCart(
                Utils.seceretKey,
                Utils.accessKey,
                carrProductId!!,
                arrayAddOnsList?.toMutableList()!!,
                posOptionId,
                Utils.keyLatitude,
                Utils.keyLongitude,
                couponCode,
                Utils.userId,
                Utils.guestId,
                deliverOption
            )
            addOnsViewModel.getUpdateCustomiseApi(customiseCart)

        } else {
            val intentNew = Intent(this, SelectQuantityActivity::class.java)
            intentNew.putExtra(KeysUtils.keyProductId, productId)
            intentNew.putExtra(KeysUtils.keyProductName, productInfo?.product_name)
            intentNew.putExtra(KeysUtils.keyStoreId, storeId)
            intentNew.putExtra(KeysUtils.keyProductCategory, categoryTitle)
            intentNew.putExtra(KeysUtils.keyRs, finalAmount.toString())
            intentNew.putExtra(KeysUtils.keyItem, selectQuantity)
            intentNew.putExtra(KeysUtils.keyAddOns, hasAddONS)
            intentNew.putExtra(KeysUtils.keyProductOptionPos, posOption)
            SharedPrefsUtils.setListPreference(
                applicationContext, KeysUtils.keyListProductOption,
                arrayProductCheckList?.toMutableList()!!
            )
            SharedPrefsUtils.setListPreference(
                applicationContext, KeysUtils.keyListAddOns,
                arrayAddOnsList?.toMutableList()!!
            )
            startActivityForResultWithDefaultAnimations(
                intentNew,
                ConstantUtils.REQUEST_CODE_ADDADDONS
            )
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)


        if (requestCode == ConstantUtils.REQUEST_CODE_ADDADDONS) {
            val intent = intent
            if (resultCode == Activity.RESULT_OK) {
                if (data != null) {
                    selectQuantity = data.getStringExtra(KeysUtils.keyItem) as String
                    var amountDifferent = data.getStringExtra(KeysUtils.keyRs)
                    booleanCustomise = data.getBooleanExtra(KeysUtils.keyQuantityCustomise, false)

                    if (booleanCustomise) {

                    } else {
                        intent.putExtra(KeysUtils.keyItem, selectQuantity)
                        intent.putExtra(KeysUtils.keyRs, amountDifferent)
                        intent.putExtra(KeysUtils.keyProductId, productId)
                        setResult(Activity.RESULT_OK, intent)
                        finish()
                    }

                }
            } else {
                finish()
            }
        }
    }

    private fun setSizeProduct(pos: Int) {

        arrayProductCheckList?.clear()
        posOption = pos
        selectedPrize = arrayProductOptionList?.get(posOption)?.price!!.toFloat()
        arrayProductCheckList?.add(arrayProductOptionList?.get(posOption)!!)
        posOptionId = arrayProductOptionList?.get(posOption)?.option_id!!
        setSizePlus()
    }

    private fun setSizePlus() {
        finalAmount = selectedPrize!! + sum
        tvAmount.text = resources.getString(R.string.itemTotal) + " | " + finalAmount
    }


    private fun sumOfTwo(twoVal: Float, pos: Int) {
        sum += twoVal
        setSizePlus()


        for ((item, value) in arrayCheckItemList?.withIndex()!!) {
            if (item == pos) {
                if (!arrayAddOnsList?.contains(arrayCheckItemList?.get(pos))!!) {
                    arrayAddOnsList?.add(arrayCheckItemList?.get(pos)!!)

                }
            }

        }
    }

    private fun minusOfTwo(twoVal: Float, pos: Int) {
        sum -= twoVal
        setSizePlus()

        for ((item, value) in arrayCheckItemList?.withIndex()!!) {
            if (item == pos) {
                arrayAddOnsList?.remove(arrayCheckItemList?.get(pos)!!)

            }
        }
    }

    private fun updateCustomiseItem() {
        val intent = intent
        setResult(Activity.RESULT_OK, intent)
        finish()
    }

    private fun observeViewModel() {

        addOnsViewModel.product_info.observe(this,
            Observer {
                hideProgress()
                productInfo = it
                arrayProductOptionList?.clear()
                arrayCheckItemList?.clear()
                if (it.addons.size > 0) {
                    arrayCheckItemList?.addAll(it.addons.toMutableList())
                    addAddOnsAdapter?.checkList(arrayAddOnsList)
                    addAddOnsAdapter?.notifyDataSetChanged()
                    addOnsConstraint.visibility = View.VISIBLE
                    if (it.product_option.size > 0) {
                        arrayProductOptionList?.addAll(it.product_option.toMutableList())
                    }
                    setAllProductInfo()
                    setPriceInfo()


                } else if (it.product_option.size > 0) {
                    arrayProductOptionList?.addAll(it.product_option.toMutableList())
                    addOnsConstraint.visibility = View.GONE

                    setAllProductInfo()
                    setPriceInfo()
                } else {
                    newActivity()
                }
            })
        addOnsViewModel.cartCustomise.observe(this,
            Observer {
                hideProgress()
                updateCustomiseItem()
            })
        addOnsViewModel.errorMessage.observe(this,
            Observer {
                hideProgress()
            })
    }

    private fun setPriceInfo() {

        if (arrayProductOptionList?.size!! > 1) {
            var maxPrice = 0f
            for ((i, v) in arrayProductOptionList?.withIndex()!!) {
                if (i == 0) {
                    sb.append(getString(R.string.rs))
                    sb.append(arrayProductOptionList?.get(0)?.price!!.toFloat())
                }
                if (i == arrayProductOptionList?.size!! - 1) {
                    if (arrayCheckItemList?.size!! > 0) {
                        for ((j, k) in arrayCheckItemList?.withIndex()!!) {

                            if (j == 0) {
                                maxPrice = arrayProductOptionList?.get(i)?.price!!.toFloat()
                            }
                            maxPrice =
                                maxPrice.toFloat() + arrayCheckItemList?.get(j)?.addon_price!!.toFloat()
                            if (j == arrayCheckItemList?.size!! - 1) {
                                sb.append("-")
                                sb.append(getString(R.string.rs))
                                sb.append(maxPrice.toString())
                            }
                        }

                    } else {
                        if (i == arrayProductOptionList?.size!! - 1) {
                            sb.append("-")
                            sb.append(getString(R.string.rs))
                            sb.append(arrayProductOptionList?.get(i)?.price!!.toFloat())
                        }
                    }
                }
            }
        } else if (arrayCheckItemList?.size!! > 0) {
            var maxPrice = 0f
            for ((j, k) in arrayCheckItemList?.withIndex()!!) {
                if (j == 0) {
                    sb.append(getString(R.string.rs))
                    sb.append(productInfo?.product_price!!.toFloat())
                    maxPrice = productInfo?.product_price!!.toFloat()
                }
                maxPrice = maxPrice.toFloat() + arrayCheckItemList?.get(j)?.addon_price!!.toFloat()
                if (j == arrayCheckItemList?.size!! - 1) {
                    sb.append("-")
                    sb.append(getString(R.string.rs))
                    sb.append(maxPrice.toString())
                }

            }
        } else {
            sb.append(getString(R.string.rs))
            sb.append(productInfo?.product_price!!.toFloat())
        }
        tvProductPrice.text = sb
    }

    private fun getAddProductAddOns(): AddProductAddOns {
        return AddProductAddOns(
            Utils.seceretKey,
            Utils.accessKey,
            this.productId!!
        )
    }

    private fun getProductAddOnsApi() {
        showProgress()
        addOnsViewModel.getProductAddOnsDetailsApi(getAddProductAddOns())
    }

    override fun onBackPressed() {
        if (booleanCustomise) {
            var intentNew = Intent(this, SelectQuantityActivity::class.java)
            intentNew.putExtra(KeysUtils.keyProductId, productId)
            intentNew.putExtra(KeysUtils.keyProductName, productInfo?.product_name)
            intentNew.putExtra(KeysUtils.keyStoreId, storeId)
            intentNew.putExtra(KeysUtils.keyProductCategory, categoryTitle)
            intentNew.putExtra(KeysUtils.keyRs, finalAmount.toString())
            intentNew.putExtra(KeysUtils.keyItem, selectQuantity)
            intentNew.putExtra(KeysUtils.keyAddOns, hasAddONS)
            intentNew.putExtra(KeysUtils.keyProductOptionPos, posOption)
            SharedPrefsUtils.setListPreference(
                applicationContext, KeysUtils.keyListProductOption,
                arrayProductCheckList?.toMutableList()!!
            )
            SharedPrefsUtils.setListPreference(
                applicationContext, KeysUtils.keyListAddOns,
                arrayAddOnsList?.toMutableList()!!
            )
            startActivityForResultWithDefaultAnimations(
                intentNew,
                ConstantUtils.REQUEST_CODE_ADDADDONS
            )

        } else {
            super.onBackPressed()
        }
    }
}
