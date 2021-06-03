package com.quedrop.customer.ui.cart.view

import android.annotation.SuppressLint
import android.graphics.Color
import android.graphics.Typeface
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.Gravity
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.GoogleMap.InfoWindowAdapter
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.MarkerOptions
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.socket.SocketConstants
import com.quedrop.customer.utils.ConstantUtils.Companion.KEY_DELIVERY_TYPE
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import io.socket.client.Ack
import kotlinx.android.synthetic.main.activity_view_all_driver.*
import kotlinx.android.synthetic.main.fragment_driver_location.*
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.util.*


class ViewAllDriverActivity : BaseActivity(), GoogleMap.OnMarkerClickListener {

    private var mDriverMarker: Marker? = null
    private var mStoreMarker: Marker? = null
    lateinit var mGoogleMap: GoogleMap

    var deliveryOption: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_view_all_driver)

        if (intent.hasExtra(KEY_DELIVERY_TYPE)) {
            deliveryOption = intent.getStringExtra(KEY_DELIVERY_TYPE)
        }


        Utils.userId = SharedPrefsUtils.getIntegerPreference(this, KeysUtils.keyUserId, 0)
        Utils.guestId = SharedPrefsUtils.getIntegerPreference(this, KeysUtils.keyGuestId, 0)
        Utils.keyLatitude = SharedPrefsUtils.getStringPreference(this, KeysUtils.KeyLatitude)!!
        Utils.keyLongitude = SharedPrefsUtils.getStringPreference(this, KeysUtils.KeyLongitude)!!

        val map = supportFragmentManager.findFragmentById(R.id.mapFragment) as SupportMapFragment
        map.getMapAsync { googleMap ->
            mGoogleMap = googleMap
            mGoogleMap.setOnMarkerClickListener(this)
        }

        initViews()
    }

    private fun initViews() {
        setUpToolBar()

        callViewAllDriverSocketApi()

        Timer().schedule(object : TimerTask() {
            override fun run() {
                callViewAllDriverSocketApi()
            }
        }, 60000)

    }

    private fun callViewAllDriverSocketApi() {
        callSocketApi(
            Utils.userId,
            Utils.guestId,
            deliveryOption,
            Utils.keyLatitude,
            Utils.keyLongitude
        )

    }

    @SuppressLint("SetTextI18n")
    private fun callSocketApi(
        userId: Int,
        guestUserId: Int,
        deliveryOption: String,
        deliveryLatitude: String,
        deliveryLongitude: String
    ) {
        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {
                jsonObject.put(SocketConstants.KeyUserId, userId)
                jsonObject.put(SocketConstants.keyGuestId, guestUserId)
                jsonObject.put(SocketConstants.KeyDeliveryOption, deliveryOption)
                jsonObject.put(SocketConstants.KeyDeliveryLatitude, deliveryLatitude.toDouble())
                jsonObject.put(SocketConstants.KeyDeliveryLongitude, deliveryLongitude.toDouble())

                SocketConstants.socketIOClient!!.emit(
                    SocketConstants.SocketGetDriverList,
                    jsonObject, Ack {
                        try {
                            val responseJson = JSONObject(it[0].toString())
                            val responseStatus = responseJson.getString("status").toInt()
                            runOnUiThread {
                                if (responseStatus == 1) {
                                    loadingView.visibility = View.GONE
                                    val data = responseJson.getJSONObject("data")
                                    val arrayNearbyDrivers = data.getJSONArray("nearby_drivers")
                                    val arrayFastestStoreDetails = data.getJSONObject("fathest_store_details")

                                    if(arrayNearbyDrivers.length() == 0){
                                        txtViewAllOrderTitle.text = "No driver available"
                                    } else if (arrayNearbyDrivers.length() == 1) {
                                        txtViewAllOrderTitle.text = arrayNearbyDrivers.length().toString() + " driver available"
                                    } else {
                                        txtViewAllOrderTitle.text = arrayNearbyDrivers.length().toString() + " drivers available"
                                    }

                                    mGoogleMap.clear()
                                    setMarker(arrayNearbyDrivers, arrayFastestStoreDetails)
                                }
                            }

                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }
                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        } else {
            txtViewAllOrderTitle.text = getString(R.string.available_drivers)
            loadingView.visibility = View.VISIBLE
        }
    }

    private fun setMarker(
        arrayNearbyDrivers: JSONArray,
        arrayFastestStoreDetails: JSONObject
    ) {
        for (index in 0 until arrayNearbyDrivers.length()) {

            val jsonObject: JSONObject = arrayNearbyDrivers.getJSONObject(index)
            val driverLatLng = LatLng(
                jsonObject.getString("latitude").toDouble(),
                jsonObject.getString("longitude").toDouble()
            )
            mDriverMarker = mGoogleMap.addMarker(
                MarkerOptions().position(driverLatLng)
                    .title(jsonObject.getString("distance") + " KM")
            )

            mDriverMarker?.setIcon(BitmapDescriptorFactory.fromResource(R.drawable.delivery_icon))
            val yourLocation = CameraUpdateFactory.newLatLngZoom(driverLatLng, 10f)
            mGoogleMap.animateCamera(yourLocation)
        }

        val storeLatLng = LatLng(
            arrayFastestStoreDetails.getString("store_lat").toDouble(),
            arrayFastestStoreDetails.getString("store_long").toDouble()
        )

        mStoreMarker = mGoogleMap.addMarker(
            MarkerOptions().position(storeLatLng)
                .title(arrayFastestStoreDetails.getString("store_name"))
                .snippet(arrayFastestStoreDetails.getString("store_address"))
        )
        mStoreMarker?.setIcon(BitmapDescriptorFactory.fromResource(R.drawable.mapnearicon_press))

//        mGoogleMap.setOnMarkerClickListener(OnMarkerClickListener { marker ->
//            mDriverMarker = marker
//            marker.showInfoWindow()
//            true
//        })

        mGoogleMap.setInfoWindowAdapter(object : InfoWindowAdapter {
            override fun getInfoWindow(arg0: Marker): View? {
                return null
            }

            override fun getInfoContents(marker: Marker): View {
                val info = LinearLayout(this@ViewAllDriverActivity)
                info.orientation = LinearLayout.VERTICAL
                val title = TextView(this@ViewAllDriverActivity)
                title.setTextColor(Color.BLACK)
                title.gravity = Gravity.CENTER
                title.setTypeface(null, Typeface.BOLD)
                title.text = marker.title
                val snippet = TextView(this@ViewAllDriverActivity)
                snippet.setTextColor(Color.GRAY)
                snippet.text = marker.snippet
                info.addView(title)
                info.addView(snippet)
                return info
            }

        })
    }


    private fun setUpToolBar() {
        ivBackViewAllDriver.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)
    }

    override fun onBackPressed() {
        super.onBackPressed()
    }

    override fun onMarkerClick(p0: Marker?): Boolean {
        return false
    }
}