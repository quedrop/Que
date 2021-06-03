package com.quedrop.customer.ui.supplier.store.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.SupplierStoreDetail
import com.quedrop.customer.network.ApiInterface
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import okhttp3.MultipartBody
import okhttp3.RequestBody
import timber.log.Timber


class EditStoreDetailViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val storeDetail: MutableLiveData<SupplierStoreDetail> = MutableLiveData()


    fun editStoreDetailList(
        store_id: RequestBody,
        store_name: RequestBody,
        store_address: RequestBody,
        latitude: RequestBody,
        longitude: RequestBody,
        store_schedule: RequestBody,
        slider_image: ArrayList<MultipartBody.Part>,
        delete_slider_image_ids: RequestBody,
        secret_key: RequestBody,
        access_key: RequestBody,
        user_id: RequestBody,
        store_logo: MultipartBody.Part?,
        service_category_id: RequestBody
    ) {

        apiService.editStoreDetailList(
            store_id,
            store_name,
            store_address,
            latitude,
            longitude,
            store_schedule,
            slider_image,
            delete_slider_image_ids,
            secret_key,
            access_key,
            user_id,
            store_logo,
            service_category_id
        ).observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ response ->
                if (response != null && response.status)
                {
                    storeDetail.value = response.data?.get("store_detail")
                    message.value = response.message
                    Log.e("Message", "==>Message " + response.message)
                }else{
                    errorMessage.value = response.message
                }
            }, {
                errorMessage.value = it.message
                Log.e("Error", "==>Message " + it.message)
                Timber.e(it.toString())
            }).autoDispose(compositeDisposable)
    }



    fun createStoreDetailList(
        store_name: RequestBody,
        store_address: RequestBody,
        latitude: RequestBody,
        longitude: RequestBody,
        store_schedule: RequestBody,
        slider_image: ArrayList<MultipartBody.Part>,
        secret_key: RequestBody,
        access_key: RequestBody,
        user_id: RequestBody,
        store_logo: MultipartBody.Part?,
        service_category_id: RequestBody
    ) {

        apiService.createStoreDetailList(
            store_name,
            store_address,
            latitude,
            longitude,
            store_schedule,
            slider_image,
            secret_key,
            access_key,
            user_id,
            store_logo,
            service_category_id
        ).observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ response ->
                if (response != null && response.status)
                {
                    storeDetail.value = response.data?.get("store_detail")
                    message.value = response.message
                    Log.e("Message", "==>Message " + response.message)
                }else{
                    errorMessage.value = response.message
                }
            }, {
                errorMessage.value = it.message
                Log.e("Error", "==>Message " + it.message)
                Timber.e(it.toString())
            }).autoDispose(compositeDisposable)
    }

}