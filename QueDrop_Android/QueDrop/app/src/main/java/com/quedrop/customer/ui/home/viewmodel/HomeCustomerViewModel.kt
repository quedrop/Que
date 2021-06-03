package com.quedrop.customer.ui.home.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface

import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class HomeCustomerViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val categoriesList: MutableLiveData<List<Categories>> = MutableLiveData()
    val restaurantOfferList: MutableLiveData<List<StoreOfferList>> = MutableLiveData()
    val productOfferList: MutableLiveData<List<ProfuctOfferList>> = MutableLiveData()
    val cartTermsNoteList: MutableLiveData<List<NotesResponse>> = MutableLiveData()
    val paymentOrderOfferList: MutableLiveData<List<OrderOffer>> = MutableLiveData()
    val freshProduceCategories: MutableLiveData<List<FreshProduceCategories>> = MutableLiveData()
    val user: MutableLiveData<User> = MutableLiveData()
    var totalItemsString: MutableLiveData<Int> = MutableLiveData()


    fun getAllCategoriesApi(allCategoriesRequest: AllCategories) {

        apiService.allCategories(allCategoriesRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ categoriesResponse ->

                if (categoriesResponse.status) {
                    categoriesList.value = categoriesResponse.data.service_categories
                } else {
                    errorMessage.value = categoriesResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getOffersApi(offersRequest: OfferList) {

        apiService.getOfferList(offersRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ offersResponse ->

                if (offersResponse.status) {
                    restaurantOfferList.value = offersResponse.data.store_offer
                    productOfferList.value = offersResponse.data.product_offer
                    paymentOrderOfferList.value = offersResponse.data.order_offer
                    paymentOrderOfferList.value = offersResponse.data.order_offer
                    freshProduceCategories.value = offersResponse.data.fresh_produce_categories
                } else {
                    errorMessage.value = offersResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getNotesApi(getNotesRequest: GetNotes) {

        apiService.getCartTermsNote(getNotesRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ cartTermsNotesResponse ->

                if (cartTermsNotesResponse.status) {
                    cartTermsNoteList.value = cartTermsNotesResponse.data.cart_term_notes
                } else {
                    errorMessage.value = cartTermsNotesResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

}