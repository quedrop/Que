package com.quedrop.driver.ui.splash

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.quedrop.driver.R
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.ui.dashboard.PermissionActivity
import com.quedrop.driver.utils.DEVICE_TOKEN
import com.quedrop.driver.utils.NOTI_LOGS
import com.quedrop.driver.utils.NotificationUtils
import com.quedrop.driver.utils.SharedPreferenceUtils
import com.google.android.gms.tasks.OnCompleteListener
import com.google.firebase.iid.FirebaseInstanceId
import kotlinx.android.synthetic.main.activity_splash.*
import java.lang.Exception

class SplashActivity : AppCompatActivity() {

    var remoteMessage: String? = ""
    private var bundleData: Bundle? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)

        if (intent.extras != null) {

            if (intent.hasExtra("remote_message_data")) {
                remoteMessage = intent.getStringExtra("remote_message_data")
                Log.i(NOTI_LOGS, "splashIntentX==>" + remoteMessage)

            } else {
                bundleData = intent.extras
                remoteMessage = NotificationUtils.convertBundleToJsonObject(bundleData)
                Log.i(NOTI_LOGS, "splashBundleX==>" + remoteMessage)

            }

        }


        FirebaseInstanceId.getInstance().instanceId
            .addOnCompleteListener(OnCompleteListener { task ->
                if (!task.isSuccessful) {
                    Log.w("TAG", "getInstanceId failed", task.exception)
                    return@OnCompleteListener
                }
                // Get new Instance ID token
                val token = task.result?.token
                token?.let {
                    Log.e("Device token", "==>" + it)
                    SharedPreferenceUtils.setString(
                        DEVICE_TOKEN,
                        it
                    )
                }
            })
        try {
            startSplashVideo()
        } catch (e: Exception) {
            Log.e("Exception", "==>" + e.message)
        }

        val intent = Intent(this, PermissionActivity::class.java)
        intent.putExtra("remote_message", remoteMessage)

        Handler().postDelayed({
            startActivityWithDefaultAnimations(intent)
            finish()
        }, 4000)
    }

    private fun startSplashVideo() {
        splash_video.setVideoURI(Uri.parse("android.resource://" + packageName + "/" + R.raw.splash_video))
        splash_video.setZOrderOnTop(true)
        splash_video.start()

    }
}
