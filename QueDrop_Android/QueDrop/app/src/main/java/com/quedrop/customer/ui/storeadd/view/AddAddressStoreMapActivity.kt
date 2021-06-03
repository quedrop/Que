package com.quedrop.customer.ui.storeadd.view

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.RelativeLayout
import androidx.core.content.ContextCompat
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
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
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.MarkerOptions
import kotlinx.android.synthetic.main.activity_add_address_store_map.*


class AddAddressStoreMapActivity : BaseActivity(), OnMapReadyCallback,
    GoogleApiClient.ConnectionCallbacks,
    GoogleApiClient.OnConnectionFailedListener, LocationListener, GoogleMap.OnMarkerDragListener {

    private var mMap: GoogleMap? = null
    private lateinit var mGoogleApiClient: GoogleApiClient
    private var mLastLocation: Location? = null
    private var mCurrLocationMarker: Marker? = null
    private var placeAddressId: String? = null
    private var placeAddressTitle: String? = null
    private var placeAddressAddress: String? = null
    private var currentLocationLatitude: Double = 0.0
    private var currentLocationLongitude: Double = 0.0
    private var placeAddressLatitude: Double = 0.0
    var placeAddressLongitude: Double = 0.0
    private var mapView: View? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_address_store_map)
        showProgress()
        initMethod()
        onClickMethod()
    }

    private fun initMethod() {

        val mapFragment =
            supportFragmentManager.findFragmentById(R.id.googleMapAddStore) as SupportMapFragment

        mapView = mapFragment.view
        mapFragment.getMapAsync(this)

    }

    private fun onClickMethod() {

        ivCrossStore.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        tvStoreAddressPlaceStore.throttleClicks().subscribe {
            val intent = Intent(this, PlaceAutoCompleteSearchActivity::class.java)
            startActivityForResult(intent, ConstantUtils.REQUEST_PLACE_ADD)
        }.autoDispose(compositeDisposable)

        ivClearStore.throttleClicks().subscribe {
            tvStoreAddressPlaceStore.text = ""
        }.autoDispose(compositeDisposable)
    }


    override fun onMapReady(p0: GoogleMap?) {
        mMap = p0


        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(
                    applicationContext,
                    Manifest.permission.ACCESS_FINE_LOCATION
                )
                == PackageManager.PERMISSION_GRANTED
            ) {
                buildGoogleApiClient()
                mMap!!.isMyLocationEnabled = true
            }
        } else {
            buildGoogleApiClient()
            mMap!!.isMyLocationEnabled = true
        }

        if (mapView != null && mapView?.findViewById<View>(Integer.parseInt("1")) != null) {

            // Get the button view
            val locationButton: View =
                (mapView!!.findViewById<View>(Integer.parseInt("1")).parent as View).findViewById(
                    Integer.parseInt("2")
                )

            // and next place it, on bottom right (as Google Maps app)
            val layoutParams = locationButton.layoutParams as RelativeLayout.LayoutParams

            // position on right bottom
            layoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP, 0)
            layoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT, 0)
            layoutParams.setMargins(0, 20, 0, 0)

            locationButton.layoutParams = layoutParams

            locationButton.setOnClickListener {
                setMarker()
            }
        }

        mMap!!.setOnMarkerDragListener(this)

    }


    private fun setMarker() {
        mCurrLocationMarker?.remove()

        val latLng =
            LatLng(currentLocationLatitude.toDouble(), currentLocationLongitude.toDouble())
        val markerOptions = MarkerOptions().draggable(true)
        markerOptions.position(latLng)
        markerOptions.icon(BitmapUtils.icon_pin_press)
        mCurrLocationMarker = mMap!!.addMarker(markerOptions)

        mMap!!.moveCamera(CameraUpdateFactory.newLatLng(latLng))
        mMap!!.animateCamera(CameraUpdateFactory.zoomTo(ConstantUtils.VALUE_15))

        placeAddressLatitude = currentLocationLatitude
        placeAddressLongitude = currentLocationLongitude
        placeAddressAddress =
            Utils.getCompleteAddressString(
                applicationContext,
                placeAddressLatitude,
                placeAddressLongitude
            )
        placeAddressTitle =
            Utils.getCompleteAddressName(
                applicationContext,
                placeAddressLatitude,
                placeAddressLongitude
            )

        if (placeAddressTitle.isNullOrBlank()) {
            placeAddressTitle = placeAddressAddress
        }
        setAddress(placeAddressLatitude, placeAddressLongitude)

        if (mGoogleApiClient != null) {
            LocationServices.FusedLocationApi.removeLocationUpdates(mGoogleApiClient, this)
        }
    }

    @Synchronized
    private fun buildGoogleApiClient() {
        mGoogleApiClient = GoogleApiClient.Builder(applicationContext)
            .addConnectionCallbacks(this)
            .addOnConnectionFailedListener(this)
            .addApi(LocationServices.API).build()
        mGoogleApiClient.connect()
    }

    override fun onConnected(p0: Bundle?) {
        val mLocationRequest = LocationRequest()
        mLocationRequest.interval = ConstantUtils.VALUE_1000.toLong()
        mLocationRequest.fastestInterval = ConstantUtils.VALUE_1000.toLong()
        mLocationRequest.priority = LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY

        if (ContextCompat.checkSelfPermission(
                applicationContext,
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

    override fun onLocationChanged(p0: Location?) {
        mLastLocation = p0

        mCurrLocationMarker?.remove()

        hideProgress()

        currentLocationLatitude = p0!!.latitude
        currentLocationLongitude = p0.longitude

        val latLng = LatLng(p0.latitude, p0.longitude)
        val markerOptions = MarkerOptions().draggable(true)
        markerOptions.position(latLng)
        markerOptions.icon(BitmapUtils.icon_pin_press)
        mCurrLocationMarker = mMap!!.addMarker(markerOptions)

        mMap!!.moveCamera(CameraUpdateFactory.newLatLng(latLng))
        mMap!!.animateCamera(CameraUpdateFactory.zoomTo(ConstantUtils.VALUE_15))

        if (mGoogleApiClient != null) {
            LocationServices.FusedLocationApi.removeLocationUpdates(mGoogleApiClient, this)
        }



        placeAddressLatitude = p0.latitude
        placeAddressLongitude = p0.longitude
        placeAddressAddress =
            Utils.getCompleteAddressString(applicationContext, p0.latitude, p0.longitude)
        placeAddressTitle =
            Utils.getCompleteAddressName(applicationContext, p0.latitude, p0.longitude)

        if (placeAddressTitle.isNullOrBlank()) {
            placeAddressTitle = placeAddressAddress
        }

        //setAddress(placeAddressLatitude, placeAddressLongitude)

        mMap!!.setOnMarkerClickListener {


            val intent = intent
            intent.putExtra(KeysUtils.keyPlaceId, placeAddressId)
            intent.putExtra(KeysUtils.keyPlaceTitle, placeAddressTitle)
            intent.putExtra(KeysUtils.keyPlaceAddress, placeAddressAddress)
            intent.putExtra(KeysUtils.keyPlaceLatitude, placeAddressLatitude)
            intent.putExtra(KeysUtils.keyPlaceLongitude, placeAddressLongitude)
            setResult(Activity.RESULT_OK, intent)
            finish()

            return@setOnMarkerClickListener true

        }

    }

    private fun setAddress(latitude: Double, longitude: Double) {
        tvStoreAddressPlaceStore.text = Utils.getCompleteAddressString(
            applicationContext, latitude,
            longitude
        )
    }

    override fun onMarkerDragEnd(p0: Marker?) {

        tvStoreAddressPlaceStore.text = Utils.getCompleteAddressString(
            applicationContext, p0?.position?.latitude!!,
            p0.position?.longitude!!
        )

        placeAddressLatitude = p0.position?.latitude!!
        placeAddressLongitude = p0.position?.longitude!!
        placeAddressAddress =
            Utils.getCompleteAddressString(
                applicationContext,
                p0.position?.latitude!!,
                p0.position?.longitude!!
            )
        placeAddressTitle =
            Utils.getCompleteAddressName(applicationContext, p0.position?.latitude!!,
                p0.position?.longitude!!)

        if (placeAddressTitle.isNullOrBlank()) {
            placeAddressTitle = placeAddressAddress
        }

    }

    override fun onMarkerDragStart(p0: Marker?) {

    }

    override fun onMarkerDrag(p0: Marker?) {

    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == ConstantUtils.REQUEST_PLACE_ADD && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                placeAddressId = data.getStringExtra(KeysUtils.keyPlaceId)
                placeAddressTitle = data.getStringExtra(KeysUtils.keyPlaceTitle)
                placeAddressAddress = data.getStringExtra(KeysUtils.keyPlaceAddress)
                placeAddressLatitude = data.getDoubleExtra(KeysUtils.keyPlaceLatitude, 0.0)
                placeAddressLongitude = data.getDoubleExtra(KeysUtils.keyPlaceLongitude, 0.0)

                tvStoreAddressPlaceStore.text = placeAddressTitle

                mCurrLocationMarker?.remove()

                val latLng =
                    LatLng(placeAddressLatitude.toDouble(), placeAddressLongitude.toDouble())
                val markerOptions = MarkerOptions().draggable(true)
                markerOptions.position(latLng)
                markerOptions.icon(BitmapUtils.icon_pin_press)
                mCurrLocationMarker = mMap!!.addMarker(markerOptions)

                mMap!!.moveCamera(CameraUpdateFactory.newLatLng(latLng))
                mMap!!.animateCamera(CameraUpdateFactory.zoomTo(ConstantUtils.VALUE_15))


                if (mGoogleApiClient != null) {
                    LocationServices.FusedLocationApi.removeLocationUpdates(mGoogleApiClient, this)
                }
            }
        }
    }





}
