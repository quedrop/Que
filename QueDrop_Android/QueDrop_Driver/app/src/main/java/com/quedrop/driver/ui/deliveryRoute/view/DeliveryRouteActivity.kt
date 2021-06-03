package com.quedrop.driver.ui.deliveryRoute.view

import android.annotation.SuppressLint
import android.graphics.Color
import android.os.Bundle
import androidx.recyclerview.widget.LinearLayoutManager
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.base.JSDrawRoute
import com.quedrop.driver.base.JSDrawRoute.Companion.directionDistance
import com.quedrop.driver.base.JSDrawRoute.Companion.directionTime
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.Orders
import com.quedrop.driver.service.model.StoreDetail
import com.quedrop.driver.ui.deliveryRoute.adapter.DeliveryRouteAdapter
import com.quedrop.driver.ui.homeFragment.view.DriverMapView
import com.quedrop.driver.ui.homeFragment.viewModel.HomeViewModel
import com.quedrop.driver.utils.Utility
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.SupportMapFragment
import com.google.gson.Gson
import com.psp.google.direction.model.Direction
import com.psp.google.direction.util.DirectionConverter
import kotlinx.android.synthetic.main.activity_delivery_route.*
import kotlinx.android.synthetic.main.toolbar_normal.*


class DeliveryRouteActivity : BaseActivity() {

    private var deliveryRouteAdapter: DeliveryRouteAdapter? = null
    private var arrayDeliverStoreList: MutableList<StoreDetail>? = null


    private var orderDetail: Orders? = null
    private var rideMapView: DriverMapView? = null

    private var jsDrawRoute: JSDrawRoute? = null
    lateinit var mGoogleMap: GoogleMap

    private lateinit var homeViewModel: HomeViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_delivery_route)

        val strOrderDetail = intent?.getStringExtra("orderDetail")
        orderDetail = Gson().fromJson(strOrderDetail, Orders::class.java)

        homeViewModel = HomeViewModel(appService)
        arrayDeliverStoreList = mutableListOf()

        initViews()
    }



    @SuppressLint("SetTextI18n")
    private fun initViews() {

        tvTitle.text = resources.getString(R.string.delivery_route)
        ivBack.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)


        val map =
            supportFragmentManager.findFragmentById(R.id.mapFragment) as SupportMapFragment
        map.getMapAsync { googleMap ->
            mGoogleMap = googleMap
            rideMapView = DriverMapView(
                true,
                map,
                googleMap,
                homeViewModel
            )
            rideMapView?.clearMap()
            requestDirection()
        }


        rvDeliveryRoute.layoutManager = LinearLayoutManager(
            this,
            LinearLayoutManager.HORIZONTAL,
            false
        )

        deliveryRouteAdapter = DeliveryRouteAdapter(
            this,
            orderDetail?.stores!!

        )
        rvDeliveryRoute.adapter = deliveryRouteAdapter
    }





    //DRAWING ROUTE...
    private fun requestDirection() {
        jsDrawRoute = JSDrawRoute(this, orderDetail!!, mGoogleMap,true)
        jsDrawRoute?.setOnDrawListener(object : JSDrawRoute.DrawEventListener {
            override fun onDrawListener(direction: Direction?, error: Boolean) {
                if (direction != null && !error) {
                    onDirectionSuccess(direction)
                } else {
                    Utility.toastLong(applicationContext, "Something went wrong in drawing route")
                }
            }
        })
        jsDrawRoute?.initDrawRoute(true)
    }


    private fun onDirectionSuccess(direction: Direction) {
        if (direction.isOK) {
            val route = direction.routeList[0]
            txtTotalKm.text = directionTime(route.totalDuration) + directionDistance(route.totalDistance)
            val legCount = route.legList.size
            for (index in 0 until legCount) {
                val leg = route.legList[index]
                val stepList = leg.stepList
                val polylineOptionList = DirectionConverter.createTransitPolyline(
                    this,
                    stepList,
                    5,
                    Color.parseColor("#1c77f2"),
                    3,
                    Color.BLUE
                )
                for (polylineOption in polylineOptionList) {
                    mGoogleMap.addPolyline(polylineOption)
                }
            }
            jsDrawRoute?.setCameraUpdateBounds(route)
        } else {
            Utility.toastLong(applicationContext, "Something went wrong in drawing route")
        }
    }


    override fun onBackPressed() {
        super.onBackPressed()
        finish()
    }
}