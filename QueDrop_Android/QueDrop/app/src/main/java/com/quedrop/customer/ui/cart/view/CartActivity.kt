package com.quedrop.customer.ui.cart.view

import android.app.Activity
import android.app.AlertDialog
import android.app.Dialog
import android.content.*
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.View
import android.widget.TextView
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.recyclerview.widget.LinearLayoutManager
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.*
import com.quedrop.customer.ui.cart.viewmodel.CartViewModel
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import kotlinx.android.synthetic.main.activity_cart.*
import androidx.recyclerview.widget.SimpleItemAnimator
import com.quedrop.customer.network.ResponseWrapper
import com.quedrop.customer.socket.SocketConstants
import com.quedrop.customer.ui.addons.view.AddOnsActivity
import com.quedrop.customer.ui.cart.view.adapter.CartAdapter
import com.quedrop.customer.ui.enterphonenumber.EnterPhoneNumberActivity
import com.quedrop.customer.ui.storewithoutproduct.view.StoreWithoutProductActivity
import com.quedrop.customer.ui.storewithproduct.view.StoreDetailsActivity
import com.quedrop.customer.utils.*
import com.quedrop.customer.utils.ConstantUtils.Companion.EXPRESS_DELIVERY
import com.quedrop.customer.utils.ConstantUtils.Companion.KEY_DELIVERY_TYPE
import com.quedrop.customer.utils.ConstantUtils.Companion.STANDARD_DELIVERY
import io.socket.client.Ack
import kotlinx.android.synthetic.main.layout_extra_item_cart_recycle.*
import org.json.JSONException
import org.json.JSONObject
import java.lang.Exception


class CartActivity : BaseActivity() {

    var arrayCartList: MutableList<UserCart>? = null
    var cartAdapter: CartAdapter? = null
    var startDateString: String = ""
    var startTimeString: String = ""
    var endDateString: String = ""
    var endTimeString: String = ""
    lateinit var cartViewModel: CartViewModel
    var cart_id_delete: Int = 0
    var product_id: Int = 0
    var itemsCount: Int = 0
    lateinit var amoutdetails: AmountDetails
    var couponCode: String = "0"
    var isRecurringOrder: String = "0"
    var isRecurringTypeId: Int = 0
    var isRecurringOn: String = ""
    var isRecurringTime: String = ""
    var label: String = ""
    var repeatUntilDate: String = ""
    var isCheckedFlag: Boolean = false
    var totalItemPriceMain: String = ""
    var saveRs: String = ""
    var driverId: String = ""
    var server_time: String? = null
    var timeRemainingMain: Long = 0
    var isDriverAccepted: Boolean = false
    var isFinish: Boolean = false
    var flagStoreOpen: Boolean = true
    var deliverOption: String = STANDARD_DELIVERY
    var handler = Handler()
    lateinit var mRunnable: Runnable

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_cart)

        isCheckedFlag = false
        bottomTextConstraint.alpha = 0.4f


        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyGuestId, 0)
        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyUserId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyAccessKey)!!
        Utils.selectAddressTitle =
            SharedPrefsUtils.getStringPreference(
                applicationContext,
                KeysUtils.KeySelectAddressName
            )!!
        Utils.selectAddress =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeySelectAddress)!!
        Utils.selectAddressType =
            SharedPrefsUtils.getStringPreference(
                applicationContext,
                KeysUtils.KeySelectAddressType
            )!!
        Utils.keyLatitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLatitude)!!
        Utils.keyLongitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLongitude)!!
        cartViewModel = CartViewModel(appService)


        amoutdetails = AmountDetails(
            "", "", "", "", "", "",
            "", "", "", "", ""
        )
        LocalBroadcastManager.getInstance(applicationContext).registerReceiver(
            eventUpdate,
            IntentFilter(BroadCastConstant.BROADCAST_EVENT_CHANGE)
        )


        initMethod()
        observeViewModel()
        onClickMethod()

    }

    private fun initMethod() {


        tvAddressCart.text = Utils.selectAddress
        arrayCartList = mutableListOf()

        tvTitleAddressCart.text =
            resources.getString(R.string.deliverNow) + " " + Utils.selectAddressTitle
//
        (rvCartItems.itemAnimator as SimpleItemAnimator).supportsChangeAnimations = false

        rvCartItems.layoutManager = LinearLayoutManager(
            applicationContext,
            LinearLayoutManager.VERTICAL,
            false
        )


        cartAdapter = CartAdapter(
            applicationContext,
            arrayCartList

        ).apply {
            checkStoreOpenInvoke = {
                flagStoreOpen = it
            }
            showAlertChragesInvoke = { title: String, message: String ->
                showAlertCharges(title, message)
            }
            updateQuantityClickInvoke1 =
                { sumQuantity: Int, cart_product_id: Int, position: Int ->
                    updateQuantityClick(sumQuantity, cart_product_id, position)
                }
            minusDeleteFromProductClickInvoke1 =
                { cart_id: Int, cart_product_id: Int, position: Int ->
                    minusDeleteFromProductCartClick(cart_id, cart_product_id, position)
                }
            setRecurringInvoke = {
                setRecurringTime()
            }
            setCouponCartInvoke = { view: View, totalItemPrice: String, couponCodeMa: String ->

                totalItemPriceMain = totalItemPrice
                couponCode = couponCodeMa
                couponCart()
            }
            cartRemoveClickInvoke = { cart_id: Int, position: Int ->
                cartRemoveClick(cart_id, position)
            }
            storeProductIntent = {
                getIntentStoreProduct(it)
            }

            isCheckInvoke = { isCheckFlag: Boolean ->
                checkBoxClick(isCheckFlag)

            }

            storeWithoutProductIntent = {
                getIntentStoreWithoutProduct(it)
            }

            viewAllNearDriversInvoke = {
                val intent = Intent(contextCart, ViewAllDriverActivity::class.java)
                intent.putExtra(KEY_DELIVERY_TYPE, deliverOption)

                startActivityWithDefaultAnimations(intent)
            }
            standardRadioInvoke = {
                deliverOption = STANDARD_DELIVERY
                getUserCartApi()
            }

            expressRadioInvoke = {
                deliverOption = EXPRESS_DELIVERY
                getUserCartApi()
            }

            customiseCartInvoke =
                { cartProductId: Int, productId: Int, optionId: Int, storeId: Int, hasAddOns: String, arrayAddOnsList: MutableList<AddOns> ->
                    addNewActivity(
                        cartProductId,
                        productId,
                        optionId,
                        storeId,
                        hasAddOns,
                        arrayAddOnsList
                    )
                }


        }

        rvCartItems!!.adapter = cartAdapter

        when (Utils.selectAddressType) {
            getString(R.string.work) -> {

                ivHomeDoneCart.setImageResource(com.quedrop.customer.R.drawable.office_done)

            }
            getString(R.string.hotel) -> {
                ivHomeDoneCart.setImageResource(R.drawable.sun_umbrella_done)
            }
            getString(R.string.other) -> {
                ivHomeDoneCart.setImageResource(R.drawable.placeholder_done)
            }
            else -> ivHomeDoneCart.setImageResource(R.drawable.home_done)
        }

        getUserCartApi()
    }

    private fun onClickMethod() {

        ivBackCart.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        ivHomeCart.throttleClicks().subscribe {
            var intent = Intent(this, CustomerMainActivity::class.java)
            intent.flags =
                Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            startActivityWithDefaultAnimations(intent)
            finish()
        }.autoDispose(compositeDisposable)

        btnMenuList.throttleClicks().subscribe {
            var intent = Intent(this, CustomerMainActivity::class.java)

            intent.flags =
                Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            startActivityWithDefaultAnimations(intent)
            finish()
        }.autoDispose(compositeDisposable)

        tvPlaceOrder.throttleClicks().subscribe {

            if (isCheckedFlag) {
                bottomTextConstraint.alpha = 1.0f

                val userData = (SharedPrefsUtils.getModelPreferences(
                    applicationContext,
                    KeysUtils.keyUser,
                    User::class.java
                )) as User?

                Utils.guestId =
                    SharedPrefsUtils.getIntegerPreference(
                        applicationContext,
                        KeysUtils.keyGuestId,
                        0
                    )
                Utils.userId =
                    SharedPrefsUtils.getIntegerPreference(
                        applicationContext,
                        KeysUtils.keyUserId,
                        0
                    )
                if (userData != null) {
                    if (userData.is_phone_verified == "0") {
                        navigateToPhoneNumberActivity()
                    } else {
                        getPlaceOrderApi()
                    }
                } else {
                    navigateToPhoneNumberActivity()
                }
            } else {
                Toast.makeText(
                    applicationContext,
                    resources.getString(R.string.checkNotes),
                    Toast.LENGTH_SHORT
                ).show()
            }

        }.autoDispose(compositeDisposable)

    }

    private fun navigateToPhoneNumberActivity() {
//        Utils.isPlaceOrderBoolean=true
        var intent = Intent(this, EnterPhoneNumberActivity::class.java)
        startActivityForResultWithDefaultAnimations(
            intent,
            ConstantUtils.LOGIN_ENTER_PHONE_REQUEST_CODE
        )
    }

//    private fun checkLogin() {
//        Utils.isPlaceOrderBoolean=true
//        SharedPrefsUtils.setBooleanPreference(applicationContext,KeysUtils.keyCheckVerify,Utils.isPlaceOrderBoolean)
//        var intent = Intent(applicationContext, LoginActivity::class.java)
//        startActivityForResultWithDefaultAnimations(
//            intent,
//            ConstantUtils.LOGIN_CART_REQUEST_CODE
//        )
//    }

    private fun checkLoginCoupon() {
        var intent = Intent(applicationContext, EnterPhoneNumberActivity::class.java)
        startActivityForResultWithDefaultAnimations(
            intent,
            ConstantUtils.REQUEST_LOGIN_COUPON
        )
    }


    private fun setAllDetails() {
        cartAdapter?.notifyDataSetChanged()

    }

    private fun checkBoxClick(isCheckFlag: Boolean) {
        isCheckedFlag = isCheckFlag
        if (isCheckedFlag) {
            bottomTextConstraint.alpha = 1.0f
        } else {
            bottomTextConstraint.alpha = 0.4f
        }
    }

    private fun setRecurringTime() {
        startActivityForResultWithDefaultAnimations(
            Intent(applicationContext, FutureOrderActivity::class.java),
            ConstantUtils.REQUEST_RECURRING
        )
    }

    private fun couponCart() {

        var intent = Intent(applicationContext, CouponActivity::class.java)
        intent.putExtra(KeysUtils.keyTotalItemPriceCart, totalItemPriceMain)
        intent.putExtra(KeysUtils.keyCouponCode, couponCode)
        startActivityForResultWithDefaultAnimations(intent, ConstantUtils.REQUEST_COUPON_CART)

    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == ConstantUtils.REQUEST_RECURRING && resultCode == Activity.RESULT_OK) {
            if (data != null) {

                isRecurringOrder = "1"
                isRecurringTypeId = data.getIntExtra(KeysUtils.keyRecurringTypeId, 0)
                isRecurringOn = data.getStringExtra(KeysUtils.keyRecurringOn)
                isRecurringTime = data.getStringExtra(KeysUtils.keyRecurringTime)
                label = data.getStringExtra(KeysUtils.keyLabel)
                repeatUntilDate = data.getStringExtra(KeysUtils.keyRepeatUntilDate)
                cartAdapter?.setFlag()
//                startTimeString = data.getStringExtra(KeysUtils.keyStartTime)
//                endDateString = data.getStringExtra(KeysUtils.keyEndDate)
//                endTimeString = data.getStringExtra(KeysUtils.keyEndTime)
            }
        } else if (requestCode == ConstantUtils.REQUEST_CART_CUSTOMISE && resultCode == Activity.RESULT_OK) {
            getUserCartApi()
        }
//        else if (requestCode == ConstantUtils.LOGIN_CART_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
//            if (data != null) {
//                Utils.userId =
//                    SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyUserId, 0)!!
//
//                getPlaceOrderApi()
//            }
//        }
        else if (requestCode == ConstantUtils.LOGIN_ENTER_PHONE_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            if (data != null) {

                Utils.userId =
                    SharedPrefsUtils.getIntegerPreference(
                        applicationContext,
                        KeysUtils.keyUserId,
                        0
                    )
                Utils.guestId =
                    SharedPrefsUtils.getIntegerPreference(
                        applicationContext,
                        KeysUtils.keyGuestId,
                        0
                    )

                getPlaceOrderApi()
            }
        } else if (requestCode == ConstantUtils.REQUEST_COUPON_CART && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                saveRs = data.getStringExtra(KeysUtils.keySaveMaxRs)
                couponCode = data.getStringExtra(KeysUtils.keyCouponCode)
                arrayCartList?.clear()
                arrayCartList?.addAll(
                    SharedPrefsUtils.getObjectList(
                        applicationContext,
                        KeysUtils.keyCouponCodeCartArray,
                        UserCart::class.java
                    )
                )
                amoutdetails = AmountDetails(
                    "", "", "", "", "", "",
                    "", "", "", "", ""
                )
                amoutdetails = (SharedPrefsUtils.getModelPreferences(
                    applicationContext,
                    KeysUtils.keySetAmount, AmountDetails::class.java
                )) as AmountDetails
                cartAdapter?.setAllDetails(amoutdetails)
                Utils.convertDeliveryTime(
                    applicationContext,
                    amoutdetails.total_delivery_time,
                    tvTimeCart
                )

                addArrayCartList()
                cartAdapter?.couponSetData(saveRs, couponCode)
            }
        } else if (requestCode == ConstantUtils.REQUEST_LOGIN_COUPON && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                Utils.userId =
                    SharedPrefsUtils.getIntegerPreference(
                        applicationContext,
                        KeysUtils.keyUserId,
                        0
                    )

                couponCart()
//                getUserCartApi()
            }
        }
    }

    private fun setAmountDetails(amountDetails: AmountDetails) {
        if (itemsCount.toString() <= "1") {
            tvRsTotal.text =
                itemsCount.toString() + " " + resources.getString(R.string.itemTotalRs) + " | " + resources.getString(
                    R.string.rs
                ) + amountDetails.grand_total
        } else {
            tvRsTotal.text =
                itemsCount.toString() + " " + resources.getString(R.string.itemsTotalRs) + " | " + resources.getString(
                    R.string.rs
                ) + amountDetails.grand_total
        }

    }

    private fun observeViewModel() {

        cartViewModel.responsePlaceOrder.observe(this, androidx.lifecycle.Observer {
            hideProgress()
            driverId = it.driver_ids
            server_time = it.server_time
            isDriverAccepted = false
            Log.e("driver id", "---" + it.driver_ids)
            if (it.driver_ids == "") {
                isFinish = false
                dialogAlaram()
            } else {
                dialogAlaram()
                sendSocketEvent(it)
            }


//            Toast.makeText(applicationContext, it.driver_ids, Toast.LENGTH_SHORT).show()
        })
        cartViewModel.addUpdateUserCart.observe(this, androidx.lifecycle.Observer {
            arrayCartList?.clear()
            arrayCartList?.addAll(it.toMutableList())
            itemsCount = 0
            for ((i, v) in arrayCartList?.withIndex()!!) {
                for ((j, k) in v.products.withIndex()) {
                    itemsCount = itemsCount + k.quantity.toInt()
                }

            }

            setAmountDetails(amoutdetails)
            addArrayCartList()
        })

        cartViewModel.deleteProductFromUserCart.observe(this, Observer {

            arrayCartList?.clear()
            arrayCartList?.addAll(it.toMutableList())
            itemsCount = 0
            for ((i, v) in arrayCartList?.withIndex()!!) {
                for ((j, k) in v.products.withIndex()) {
                    itemsCount = itemsCount + k.quantity.toInt()
                }

            }
            setAmountDetails(amoutdetails)
            addArrayCartListDeleteItem()
        })

        cartViewModel.deleteUserCart.observe(this, Observer {
            arrayCartList?.clear()
            arrayCartList?.addAll(it.toMutableList())

            itemsCount = 0
            for ((i, v) in arrayCartList?.withIndex()!!) {
                for ((j, k) in v.products.withIndex()) {
                    itemsCount = itemsCount + k.quantity.toInt()
                }

            }
            setAmountDetails(amoutdetails)
            addArrayCartListDeleteItem()
        })

        cartViewModel.addUserCart.observe(this, Observer {

            arrayCartList?.clear()
            arrayCartList?.addAll(it.toMutableList())

            itemsCount = 0

            for ((i, v) in arrayCartList?.withIndex()!!) {
                for ((j, k) in v.products.withIndex()) {
                    itemsCount = itemsCount + k.quantity.toInt()
                }

            }
            setAmountDetails(amoutdetails)
            addArrayCartList()
        })

        cartViewModel.amountDetails.observe(this, Observer {

            cartAdapter?.setAllDetails(it)
            amoutdetails = it

            if (it.total_delivery_time != null) {
                Utils.convertDeliveryTime(applicationContext, it.total_delivery_time, tvTimeCart)
            }

        })

        cartViewModel.errorMessage.observe(this, androidx.lifecycle.Observer {
            hideProgress()
            arrayCartList?.clear()
            setAllDetails()
            thirdConstraintCart.visibility = View.GONE
            bottomTextConstraint.visibility = View.GONE
            if (arrayCartList?.isEmpty()!!) {
                ivCartEmpty.visibility = View.VISIBLE
                tvCartEmpty.visibility = View.VISIBLE
                tvCartEmptyLooks.visibility = View.VISIBLE
                btnMenuList.visibility = View.VISIBLE
            }
        })
    }

    private fun sendSocketEvent(data: ResponseWrapper?) {

        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {

                jsonObject.put(
                    SocketConstants.KeyUserId, (SharedPrefsUtils.getModelPreferences(
                        applicationContext, KeysUtils.keyUser,
                        User::class.java
                    ) as User).user_id.toString()
                )

                Log.e("driver-id", data?.driver_ids.toString())
                Log.e("order-id", "--" + data?.order_id?.toInt())
                Log.e("recurring-id", "---" + data?.recurring_order_id?.toInt())

                jsonObject.put(SocketConstants.KeyOrderId, data?.order_id?.toInt())
                jsonObject.put(SocketConstants.KeyDriverId, data?.driver_ids.toString())


                SocketConstants.socketIOClient!!.emit(SocketConstants.SocketPlaceOrder,
                    jsonObject, Ack {
                        try {
                            val messageJson = JSONObject(it[0].toString())
                            val responseStatus = messageJson.getString("status").toInt()
                            val message = messageJson.getString("message")

//                            dialogAlaram()


                            Log.e("SocketStatus", responseStatus.toString())
                            Log.e("SocketMessage", message.toString())

                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }

                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        } else {
            Log.e("Socket", "isDisconnecting==========================")
        }

    }

    private fun navigateToOrderScreenActivity() {


        var intent = Intent(this, CustomerMainActivity::class.java)
        intent.flags =
            Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        intent.putExtra(KeysUtils.keyCustomer, resources.getString(R.string.orderScreen))

        SharedPrefsUtils.setStringPreference(
            applicationContext,
            KeysUtils.keyServerTime,
            server_time!!
        )
        startActivity(intent)
        finish()

    }


    private fun cartRemoveClick(cartId: Int, posDeleteCartItem: Int) {
        getDeleteCartItemApi(cartId, posDeleteCartItem)
    }

    private fun minusDeleteFromProductCartClick(cartId: Int, cart_product_id: Int, pos: Int) {
        //TODO add delete popup
        deleteAlertDialog(cartId, cart_product_id, pos)
    }

    private fun updateQuantityClick(quantity: Int, cart_product_id: Int, pos: Int) {

        updateQuantityApi(quantity, cart_product_id)
    }

    private fun getIntentStoreProduct(pos: Int) {
        val intentStore = Intent(
            applicationContext,
            StoreDetailsActivity::class.java
        )
        intentStore.putExtra(KeysUtils.keyStoreId, arrayCartList?.get(pos)?.store_details?.store_id)
        startActivityWithDefaultAnimations(intentStore)
    }

    private fun getIntentStoreWithoutProduct(pos: Int) {
        val intentStore = Intent(
            applicationContext,
            StoreWithoutProductActivity::class.java
        )
        intentStore.putExtra(KeysUtils.keyStoreId, arrayCartList?.get(pos)?.store_details?.store_id)
        startActivityWithDefaultAnimations(intentStore)
    }

    private fun updateQuantityApi(quantity: Int, cart_product_id: Int) {

        showProgress()
        val updateQuantity = UpdateCartQuantity(
            Utils.seceretKey,
            Utils.accessKey,
            quantity.toString(),
            Utils.userId,
            cart_product_id,
            Utils.keyLatitude,
            Utils.keyLongitude,
            couponCode,
            Utils.guestId,
            deliverOption
        )

        cartViewModel.getUpdateProductCartQuantityApi(updateQuantity)

    }


    private fun deleteCartFromProductApi(cartId: Int, cart_product_id: Int, pos: Int) {
        product_id = cart_product_id
        showProgress()
        val deleteProductFromCartItem = DeleteProductFromCartItem(
            Utils.seceretKey,
            Utils.accessKey,
            cartId,
            Utils.userId,
            cart_product_id,
            Utils.keyLatitude,
            Utils.keyLongitude,
            couponCode,
            Utils.guestId,
            deliverOption
        )

        cartViewModel.getDeleteProductFromCartApi(deleteProductFromCartItem)

    }

    private fun getDeleteCartItemApi(cartId: Int, posDeleteCartItem: Int) {
        cart_id_delete = cartId
        showProgress()
        val deleteCartItem = DeleteCartItem(
            Utils.seceretKey,
            Utils.accessKey,
            cartId,
            Utils.userId,
            Utils.keyLatitude,
            Utils.keyLongitude,
            couponCode,
            Utils.guestId,
            deliverOption
        )

        cartViewModel.getDeleteCartItemApi(deleteCartItem)
    }

    private fun getUserCartApi() {
        showProgress()
        val addUserCart = AddUserCart(
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId,
            Utils.keyLatitude,
            Utils.keyLongitude,
            couponCode,
            Utils.guestId,
            deliverOption
        )
        cartViewModel.getUserCartApi(addUserCart)


    }

    private fun addArrayCartList() {
        if (arrayCartList?.size!!.toInt() > 0) {
            val storeOffer = StoreOffer(
                0, "", "", "",
                "", "", "", 0, "",
                "", ""
            )
            val store_details =
                StoreDetails(
                    0, "", "", "",
                    "", "", "", "", 0,
                    storeOffer, arrayListOf(), ""
                )
            val arrayProductsList = mutableListOf<Product>()
            val addUserCart = UserCart(0, store_details, arrayProductsList)
            arrayCartList?.add(arrayCartList!!.size, addUserCart)

            thirdConstraintCart.visibility = View.VISIBLE
            bottomTextConstraint.visibility = View.VISIBLE
            ivCartEmpty.visibility = View.GONE
            tvCartEmpty.visibility = View.GONE
            tvCartEmptyLooks.visibility = View.GONE
            btnMenuList.visibility = View.GONE
        } else {
            thirdConstraintCart.visibility = View.GONE
            bottomTextConstraint.visibility = View.GONE
            ivCartEmpty.visibility = View.VISIBLE
            tvCartEmpty.visibility = View.VISIBLE
            tvCartEmptyLooks.visibility = View.VISIBLE
            btnMenuList.visibility = View.VISIBLE
        }

        hideProgress()


        setAllDetails()
    }

    private fun addArrayCartListDeleteItem() {
        if (arrayCartList?.size!!.toInt() > 0) {
            val storeOffer = StoreOffer(
                0, "", "", "",
                "", "", "",
                0, "", "",
                ""
            )
            val store_details =
                StoreDetails(
                    0, "", "", "",
                    "", "", "", "", 0,
                    storeOffer, arrayListOf(), ""
                )
            val arrayProductsList = mutableListOf<Product>()
            val addUserCart = UserCart(0, store_details, arrayProductsList)
            arrayCartList?.add(arrayCartList!!.size, addUserCart)

            thirdConstraintCart.visibility = View.VISIBLE
            bottomTextConstraint.visibility = View.VISIBLE
            ivCartEmpty.visibility = View.GONE
            tvCartEmpty.visibility = View.GONE
            tvCartEmptyLooks.visibility = View.GONE
            btnMenuList.visibility = View.GONE
        } else {
            thirdConstraintCart.visibility = View.GONE
            bottomTextConstraint.visibility = View.GONE
            onBackPressed()
        }

        hideProgress()
        setAllDetails()
    }

    private fun getPlaceOrderRequest(): PlaceOrder {
        return PlaceOrder(
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId,
            Utils.keyLatitude,
            Utils.keyLongitude,
            Utils.getCompleteAddressString(
                this,
                Utils.keyLatitude.toDouble(),
                Utils.keyLongitude.toDouble()
            ),
            editNoteRv.text.toString(),
            1,
            couponCode,
            Utils.getTimeZone(),
            isRecurringOrder,
            isRecurringTypeId,
            isRecurringOn,
            isRecurringTime,
            label,
            repeatUntilDate,
            deliverOption
        )
    }

    private fun getPlaceOrderApi() {

        if (flagStoreOpen) {
            showProgress()
            cartViewModel.getPlaceOrderApi(getPlaceOrderRequest())
        } else {
            Toast.makeText(applicationContext, getString(R.string.storeClosed), Toast.LENGTH_SHORT)
                .show()
        }
    }

    private fun addNewActivity(
        cart_product_id: Int,
        productId: Int,
        optionId: Int,
        storeId: Int,
        hasAddOns: String,
        arrayAddOnsList: MutableList<AddOns>
    ) {
        Utils.flagCartCustomise = true

        SharedPrefsUtils.removeSharedPreference(applicationContext, KeysUtils.keyListAddOns)
        SharedPrefsUtils.removeSharedPreference(applicationContext, KeysUtils.keyListProductOption)
        val intent = Intent(this, AddOnsActivity::class.java)
        SharedPrefsUtils.setBooleanPreference(
            applicationContext,
            KeysUtils.keyFlagCart,
            Utils.flagCartCustomise
        )
        intent.putExtra(KeysUtils.keyCartProductId, cart_product_id)
        intent.putExtra(KeysUtils.keyProductId, productId)
        intent.putExtra(KeysUtils.keyStoreId, storeId)
        intent.putExtra(KeysUtils.keyAddOns, hasAddOns)
        intent.putExtra(KeysUtils.keyProductOptionId, optionId)
        SharedPrefsUtils.setListPreference(
            applicationContext, KeysUtils.keyListAddOns,
            arrayAddOnsList.toMutableList()
        )
        intent.putExtra(KeysUtils.keyProductPrice, "0")
        intent.putExtra(KeysUtils.keyDeliveryOption, deliverOption)

        startActivityForResultWithDefaultAnimations(intent, ConstantUtils.REQUEST_CART_CUSTOMISE)

    }

    override fun onBackPressed() {
        val fromIntent = intent.getStringExtra(KeysUtils.keyUserProductId)
        if (fromIntent == resources.getString(R.string.titleCart)) {
            val intent = Intent()
            setResult(Activity.RESULT_OK, intent)

        } else {
            val intent = Intent()
            setResult(Activity.RESULT_OK, intent)
        }
        finish()

    }


    private fun dialogAlaram() {

        try {

            val dialog = Dialog(this)
            dialog.setContentView(R.layout.layout_dialog_driver)
            dialog.setCancelable(false)
            dialog.setCanceledOnTouchOutside(false)
            dialog.show()

            val textOk = dialog.findViewById<TextView>(R.id.dialog_ok)
            val tvTimer = dialog.findViewById<TextView>(R.id.tvTimer)


            doFirstWork(tvTimer)

            textOk.setOnClickListener {

                textOk.setTextColor(ContextCompat.getColor(this, R.color.colorBlue))

                navigateToOrderScreenActivity()
                if (dialog.isShowing) {
                    dialog.dismiss()
                }
            }


        } catch (e: Exception) {
            e.printStackTrace()
        }


    }

    private fun doFirstWork(textView: TextView) {

        isFinish = true

        var timeRemaining: Long = 3 * 60000

        mRunnable = object : Runnable {
            override fun run() {
                textView.text = Utils.msToString(timeRemaining)

                timeRemaining -= 1000

                timeRemainingMain = timeRemaining

                if (timeRemaining >= 0) {
                    handler.postDelayed(this, 1000)
                } else {

                    navigateToOrderScreenActivity()
                    handler.removeCallbacks(this)
                }
            }
        }

        handler.post(mRunnable)


    }

    // get Socket event
    private val eventUpdate = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val events = intent.getStringExtra(BroadCastConstant.BROADCAST_KEY_EVENT)!!
            try {
                val jsonObject =
                    JSONObject(intent.getStringExtra(BroadCastConstant.BROADCAST_KEY_OBJ)!!)
                Log.e("start", "Start")
                parseResponse(events, jsonObject)
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }

    private fun parseResponse(event: String, argument: JSONObject) {
        when (event) {
            SocketConstants.SocketOrderAccepted -> {
                val orderId = argument.getString("order_id")
                val driverId = argument.getString("driver_id")
                val status = argument.getString("status")
//                val orderStatus = argument.getString("order_status")

                //  Toast.makeText(applicationContext, "Accepted" + driverId, Toast.LENGTH_SHORT).show()
                isDriverAccepted = true
                navigateToOrderScreenActivity()
                Log.e("status", status)
                Log.e("driverId", driverId)

            }
        }
    }

    private fun showAlertCharges(title: String, message: String) {
        val alertDialogBuilder = AlertDialog.Builder(this)

        alertDialogBuilder.setTitle(title)

        alertDialogBuilder.setMessage(message)

        alertDialogBuilder.setPositiveButton(
            resources.getString(R.string.ok),
            DialogInterface.OnClickListener { dialog, which ->
                dialog.dismiss()
            })

        alertDialogBuilder.show()

    }


    private fun deleteAlertDialog(cartId: Int, cartProductId: Int, pos: Int) {

        val dialog = Dialog(this)
        dialog.setContentView(R.layout.layout_deletedialog)

        val textOk = dialog.findViewById<TextView>(R.id.dialog_ok)
        val textCancel = dialog.findViewById<TextView>(R.id.dialog_cancel)
        val textTitleDelete = dialog.findViewById<TextView>(R.id.textTitleDelete)

        textTitleDelete.text = "Are you sure you want to delete?"

        textOk.setOnClickListener {

            textOk.setTextColor(ContextCompat.getColor(this, R.color.colorBlue))
            textCancel.setTextColor(ContextCompat.getColor(this, R.color.colorGrey))
            deleteCartFromProductApi(cartId, cartProductId, pos)

            dialog.dismiss()

            dialog.dismiss()
        }

        textCancel.setOnClickListener {
            textOk.setTextColor(ContextCompat.getColor(this, R.color.colorGrey))
            textCancel.setTextColor(ContextCompat.getColor(this, R.color.colorBlue))
            dialog.dismiss()
        }
        dialog.show()
    }


    override fun onDestroy() {
        super.onDestroy()

        if (isFinish) {
            handler.removeCallbacks(mRunnable)
        }
        LocalBroadcastManager.getInstance(applicationContext).unregisterReceiver(eventUpdate)
    }


}
