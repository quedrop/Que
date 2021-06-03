package com.quedrop.customer.utils

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.quedrop.customer.R


class NotificationCreator {

    companion object {

        val channel_id = "QueDrop App Channel"


        private var notification: Notification? = null

        fun getNotification(
            context: Context, newIntent: Intent,
            title: String, body: String
        ): Notification? {

            notification = null
            if (notification == null) {
//                val newIntent = Intent(context, SplashActivity::class.java).apply {
//                    putExtra(KeysUtils.keyCustomer, "OrderScreen")
//                    putExtra("notification_type", notification_type)
//                    putExtra("order_id", orderId)
//                    putExtra("noti_id", NOTIFICATION_ID)
//                }
                newIntent.putExtra("local", true)
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    System.currentTimeMillis().toInt(), newIntent, Intent.FILL_IN_DATA
                )

                /************************ Create notification channel ************************/
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val serviceChannel = NotificationChannel(
                        channel_id, "QueDrop App Channel",
                        NotificationManager.IMPORTANCE_DEFAULT
                    )
                    val manager = context.getSystemService(NotificationManager::class.java)
                    manager?.createNotificationChannel(serviceChannel)
                }

                /************************ Create notification ************************/
                notification = NotificationCompat.Builder(context, channel_id)
                    .setContentTitle(title)
                    .setContentText(body)
                    .setPriority(NotificationCompat.PRIORITY_HIGH)
                    .setSmallIcon(R.drawable.ic_app_trans)
                    .setColor(ContextCompat.getColor(context, R.color.colorThemeGreen))
                    .setAutoCancel(true)
                    .setContentIntent(pendingIntent)
                    .build()

            }
            return notification
        }

        fun getNotificationId(): Int {
            val id = System.currentTimeMillis().toInt()
            return System.currentTimeMillis().toInt()
        }
    }
}