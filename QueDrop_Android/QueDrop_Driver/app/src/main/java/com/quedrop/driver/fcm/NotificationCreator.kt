package com.quedrop.driver.fcm

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.quedrop.driver.R
import com.quedrop.driver.ui.mainActivity.view.MainActivity
import com.quedrop.driver.ui.orderDetailsFragment.view.OrderDetailActivity
import com.quedrop.driver.ui.splash.SplashActivity
import com.quedrop.driver.utils.ENUMNotificationType
import com.google.firebase.messaging.RemoteMessage
import org.json.JSONObject


class NotificationCreator {

    companion object {
        val CHANNEL_ID = "QurDropAppChannel"

        private val NOTIFICATION_ID =
            1094 //todo...manage dynamic. current will override notification

        private var notification: Notification? = null
        private var notification_type: Int? = null

        private var resultPendingIntent: PendingIntent? = null

        fun getNotification(
            context: Context,
            notificationData: String,
            notificationmessage: RemoteMessage.Notification?
        ): Notification? {

            Log.e("Notification Data", "2==>" + notificationData)
            Log.e("Notification Data", "2==>" + notificationmessage)
/*

            {customer_id=261, notification_type=1, first_name=zp, order_id=723, order_drivers=195,137,224,196,215, last_name=Patel}
*/

            //map-->JsonObject

            if (this.notification == null) {

                try {

                    val obj = JSONObject(notificationData)

                    Log.d("My App", obj.toString())
                    notification_type = obj.getString("notification_type").toInt()


                    when (notification_type) {
                        ENUMNotificationType.ORDER_REQUEST.posVal -> {
                            val notificationIntent = Intent(context, MainActivity::class.java)
                            resultPendingIntent = PendingIntent.getActivity(
                                context,
                                0, notificationIntent, 0
                            )
                        }
                        ENUMNotificationType.ORDER_DISPATCH.posVal -> {
                            // Create an Intent for the activity you want to start
                            val resultIntent = Intent(context, OrderDetailActivity::class.java)
                            // Create the TaskStackBuilder
                            resultPendingIntent = TaskStackBuilder.create(context).run {
                                // Add the intent, which inflates the back stack
                                addNextIntentWithParentStack(resultIntent)
                                // Get the PendingIntent containing the entire back stack
                                getPendingIntent(0, PendingIntent.FLAG_UPDATE_CURRENT)
                            }
                        }
                    }

                } catch (t: Throwable) {
                    Log.e("My App", "Could not parse malformed JSON: \"$notificationData\"")
                }


                val notificationIntent = Intent(context, SplashActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0, notificationIntent, 0
                )

                /************************ Create notification channel ************************/
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val serviceChannel = NotificationChannel(
                        CHANNEL_ID, "QueDrop App Channel",
                        NotificationManager.IMPORTANCE_DEFAULT
                    )
                    val manager = context.getSystemService(NotificationManager::class.java)
                    manager.createNotificationChannel(serviceChannel)
                }

                /************************ Create notification ************************/
                this.notification = NotificationCompat.Builder(context, CHANNEL_ID)
                    .setContentTitle(notificationmessage?.title)
                    .setContentText(notificationmessage?.body)
                    .setSmallIcon(R.drawable.ic_launcher_background)//ToDo ask hb for icons
                    .setLargeIcon(
                        BitmapFactory.decodeResource(
                            context.resources,
                            R.drawable.ic_launcher_background
                        )
                    )
                    .setContentIntent(resultPendingIntent)
                    .build()
            }
            return this.notification
        }

        fun getNotificationId(): Int {
            return NOTIFICATION_ID
        }
    }


}