package com.quedrop.driver.ui.homeFragment.view

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import com.quedrop.driver.R
import com.quedrop.driver.service.request.InfoWindow
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.Marker
import kotlinx.android.synthetic.main.layout_googlemap_snippet.view.*

class CustomMarkerInfoWindowView ( var context: Context
) : GoogleMap.InfoWindowAdapter {

    var inflater: LayoutInflater? = null
    override fun getInfoContents(p0: Marker?): View? {
        return null
    }

    override fun getInfoWindow(p0: Marker?): View {

        inflater =
            context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        var v: View? = null

        v = inflater!!.inflate(R.layout.layout_googlemap_snippet, null, false)

        p0!!.setInfoWindowAnchor(0.5f, 0.4f)

        if(p0.tag!=null) {
            val info: InfoWindow = p0.tag as InfoWindow
            v!!.tvDistance.text = info.distance
            v.tvTime.text = info.time
        }
        return v!!
    }



}