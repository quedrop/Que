package com.quedrop.customer.ui.addons.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface

import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class AddOnsViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val cartCustomise: MutableLiveData<String> = MutableLiveData()
    val product_info: MutableLiveData<ProductAddOns> = MutableLiveData()

    fun getProductAddOnsDetailsApi(addOnsRequest: AddProductAddOns) {

        apiService.getAddOnsProduct(addOnsRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ productAddOnsResponse ->

                if (productAddOnsResponse.status) {
                    product_info.value = productAddOnsResponse.data.product_info
                }else{
                    errorMessage.value = productAddOnsResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getUpdateCustomiseApi(customiseCartRequest: CustomiseCart) {
        apiService.customiseCartItem(customiseCartRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ customiseCartResponse ->

                if (customiseCartResponse.status) {
                    cartCustomise.value = customiseCartResponse.message
                }else{
                    errorMessage.value = customiseCartResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }


}