package com.quedrop.customer.ui.addaddress.view

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.os.Build
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.RelativeLayout
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.AddAddress
import com.quedrop.customer.model.EditAddress
import com.quedrop.customer.ui.addaddress.viewmodel.AddAddressViewModel
import com.quedrop.customer.utils.BitmapUtils
import com.quedrop.customer.utils.ConstantUtils
import com.quedrop.customer.utils.Utils
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
import com.google.android.libraries.places.api.model.Place
import kotlinx.android.synthetic.main.fragment_location_picker.*


class LocationPickerFragment : BaseFragment(), OnMapReadyCallback,
    GoogleApiClient.ConnectionCallbacks,
    GoogleApiClient.OnConnectionFailedListener, LocationListener, GoogleMap.OnMarkerDragListener {


    private var mMap: GoogleMap? = null
    var mLastLocation: Location? = null
    private var mCurrLocationMarker: Marker? = null
    private var selectedPlace: Place? = null
    var latitude: String? = null
    var longitude: String? = null
    var areaAddress: String? = null
    var addressType: String = ConstantUtils.ONE.toString()
    private lateinit var addAddressViewModel: AddAddressViewModel
    private var mapView: View? = null
    var addressTitle:String?=null
    var unitNumber:String?=null
    var address:String?=null

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {


        return inflater.inflate(
            R.layout.fragment_location_picker,
            container, false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val mapFragment = childFragmentManager.findFragmentById(R.id.googleMap) as SupportMapFragment
        mapView = mapFragment.view
        mapFragment.getMapAsync(this)
        initMethod()

    }


    private fun initMethod() {

        addAddressViewModel = (activity as AddAddressActivity).addAddressViewModel
        val addressId = (activity as AddAddressActivity).addressId
        addressTitle = (activity as AddAddressActivity).addressTitle
        latitude = (activity as AddAddressActivity).latitude
        longitude = (activity as AddAddressActivity).longitude
        unitNumber = (activity as AddAddressActivity).unitNumber
        val addressType = (activity as AddAddressActivity).addressType
        address = (activity as AddAddressActivity).address
        val editFlag = (activity as AddAddressActivity).editFlag


        setCurrentLocation(address, addressTitle, unitNumber)

        latitude = latitude
        longitude = longitude

        when (addressType) {

            resources.getString(R.string.home) -> {
                addressTypeOneClick()
            }
            resources.getString(R.string.work) -> {

                addressTypeTwoClick()
            }
            resources.getString(R.string.hotel) -> {
                addressTypeThreeClick()

            }
            resources.getString(R.string.other) -> {
                addressTypeFourClick()
            }
            else -> {
                addressTypeOneClick()
            }

        }


        (activity as AddAddressActivity).showPlaceSearchFragment(false, Utils.textAddress)
        textAddressMain.throttleClicks().subscribe {

            Utils.textAddress = textAddressMain.text.toString()
            (activity as AddAddressActivity).showPlaceSearchFragment(true, Utils.textAddress)
        }.autoDispose(compositeDisposable)


        btnConfirm.throttleClicks().subscribe() {
            viewInfoDialog.visibility = View.VISIBLE
            btnSaveAddress.visibility = View.VISIBLE
            btnConfirm.visibility = View.GONE
        }.autoDispose(compositeDisposable)

        clearText.throttleClicks().subscribe {

            textAddressMain.text = ""
        }.autoDispose(compositeDisposable)

        clearInfo.throttleClicks().subscribe {
            editInfo.setText("")
        }.autoDispose(compositeDisposable)

        clearAddressUnitNumber.throttleClicks().subscribe {

            editAddressUnitNumber.setText("")
        }.autoDispose(compositeDisposable)

        clearAddressName.throttleClicks().subscribe {

            editAddressName.setText("")
        }.autoDispose(compositeDisposable)

        ivHomeIcon.throttleClicks().subscribe {

            addressTypeOneClick()
        }.autoDispose(compositeDisposable)

        ivBusinessIcon.throttleClicks().subscribe {

            addressTypeTwoClick()
        }.autoDispose(compositeDisposable)

        ivSunumbrellaIcon.throttleClicks().subscribe {

            addressTypeThreeClick()
        }.autoDispose(compositeDisposable)

        ivPlaceHolderIcon.throttleClicks().subscribe {

            addressTypeFourClick()
        }.autoDispose(compositeDisposable)

        viewInfoDialog.throttleClicks().subscribe() {

        }.autoDispose(compositeDisposable)

        btnSaveAddress.throttleClicks().subscribe {
            if (editFlag) {

                editAddressApi(
                    addressId.toInt()
                )

            } else {
                addAddressApi()
            }

        }.autoDispose(compositeDisposable)

        observeViewModel()
    }

    private fun setCurrentLocation(
        address: String?,
        addressTitle: String?,
        unitNumber: String?
    ) {

        if (textAddressMain != null) {
            textAddressMain.text = address
        }
        if (editAddressName != null) {
            editAddressName.setText(addressTitle)
        }
        if (editInfo != null) {
            editInfo.setText(address)
        }
        if (editAddressUnitNumber != null) {
            editAddressUnitNumber.setText(unitNumber)
        }

    }


    private fun addressTypeOneClick() {
        imageUnpress()
        ivHomeIcon.setImageResource(R.drawable.home_press)
        addressType = ConstantUtils.ONE.toString()
    }

    private fun addressTypeTwoClick() {
        imageUnpress()
        ivBusinessIcon.setImageResource(R.drawable.briefcase_press)
        addressType = ConstantUtils.TWO.toString()
    }

    private fun addressTypeThreeClick() {
        imageUnpress()
        ivSunumbrellaIcon.setImageResource(R.drawable.sunumbrella_press)
        addressType = ConstantUtils.THREE.toString()
    }

    private fun addressTypeFourClick() {
        imageUnpress()
        ivPlaceHolderIcon.setImageResource(R.drawable.placeholder_press)
        addressType = ConstantUtils.FOUR.toString()
    }

    private fun imageUnpress() {
        ivHomeIcon.setImageResource(R.drawable.home_unpress)
        ivBusinessIcon.setImageResource(R.drawable.briefcase_unpress)
        ivSunumbrellaIcon.setImageResource(R.drawable.sunumbrella_unpress)
        ivPlaceHolderIcon.setImageResource(R.drawable.placeholder_unpress)

    }

    override fun onMapReady(p0: GoogleMap?) {
        mMap = p0

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
            layoutParams.setMargins(0, 250, 0, 0)

            locationButton.layoutParams = layoutParams

            locationButton.setOnClickListener {
                setMarker()
            }
        }



        mMap!!.setOnMapClickListener {
            viewInfoDialog.visibility = View.GONE
            btnConfirm.visibility = View.VISIBLE
            btnSaveAddress.visibility = View.GONE
        }

        mMap!!.setOnMarkerDragListener(this)

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

    override fun onConnected(p0: Bundle?) {
        val mLocationRequest = LocationRequest()
        mLocationRequest.interval = ConstantUtils.VALUE_1000.toLong()
        mLocationRequest.fastestInterval = ConstantUtils.VALUE_1000.toLong()
        mLocationRequest.priority = LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY

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

    override fun onLocationChanged(p0: Location?) {

        mLastLocation = p0

        mCurrLocationMarker?.remove()

        val latLng = LatLng(latitude!!.toDouble(), longitude!!.toDouble())
        val markerOptions = MarkerOptions().draggable(true)
        markerOptions.position(latLng)
        markerOptions.icon(BitmapUtils.iconMap)
        mCurrLocationMarker = mMap!!.addMarker(markerOptions)

        mMap!!.moveCamera(CameraUpdateFactory.newLatLng(latLng))
        mMap!!.animateCamera(CameraUpdateFactory.zoomTo(ConstantUtils.VALUE_15))


        if (mGoogleApiClient != null) {
            LocationServices.FusedLocationApi.removeLocationUpdates(mGoogleApiClient, this)
        }

    }


    private fun setMarker() {
        mCurrLocationMarker?.remove()

        val latLng = LatLng(latitude!!.toDouble(), longitude!!.toDouble())
        val markerOptions = MarkerOptions().draggable(true)
        markerOptions.position(latLng)
        markerOptions.icon(BitmapUtils.iconMap)
        mCurrLocationMarker = mMap!!.addMarker(markerOptions)

        mMap!!.moveCamera(CameraUpdateFactory.newLatLng(latLng))
        mMap!!.animateCamera(CameraUpdateFactory.zoomTo(ConstantUtils.VALUE_15))

        setCurrentLocation(address, addressTitle, unitNumber)

        if (mGoogleApiClient != null) {
            LocationServices.FusedLocationApi.removeLocationUpdates(mGoogleApiClient, this)
        }
    }


    override fun onMarkerDragEnd(p0: Marker?) {

        textAddressMain.text = Utils.getCompleteAddressString(
            activity, p0?.position?.latitude!!,
            p0.position?.longitude!!
        )
        editInfo.setText(
            Utils.getCompleteAddressString(
                activity, p0.position?.latitude!!,
                p0.position?.longitude!!
            )
        )

        editAddressName.setText(
            Utils.getCompleteAddressName(
                activity, p0.position?.latitude!!,
                p0.position?.longitude!!
            )
        )
    }

    override fun onMarkerDragStart(p0: Marker?) {

    }

    override fun onMarkerDrag(p0: Marker?) {

    }


    fun updateData(place: Place) {

        if (Utils.isKeyboardShown(activity, constraintLocationPicker)) {

        } else {
        }

        selectedPlace = place

        textAddressMain.text = selectedPlace!!.address.toString()
        editAddressName.setText(selectedPlace!!.name.toString())
        latitude = selectedPlace!!.latLng!!.latitude.toString()
        longitude = selectedPlace!!.latLng!!.longitude.toString()
        editInfo.setText(selectedPlace!!.address.toString())

        val latLng = LatLng(latitude!!.toDouble(), longitude!!.toDouble())

        if (mCurrLocationMarker != null) {
            mCurrLocationMarker?.remove()
            mCurrLocationMarker = null
        }

        val markerOptions = MarkerOptions()
        markerOptions.position(latLng)
        markerOptions.icon(BitmapUtils.iconMap)
        mCurrLocationMarker = mMap!!.addMarker(markerOptions)

        mMap!!.moveCamera(CameraUpdateFactory.newLatLng(latLng))
        mMap!!.animateCamera(CameraUpdateFactory.zoomTo(ConstantUtils.VALUE_15))


        if (mGoogleApiClient != null) {
            LocationServices.FusedLocationApi.removeLocationUpdates(mGoogleApiClient, this)
        }
    }

    private fun observeViewModel() {

        addAddressViewModel.addressListEdit.observe(viewLifecycleOwner, Observer {
            (activity as AddAddressActivity).hideProgress()
            val intent = Intent()
            activity.setResult(ConstantUtils.REQUEST_CODE_EDITADDRESS, intent)
            activity.finish()
        })

        addAddressViewModel.addressListAdd.observe(viewLifecycleOwner, Observer {
            (activity as AddAddressActivity).hideProgress()
            val intent = Intent()
            activity.setResult(ConstantUtils.REQUEST_CODE_ADDRESS, intent)
            activity.finish()
        })

        addAddressViewModel.errorMessage.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (activity as AddAddressActivity).hideProgress()
            Toast.makeText(
                context,
                it,
                Toast.LENGTH_SHORT
            ).show()
        })
    }

    private fun getAddAddress(): AddAddress {
        return AddAddress(
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId,
            editAddressName.text.toString(),
            latitude.toString(),
            longitude.toString(),
            editInfo.text.toString(),
            addressType,
            editInfo.text.toString(),
            editAddressUnitNumber.text.toString(),
            Utils.guestId
        )
    }

    private fun getEditAddress(id: Int?): EditAddress {
        return EditAddress(
            Utils.seceretKey,
            Utils.accessKey,
            id!!,
            Utils.userId,
            editAddressName.text.toString(),
            latitude.toString(),
            longitude.toString(),
            editInfo.text.toString(),
            addressType,
            editInfo.text.toString(),
            Utils.is_default,
            editAddressUnitNumber.text.toString(),
            Utils.guestId
        )
    }

    private fun addAddressApi() {

        if (editInfo.text.isNullOrBlank()) {
            Toast.makeText(
                activity,
                resources.getString(R.string.editAddressBlank),
                Toast.LENGTH_SHORT
            ).show()
        } else if (editAddressName.text.isNullOrBlank()) {
            Toast.makeText(
                activity,
                resources.getString(R.string.editAddressNameBlank),
                Toast.LENGTH_SHORT
            ).show()
        } else {
            (activity as AddAddressActivity).showProgress()
            addAddressViewModel.getAddAddressApi(getAddAddress())
        }
    }


    private fun editAddressApi(
        id: Int?
    ) {
        if (editInfo.text.isNullOrBlank()) {
            Toast.makeText(
                activity,
                resources.getString(R.string.editAddressBlank),
                Toast.LENGTH_SHORT
            ).show()
        } else if (editAddressName.text.isNullOrBlank()) {
            Toast.makeText(
                activity,
                resources.getString(R.string.editAddressNameBlank),
                Toast.LENGTH_SHORT
            ).show()
        } else {
            (activity as AddAddressActivity).showProgress()
            addAddressViewModel.getEditAddressApi(getEditAddress(id!!))
        }
    }

}