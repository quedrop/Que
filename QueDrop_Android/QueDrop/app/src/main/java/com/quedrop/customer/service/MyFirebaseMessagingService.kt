package com.quedrop.customer.service

import android.util.Log
import com.quedrop.customer.utils.ConstantUtils
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.NotificationUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage


class MyFirebaseMessagingService : FirebaseMessagingService() {

    override fun onNewToken(token: String) {
        val token = token
        Log.e("tokenService", token)
        SharedPrefsUtils.setStringPreference(
            applicationContext,
            KeysUtils.keyDeviceToken,
            token
        )
    }


    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        Log.i(ConstantUtils.NOTICES, "onMessageServiceX==>${remoteMessage.data}")
        val notificationUtils = NotificationUtils(applicationContext)
        notificationUtils.startNotification(remoteMessage)

    }
}