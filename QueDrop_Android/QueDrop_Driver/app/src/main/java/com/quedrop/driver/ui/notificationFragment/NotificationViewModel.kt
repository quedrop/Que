package com.quedrop.driver.ui.notificationFragment

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.driver.viewModel.BaseViewModel
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.service.ApiService
import com.quedrop.driver.service.model.NotificationData
import com.quedrop.driver.service.request.NotificationListRequest
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class NotificationViewModel(private val apiService: ApiService) : BaseViewModel() {

    val notificationList: MutableLiveData<NotificationData> = MutableLiveData()
    val errorMessage: MutableLiveData<String> = MutableLiveData()

    fun getDriverNotification(notificationListRequest: NotificationListRequest) {
        try {
            apiService.getNotifications(notificationListRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ notificationResponse ->

                    if (notificationResponse.status!!) {
                        notificationList.value = notificationResponse.notificationData
                    } else {
                        errorMessage.value = notificationResponse.message
                    }
                }, {
                    Log.e("Error ", "===> " + it.message.toString())
                }).autoDispose(compositeDisposable)
        } catch (e: Exception) {
            Log.e("exception ", "===> " + e.message.toString())

        }

    }

}
