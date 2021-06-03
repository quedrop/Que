package com.quedrop.customer.ui.splash

import android.app.NotificationManager
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.ui.permission.PermissionActivity
import com.quedrop.customer.utils.*
import com.google.android.gms.tasks.OnCompleteListener
import com.google.firebase.iid.FirebaseInstanceId
import com.google.firebase.messaging.FirebaseMessagingService
import kotlinx.android.synthetic.main.activity_splash.*
import org.json.JSONObject


class SplashActivity : AppCompatActivity() {
    private val TAG = SplashActivity::class.java.simpleName
    private var tempString: String? = null
    private var orderId: Int? = null
    private var notificationManager: NotificationManager? = null

    private var remoteMessage: String? = null
    private var bundleData: Bundle? = null
    private var typeData = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)

        notificationManager =
            getSystemService(FirebaseMessagingService.NOTIFICATION_SERVICE) as NotificationManager

        if (intent.extras != null) {

            if (intent.hasExtra("remote_message_data")) {
                remoteMessage = intent.getStringExtra("remote_message_data")
                typeData = 1
            } else if (intent.hasExtra("local")) {
                typeData = 2
                remoteMessage = null
            } else {
                typeData = 1
                bundleData = intent.extras
                remoteMessage = NotificationUtils.convertBundleToJsonObject(bundleData)

            }
            notificationIntent(remoteMessage, typeData)
        }


        startSplashVideo()

        Handler().postDelayed({

            val intent = Intent(this, PermissionActivity::class.java).apply {
                if (!tempString.isNullOrEmpty()) {
                    putExtra(KeysUtils.keyCustomer, tempString)
                    putExtra(KeysUtils.keyOrderId, orderId)
                    putExtra(KeysUtils.KeyRemoteMessage, remoteMessage)
                }
            }
            startActivityWithDefaultAnimations(intent)
            finish()
        }, 4000)



        FirebaseInstanceId.getInstance().instanceId
            .addOnCompleteListener(OnCompleteListener { task ->
                if (!task.isSuccessful) {
                    return@OnCompleteListener
                }
                // Get new Instance ID token
                val token = task.result?.token
                token?.let {
                    SharedPrefsUtils.setStringPreference(
                        applicationContext,
                        KeysUtils.keyDeviceToken,
                        it
                    )
                }
            })
    }


    private fun startSplashVideo() {
        splash_video.setVideoURI(Uri.parse("android.resource://" + packageName + "/" + R.raw.splash_video))
        splash_video.setZOrderOnTop(true)
        splash_video.start()
    }


    private fun notificationIntent(it: String?, typeData: Int) {
        var notificationType = ""
        var orderIdMain = ""
        if (typeData == 2) {
            notificationType = intent.getStringExtra("notification_type")!!
            orderIdMain = intent.getIntExtra("order_id", 0).toString()
        } else {
            if (it != null) {
                val jsonObject = JSONObject(it)
                if (jsonObject.has("notification_type") && jsonObject.has("order_id")) {
                    notificationType = jsonObject.getString("notification_type")
                    orderIdMain = jsonObject.getString("order_id")
                }
            }
        }
        if (notificationType.isNotEmpty()) {

            when (notificationType.toInt()) {
                ENUMNotificationType.ORDER_REQUEST.posVal -> {
                    tempString = resources.getString(R.string.orderScreen)
                    orderId = orderIdMain.toInt()
                    remoteMessage = it
                }
                ENUMNotificationType.ORDER_ACCEPT.posVal -> {
                    tempString = resources.getString(R.string.orderScreen)
                    orderId = orderIdMain.toInt()

                }

                ENUMNotificationType.ORDER_REJECT.posVal -> {
                    tempString = resources.getString(R.string.orderScreen)
                    orderId = orderIdMain.toInt()

                }
                ENUMNotificationType.ORDER_REQUEST_TIMEOUT.posVal -> {
                    tempString = resources.getString(R.string.orderScreen)
                    orderId = orderIdMain.toInt()

                }
                ENUMNotificationType.RECURRING_ORDER_PLACED.posVal -> {
                    tempString = resources.getString(R.string.orderScreen)
                    orderId = orderIdMain.toInt()

                }
                ENUMNotificationType.ORDER_DISPATCH.posVal -> {
                    tempString = resources.getString(R.string.orderScreen)
                    orderId = orderIdMain.toInt()

                }
                ENUMNotificationType.ORDER_RECEIPT.posVal -> {
                    tempString = resources.getString(R.string.orderScreen)
                    orderId = orderIdMain.toInt()

                }
                ENUMNotificationType.ORDER_CANCELLED.posVal -> {
                    tempString = resources.getString(R.string.orderScreen)
                    orderId = orderIdMain.toInt()

                }
                ENUMNotificationType.ORDER_DELIVERED.posVal -> {
                    tempString = resources.getString(R.string.orderScreen)
                    orderId = orderIdMain.toInt()
                }
                ENUMNotificationType.DRIVER_VERIFICATION.posVal -> {
                    tempString = resources.getString(R.string.orderScreen)
                    orderId = orderIdMain.toInt()
                }
                ENUMNotificationType.RATING.posVal -> {
                    tempString = resources.getString(R.string.orderScreen)
                    orderId = orderIdMain.toInt()
                }
                ENUMNotificationType.NEAR_BY_PLACE.posVal -> {
                    tempString = resources.getString(R.string.orderScreen)
                    orderId = orderIdMain.toInt()

                }
                ENUMNotificationType.CHAT.posVal -> {
                    tempString = resources.getString(R.string.orderScreen)
                    orderId = orderIdMain.toInt()
                    remoteMessage = it
                }
                ENUMNotificationType.UNKNOWN_TYPE.posVal -> {
                    tempString = resources.getString(R.string.orderScreen)
                    orderId = orderIdMain.toInt()
                }
                ENUMNotificationType.NOTIFICATION_SUPPLIER_STORE_VERIFICATION.posVal -> {
                    tempString = resources.getString(R.string.orderScreen)
                    orderId = orderIdMain.toInt()
                    remoteMessage = it
                }
            }
        }
    }
}

