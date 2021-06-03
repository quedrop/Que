package com.quedrop.customer.ui.notification.viewmodel

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.quedrop.customer.model.NotificationModel
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.network.GenieResponse
import com.google.gson.JsonObject
import io.reactivex.Single

class NotificationViewModel(private val apiService: ApiInterface) : ViewModel() {

    val notificationList: MutableLiveData<MutableList<NotificationModel>> = MutableLiveData()

    fun getSupplierNotifications(jsonObject: JsonObject): Single<GenieResponse<MutableList<NotificationModel>>> {
        return apiService.getNotifications(jsonObject)
    }
}
