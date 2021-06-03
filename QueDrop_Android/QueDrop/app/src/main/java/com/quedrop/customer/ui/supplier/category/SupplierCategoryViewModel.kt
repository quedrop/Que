package com.quedrop.customer.ui.supplier.category

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.FoodCategory
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.network.GenieResponse
import com.google.gson.JsonObject
import com.quedrop.customer.model.FreshProduce
import com.quedrop.customer.model.FreshProduceCategory
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import okhttp3.MultipartBody
import okhttp3.RequestBody
import timber.log.Timber

class SupplierCategoryViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val categories: MutableLiveData<MutableList<FoodCategory>> = MutableLiveData()
    val freshProduceCategories: MutableLiveData<MutableList<FoodCategory>> = MutableLiveData()
    val freshProduceList: MutableLiveData<MutableList<FreshProduce>> = MutableLiveData()

    fun getSupplierCategories(jsonObject: JsonObject) {
        apiService.getSupplierCategories(jsonObject)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ response ->
                if (response != null) {
                    if (response.status) {
                        categories.value = response.data?.get("categories")
                    } else {
                        message.value = response.message
                    }
                }

            }, {
                Log.e("Supplier", "==>" + it.toString())
                Timber.e(it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getSupplierFreshProduceCategory(jsonObject: JsonObject) {
        apiService.getSupplierFreshProduceCategory(jsonObject)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ response ->
                if (response != null) {
                    if (response.status) {
                        freshProduceCategories.value = response.data?.get("categories")
                    } else {
                        message.value = response.message
                    }
                }

            }, {
                Log.e("Supplier", "==>" + it.toString())
                Timber.e(it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getFreshProduces(jsonObject: JsonObject) {
        apiService.getFreshProduces(jsonObject)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ response ->
                if (response != null) {
                    if (response.status) {
                        freshProduceList.value = response.data?.get("fresh_produce_categories")
                    } else {
                        message.value = response.message
                    }
                }
            }, {
                Log.e("Supplier", "==>" + it.toString())
                Timber.e(it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun addFreshProduceCategory(jsonObject: JsonObject) {
        apiService.addFreshProduceCategory(jsonObject)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ response ->
                if (response != null) {
                    if (response.status) {
                        freshProduceCategories.value = response.data?.get("categories")
                    } else {
                        message.value = response.message
                    }
                }
            }, {
                Log.e("Supplier", "==>" + it.toString())
                Timber.e(it.toString())
            }).autoDispose(compositeDisposable)
    }


    fun addCategoryApi(
        store_id: RequestBody,
        user_id: RequestBody,
        category_name: RequestBody,
        category_image: MultipartBody.Part,
        secret_key: RequestBody,
        access_key: RequestBody
    ) {

        apiService.addSupplierCategory(
            store_id,
            user_id,
            category_name,
            category_image,
            secret_key,
            access_key
        ).observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ response ->
                if (response != null && response.status) {
                    val obj = response.data?.get("category")
                    obj?.let {
                        categories.value?.add(it)
                        categories.postValue(categories.value)
                    }
                }
            }, {
                Timber.e(it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun deleteCategory(jsonObject: JsonObject): Single<GenieResponse<Nothing>> {
        return apiService.deleteSupplierCategories(jsonObject)

//        authenticationRepository.login(loginRequest)
//            .doOnSubscribe {
//                loginViewStatesSubject.onNext(LoginViewState.Loading)
//            }
//            .doAfterTerminate {
//                loginViewStatesSubject.onNext(LoginViewState.Finish)
//            }
//            .subscribe({
//                loginViewStatesSubject.onNext(LoginViewState.Success)
//            }, {
//                it.parseRetrofitException<GenieErrorResponse>()?.let { registerErrorResponse ->
//                    loginViewStatesSubject.onNext(LoginViewState.Fail(registerErrorResponse.message))
//                } ?: run {
//                    loginViewStatesSubject.onNext(LoginViewState.Fail(it.message ?: ""))
//                }
//            }).autoDispose()
    }

    fun editCategoryApi(
        store_category_id: RequestBody,
        category_name: RequestBody,
        category_image: MultipartBody.Part?,
        secret_key: RequestBody,
        access_key: RequestBody
    ): Single<GenieResponse<FoodCategory>> {
        return apiService.editSupplierCategory(
            store_category_id,
            category_name,
            category_image,
            secret_key,
            access_key
        )
    }
}
