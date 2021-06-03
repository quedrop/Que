package com.quedrop.customer.ui.cart.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.network.ResponseWrapper

import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import java.lang.Exception

class CartViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val addUserCart: MutableLiveData<List<UserCart>> = MutableLiveData()
    val addUpdateUserCart: MutableLiveData<List<UserCart>> = MutableLiveData()
    val deleteProductFromUserCart: MutableLiveData<List<UserCart>> = MutableLiveData()
    val deleteUserCart: MutableLiveData<List<UserCart>> = MutableLiveData()
    val amountDetails: MutableLiveData<AmountDetails> = MutableLiveData()
    val amountDetailsCoupons: MutableLiveData<AmountDetails> = MutableLiveData()
    val messageUpdateCartQuantity: MutableLiveData<String> = MutableLiveData()
    val messageDeleteProductFromCart: MutableLiveData<String> = MutableLiveData()
    val messageDeleteCartIem: MutableLiveData<String> = MutableLiveData()
    val driverId: MutableLiveData<String> = MutableLiveData()
    val orderId: MutableLiveData<String> = MutableLiveData()
    val recurringOrderId: MutableLiveData<String> = MutableLiveData()
    val responsePlaceOrder: MutableLiveData<ResponseWrapper> = MutableLiveData()
    val arrayRecurringResponse: MutableLiveData<List<GetRecurringTypeResponse>> = MutableLiveData()
    val arrayCouponCodeList: MutableLiveData<List<GetCouponCodeResponse>> = MutableLiveData()
    val arrayApplyCouponCodeList: MutableLiveData<List<UserCart>> = MutableLiveData()
    val errorVal :MutableLiveData<String> = MutableLiveData()



    fun getUpdateProductCartQuantityApi(updateCartQuantityRequest: UpdateCartQuantity) {
        try {
            apiService.updateProductCartQuantity(updateCartQuantityRequest)
                .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
                .subscribe({ response ->

                    if (response.status) {
                        amountDetails.value = response.data.amount_details
                        messageUpdateCartQuantity.value = response.message
                        addUpdateUserCart.value = response.data.cart_items
                    } else {
                        errorMessage.value = response.message
                    }
                }, {
                    errorMessage.value = it.toString()
                    Log.e("Error", it.toString())
                }).autoDispose(compositeDisposable)
        }catch (e:Exception){}
    }

    fun getDeleteProductFromCartApi(deleteProductFromCartRequest: DeleteProductFromCartItem) {
        try {
        apiService.deleteProductFromCart(deleteProductFromCartRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ deleteProductFromCartResponse ->

                if (deleteProductFromCartResponse.status) {
                    amountDetails.value = deleteProductFromCartResponse.data.amount_details
                    messageDeleteProductFromCart.value = deleteProductFromCartResponse.message
                    deleteProductFromUserCart.value = deleteProductFromCartResponse.data.cart_items
                }else{
                    errorMessage.value = deleteProductFromCartResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
        }catch (e:Exception){}
    }

    fun getDeleteCartItemApi(deleteCartItemRequest: DeleteCartItem) {

        apiService.getDeleteCartItem(deleteCartItemRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ deleteCartItemResponse ->

                if (deleteCartItemResponse.status) {
                    amountDetails.value = deleteCartItemResponse.data.amount_details
                    messageDeleteCartIem.value = deleteCartItemResponse.message
                    deleteUserCart.value = deleteCartItemResponse.data.cart_items
                }else{
                    errorMessage.value = deleteCartItemResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getUserCartApi(userCartRequest: AddUserCart) {

        apiService.getUserCart(userCartRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ userCartResponse ->

                if (userCartResponse.status) {
                    amountDetails.value = userCartResponse.data.amount_details
                    addUserCart.value = userCartResponse.data.cart_items
                }else{
                    errorMessage.value = userCartResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getPlaceOrderApi(placeOrderRequest: PlaceOrder) {

        apiService.placeOrder(placeOrderRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ placeOrderResponse ->

                if (placeOrderResponse.status) {
                    responsePlaceOrder.value = placeOrderResponse.data
//                    driverId.value = placeOrderResponse.data.driver_ids
//                    orderId.value = placeOrderResponse.data.driver_ids
//                    recurringOrderId.value = placeOrderResponse.data.recurring_order_id
//                    responsePlaceOrder.value =
                }else{
                    errorMessage.value = placeOrderResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getRecurringTypesApi(getRecurringRequest:  GetRecurringRequest) {

        apiService.getRecurringTypes(getRecurringRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ getRecurringTypeResponse ->

                if (getRecurringTypeResponse.status) {
                    arrayRecurringResponse.value = getRecurringTypeResponse.data.recurring_types

                }else{
                    errorMessage.value = getRecurringTypeResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getCouponCodeApi(getCouponCodeRequest:  GetCouponRequest) {

        apiService.getAllCoupuns(getCouponCodeRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ getCouponCodeResponse ->

                if (getCouponCodeResponse.status) {
                    arrayCouponCodeList.value = getCouponCodeResponse.data.coupons

                }else{
                    errorMessage.value = getCouponCodeResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun applyCouponCodeApi(applyCouponCodeRequest: ApplyCouponCodeRequest) {

        apiService.applyCouponCode(applyCouponCodeRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ applyCouponCodeResponse ->

                if (applyCouponCodeResponse.status) {
                    amountDetailsCoupons.value = applyCouponCodeResponse.data.amount_details
                    arrayApplyCouponCodeList.value = applyCouponCodeResponse.data.cart_items
                }else{
                    errorVal.value = applyCouponCodeResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

}