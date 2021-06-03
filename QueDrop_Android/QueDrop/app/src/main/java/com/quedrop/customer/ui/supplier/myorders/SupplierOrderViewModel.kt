package com.quedrop.customer.ui.supplier.myorders

import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.model.BillingSummary
import com.quedrop.customer.model.SupplierOrder
import com.quedrop.customer.model.WeeklyData
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.network.GenieResponse
import com.google.gson.JsonObject
import com.quedrop.customer.model.FreshProduce
import io.reactivex.Single

class SupplierOrderViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val orderList: MutableLiveData<MutableList<SupplierOrder>> = MutableLiveData()
    val singleOrderList: MutableLiveData<SupplierOrder> = MutableLiveData()
    val weeklyDataList: MutableLiveData<MutableList<WeeklyData>> = MutableLiveData()
    val billingDataList: MutableLiveData<BillingSummary> = MutableLiveData()

    fun getSupplierOrderApi(jsonObject: JsonObject): Single<GenieResponse<MutableList<SupplierOrder>>> {
        return apiService.getSupplierOrder(jsonObject)
    }

    fun getSingleSupplierOrderDetail(jsonObject: JsonObject): Single<GenieResponse<SupplierOrder>> {
        return apiService.getSingleSupplierOrderDetail(jsonObject)
    }

    fun getWeeklyPaymentRequest(jsonObject: JsonObject): Single<GenieResponse<Nothing>> {
        return apiService.getSupplierWeekleyPaymentDetail(jsonObject)
    }
}
