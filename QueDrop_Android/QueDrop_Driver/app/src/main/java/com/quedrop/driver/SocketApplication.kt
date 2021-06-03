package com.quedrop.driver

import android.annotation.SuppressLint
import android.app.AlarmManager
import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.ProcessLifecycleOwner
import com.quedrop.driver.api.authentication.LoggedInUserCache
import com.quedrop.driver.base.QueDropDriverApplication
import com.quedrop.driver.base.rxjava.subscribeOnIoAndObserveOnMainThread
import com.quedrop.driver.socket.SocketDataManager
import com.quedrop.driver.socket.model.Message
import com.quedrop.driver.socket.model.SocketRequest
import com.quedrop.driver.ui.chat.ChatActivity
import com.quedrop.driver.utils.localnotification.MyNotificationPublisher
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import timber.log.Timber
import javax.inject.Inject


open class SocketApplication : QueDropDriverApplication(), LifecycleObserver {
    private lateinit var applicationCompositeDisposable: CompositeDisposable

    @Inject
    lateinit var loggedInUserCache: LoggedInUserCache

    @Inject
    lateinit var socketDataManager: SocketDataManager

    override fun onCreate() {
        super.onCreate()
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)
        applicationCompositeDisposable = CompositeDisposable()

        socketDataManager.getChatRepository().connectionEmitter().subscribe({
            loggedInUserCache.getLoggedInUser()?.userId?.let { userId ->
                socketDataManager.getChatRepository()
                    .joinSocket(SocketRequest(senderId = userId)).subscribe({
                        Timber.i("joinSocket successfully called")
                    }, {
                        Timber.e(it)
                    }).autoDispose()
            }
        }, {
            Timber.e(it)
        }).autoDispose()

        socketDataManager.getChatRepository().disconnectEmitter().subscribe({
            Timber.i("Socket disconnected")
        }, {
            Timber.e(it)
        }).autoDispose()

        initChatNotification()

    }

    private fun Disposable.autoDispose() {
        applicationCompositeDisposable.add(this)
    }

    private fun initChatNotification() {
        socketDataManager.getChatRepository().observeNewMessage()
            .subscribeOnIoAndObserveOnMainThread({
                Timber.i(it.toString())
                it.chatMessages.firstOrNull()?.let { message ->
                    val messageOrderId = message.orderId ?: return@let
                    val orderId = loggedInUserCache.getCurrentOrderId()
                    if (orderId == null) {
                        // chat screen not open fire the notification with message

                        Log.d("Chat Screen", "==>chat screen not open" + message.message)

                        scheduleNotification(
                            getNotification("New Meesage In Order #$messageOrderId", message),
                            1000
                        )
                    } else {
                        if (messageOrderId.toString() != orderId) {
                            //chat screen open but diffrent order id
                            // Send notification
                            scheduleNotification(
                                getNotification("New Meesage In Order #$messageOrderId", message),
                                1000
                            )
                            Log.d("Chat Screen", "==>chat screen open but different user")
                        }
                    }
                }
            }, {
                Timber.e(it)
            }).autoDispose()
    }

    private fun scheduleNotification(notification: Notification, delay: Int) {
        val notificationIntent = Intent(context, MyNotificationPublisher::class.java)
        notificationIntent.putExtra(MyNotificationPublisher.NOTIFICATION_ID, 1)
        notificationIntent.putExtra(MyNotificationPublisher.NOTIFICATION, notification)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            notificationIntent,
            PendingIntent.FLAG_UPDATE_CURRENT
        )
        val futureInMillis = SystemClock.elapsedRealtime() + delay
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.set(AlarmManager.ELAPSED_REALTIME_WAKEUP, futureInMillis, pendingIntent)
    }

    @SuppressLint("WrongConstant")
    private fun getNotification(title: String, messageObj: Message): Notification {

        val myIntent = Intent(context, ChatActivity::class.java)
        myIntent.putExtra(ChatActivity.NOTIFICATION_DATA, messageObj)
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            myIntent,
            Intent.FLAG_ACTIVITY_NEW_TASK

        )
        val builder = NotificationCompat.Builder(
            context,
            MyNotificationPublisher.default_notification_channel_id
        )
        builder.setContentTitle(title)
        builder.setContentText(messageObj.message)
        builder.priority = NotificationCompat.PRIORITY_HIGH
        builder.setCategory(NotificationCompat.CATEGORY_SERVICE)
        builder.setSmallIcon(R.drawable.ic_app_trans)
        builder.color = ContextCompat.getColor(context,R.color.colorThemeGreen)
        builder.setAutoCancel(true)
        builder.setContentIntent(pendingIntent)
        builder.setTicker(messageObj.message)
        builder.setDefaults(Notification.DEFAULT_ALL)
        builder.setChannelId(MyNotificationPublisher.NOTIFICATION_CHANNEL_ID)
        return builder.build()
    }

}