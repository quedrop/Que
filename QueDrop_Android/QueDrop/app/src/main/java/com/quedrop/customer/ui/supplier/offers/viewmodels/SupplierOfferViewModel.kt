package com.quedrop.customer.ui.supplier.offers.viewmodels

import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.model.SupplierProductOffer
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.network.GenieResponse
import com.google.gson.JsonObject
import io.reactivex.Single

class SupplierOfferViewModel(private val apiService: ApiInterface) : BaseViewModel() {
    var offerList :MutableLiveData<MutableList<SupplierProductOffer>> = MutableLiveData()

    fun getSupplierOffer(jsonObject: JsonObject): Single<GenieResponse<MutableList<SupplierProductOffer>>> {
        return apiService.getSupplierOffer(jsonObject)
    }

    fun deleteSupplierOffer(jsonObject: JsonObject): Single<GenieResponse<Nothing>> {
        return apiService.deleteSupplierOffer(jsonObject)
    }
}
