package com.quedrop.driver.ui.dashboard

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.location.LocationManager
import android.os.Bundle
import android.provider.Settings
import com.bumptech.glide.Glide
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.ui.login.view.LoginActivity
import com.quedrop.driver.utils.REQUEST_CODE_GPS
import com.quedrop.driver.utils.locationservice.LocationService
import com.quedrop.driver.utils.showInfoMessage
import com.tbruyelle.rxpermissions2.RxPermissions
import kotlinx.android.synthetic.main.activity_dashboard.*

class PermissionActivity : BaseActivity() {
    private lateinit var rxPermissions: RxPermissions

    var remoteMessage: String? = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_dashboard)

        if (intent != null) {
            remoteMessage = intent.getStringExtra("remote_message")
        }

        Glide.with(this).load(R.drawable.bg_splash).into(dashboardImage)
        rxPermissions = RxPermissions(this)
        checkGPSStatus()
        ivGPSOn.throttleClicks().subscribe {
            startActivityForResult(
                Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS),
                REQUEST_CODE_GPS
            )
        }.autoDispose(compositeDisposable)
    }

    private fun checkGPSStatus() {
        val locationManager: LocationManager =
            applicationContext.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val isGPSOn = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)

        if (isGPSOn) {
            requestOtherPermission()
        } else {
            showInfoMessage(this,"Please turn on GPS")
        }

    }

    @SuppressLint("CheckResult")
    private fun requestOtherPermission() {
        rxPermissions
            .request(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.READ_EXTERNAL_STORAGE,
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
                Manifest.permission.CAMERA
            )
            .subscribe { granted ->
                if (granted) {
                    startService(Intent(this, LocationService::class.java))

                    val intent = Intent(this, LoginActivity::class.java)
                    intent.putExtra("remote_message", remoteMessage)
                    startActivityWithDefaultAnimations(intent)
                    finish()
                } else {
                    requestOtherPermission()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_GPS) {
            checkGPSStatus()
        }
    }

}
