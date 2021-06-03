package com.quedrop.customer.base

import android.content.Context
import com.quedrop.customer.BuildConfig
import com.quedrop.customer.R
import com.quedrop.customer.model.GetSingleOrderDetailsResponse
import com.quedrop.customer.utils.Utility
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.*
import com.psp.google.direction.GoogleDirection
import com.psp.google.direction.config.GoogleDirectionConfiguration
import com.psp.google.direction.constant.TransportMode
import com.psp.google.direction.model.Direction
import com.psp.google.direction.model.Route
import com.psp.google.direction.util.execute
import java.util.concurrent.TimeUnit


class JSDrawRoute(
    var mContext: Context,
    var orderDetail: GetSingleOrderDetailsResponse,
    var mGoogleMap: GoogleMap,
    var iconVisibility: Boolean
) {


    private var driverLatLng: LatLng? = null
    private var userLatLng: LatLng? = null
    private var wayLists: ArrayList<LatLng>? = null
    private var mDrawEventListener: DrawEventListener? = null
    private var mDriverMarker :Marker?= null
    private var driverIcon : BitmapDescriptor? =null


    fun initDrawRoute(withoutStore: Boolean) {

        if(orderDetail.driver_detail.latitude.isNotEmpty()) {

            driverLatLng = LatLng(
                orderDetail.driver_detail.latitude.toDouble(),
                orderDetail.driver_detail.longitude.toDouble()
            )

            if(!orderDetail.delivery_latitude.isNullOrEmpty()) {

                userLatLng = LatLng(
                    orderDetail.delivery_latitude.toDouble(),
                    orderDetail.delivery_longitude.toDouble()
                )
            }


            wayLists = ArrayList()

            val listLatLng = orderDetail.stores
            for (i in 0 until listLatLng.size) {
                val lat = listLatLng[i].latitude.toDouble()
                val lng = listLatLng[i].longitude.toDouble()
                wayLists?.add(LatLng(lat, lng))
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
    }


    private fun setupMarkerData(route: Route?) {
        if (route != null) {
            val leg = route.legList
            if (iconVisibility) {
                for (index in 0 until leg.size) {
                    if (index == 0) {
                        driverIcon=BitmapDescriptorFactory.fromResource(R.drawable.delivery_icon)
                        mDriverMarker =
                            mGoogleMap.addMarker(MarkerOptions().position(driverLatLng!!))
                            mDriverMarker?.setIcon(driverIcon)


                        /*mGoogleMap
                            .addMarker(MarkerOptions().position(driverLatLng!!))
                            .setIcon(BitmapDescriptorFactory.fromResource(R.drawable.delivery_icon))*/
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
                for (index in 0 until leg.size) {
                    if (index == 0) {
                        mGoogleMap
                            .addMarker(MarkerOptions().position(driverLatLng!!))
                            .setIcon(BitmapDescriptorFactory.fromResource(R.drawable.ic_pin_press))
                    }
                }
                mGoogleMap
                    .addMarker(MarkerOptions().position(userLatLng!!))
                    .setIcon(BitmapDescriptorFactory.fromResource(R.drawable.ic_pin_press))
            }
        }

    }

    fun updateMarker(latLng:LatLng?){
        if(latLng!=null) {
            mDriverMarker?.remove()
            driverIcon = BitmapDescriptorFactory.fromResource(R.drawable.delivery_icon)
            mDriverMarker =
                mGoogleMap.addMarker(MarkerOptions().position(latLng))
            mDriverMarker?.setIcon(driverIcon)
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
