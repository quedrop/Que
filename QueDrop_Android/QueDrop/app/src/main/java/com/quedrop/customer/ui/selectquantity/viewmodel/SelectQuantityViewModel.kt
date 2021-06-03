package com.quedrop.customer.ui.selectquantity.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface

import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class SelectQuantityViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val store_detail: MutableLiveData<GetStoreDetails> = MutableLiveData()

    fun getStoreWithProductDetailsApi(storeWithProductDetailsRequest: AddStoreDetails) {

        apiService.getStoreDetails(storeWithProductDetailsRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ storeDetailsResponse ->

                if (storeDetailsResponse.status) {
                    store_detail.value = storeDetailsResponse.data.store_detail
                }else{
                    errorMessage.value = storeDetailsResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }


    fun getAddItemCartApi(addItemCartRequest: AddItemCart) {
        apiService.getAddItemCart(addItemCartRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ searchStoreResponse ->

                if (searchStoreResponse.status) {
                    message.value = searchStoreResponse.message
                }else{
                    errorMessage.value = searchStoreResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

}