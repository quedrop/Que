package com.quedrop.customer.ui.selectaddress.view

import android.Manifest
import android.annotation.SuppressLint
import android.app.Dialog
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.text.SpannableStringBuilder
import android.text.method.LinkMovementMethod
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.*
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.api.GoogleApiClient
import com.google.android.gms.location.LocationListener
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.libraries.places.api.model.Place
import com.google.android.gms.maps.*
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.MarkerOptions
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.glide.makeClickSpannable
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.AddCustomerAddress
import com.quedrop.customer.model.AddGuestRegister
import com.quedrop.customer.model.Address
import com.quedrop.customer.model.DeleteAddress
import com.quedrop.customer.ui.addaddress.view.AddAddressActivity
import com.quedrop.customer.ui.addaddress.view.LocationPickerFragment
import com.quedrop.customer.ui.addaddress.view.PlaceAutoCompleteFragment
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.selectaddress.viewmodel.SelectAddressViewModel
import com.quedrop.customer.ui.supplier.suppplierLogin.SupplierLoginActivity
import com.quedrop.customer.utils.*
import kotlinx.android.synthetic.main.activity_select_address.*
import org.json.JSONObject
import java.util.*


class SelectAddressActivity : BaseActivity(), OnMapReadyCallback,
    GoogleApiClient.ConnectionCallbacks,
    GoogleApiClient.OnConnectionFailedListener, LocationListener, GoogleMap.OnMarkerDragListener {

    private val TAG = SelectAddressActivity::class.java.simpleName

    private lateinit var selectAddressViewModel: SelectAddressViewModel

    private var addressList: MutableList<Address>? = mutableListOf()
    var adapter: AddressDisplayAdapter? = null
    private var mCurrLocationMarker: Marker? = null
    private var mMap: GoogleMap? = null
    var mLastLocation: Location? = null

    var mRecyclerView: RecyclerView? = null
    private var tempString: String? = null
    private var orderId: Int? = null
    var isCheckUserId: Boolean = false
    var currentAddress = ""
    var currentAddressName = ""
    var currentLatitude = ""
    var currentLongitude = ""
    var deviceType = "1"
    var uuid = "1"
    var intentFromSetting = "home"
    val mLocationRequest: LocationRequest? = null

    private var mapView: View? = null

    private var remoteMessage: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_select_address)

        //ZPchanges
        socketHandler?.connectToSocket()

        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyGuestId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyAccessKey)!!
        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyUserId, 0)

        when {
            intent.getStringExtra(KeysUtils.keyHomeAddress) != null -> {
                intentFromSetting = intent.getStringExtra(KeysUtils.keyHomeAddress)!!
                tvLoginSupplier.visibility = View.GONE
            }
            intent.getStringExtra(KeysUtils.keySettingAddress) != null -> {
                intentFromSetting = intent.getStringExtra(KeysUtils.keySettingAddress)!!
                tvLoginSupplier.visibility = View.GONE
            }
            else -> {
                intentFromSetting = "home"
                tvLoginSupplier.visibility = View.VISIBLE

            }
        }

        intent?.let { intent ->
            intent.getStringExtra(KeysUtils.keyCustomer)?.let {
                Log.e(TAG, it)
                tempString = it
            }
            intent.getIntExtra(KeysUtils.keyOrderId, 0).let {
                Log.e(TAG, it.toString())
                orderId = it
            }
            intent.getStringExtra(KeysUtils.KeyRemoteMessage).let {
                if (it != null) {
                    Log.e(TAG, it.toString())
                    remoteMessage = it
                }
            }
        }

        if (remoteMessage != null) {
            val jsonObject = JSONObject(remoteMessage!!)
            val notificationType = jsonObject.getString("notification_type").toInt()

            Log.e("notificationType", notificationType.toString())

            if (notificationType == ENUMNotificationType.ORDER_REQUEST.posVal || notificationType == ENUMNotificationType.NOTIFICATION_SUPPLIER_WEEKLY_PAYMENT.posVal || notificationType == ENUMNotificationType.NOTIFICATION_SUPPLIER_STORE_VERIFICATION.posVal) {
                SharedPrefsUtils.setIntegerPreference(
                    applicationContext,
                    KeysUtils.keyUserType,
                    ConstantUtils.USER_TYPE_SUPPLIER
                )

                /* val intent = Intent(this, HomeSupplierActivity::class.java).apply {
                     putExtra(KeysUtils.KeyRemoteMessage, remoteMessage)
                 }
                 startActivityWithDefaultAnimations(intent)
                 finish()*/

            } else {
                SharedPrefsUtils.setIntegerPreference(
                    applicationContext,
                    KeysUtils.keyUserType,
                    ConstantUtils.USER_TYPE_CUSTOMER
                )
                /*val intent = Intent(this, CustomerMainActivity::class.java).apply {
                    if (!tempString.isNullOrEmpty()) {
                        putExtra(KeysUtils.keyCustomer, tempString)
                        putExtra(KeysUtils.keyOrderId, orderId)
                        putExtra(KeysUtils.KeyRemoteMessage, remoteMessage)
                    }
                }

                startActivityWithDefaultAnimations(intent)
                finish()*/
            }

        }

        val role = SharedPrefsUtils.getIntegerPreference(
            applicationContext,
            KeysUtils.keyUserType,
            ConstantUtils.USER_TYPE_CUSTOMER
        )

        when (role) {
            ConstantUtils.USER_TYPE_CUSTOMER -> {
                SharedPrefsUtils.setIntegerPreference(
                    applicationContext,
                    KeysUtils.keyUserType,
                    ConstantUtils.USER_TYPE_CUSTOMER
                )
                initMethod()
                observeViewModel()
                onclickViewMethod()
            }
            ConstantUtils.USER_TYPE_SUPPLIER -> {
                SharedPrefsUtils.setIntegerPreference(
                    applicationContext,
                    KeysUtils.keyUserType,
                    ConstantUtils.USER_TYPE_SUPPLIER
                )
                // startActivity(Intent(this, HomeSupplierActivity::class.java))
                //startActivityWithDefaultAnimations(Intent(this, ::class.java))


                initMethod()
                observeViewModel()
                onclickViewMethod()

                val intent = Intent(this, SupplierLoginActivity::class.java).apply {
                    if (!remoteMessage.isNullOrEmpty()) {
                        putExtra(KeysUtils.KeyRemoteMessage, remoteMessage)
                    }
                }
                startActivityWithDefaultAnimations(intent)
                //finish()
            }

        }


    }

    private fun initMethod() {
        Utils.is_default = SharedPrefsUtils.getIntegerPreference(
            applicationContext,
            KeysUtils.keyIsDefault,
            ConstantUtils.ONE
        )
        Utils.isCallOnceMap =
            SharedPrefsUtils.getBooleanPreference(applicationContext, KeysUtils.keyMap, false)
        if (Utils.isCallOnceMap) {
            val intent = Intent(this, CustomerMainActivity::class.java).apply {
                if (!tempString.isNullOrEmpty()) {
                    putExtra(KeysUtils.keyCustomer, tempString)
                    putExtra(KeysUtils.keyOrderId, orderId)
                    putExtra(KeysUtils.KeyRemoteMessage, remoteMessage)
                }
            }
            startActivityWithDefaultAnimations(intent)
            finish()
        } else {
//            Utils.isCallOnceMap = true
            showProgress()
            SharedPrefsUtils.setBooleanPreference(
                applicationContext,
                KeysUtils.keyMap,
                Utils.isCallOnceMap
            )
        }
        selectAddressViewModel = SelectAddressViewModel(appService)
        addressList?.clear()

        mRecyclerView = findViewById<RecyclerView>(R.id.mRecyclerView)
//        mProgress.visibility = View.VISIBLE
        val mapFragment = supportFragmentManager.findFragmentById(R.id.g_map) as SupportMapFragment?
        mapView = mapFragment?.view
        mapFragment!!.getMapAsync(this)


        mRecyclerView!!.setHasFixedSize(true)
        val llm = LinearLayoutManager(applicationContext)
        mRecyclerView!!.layoutManager = llm

        adapter = AddressDisplayAdapter(applicationContext, addressList).apply {
            onDeleteAddress = { position: Int, view: View ->
                showPopupMenu(view, position)
            }
            finishAct = {
                finishActivityMethod(it)
            }
            addressInvoke = {
                setUpdateLocation()
            }
        }
        mRecyclerView!!.adapter = adapter

        adapter?.setCurentAddress(currentAddress)


        val registerSpan = SpannableStringBuilder()
        registerSpan.append(resources.getString(R.string.notCustomer))
        registerSpan.append(" ")
        registerSpan.append(getRegisterSpan())

        tvLoginSupplier.text = registerSpan
        tvLoginSupplier.movementMethod = LinkMovementMethod.getInstance()
    }

    private fun onclickViewMethod() {
        btnAddAddress.throttleClicks().subscribe {
            val intent = Intent(this, AddAddressActivity::class.java)
            val b = Bundle()
            b.putString(KeysUtils.address, currentAddress)
            b.putString(KeysUtils.address_title, currentAddressName)
            b.putString(KeysUtils.latitude, currentLatitude)
            b.putString(KeysUtils.longitude, currentLongitude)
            intent.putExtras(b)
            intent.putExtra(KeysUtils.keyEdit, false)
            startActivityForResultWithDefaultAnimations(
                intent,
                ConstantUtils.REQUEST_CODE_ADDRESS
            )
        }.autoDispose(compositeDisposable)

        ivBackAddress.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        ivSearchAddress.throttleClicks().subscribe {
            val intent = Intent(this, AddAddressActivity::class.java)
            val b = Bundle()
            b.putString(KeysUtils.address, currentAddress)
            b.putString(KeysUtils.address_title, currentAddressName)
            b.putBoolean(KeysUtils.KeyIsFromHomeScreenSearch, true)
            intent.putExtras(b)
            startActivityForResultWithDefaultAnimations(
                intent,
                ConstantUtils.REQUEST_CODE_SEARCH_ADDRESS
            )
        }.autoDispose(compositeDisposable)
    }

    override fun onMapReady(p0: GoogleMap?) {

        mMap = p0
        // mMap!!.uiSettings.isScrollGesturesEnabled = false
        mMap!!.setOnMarkerDragListener(this)

        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.ACCESS_FINE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED
            ) {
                buildGoogleApiClient()
                mMap!!.isMyLocationEnabled = true
            }
        } else {
            buildGoogleApiClient()
            mMap!!.isMyLocationEnabled = true

        }
        val locationButton: View =
            (mapView!!.findViewById<View>(Integer.parseInt("1")).parent as View).findViewById(
                Integer.parseInt("2")
            )

        val layoutParams = locationButton.layoutParams as RelativeLayout.LayoutParams

        // position on right bottom
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP, 0)
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT, 0)
        layoutParams.setMargins(0, 150, 0, 0)

        locationButton.layoutParams = layoutParams

        locationButton.setOnClickListener {
            setCurrentLocation()
        }

    }

    private fun setCurrentLocation() {
        mCurrLocationMarker?.remove()

        val loc: Location = mMap?.myLocation!!
        if (loc != null) {
            val latLng = LatLng(loc.latitude, loc.longitude)

            val markerOptions = MarkerOptions().draggable(true)
            markerOptions.position(latLng)
            //TODO ZP
            markerOptions.icon(BitmapUtils.icon_pin_press)
            mCurrLocationMarker = mMap!!.addMarker(markerOptions)

            mMap!!.moveCamera(CameraUpdateFactory.newLatLng(latLng))
            mMap!!.animateCamera(CameraUpdateFactory.zoomTo(ConstantUtils.VALUE_15))

            currentAddress =
                Utils.getCompleteAddressString(applicationContext, loc.latitude, loc.longitude)
            currentAddressName =
                Utils.getCompleteAddressName(applicationContext, loc.latitude, loc.longitude)
            adapter?.setCurentAddress(currentAddress)
            adapter?.setCurrentAddressIntoPreference(
                currentAddress,
                currentAddressName,
                loc.latitude,
                loc.longitude
            )

        }
    }

    private fun setUpdatedLocation(place: Place) {
        mCurrLocationMarker?.remove()
        if (place != null) {
            val latLng = LatLng(place.latLng?.latitude!!, place.latLng?.longitude!!)

            val markerOptions = MarkerOptions().draggable(true)
            markerOptions.position(latLng)
            markerOptions.icon(BitmapUtils.iconMap)
            mCurrLocationMarker = mMap!!.addMarker(markerOptions)

            mMap!!.moveCamera(CameraUpdateFactory.newLatLng(latLng))
            mMap!!.animateCamera(CameraUpdateFactory.zoomTo(ConstantUtils.VALUE_15))
            currentAddress = Utils.getCompleteAddressString(
                applicationContext,
                place.latLng?.latitude!!,
                place.latLng?.longitude!!
            )

            currentAddressName = Utils.getCompleteAddressName(
                applicationContext,
                place.latLng?.latitude!!,
                place.latLng?.longitude!!
            )

            adapter?.setCurentAddress(currentAddress)
            adapter?.setCurrentAddressIntoPreference(
                currentAddress, currentAddressName, place.latLng?.latitude!!,
                place.latLng?.longitude!!
            )

        }
    }

    private lateinit var mGoogleApiClient: GoogleApiClient

    @Synchronized
    private fun buildGoogleApiClient() {
        mGoogleApiClient = GoogleApiClient.Builder(this)
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
                this,
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

    private fun setUpdateLocation() {
        showProgress()
        val mLocationRequest = LocationRequest()
        mLocationRequest.interval = ConstantUtils.VALUE_1000.toLong()
        mLocationRequest.fastestInterval = ConstantUtils.VALUE_1000.toLong()
        mLocationRequest.priority = LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY
        if (ContextCompat.checkSelfPermission(
                this,
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
        val latLng = LatLng(p0!!.latitude, p0.longitude)
        val markerOptions = MarkerOptions().draggable(true)
        markerOptions.position(latLng)
        //TODO ZP: Check new pin with arp once
        markerOptions.icon(BitmapUtils.icon_pin_press)

        mCurrLocationMarker = mMap!!.addMarker(markerOptions)
        currentAddressName =
            Utils.getCompleteAddressName(applicationContext, p0.latitude, p0.longitude)
        currentAddress =
            Utils.getCompleteAddressString(applicationContext, p0.latitude, p0.longitude)
        currentLatitude = p0.latitude.toString()
        currentLongitude = p0.longitude.toString()

        if (currentAddressName.isNullOrBlank()) {
            currentAddressName = currentAddress
        }

        mMap!!.moveCamera(CameraUpdateFactory.newLatLng(latLng))
        mMap!!.animateCamera(CameraUpdateFactory.zoomTo(ConstantUtils.VALUE_15))
        hideProgress()
        adapter?.setCurentAddress(currentAddress)
        adapter?.setCurrentAddressIntoPreference(
            currentAddress,
            currentAddressName,
            currentLatitude.toDouble(),
            currentLongitude.toDouble()
        )

        if (mGoogleApiClient != null) {
            LocationServices.FusedLocationApi.removeLocationUpdates(mGoogleApiClient, this)
        }

        isCheckUserId = SharedPrefsUtils.getBooleanPreference(
            applicationContext,
            KeysUtils.keyIsCheckGuest,
            false
        )
        if (isCheckUserId) {
            addressList?.clear()
            getCustomAddressApi()
        } else {
            addressList?.clear()
            getUUID()
        }
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == ConstantUtils.REQUEST_CODE_ADDRESS) {
            getCustomAddressApi()
        }
        if (requestCode == ConstantUtils.REQUEST_CODE_EDITADDRESS) {
            getCustomAddressApi()
        }
        if (requestCode == ConstantUtils.REQUEST_CODE_SEARCH_ADDRESS) {
            val place = data?.extras?.get("place") as Place
            setUpdatedLocation(place)
            Log.e("PLACE", "==>" + place)
        }
    }

    private fun showPopupMenu(
        parentView: View
        , positionAdd: Int
    ) {

        val items = resources.getStringArray(R.array.editItem)
        val inflater =
            applicationContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        val popupView = inflater.inflate(R.layout.popup_assigned_contacts, null, false)
        val myPopupWindow =
            PopupWindow(popupView, 300, RelativeLayout.LayoutParams.WRAP_CONTENT, true)
        val lvItems = popupView.findViewById<ListView>(R.id.lvItems)

        lvItems.adapter = ArrayAdapter<String>(this, R.layout.item_popup, items)

        lvItems.onItemClickListener =
            AdapterView.OnItemClickListener { parent, view, position, id ->
                myPopupWindow.dismiss()

                if (position == ConstantUtils.ZERO) {

                    val intentBundle = Intent(this, AddAddressActivity::class.java)
                    intentBundle.putExtra(KeysUtils.keyEdit, true)
                    val b = Bundle()

                    b.putString(
                        KeysUtils.address_id,
                        addressList?.get(positionAdd)?.address_id.toString()
                    )
                    b.putString(
                        KeysUtils.address_title,
                        addressList?.get(positionAdd)?.address_title.toString()
                    )
                    b.putString(
                        KeysUtils.latitude,
                        addressList?.get(positionAdd)?.latitude.toString()
                    )
                    b.putString(
                        KeysUtils.longitude,
                        addressList?.get(positionAdd)?.longitude.toString()
                    )
                    b.putString(
                        KeysUtils.unit_number,
                        addressList?.get(positionAdd)?.unit_number.toString()
                    )
                    b.putString(
                        KeysUtils.address_type,
                        addressList?.get(positionAdd)?.address_type.toString()
                    )
                    b.putString(
                        KeysUtils.address,
                        addressList?.get(positionAdd)?.address.toString()
                    )
                    intentBundle.putExtras(b)
                    startActivityForResultWithDefaultAnimations(
                        intentBundle,
                        ConstantUtils.REQUEST_CODE_EDITADDRESS
                    )
                } else {
                    dialogDelete(addressList?.get(positionAdd)?.address_id)
                }
            }


        myPopupWindow.showAsDropDown(parentView, -235, -10)
    }

    private fun dialogDelete(id: Int?) {

        val dialog = Dialog(this)
        dialog.setContentView(R.layout.layout_deletedialog)

        val textOk = dialog.findViewById<TextView>(R.id.dialog_ok)
        val textCancel = dialog.findViewById<TextView>(R.id.dialog_cancel)

        textOk.setOnClickListener {

            textOk.setTextColor(ContextCompat.getColor(this, R.color.colorBlue))
            textCancel.setTextColor(ContextCompat.getColor(this, R.color.colorGrey))

            deleteApiAddressApi(id)
            dialog.dismiss()
        }

        textCancel.setOnClickListener {

            textOk.setTextColor(ContextCompat.getColor(this, R.color.colorGrey))
            textCancel.setTextColor(ContextCompat.getColor(this, R.color.colorBlue))
            dialog.dismiss()
        }

        dialog.show()


    }

    private fun observeViewModel() {
        selectAddressViewModel.addressList.observe(this, androidx.lifecycle.Observer {
            hideProgress()
            addressList?.addAll(it.toMutableList())
            adapter?.notifyDataSetChanged()

        })

        selectAddressViewModel.errorMessage.observe(this, androidx.lifecycle.Observer {
            hideProgress()
        })

        selectAddressViewModel.userGuest.observe(this, androidx.lifecycle.Observer {
            hideProgress()
            val user = it

            val guestId = user.guest_user_id
            val is_guest = user.is_guest
            Utils.guestId = guestId
            isCheckUserId = true

            SharedPrefsUtils.setBooleanPreference(
                applicationContext,
                KeysUtils.keyIsCheckGuest,
                isCheckUserId
            )

            SharedPrefsUtils.setIntegerPreference(
                applicationContext,
                KeysUtils.keyGuestId,
                guestId
            )
            SharedPrefsUtils.setIntegerPreference(
                applicationContext,
                KeysUtils.keyIsGuest,
                is_guest
            )
            getCustomAddressApi()
        })

        selectAddressViewModel.message.observe(this, androidx.lifecycle.Observer {
            hideProgress()
            Toast.makeText(
                applicationContext,
                it, Toast.LENGTH_LONG
            ).show()
            getCustomAddressApi()
        })
    }

    private fun getCustomerAddressRequest(): AddCustomerAddress {
        return AddCustomerAddress(
            Utils.userId,
            Utils.guestId,
            Utils.seceretKey,
            Utils.accessKey
        )
    }

    private fun getCustomerAddressResponse(): Address {
        return Address(
            0,
            currentAddress,
            currentAddress,
            currentLatitude,
            currentLongitude,
            "",
            "",
            " ",
            "0",
            Utils.userId,
            Utils.guestId

        )
    }

    private fun getDeleteAddressRequest(id: Int?): DeleteAddress {
        return DeleteAddress(
            Utils.userId,
            id!!,
            Utils.seceretKey,
            Utils.accessKey,
            Utils.guestId

        )
    }

    @SuppressLint("HardwareIds")
    private fun getUUID() {
        try {
            val device_uuid = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
            uuid = device_uuid
        } catch (e: Exception) {
            e.printStackTrace()
        }
        guestRegisterApi()
    }

    private fun getAddGuestRegisterRequest(): AddGuestRegister {
        val Number = Random()
        val Rnumber = Number.nextInt(100)

        val firstName = "GuestUser" + Rnumber.toString()
        SharedPrefsUtils.setStringPreference(applicationContext, KeysUtils.keyGuestUser, firstName)
        return AddGuestRegister(
            Utils.seceretKey,
            Utils.accessKey,
            firstName,
            uuid,
            deviceType,
            Utils.deviceToken,
            currentLatitude,
            currentLongitude,
            currentAddress
        )
    }

    private fun deleteApiAddressApi(id: Int?) {
        showProgress()
        selectAddressViewModel.deleteAddressApi(getDeleteAddressRequest(id!!))

    }

    private fun getCustomAddressApi() {
        showProgress()
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyGuestId, 0)

        addressList?.clear()
        addressList?.add(getCustomerAddressResponse())
        adapter?.notifyDataSetChanged()
        selectAddressViewModel.getCustomAddressApi(getCustomerAddressRequest())
    }

    private fun guestRegisterApi() {
        showProgress()
        val token = SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keySecretKey)
        selectAddressViewModel.guestRegisterApi(getAddGuestRegisterRequest())

    }

    private fun finishActivityMethod(view: View) {
        Utils.isCallOnceMap = true

        SharedPrefsUtils.setBooleanPreference(
            applicationContext,
            KeysUtils.keyMap,
            Utils.isCallOnceMap
        )

        if (intentFromSetting == getString(R.string.fromSettingAddress)) {
            val intent = Intent(this, CustomerMainActivity::class.java)
            intent.putExtra(KeysUtils.keyCustomer, getString(R.string.fromSettingAddress))
            startActivityWithDefaultAnimations(intent)
        } else {

            val intent = Intent(this, CustomerMainActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            startActivityWithDefaultAnimations(intent)
            finish()
        }
    }

    private fun getRegisterSpan() = getString(R.string.loginAsSupplier).makeClickSpannable(
        {
            try {
                // remove
                /* SharedPrefsUtils.setIntegerPreference(
                     applicationContext,
                     KeysUtils.keyUserType,
                     ConstantUtils.USER_TYPE_SUPPLIER
                 )*/
                startActivityWithDefaultAnimations(Intent(this, SupplierLoginActivity::class.java))
//                finish()
            } catch (e: ActivityNotFoundException) {
                e.printStackTrace()
            }
        },
        ContextCompat.getColor(this, R.color.colorBlueText),
        true,
        false,
        resources.getString(R.string.loginAsSupplier),
        null
    )

    override fun onBackPressed() {
        super.onBackPressed()
        finish()
    }

    override fun onMarkerDragEnd(p0: Marker?) {
        currentAddress = Utils.getCompleteAddressString(
            applicationContext,
            p0?.position?.latitude!!,
            p0.position?.longitude!!
        )
        adapter?.setCurentAddress(currentAddress)

        currentAddressName = Utils.getCompleteAddressName(
            applicationContext,
            p0.position?.latitude!!,
            p0.position?.longitude!!
        )

        adapter?.setCurrentAddressIntoPreference(
            currentAddress,
            currentAddressName,
            p0.position.latitude,
            p0.position.longitude
        )

    }

    override fun onMarkerDragStart(p0: Marker?) {

    }

    override fun onMarkerDrag(p0: Marker?) {

    }
}
