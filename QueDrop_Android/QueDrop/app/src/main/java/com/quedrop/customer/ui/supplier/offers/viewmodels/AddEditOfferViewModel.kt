package com.quedrop.customer.ui.supplier.offers.viewmodels

import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.model.FoodCategory
import com.quedrop.customer.model.SupplierProduct
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.network.GenieResponse
import com.google.gson.JsonObject
import io.reactivex.Single

class AddEditOfferViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val categories: MutableLiveData<MutableList<FoodCategory>> = MutableLiveData()
    val productList: MutableLiveData<MutableList<SupplierProduct>> = MutableLiveData()

    fun getSupplierCategories(jsonObject: JsonObject): Single<GenieResponse<MutableList<FoodCategory>>> {
        return apiService.getSupplierCategories(jsonObject)
    }

    fun getSupplierProducts(jsonObject: JsonObject): Single<GenieResponse<MutableList<SupplierProduct>>> {
        return apiService.getSupplierProducts(jsonObject)
    }

    fun searchSupplierProducts(jsonObject: JsonObject): Single<GenieResponse<MutableList<SupplierProduct>>> {
        return apiService.searchSupplierProduct(jsonObject)
    }

    fun addProductOfferApi(jsonObject: JsonObject): Single<GenieResponse<Nothing>> {
        return apiService.addProductOffer(jsonObject)
    }

    fun editProductOfferApi(jsonObject: JsonObject): Single<GenieResponse<Nothing>> {
        return apiService.editProductOffer(jsonObject)
    }

}