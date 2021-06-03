package com.quedrop.customer.ui.favourite.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import java.lang.NumberFormatException

class FavoriteViewModel(private val apiService: ApiInterface) : BaseViewModel() {


    val favoriteStoresList: MutableLiveData<List<NearByStores>> = MutableLiveData()

    fun favouriteApiCall(favouriteRequest: FavoriteStoresRequest) {

        try {
            apiService.getFavouriteStores(favouriteRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ favouriteResponse ->
                    if (favouriteResponse.status) {
                        favoriteStoresList.value = favouriteResponse.data.stores
                    } else {
                        errorMessage.value = favouriteResponse.message

                    }

                }, {
                    errorMessage.value = it.toString()
                    Log.e("error", it.toString())
                }).autoDispose(compositeDisposable)

        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }

    }
}
