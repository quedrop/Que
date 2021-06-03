package com.quedrop.customer.ui.storeadd.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface

import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import okhttp3.MultipartBody
import okhttp3.RequestBody

class AddStoreViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val messageAddProduct: MutableLiveData<String> = MutableLiveData()
    val user_store: MutableLiveData<AddUserStore> = MutableLiveData()

    fun addStoreApi(
        userId: RequestBody,
        guestId:RequestBody,
        storeName: RequestBody,
        storeAddress: RequestBody,
        storeDescription: RequestBody,
        latitude: RequestBody,
        longitude: RequestBody,
        secretKey: RequestBody,
        accessKey: RequestBody,
        imageStoreLogo : MultipartBody.Part
    ) {
        apiService.addStore(
            userId,
            guestId,
            storeName,
            storeAddress,
            storeDescription,
            latitude,
            longitude,
            secretKey,
            accessKey,
            imageStoreLogo )
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ addUserStore ->

                if (addUserStore.status) {
                    user_store.value = addUserStore.data.user_store
                } else {
                    errorMessage.value = addUserStore.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

}