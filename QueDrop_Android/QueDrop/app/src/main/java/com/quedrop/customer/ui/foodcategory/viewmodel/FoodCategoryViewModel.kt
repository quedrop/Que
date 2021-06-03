package com.quedrop.customer.ui.foodcategory.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface

import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class FoodCategoryViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val storeCategoryProductList: MutableLiveData<List<StoreCategoryProduct>> = MutableLiveData()
    val otherDetails: MutableLiveData<OtherDetails> = MutableLiveData()
    val user: MutableLiveData<User> = MutableLiveData()



    fun getStoreCategoryWithProductApi(storeCategoryProductRequest: AddStoreCategoriesItem) {

        apiService.getStoreCategoryWithProduct(storeCategoryProductRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ storeCategoryProductResponse ->

                if (storeCategoryProductResponse.status) {
                    storeCategoryProductList.value = storeCategoryProductResponse.data.categories
                    otherDetails.value = storeCategoryProductResponse.data.other_detail
                }else{
                    errorMessage.value = storeCategoryProductResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

}