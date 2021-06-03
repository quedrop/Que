package com.quedrop.customer.ui.nearby.view

import com.google.android.gms.maps.model.Marker

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import com.quedrop.customer.R
import com.quedrop.customer.model.InfoWindowForPoly
import com.google.android.gms.maps.GoogleMap


class CustomMarkerInfoWindowViewForPoly(
    var context: Context
) : GoogleMap.InfoWindowAdapter {

    var inflater: LayoutInflater? = null
    override fun getInfoContents(p0: Marker?): View? {
        return null
    }

    override fun getInfoWindow(p0: Marker?): View {
        inflater =
            context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
       val v: View = inflater!!.inflate(R.layout.layout_polyline_tag, null, false)


        val tvDistance = v.findViewById(R.id.textDistanceLine) as TextView
        val tvtime = v.findViewById(R.id.textTimeLine) as TextView

//        p0!!.setIcon(BitmapDescriptorFactory.fromResource(R.drawable.transparent))


        val info12: InfoWindowForPoly = p0?.tag as InfoWindowForPoly


        tvDistance.text = info12.distance
        tvtime.text = info12.time
        return v
    }

}
