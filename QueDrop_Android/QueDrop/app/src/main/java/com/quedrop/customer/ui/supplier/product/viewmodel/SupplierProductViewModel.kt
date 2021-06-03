package com.quedrop.customer.ui.supplier.product.viewmodel

import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.model.SupplierProduct
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.network.GenieResponse
import com.google.gson.JsonObject
import io.reactivex.Single

class SupplierProductViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val productList: MutableLiveData<MutableList<SupplierProduct>> = MutableLiveData()

    fun getSupplierProducts(jsonObject: JsonObject): Single<GenieResponse<MutableList<SupplierProduct>>> {
        return apiService.getSupplierProducts(jsonObject)
    }

    fun searchSupplierProducts(jsonObject: JsonObject): Single<GenieResponse<MutableList<SupplierProduct>>> {
        return apiService.searchSupplierProduct(jsonObject)
    }

    fun deleteSupplierProducts(jsonObject: JsonObject): Single<GenieResponse<Nothing>> {
        return apiService.deleteSupplierProduct(jsonObject)
    }
}