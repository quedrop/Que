package com.quedrop.customer.ui.supplier.payment.viewmodel

import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.model.BankDetails
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.network.GenieResponse
import com.google.gson.JsonObject
import io.reactivex.Single

class ManagePaymentViewModel (private val apiService: ApiInterface):BaseViewModel(){
    var bankDetailList: MutableLiveData<MutableList<BankDetails>> = MutableLiveData()

    fun getUserBankDetailList(jsonObject: JsonObject): Single<GenieResponse<MutableList<BankDetails>>> {
        return apiService.getBankDetails(jsonObject)
    }

    fun deleteBankDetail(jsonObject: JsonObject): Single<GenieResponse<MutableList<BankDetails>>> {
        return apiService.deleteBankDetail(jsonObject)
    }
}