package com.quedrop.driver.utils.locationservice

import android.annotation.SuppressLint
import android.app.Service
import android.content.Context
import android.content.Intent
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import android.os.IBinder
import com.quedrop.driver.utils.KEY_LATITUDE
import com.quedrop.driver.utils.KEY_LONGITUDE
import com.quedrop.driver.utils.SharedPreferenceUtils

class LocationService : Service(), LocationListener {
    var latitude = 0.0
    var longitude = 0.0

    override fun onBind(p0: Intent?): IBinder? {
        return null
    }

    override fun onLocationChanged(location: Location) {
        latitude = location.latitude
        longitude = location.longitude
        updateLocation()
    }

    override fun onStatusChanged(p0: String?, p1: Int, p2: Bundle?) {

    }

    override fun onProviderEnabled(p0: String?) {

    }

    override fun onProviderDisabled(p0: String?) {

    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        getLocation()
        return Service.START_NOT_STICKY

    }

    override fun onCreate() {
        super.onCreate()
        getLocation()
    }

    private fun updateLocation() {
        SharedPreferenceUtils.setString(KEY_LATITUDE, latitude.toString())
        SharedPreferenceUtils.setString(KEY_LONGITUDE, longitude.toString())
    }

    @SuppressLint("MissingPermission")
    fun getLocation() {
        try {
            val locationManager =
                applicationContext.getSystemService(Context.LOCATION_SERVICE) as LocationManager?

            if (locationManager!!.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                locationManager.requestLocationUpdates(
                    LocationManager.GPS_PROVIDER,
                    1000,
                    5f,
                    this
                )
                val lastKnownLocation =
                    locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER)
                lastKnownLocation?.let { location ->
                    latitude = location.latitude
                    longitude = location.longitude
                    updateLocation()


                }

            }

            if (locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
                locationManager.requestLocationUpdates(
                    LocationManager.NETWORK_PROVIDER,
                    1000,
                    5f,
                    this
                )
                val lastKnownLocation =
                    locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)
                lastKnownLocation?.let { location ->
                    latitude = location.latitude
                    longitude = location.longitude
                    updateLocation()

                }
            }

        } catch (e: SecurityException) {
            e.printStackTrace()
        }

    }

}