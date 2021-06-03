package com.quedrop.customer.ui.nearby.view

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.os.Build
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import com.android.volley.Request
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.quedrop.customer.R
import com.quedrop.customer.ui.storewithproduct.view.StoreDetailsActivity
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.model.*
import com.quedrop.customer.utils.*
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.api.GoogleApiClient
import com.google.android.gms.location.LocationListener
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.*
import com.google.android.libraries.places.api.model.Place
import org.json.JSONObject

import com.google.maps.android.PolyUtil


open class MapCustomerNearByFragment : BaseFragment(), OnMapReadyCallback,
    GoogleApiClient.ConnectionCallbacks,
    GoogleApiClient.OnConnectionFailedListener, LocationListener {

    private var mMap: GoogleMap? = null
    var supportMapFragment: Fragment? = null
    var mLastLocation: Location? = null
    private var mCurrLocationMarker: Marker? = null
    private var selectedPlace: Place? = null
    var latitude: String? = null
    var longitude: String? = null
    var areaAddress: String? = null
    var addressType: String = ConstantUtils.ONE.toString()
    var searchString: String? = null
    var markerWindowView: CustomMarkerInfoWindowView? = null
    var markerWindowViewPoly: CustomMarkerInfoWindowViewForPoly? = null
    var routeOptions: PolylineOptions? = null
    var latitude_mid: String? = null
    var longitude_mid: String? = null


    var arrayListNearBy: MutableList<NearByStores>? = null
    var id: Int? = null
    var name: String? = null
    var kmVariable: String? = null
    var timeVariable: String? = null
    var freshProduceCatId: Int? = 0


    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        id = arguments?.getInt(KeysUtils.KeyServiceCategoryId)
        name = arguments?.getString(KeysUtils.KeyServiceCategoryName)
        searchString = arguments?.getString(KeysUtils.KeyStringSearch)
        freshProduceCatId = arguments?.getInt(KeysUtils.KeyFreshProduceCategoryId, 0)

        return inflater.inflate(
            R.layout.fragment_map_customer_near,
            container, false
        )
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        observeViewModel()

        (activity as NearByRestaurantActivity).showProgress()
        if (supportMapFragment == null) {
            supportMapFragment =
                childFragmentManager.findFragmentById(R.id.mapView) as SupportMapFragment

            (supportMapFragment as SupportMapFragment).getMapAsync(this)
        }

        arrayListNearBy = mutableListOf()

        if ((activity as NearByRestaurantActivity).flagSearchClick) {
            if (searchString!!.isEmpty()) {

                getNearByStoresApi()

            } else {

                searchStoreApi()
            }
        } else {

            getNearByStoresApi()
        }


    }

    private lateinit var mGoogleApiClient: GoogleApiClient

    @Synchronized
    private fun buildGoogleApiClient() {
        mGoogleApiClient = GoogleApiClient.Builder(activity)
            .addConnectionCallbacks(this)
            .addOnConnectionFailedListener(this)
            .addApi(LocationServices.API).build()
        mGoogleApiClient.connect()
    }

    override fun onMapReady(p0: GoogleMap?) {
        mMap = p0

        (activity as NearByRestaurantActivity).hideProgress()
        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(
                    activity,
                    Manifest.permission.ACCESS_FINE_LOCATION
                )
                == PackageManager.PERMISSION_GRANTED
            ) {
                buildGoogleApiClient()
                mMap!!.isMyLocationEnabled = true
            }
        } else {
            buildGoogleApiClient();
            mMap!!.isMyLocationEnabled = true
        }
    }

    override fun onConnected(p0: Bundle?) {
        val mLocationRequest = LocationRequest()
        mLocationRequest.interval = ConstantUtils.VALUE_1000.toLong()
        mLocationRequest.fastestInterval = ConstantUtils.VALUE_1000.toLong()
        mLocationRequest.priority = LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY

        if (context == null) {
            return
        }

        if (ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            LocationServices.FusedLocationApi.requestLocationUpdates(
                mGoogleApiClient,
                mLocationRequest,
                this
            )
        }
    }

    override fun onConnectionSuspended(p0: Int) {

    }

    override fun onConnectionFailed(p0: ConnectionResult) {

    }

    var isPolylineAdded = false
    var prevPolyline = ""
    var line: Polyline? = null

    override fun onLocationChanged(p0: Location?) {
        mLastLocation = p0

        mCurrLocationMarker?.remove()

        if (context == null) {
            return
        }


        val latLng = LatLng(Utils.keyLatitude.toDouble(), Utils.keyLongitude.toDouble())
        val markerOptions = MarkerOptions()
        markerOptions.position(latLng)
//        markerOptions.icon(BitmapUtils.icon_home)
        markerOptions.icon(BitmapUtils.icon_pin_press)
        markerOptions.snippet(activity.resources.getString(R.string.current))
        mCurrLocationMarker = mMap!!.addMarker(markerOptions)

        mMap!!.moveCamera(CameraUpdateFactory.newLatLng(latLng))
        mMap!!.animateCamera(CameraUpdateFactory.zoomTo(ConstantUtils.VALUE_11))


        if (mGoogleApiClient != null) {
            LocationServices.FusedLocationApi.removeLocationUpdates(mGoogleApiClient, this)
        }

        mMap!!.setOnMapClickListener {
            addMarker()
            mMap!!.setInfoWindowAdapter(null)
            line?.remove()
            isPolylineAdded = false
        }

        mMap!!.setOnMarkerClickListener {


            when {
                it.snippet == activity.resources.getString(R.string.title) -> return@setOnMarkerClickListener true
                it.snippet == activity.resources.getString(R.string.current) -> return@setOnMarkerClickListener true
                else -> {
                    addMarker()

                    var position1: String = it.snippet

                    var latitude = it?.position?.latitude
                    var longitude = it?.position?.longitude
                    //            addMarker()
                    //createMarker(latitude!!, longitude!!,position1.toInt())

                    if (prevPolyline != position1) {
                        it.hideInfoWindow()
                        mMap!!.setInfoWindowAdapter(null)
                        line?.remove()
                        isPolylineAdded = false

                    }


                    //                if (!isPolylineAdded) {
                    //
                    //                    createMarkerSelected(latitude!!, longitude!!, position1.toInt())
                    //
                    //                    line?.remove()
                    //
                    //
                    //
                    //                    isPolylineAdded = true
                    //                    prevPolyline = it.snippet
                    //                } else {


                    line?.remove()
                    createMarkerSelected(latitude!!, longitude!!, position1.toInt())

                    fetchRoute(
                        Utils.keyLatitude.toDouble(), Utils.keyLongitude.toDouble(),
                        latitude, longitude, position1.toInt(), it
                    )

                    return@setOnMarkerClickListener false
                }
            }
        }


        mMap!!.setOnInfoWindowClickListener {

            var info: InfoWindow = it?.tag as InfoWindow

            var intentStore = Intent(context, StoreDetailsActivity::class.java)
            intentStore.putExtra(KeysUtils.keyStoreId, info.storeId)
            startActivityWithDefaultAnimations(intentStore)
        }

    }

    private fun observeViewModel() {
        (activity as NearByRestaurantActivity).listNearByViewModel.errorMessage.observe(
            viewLifecycleOwner,
            Observer {
                (activity as NearByRestaurantActivity).hideProgress()
//                Toast.makeText(
//                    activity,
//                    it,
//                    Toast.LENGTH_SHORT
//                ).show()
            })
        (activity as NearByRestaurantActivity).listNearByViewModel.arrayListNearBy.observe(
            viewLifecycleOwner,
            Observer {
                (activity as NearByRestaurantActivity).hideProgress()
                arrayListNearBy?.clear()
                arrayListNearBy?.addAll(it.toMutableList())
                if (mMap != null) {
                    addMarker()
                }


            })
    }

    private fun getAddNearByStore(latitude: String, longitude: String): AddNearByStores {

        return AddNearByStores(
            Utils.seceretKey,
            Utils.accessKey,
            this.id!!,
            latitude,
            longitude
        )
    }

    private fun getSearchStoreByName(): SearchStoreByName {
        return SearchStoreByName(
            Utils.seceretKey,
            Utils.accessKey,
            this.searchString!!,
            this.id!!,
            this.freshProduceCatId!!
        )

    }

    private fun getNearByStoresApi() {

        (activity as NearByRestaurantActivity).showProgress()

        var latitude = SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeyLatitude)
        var longitude =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeyLongitude)

        (activity as NearByRestaurantActivity).listNearByViewModel.getNearByStoreApi(
            getAddNearByStore(Utils.keyLatitude, Utils.keyLongitude)
        )
    }

    private fun searchStoreApi() {
        (activity as NearByRestaurantActivity).showProgress()

        (activity as NearByRestaurantActivity).listNearByViewModel.getSearchStoreApi(
            getSearchStoreByName()
        )
    }


    private fun addMarker() {

        if (arrayListNearBy!!.size > 0) {
            for ((i, item) in arrayListNearBy!!.withIndex()) {
                createMarker(
                    arrayListNearBy!![i].latitude.toDouble(),
                    arrayListNearBy!![i].longitude.toDouble(),
                    i
                )
            }
        }
    }

    private fun createMarker(latitude: Double, longitude: Double, pos: Int): Marker {
        return mMap!!.addMarker(
            MarkerOptions().position(LatLng(latitude, longitude))
                .anchor(0.5f, 0.2f)
                .snippet(pos.toString())
                .icon(BitmapDescriptorFactory.fromResource(R.drawable.ic_pin))
        )

    }

    private fun createMarkerSelected(latitude: Double, longitude: Double, pos: Int): Marker {
        return mMap!!.addMarker(
            MarkerOptions().position(LatLng(latitude, longitude))
                .anchor(0.5f, 0.2f)
                .snippet(pos.toString())
                .icon(BitmapDescriptorFactory.fromResource(R.drawable.ic_pin_press))
        )
    }

    private fun fetchRoute(
        sourceLatitude: Double,
        sourceLongitude: Double,
        destinationLatitude: Double,
        destinationLongitude: Double,
        pos: Int, marker: Marker
    ) {
        val path: MutableList<List<LatLng>> = ArrayList()
        val urlDirections =
            activity.resources.getString(R.string.urlDirection) + "origin=" + sourceLatitude + "," + sourceLongitude +
                    "&destination=" + destinationLatitude + "," + destinationLongitude +
                    "&key=" + activity.resources.getString(
                R.string.mapApiKey
            )
        val directionsRequest = object : StringRequest(
            Request.Method.GET,
            urlDirections,
            com.android.volley.Response.Listener<String> { response ->
                val jsonResponse = JSONObject(response)
                // Get routes
                val routes = jsonResponse.getJSONArray("routes")
                val legs = routes.getJSONObject(0).getJSONArray("legs")
                val steps = legs.getJSONObject(0).getJSONArray("steps")
                var jDistance = (legs.get(0) as JSONObject).getJSONObject("distance")
                var jDuration = (legs.get(0) as JSONObject).getJSONObject("duration")

                for (i in 0 until steps.length()) {

                    val points =
                        steps.getJSONObject(i).getJSONObject("polyline").getString("points")
                    if ((i + 1) == (steps.length() / 2) + 1) {
                        val endLocation: JSONObject =
                            steps.getJSONObject(i + 1).getJSONObject("end_location")
                        latitude_mid = endLocation.getString("lat")
                        longitude_mid = endLocation.getString("lng")
                    }
                    path.add(PolyUtil.decode(points))
                }
                line?.remove()
                routeOptions = PolylineOptions()
                for (i in 0 until path.size) {

                    routeOptions!!.addAll(path[i]).width(10f).color(
                        ContextCompat.getColor(activity, R.color.colorBlue)
                    )

                }
                line = mMap!!.addPolyline(routeOptions)
                line?.isClickable = true

                kmVariable = jDistance.getString("text")
                timeVariable = jDuration.getString("text")

                if (arrayListNearBy!!.size > 0) {


                    if (arrayListNearBy?.get(pos)?.schedule.isNullOrEmpty()) {
                        var info = InfoWindow(
                            arrayListNearBy?.get(pos)?.store_id!!,
                            arrayListNearBy?.get(pos.toInt())?.store_logo!!,
                            arrayListNearBy?.get(pos.toInt())?.store_name!!,
                            arrayListNearBy?.get(pos.toInt())?.store_address!!,
                            this.kmVariable!!,
                            this.timeVariable!!,
                            arrayListNearBy?.get(pos.toInt())?.latitude!!,
                            arrayListNearBy?.get(pos.toInt())?.longitude!!,
                            arrayListOf()
                        )
                        markerWindowView =
                            CustomMarkerInfoWindowView(activity)
                        mMap!!.setInfoWindowAdapter(markerWindowView)
                        marker.tag = info
                        marker.showInfoWindow()
                    } else {
                        var info = InfoWindow(
                            arrayListNearBy?.get(pos)?.store_id!!,
                            arrayListNearBy?.get(pos.toInt())?.store_logo!!,
                            arrayListNearBy?.get(pos.toInt())?.store_name!!,
                            arrayListNearBy?.get(pos.toInt())?.store_address!!,
                            this.kmVariable!!,
                            this.timeVariable!!,
                            arrayListNearBy?.get(pos.toInt())?.latitude!!,
                            arrayListNearBy?.get(pos.toInt())?.longitude!!,
                            arrayListNearBy?.get(pos)?.schedule!!

                        )
                        markerWindowView =
                            CustomMarkerInfoWindowView(activity)
                        mMap!!.setInfoWindowAdapter(markerWindowView)
                        marker.tag = info
                        marker.showInfoWindow()
                    }

                }


            },
            com.android.volley.Response.ErrorListener { _ ->
            }) {}
        val requestQueue = Volley.newRequestQueue(context)
        requestQueue.add(directionsRequest)
    }


    fun showInfoWindowForPoly(
        distance: String,
        time: String,
        latitude_mid: String,
        longitude_mid: String,
        marker: Marker
    ) {
        var info12 = InfoWindowForPoly(
            distance,
            time,
            latitude_mid,
            longitude_mid

        )
        markerWindowViewPoly =
            CustomMarkerInfoWindowViewForPoly(activity)
        mMap!!.setInfoWindowAdapter(markerWindowViewPoly)
        marker.tag = info12
        marker.showInfoWindow()
    }
}