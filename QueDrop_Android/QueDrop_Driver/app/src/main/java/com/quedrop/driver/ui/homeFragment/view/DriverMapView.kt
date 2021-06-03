package com.quedrop.driver.ui.homeFragment.view

import android.util.Log
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.quedrop.driver.R
import com.quedrop.driver.service.model.GoogleMapDirection
import com.quedrop.driver.service.model.OrderDetail
import com.quedrop.driver.service.request.InfoWindow
import com.quedrop.driver.ui.homeFragment.viewModel.HomeViewModel
import com.quedrop.driver.utils.KEY_LATITUDE
import com.quedrop.driver.utils.KEY_LONGITUDE
import com.quedrop.driver.utils.SharedPreferenceUtils
import com.quedrop.driver.utils.Utility
import com.google.android.gms.maps.CameraUpdate
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.*


internal class DriverMapView(
    private val isShowIcon: Boolean,
    private val mapFragment: SupportMapFragment,
    private val map: GoogleMap,
    private val homeViewModel: HomeViewModel
) {
    private var polyLine: Polyline? = null
    private var lineOptions: PolylineOptions? = null
    private var listOfPoints = java.util.ArrayList<LatLng>()
    private var arrayRoutes = java.util.ArrayList<java.util.ArrayList<HashMap<String, String>>>()
    private lateinit var orderDetail: OrderDetail
    private lateinit var driverIcon: BitmapDescriptor
    private lateinit var customerIcon: BitmapDescriptor

    init {
        map.uiSettings.isCompassEnabled = false
        homeViewModel.mapDirectionData.observe(mapFragment, Observer { directionArray ->
            drawRout(directionArray)
        })
    }

    fun setCurrentMarker() {
        driverIcon = if (isShowIcon) {
            BitmapDescriptorFactory.fromResource(R.drawable.ic_drive_green)
        } else {
            BitmapDescriptorFactory.fromResource(R.drawable.ic_current_marker)
        }

        map.clear()
        val startMarkerOptions =
            MarkerOptions().position(
                LatLng(
                    SharedPreferenceUtils.getString(KEY_LATITUDE).toDouble(),
                    SharedPreferenceUtils.getString(
                        KEY_LONGITUDE
                    ).toDouble()
                )
            )
                .title("")
                .icon(driverIcon)

        map.addMarker(startMarkerOptions)

        map.positionCamera(
            LatLng(
                SharedPreferenceUtils.getString(KEY_LATITUDE).toDouble(),
                SharedPreferenceUtils.getString(
                    KEY_LONGITUDE
                ).toDouble()
            ), 16f, true
        )
    }

    fun clearMap() {
        map.clear()
        map.positionCamera(
            LatLng(
                SharedPreferenceUtils.getString(KEY_LATITUDE).toDouble(),
                SharedPreferenceUtils.getString(
                    KEY_LONGITUDE
                ).toDouble()
            ), 14f, true
        )
    }

    fun setPolyLines(orderDetails: OrderDetail) {
        orderDetail = orderDetails
        map.clear()
        if (orderDetails.storeDetail!!.isNotEmpty()) {

            //sorting add
            val waypointsList = ArrayList<LatLng>()
            for (i in orderDetails.storeDetail.indices) {
                waypointsList.add(
                    LatLng(
                        orderDetails.storeDetail[i].latitude!!.toDouble(),
                        orderDetails.storeDetail[i].longitude!!.toDouble()
                    )
                )

            }
            fetchRoute(
                SharedPreferenceUtils.getString(KEY_LATITUDE).toDouble(),
                SharedPreferenceUtils.getString(KEY_LONGITUDE).toDouble(),
                orderDetails.deliveryLatitude!!.toDouble(),
                orderDetails.deliveryLongitude!!.toDouble(),
                waypointsList
            )
        }

    }

    fun setPolyLinesMarket(orderDetails: OrderDetail) {
        orderDetail = orderDetails
        map.clear()
        if (orderDetails.storeDetail!!.isNotEmpty()) {

            //sorting add karvanu aiya for loop chale che

            val waypointsList = ArrayList<LatLng>()

            for (i in orderDetails.storeDetail.indices) {
                waypointsList.add(
                    LatLng(
                        orderDetails.storeDetail[i].latitude!!.toDouble(),
                        orderDetails.storeDetail[i].longitude!!.toDouble()
                    )
                )

                val restIcon = Utility.createDrawableNode((i + 1).toString())

                val startMarkerOptions =
                    MarkerOptions().position(
                        LatLng(
                            waypointsList[i].latitude,
                            waypointsList[i].longitude
                        )
                    )
                        .title("")
                        .icon(BitmapDescriptorFactory.fromBitmap(restIcon))


                map.addMarker(startMarkerOptions)
            }

            fetchRoute(
                SharedPreferenceUtils.getString(KEY_LATITUDE).toDouble(),
                SharedPreferenceUtils.getString(KEY_LONGITUDE).toDouble(),
                orderDetails.deliveryLatitude!!.toDouble(),
                orderDetails.deliveryLongitude!!.toDouble(),
                waypointsList
            )
        }

    }

    private fun fetchRoute(
        sourceLatitude: Double,
        sourceLongitude: Double,
        destinationLatitude: Double,
        destinationLongitude: Double,
        waypointsList: ArrayList<LatLng>
    ) {
        val path: MutableList<List<LatLng>> = ArrayList()
        homeViewModel.getMapRoute(
            "$sourceLatitude,$sourceLongitude",
            "$destinationLatitude,$destinationLongitude",
            mapFragment.context!!.resources.getString(
                R.string.mapApiKey
            ),
            waypointsList
        )
    }

    private fun drawRout(directionArray: GoogleMapDirection) {
        if (polyLine != null)
            polyLine?.remove()

        if (!directionArray.arrayListRouts.isNullOrEmpty()) {
            for (rout in directionArray.arrayListRouts) {
                val path = java.util.ArrayList<HashMap<String, String>>()
                for (legs in rout.arrayListLegs) {
                    for (steps in legs.arrayListSteps) {

                        listOfPoints = (decodePoly(steps.polyline.points!!))

                        for (latlng in listOfPoints) {
                            val hm = HashMap<String, String>()
                            hm["lat"] = latlng.latitude.toString()
                            hm["lng"] = latlng.longitude.toString()
                            path.add(hm)
                        }


                    }
                    arrayRoutes.add(path);
                }
            }
        }

        addPath(directionArray)
    }

    private fun addPath(directionArray: GoogleMapDirection) {

        for (routs in arrayRoutes) {

            lineOptions = PolylineOptions()

            for (path in routs) {

                val lat = path["lat"]?.toDouble()
                val lng = path["lng"]?.toDouble()
                val position = LatLng(lat!!, lng!!)
                lineOptions?.add(position)
            }
        }
        lineOptions?.width(15f)
        lineOptions?.color(ContextCompat.getColor(mapFragment.context!!, R.color.colorBlue))

        // Drawing polyline in the Google Map for the i-th route
        if (lineOptions != null) {
            polyLine = map.addPolyline(lineOptions)
            val bounds: LatLngBounds = LatLngBounds.Builder().apply {
                lineOptions!!.points.forEach { point -> include(point) }
            }.build()

            addAllMarkerPoint(directionArray)
            map.positionCamera(bounds, mapFragment.view?.width?.div(10) ?: 10, false)
        } else {
            Log.d("onPostExecute", "without Polylines drawn");
        }


    }

    private fun addAllMarkerPoint(directionArray: GoogleMapDirection) {
        if (isShowIcon) {
            driverIcon = BitmapDescriptorFactory.fromResource(R.drawable.ic_drive_green)
            customerIcon = BitmapDescriptorFactory.fromResource(R.drawable.ic_customer_red)
        } else {
            driverIcon = BitmapDescriptorFactory.fromResource(R.drawable.ic_marker_blue)
            customerIcon = BitmapDescriptorFactory.fromResource(R.drawable.ic_marker_blue)
        }

        val startMarkerOptions =
            MarkerOptions().position(
                LatLng(
                    SharedPreferenceUtils.getString(KEY_LATITUDE).toDouble(),
                    SharedPreferenceUtils.getString(KEY_LONGITUDE).toDouble()
                )
            )
                .title("")
                .icon(driverIcon)
        map.addMarker(startMarkerOptions)


        val infoMarker =
            map.addMarker(
                MarkerOptions().position(
                    LatLng(
                        orderDetail.deliveryLatitude!!.toDouble(),
                        orderDetail.deliveryLongitude!!.toDouble()
                    )
                ).icon(customerIcon)
            )

        val infoWindow = InfoWindow(
            directionArray.arrayListRouts[0].arrayListLegs[0].distance.text,
            directionArray.arrayListRouts[0].arrayListLegs[0].duration.text
        )
        val markerWindowView =
            CustomMarkerInfoWindowView(
                mapFragment.context!!
            )
        map.setInfoWindowAdapter(markerWindowView)
        infoMarker.tag = infoWindow
        infoMarker.showInfoWindow()


    }

    private fun decodePoly(encoded: String): java.util.ArrayList<LatLng> {
        val poly = java.util.ArrayList<LatLng>()
        var index = 0
        val len = encoded.length
        var lat = 0
        var lng = 0

        while (index < len) {
            var b: Int
            var shift = 0
            var result = 0
            do {
                b = encoded[index++].toInt() - 63
                result = result or (b and 0x1f shl shift)
                shift += 5
            } while (b >= 0x20)
            val dlat = if (result and 1 != 0) (result shr 1).inv() else result shr 1
            lat += dlat

            shift = 0
            result = 0
            do {
                b = encoded[index++].toInt() - 63
                result = result or (b and 0x1f shl shift)
                shift += 5
            } while (b >= 0x20)
            val dlng = if (result and 1 != 0) (result shr 1).inv() else result shr 1
            lng += dlng

            val p = LatLng(
                lat.toDouble() / 1E5,
                lng.toDouble() / 1E5
            )
            poly.add(p)
        }

        return poly
    }
}

fun GoogleMap.positionCamera(location: LatLng, zoom: Float = 18f, animate: Boolean = true) {
    val cameraPosition = CameraPosition.fromLatLngZoom(location, zoom)
    val update = CameraUpdateFactory.newCameraPosition(cameraPosition)
    moveCamera(update, animate)
}

fun GoogleMap.positionCamera(bounds: LatLngBounds, padding: Int, animate: Boolean = true) {
    val update = CameraUpdateFactory.newLatLngBounds(bounds, padding)
    moveCamera(update, animate)
}

private fun GoogleMap.moveCamera(cameraUpdate: CameraUpdate, animate: Boolean = true) {
    if (animate) {
        this.animateCamera(cameraUpdate)
    } else {
        this.moveCamera(cameraUpdate)
    }


}