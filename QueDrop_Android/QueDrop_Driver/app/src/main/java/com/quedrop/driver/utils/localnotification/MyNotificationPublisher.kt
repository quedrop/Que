package com.quedrop.driver.utils.localnotification

import android.app.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.quedrop.driver.R
import com.quedrop.driver.base.QueDropDriverApplication
import com.quedrop.driver.ui.mainActivity.view.MainActivity


class MyNotificationPublisher : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val notification = intent.getParcelableExtra<Notification>(NOTIFICATION)

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH
            val notificationChannel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "NOTIFICATION_CHANNEL_NAME",
                importance
            )
            notificationManager.createNotificationChannel(notificationChannel)
        }
        val id = intent.getIntExtra(NOTIFICATION_ID, 0)
        notificationManager.notify(id, notification)
    }

    companion object {
        var NOTIFICATION_ID = "notification-id"
        var NOTIFICATION = "notification"

        val NOTIFICATION_CHANNEL_ID = "10001"
        val default_notification_channel_id = "default"


        fun scheduleNotification(mContext: Context, notification: Notification, delay: Int) {
            val notificationIntent = Intent(mContext, MyNotificationPublisher::class.java)
            notificationIntent.putExtra(MyNotificationPublisher.NOTIFICATION_ID, 1)
            notificationIntent.putExtra(MyNotificationPublisher.NOTIFICATION, notification)
            val pendingIntent = PendingIntent.getBroadcast(
                mContext,
                0,
                notificationIntent,
                PendingIntent.FLAG_UPDATE_CURRENT
            )
            val futureInMillis = SystemClock.elapsedRealtime() + delay
            val alarmManager = mContext.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.set(AlarmManager.ELAPSED_REALTIME_WAKEUP, futureInMillis, pendingIntent)
        }

        fun getNotification(mContext: Context, title: String, content: String,type:String): Notification {
            val myIntent = Intent(QueDropDriverApplication.context, MainActivity::class.java)
            myIntent.putExtra(type, true)
            val pendingIntent = PendingIntent.getActivity(
                mContext,
                0,
                myIntent,
                PendingIntent.FLAG_UPDATE_CURRENT

            )
            val builder = NotificationCompat.Builder(
                mContext,
                MyNotificationPublisher.default_notification_channel_id
            )
            builder.setContentTitle(title)
            builder.setContentText(content)
            builder.priority = NotificationCompat.PRIORITY_HIGH
            builder.setCategory(NotificationCompat.CATEGORY_SERVICE)
            builder.setSmallIcon(R.drawable.ic_app_trans)
            builder.color =
                ContextCompat.getColor(QueDropDriverApplication.context, R.color.colorThemeGreen)
            builder.setAutoCancel(true)
            builder.setContentIntent(pendingIntent)
            builder.setTicker(content)
            builder.setDefaults(Notification.DEFAULT_ALL)
            builder.setChannelId(MyNotificationPublisher.NOTIFICATION_CHANNEL_ID)
            return builder.build()
        }
    }
}
