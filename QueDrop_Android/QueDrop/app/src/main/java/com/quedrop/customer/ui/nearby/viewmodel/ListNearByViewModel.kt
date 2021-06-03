package com.quedrop.customer.ui.nearby.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface

import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class ListNearByViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val arrayListNearBy: MutableLiveData<List<NearByStores>> = MutableLiveData()

    fun getNearByStoreApi(addNearByStoresRequest: AddNearByStores) {

        apiService.nearByStore(addNearByStoresRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ nearByStoreResponse ->

                if (nearByStoreResponse.status) {
                    arrayListNearBy.value = nearByStoreResponse.data.stores
                }else{
                    errorMessage.value = nearByStoreResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }


    fun getSearchStoreApi(searchStoreByName: SearchStoreByName) {
        apiService.searchStoreByName(searchStoreByName)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ searchStoreResponse ->

                if (searchStoreResponse.status) {
                    arrayListNearBy.value = searchStoreResponse.data.stores
                }else{
                    errorMessage.value = searchStoreResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

}