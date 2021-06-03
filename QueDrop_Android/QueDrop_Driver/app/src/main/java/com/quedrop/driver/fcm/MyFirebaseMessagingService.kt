package com.quedrop.driver.fcm

import android.util.Log
import com.quedrop.driver.utils.DEVICE_TOKEN
import com.quedrop.driver.utils.NOTI_LOGS
import com.quedrop.driver.utils.NotificationUtils
import com.quedrop.driver.utils.SharedPreferenceUtils
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {


    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.e("Device token", "2==>$token")
        SharedPreferenceUtils.setString(DEVICE_TOKEN, token)
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        Log.i(NOTI_LOGS, "onMessageServiceX==>${remoteMessage.data}")
        val notificationUtils = NotificationUtils(applicationContext)
        notificationUtils.startNotification(remoteMessage)
    }

}