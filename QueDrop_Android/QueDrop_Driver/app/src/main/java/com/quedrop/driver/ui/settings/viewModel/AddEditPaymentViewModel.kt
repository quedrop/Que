package com.quedrop.driver.ui.settings.viewModel

import androidx.lifecycle.MutableLiveData
import com.quedrop.driver.viewModel.BaseViewModel
import com.quedrop.driver.service.ApiService
import com.quedrop.driver.service.model.GenieResponse
import com.quedrop.driver.service.model.BankDetailModel
import com.google.gson.JsonObject
import io.reactivex.Single

class AddEditPaymentViewModel(private val apiService: ApiService) : BaseViewModel() {

    var bankList: MutableLiveData<MutableList<BankDetailModel>> = MutableLiveData()

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