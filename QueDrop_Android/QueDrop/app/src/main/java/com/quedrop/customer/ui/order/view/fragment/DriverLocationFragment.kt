package com.quedrop.customer.ui.order.view.fragment

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.recyclerview.widget.LinearLayoutManager
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.JSDrawRoute
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.GetSingleOrderDetailsResponse
import com.quedrop.customer.model.StoreSingleDetails
import com.quedrop.customer.socket.SocketConstants
import com.quedrop.customer.ui.home.view.DriverMapView
import com.quedrop.customer.ui.order.view.adapter.DeliveryRouteAdapter
import com.quedrop.customer.ui.order.viewmodel.OrderViewModel
import com.quedrop.customer.utils.*
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.LatLng
import com.psp.google.direction.model.Direction
import com.psp.google.direction.util.DirectionConverter
import io.socket.client.Ack
import kotlinx.android.synthetic.main.fragment_driver_location.*
import org.json.JSONException
import org.json.JSONObject


open class DriverLocationFragment(
    var orderId: Int,
    var driverId: Int
) : BaseFragment(){

    private var deliveryRouteAdapter: DeliveryRouteAdapter? = null
    private var arrayDeliverStoreList: MutableList<StoreSingleDetails>? = null

    private var rideMapView: DriverMapView? = null

    private var jsDrawRoute: JSDrawRoute? = null
    lateinit var mGoogleMap: GoogleMap

    private lateinit var orderViewModel: OrderViewModel
    private var orderDetailsData: GetSingleOrderDetailsResponse? = null

    var deliveryLatitude:String ?=null
    var deliveryLongitude:String ?=null


    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        return inflater.inflate(
            R.layout.fragment_driver_location,
            container, false
        )
    }

    companion object {
        //        fun newInstance()
        fun newInstance(
            orderId: Int,
            driverId: Int
        ): DriverLocationFragment {

            return DriverLocationFragment(
                orderId,
                driverId
            )
        }
    }


    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyGuestId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keyAccessKey)!!

        orderDetailsData = (SharedPrefsUtils.getModelPreferences(
            activity,
            KeysUtils.keyOrderDetails,
            GetSingleOrderDetailsResponse::class.java
        )) as GetSingleOrderDetailsResponse?

        orderViewModel = OrderViewModel(appService)

        initMethod()
        onClickMethod()

    }

    private fun initMethod() {


        LocalBroadcastManager.getInstance(requireContext()).registerReceiver(
            eventUpdate,
            IntentFilter(BroadCastConstant.BROADCAST_EVENT_CHANGE)
        )

        startDriverLocationUpdate()


        val map =
            childFragmentManager.findFragmentById(R.id.mapFragment) as SupportMapFragment
        map.getMapAsync { googleMap ->
            mGoogleMap = googleMap
            rideMapView = DriverMapView(
                true,
                map,
                googleMap,
                orderViewModel
            )
            rideMapView?.clearMap(orderDetailsData)
//            rideMapView?.setPolyLinesMarket(orderDetailsData)

            requestDirection()
        }

        arrayDeliverStoreList = orderDetailsData?.stores

        deliveryLatitude = orderDetailsData?.delivery_latitude
        deliveryLongitude = orderDetailsData?.delivery_longitude

        rvDeliveryRoute.layoutManager = LinearLayoutManager(
            activity,
            LinearLayoutManager.HORIZONTAL,
            false
        )

        deliveryRouteAdapter = DeliveryRouteAdapter(
            activity,
            arrayDeliverStoreList!!,
            deliveryLatitude!!,
            deliveryLongitude!!

        )
        rvDeliveryRoute.adapter = deliveryRouteAdapter
    }

    private fun onClickMethod() {
        ivBackDriver.throttleClicks().subscribe() {
            activity.onBackPressed()
        }.autoDispose(compositeDisposable)

    }

    override fun onDestroy() {
        super.onDestroy()
        stopDriverLocationUpdate()
        LocalBroadcastManager.getInstance(requireContext()).unregisterReceiver(eventUpdate)
    }

    private fun startDriverLocationUpdate() {

        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {


                jsonObject.put(SocketConstants.keyDriverIdForRoute, driverId.toString())
//                jsonObject.put(SocketConstants.KeyDriverId, data?.driver_ids.toString())

                Log.e("driverId", "--" + driverId.toInt())

                SocketConstants.socketIOClient!!.emit(
                    SocketConstants.SocketStartDriverLocation,
                    jsonObject, Ack {
                        try {
                            val messageJson = JSONObject(it[0].toString())
                            val responseStatus = messageJson.getString("status").toInt()
                            val message = messageJson.getString("message")


                            Log.e("SocketStatus", responseStatus.toString())
                            Log.e("SocketMessage", message.toString())

                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }

                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        } else {
            Log.e("Socket", "isDisconnecting==========================")
        }

    }

    private fun stopDriverLocationUpdate() {

        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {


                jsonObject.put(SocketConstants.keyDriverIdForRoute, driverId.toString())
//                jsonObject.put(SocketConstants.KeyDriverId, data?.driver_ids.toString())

                Log.e("driverId", "--" + driverId.toInt())

                SocketConstants.socketIOClient!!.emit(
                    SocketConstants.SocketStopDriverLocation,
                    jsonObject, Ack {
                        try {
                            val messageJson = JSONObject(it[0].toString())
                            val responseStatus = messageJson.getString("status").toInt()
                            val message = messageJson.getString("message")


                            Log.e("SocketStatus", responseStatus.toString())
                            Log.e("SocketMessage", message.toString())

                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }

                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        } else {
            Log.e("Socket", "isDisconnecting==========================")
        }

    }

    private val eventUpdate = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val events = intent.getStringExtra(BroadCastConstant.BROADCAST_KEY_EVENT)!!
            try {
                val jsonObject =
                    JSONObject(intent.getStringExtra(BroadCastConstant.BROADCAST_KEY_OBJ)!!)
                Log.e("start", "Start")
                parseResponse(events, jsonObject)
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }

    private fun parseResponse(event: String, argument: JSONObject) {
        when (event) {
            SocketConstants.SocketDriverLocationChanged -> {

                val driverId = argument.getString("driver_id")
                val latitude = argument.getString("latitude")
                val longitude = argument.getString("longitude")

                Log.e("driverId", driverId)
                Log.e("latitude", latitude)
                Log.e("longitude", longitude)

                if(!latitude.isNullOrEmpty() && !longitude.isNullOrEmpty()) {

                    jsDrawRoute?.updateMarker(LatLng(latitude.toDouble(), longitude.toDouble()))
                }


            }
        }
    }

    //DRAWING ROUTE...
    private fun requestDirection() {
        jsDrawRoute = JSDrawRoute(activity, orderDetailsData!!, mGoogleMap,true)
        jsDrawRoute?.setOnDrawListener(object : JSDrawRoute.DrawEventListener {
            override fun onDrawListener(direction: Direction?, t: Boolean) {
                if (direction != null && !t) {
                    onDirectionSuccess(direction)
                } else {
                    Utility.toastLong(context, "Something went wrong in drawing route")
                }
            }
        })
        jsDrawRoute?.initDrawRoute(true)
    }


    private fun onDirectionSuccess(direction: Direction) {
        if (direction.isOK) {
            val route = direction.routeList[0]
          //  txtTotalKm.text = directionTime(route.totalDuration) + directionDistance(route.totalDistance)
            val legCount = route.legList.size
            for (index in 0 until legCount) {
                val leg = route.legList[index]
                val stepList = leg.stepList
                val polylineOptionList = DirectionConverter.createTransitPolyline(
                    activity,
                    stepList,
                    5,
                    Color.parseColor("#34BDF4"),
                    3,
                    Color.BLUE
                )
                for (polylineOption in polylineOptionList) {
                    mGoogleMap.addPolyline(polylineOption)
                }
            }
            jsDrawRoute?.setCameraUpdateBounds(route)
        } else {
            Utility.toastLong(context, "Something went wrong in drawing route")
        }
    }
}