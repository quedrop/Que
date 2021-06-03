package com.quedrop.customer.ui.storewithoutproduct.viewmodel

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

class StoreWithoutProductViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val messageAddProduct: MutableLiveData<String> = MutableLiveData()
    val noUserAddedProduct: MutableLiveData<String> = MutableLiveData()
    val store_detail: MutableLiveData<GetStoreDetails> = MutableLiveData()
    val user_products: MutableLiveData<UserProductResponse> = MutableLiveData()


    fun getStoreWithProductDetailsApi(storeWithProductDetailsRequest: AddStoreDetails) {

        apiService.getStoreDetails(storeWithProductDetailsRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ storeDetailsResponse ->

                if (storeDetailsResponse.status) {
                    store_detail.value = storeDetailsResponse.data.store_detail
                } else {
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

    fun getUserAddedStoreProductsFromCartApi(addUserProductFromCartRequest: AddUserProductFromCartRequest) {
        apiService.GetUserAddedStoreProductsFromCart(addUserProductFromCartRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ favouriteStoreResponse ->

                if (favouriteStoreResponse.status) {
                    user_products.value = favouriteStoreResponse.data.user_products
                }else{
                    noUserAddedProduct.value = favouriteStoreResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun addProductCategoryApi(
        is_user_added_store: RequestBody,
        store_id: RequestBody,
        user_store_id: RequestBody,
        user_id: RequestBody,
        guest_id: RequestBody,
        product_description: RequestBody,
        secret_key: RequestBody,
        other: RequestBody,
        products: RequestBody,
        image: ArrayList<MultipartBody.Part>,
        version:RequestBody,
        arrayDeleteList:RequestBody
    ) {
        apiService.addProduct(
            is_user_added_store,
            store_id,
            user_store_id,
            user_id,
            guest_id,
            product_description,
            secret_key,
            other,
            products,
            image,
            version,
            arrayDeleteList
        )
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ addProductCartResponse ->

                if (addProductCartResponse.status) {
                    messageAddProduct.value = addProductCartResponse.message
                } else {
                    errorMessage.value = addProductCartResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

}