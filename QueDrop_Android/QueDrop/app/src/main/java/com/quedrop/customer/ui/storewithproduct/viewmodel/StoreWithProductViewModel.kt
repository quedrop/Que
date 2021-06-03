package com.quedrop.customer.ui.storewithproduct.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface

import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class StoreWithProductViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val arrayListNearBy: MutableLiveData<List<NearByStores>> = MutableLiveData()
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


    fun getStoreFavouriteApi(setStoreFavRequest: SetFavourite) {
        apiService.setFavouriteStore(setStoreFavRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ favouriteStoreResponse ->
                if (favouriteStoreResponse.status) {
                    message.value = favouriteStoreResponse.message
                }else{
                    errorMessage.value = favouriteStoreResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

}