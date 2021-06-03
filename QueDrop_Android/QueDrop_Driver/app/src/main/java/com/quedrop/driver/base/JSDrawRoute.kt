package com.quedrop.driver.base

import android.content.Context
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import com.quedrop.driver.service.model.Orders
import com.quedrop.driver.utils.KEY_LATITUDE
import com.quedrop.driver.utils.KEY_LONGITUDE
import com.quedrop.driver.utils.SharedPreferenceUtils
import com.quedrop.driver.utils.Utility
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.LatLngBounds
import com.google.android.gms.maps.model.MarkerOptions
import com.psp.google.direction.GoogleDirection
import com.psp.google.direction.config.GoogleDirectionConfiguration
import com.psp.google.direction.constant.TransportMode
import com.psp.google.direction.model.Direction
import com.psp.google.direction.model.Route
import com.psp.google.direction.util.execute
import java.util.concurrent.TimeUnit


class JSDrawRoute(
    var mContext: Context,
    var orderDetail: Orders,
    var mGoogleMap: GoogleMap,
    var iconVisibility: Boolean
) {


    private var driverLatLng: LatLng? = null
    private var userLatLng: LatLng? = null
    private var wayLists: ArrayList<LatLng>? = null
    private var mDrawEventListener: DrawEventListener? = null

    fun initDrawRoute(withoutStore: Boolean) {

        driverLatLng = LatLng(
            SharedPreferenceUtils.getString(KEY_LATITUDE).toDouble(),
            SharedPreferenceUtils.getString(
                KEY_LONGITUDE
            ).toDouble()
        )

        userLatLng = LatLng(
            orderDetail.deliveryLatitude.toDouble(),
            orderDetail.deliveryLongitude.toDouble()
        )


        wayLists = ArrayList()

        val listLatLng = orderDetail.stores
        for (i in 0 until listLatLng.size) {
            val lat = listLatLng[i].latitude
            val lng = listLatLng[i].longitude
            if (lat != "" && lng != "")
                wayLists?.add(LatLng(lat.toDouble(), lng.toDouble()))
        }


        GoogleDirectionConfiguration.getInstance().isLogEnabled = BuildConfig.DEBUG
        GoogleDirection.withServerKey(mContext.resources.getString(R.string.mapApiKey))
            .from(driverLatLng)//driver
            .and(wayLists)//store
            .to(userLatLng)//customer
            .transportMode(TransportMode.DRIVING)
            .execute(
                onDirectionSuccess = { direction ->
                    if (direction.routeList.size != 0) {
                        val route = direction.routeList[0]
                        setupMarkerData(route)
                        onDirectionSuccess(direction)
                    }
                },
                onDirectionFailure = { t -> onDirectionFailure(t) }
            )

    }


    private fun setupMarkerData(route: Route?) {
        if (route != null) {
            val leg = route.legList
            if (iconVisibility) {
                for (index in 0 until leg.size) {
                    if (index == 0) {
                        mGoogleMap
                            .addMarker(MarkerOptions().position(driverLatLng!!))
                            .setIcon(BitmapDescriptorFactory.fromResource(R.drawable.ic_drive_green))
                    } else {
                        val restIcon = Utility.createDrawableNode((index).toString())
                        mGoogleMap
                            .addMarker(MarkerOptions().position(leg[index].startLocation.coordination))
                            .setIcon(BitmapDescriptorFactory.fromBitmap(restIcon))
                    }
                }
                mGoogleMap
                    .addMarker(MarkerOptions().position(userLatLng!!))
                    .setIcon(BitmapDescriptorFactory.fromResource(R.drawable.ic_customer_red))
            } else {

                mGoogleMap
                    .addMarker(MarkerOptions().position(driverLatLng!!))
                    .setIcon(BitmapDescriptorFactory.fromResource(R.drawable.ic_map_dot))


                mGoogleMap
                    .addMarker(MarkerOptions().position(userLatLng!!))
                    .setIcon(BitmapDescriptorFactory.fromResource(R.drawable.ic_marker_blue))

            }
        }

    }

    private fun onDirectionSuccess(direction: Direction) {
        if (direction.isOK) {
            if (mDrawEventListener != null) {
                mDrawEventListener?.onDrawListener(direction, false)
            }
        } else {
            if (mDrawEventListener != null) {
                mDrawEventListener?.onDrawListener(null, true)
            }
        }
    }

    private fun onDirectionFailure(t: Throwable) {
        if (mDrawEventListener != null) {
            mDrawEventListener?.onDrawListener(null, true)
        }
    }


    fun setCameraUpdateBounds(route: Route) {
        try {
            val southwest = route.bound.southwestCoordination.coordination
            val northeast = route.bound.northeastCoordination.coordination
            val bounds = LatLngBounds(southwest, northeast)
            mGoogleMap.animateCamera(CameraUpdateFactory.newLatLngBounds(bounds, 100))
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }


    interface DrawEventListener {
        fun onDrawListener(direction: Direction?, t: Boolean)
    }

    fun setOnDrawListener(drawEventListener: DrawEventListener) {
        this.mDrawEventListener = drawEventListener
    }


    companion object {
        fun directionTime(seconds: Long): String {
            val day = TimeUnit.SECONDS.toDays(seconds)
            val hours = TimeUnit.SECONDS.toHours(seconds) - day * 24
            val minute =
                TimeUnit.SECONDS.toMinutes(seconds) - TimeUnit.SECONDS.toHours(seconds) * 60
            val second =
                TimeUnit.SECONDS.toSeconds(seconds) - TimeUnit.SECONDS.toMinutes(seconds) * 60

            return when {
                seconds < 60 -> second.toString() + "sec"
                seconds < 3600 -> minute.toString() + "min"
                seconds < 86400 -> hours.toString() + "hr " + minute.toString() + "min"
                else -> day.toString() + "day" + hours.toString() + "hr " + minute.toString() + "min"
            }
        }

        fun directionDistance(totalDistance: Long?): String {
            return if (totalDistance!! > 1000) {
                "(" + (totalDistance / 1000).toString() + "km)"
            } else {
                "(" + (totalDistance).toString() + "m)"
            }
        }
    }
}