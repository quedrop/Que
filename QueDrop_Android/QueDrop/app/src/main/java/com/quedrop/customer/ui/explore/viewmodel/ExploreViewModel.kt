package com.quedrop.customer.ui.explore.viewmodel


import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class ExploreViewModel(private val apiService: ApiInterface) : BaseViewModel() {


    val arrayExploreStoreList: MutableLiveData<List<StoreSingleDetails>> = MutableLiveData()
    val arrayExploreProductList: MutableLiveData<List<SupplierProduct>> = MutableLiveData()


    fun exploreSearchApi(exploreSearchRequest: ExploreSearchRequest) {
        compositeDisposable.add(apiService.exploreSearch(exploreSearchRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .doOnSubscribe { isLoading.postValue(true) }
            .doOnDispose { isLoading.postValue(false) }
            .doOnError { isLoading.postValue(false) }
            .doOnSuccess { isLoading.postValue(false) }
            .subscribeOn(Schedulers.io())
            .subscribe({ exploreResponse ->
                if (exploreResponse.status) {
                    arrayExploreStoreList.value = exploreResponse.data.explore_stores
                    arrayExploreProductList.value = exploreResponse.data.products
                } else {
                    errorMessage.value = exploreResponse.message
                }
            }, {
                isLoading.postValue(false)
            })
        )
    }

}
