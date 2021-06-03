package com.quedrop.customer.ui.supplier.payment.viewmodel

import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.model.BankDetailModel
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.network.GenieResponse
import com.google.gson.JsonObject
import io.reactivex.Single

class AddEditPaymentViewModel(private val apiService: ApiInterface): BaseViewModel() {

    var bankList : MutableLiveData<MutableList<BankDetailModel>> = MutableLiveData()

    fun getAllBankList(jsonObject: JsonObject): Single<GenieResponse<MutableList<BankDetailModel>>> {
        return apiService.getAllBankList(jsonObject)
    }

    fun addPaymentDetail(jsonObject: JsonObject): Single<GenieResponse<Nothing>> {
        return apiService.addBankDetails(jsonObject)
    }

    fun editPaymentDetail(jsonObject: JsonObject): Single<GenieResponse<Nothing>> {
        return apiService.editBankDetails(jsonObject)
    }
}