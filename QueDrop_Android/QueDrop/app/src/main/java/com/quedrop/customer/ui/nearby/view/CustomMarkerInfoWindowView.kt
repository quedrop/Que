package com.quedrop.customer.ui.nearby.view

import com.google.android.gms.maps.model.Marker

import android.content.Context
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.quedrop.customer.R
import com.quedrop.customer.model.InfoWindow
import com.quedrop.customer.model.Schedule
import com.quedrop.customer.utils.Utils
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.makeramen.roundedimageview.RoundedImageView
import com.quedrop.customer.utils.URLConstant
import com.squareup.picasso.Picasso


class CustomMarkerInfoWindowView(
    var context: Context
) : GoogleMap.InfoWindowAdapter {

    var inflater: LayoutInflater? = null
    var checkTimeStatus: Boolean? = false
    var openingTime: String? = null
    var closingTime: String? = null
    var currentDay: String? = null
    var currentTimeConvert: String? = null
    var currentDate: String? = null
    var currentTime: String? = null
    override fun getInfoContents(p0: Marker?): View? {
        return null
    }

    override fun getInfoWindow(p0: Marker?): View {

        currentDate = Utils.getCurrentDate()
        currentTime = Utils.getCurrentTime()
        currentTimeConvert = Utils.convertTime(currentTime!!)
        currentDay = Utils.getCurrentDay()

        inflater =
            context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        var v: View? = null

        v = inflater!!.inflate(R.layout.layout_googlemap_snippet, null, false)

        val ivLogo = v.findViewById(R.id.ivLogoStoreSnippet) as RoundedImageView
        val title = v.findViewById(R.id.textTitleStoreSnippet) as TextView
        val titleAddress = v.findViewById(R.id.textAddressStoreSnippet) as TextView
        val distance = v.findViewById(R.id.textDistanceStoreSnippet) as TextView
        val time: TextView = v.findViewById(R.id.textTimeStoreSnippet) as TextView
        val textClosedSnippet: TextView = v.findViewById(R.id.textClosedSnippet) as TextView

        p0!!.setIcon(BitmapDescriptorFactory.fromResource(R.drawable.ic_pin_press))
        p0.setInfoWindowAnchor(0.5f, 0.4f)

        if (p0.tag != null) {


            val info: InfoWindow = p0.tag as InfoWindow

            Log.e("image",info.image.toString())

            Picasso.get()
                .load(URLConstant.nearByStoreUrl + info.image)
                .into(ivLogo)



            title.text = info.title
            titleAddress.text = info.address


            distance.text = info.distance
            time.text = info.time
            checkOpenOrCloseShop(info.schedule,ivLogo,textClosedSnippet)
        }
        return v
    }

    private fun checkOpenOrCloseShop(schedule: ArrayList<Schedule>,iv:ImageView,textClosed:TextView) {

        checkTimeStatus = false
        notGreyScale(iv,textClosed)

        if (!schedule.isNullOrEmpty()) {

            for ((index, value) in schedule.withIndex()) {
                if (currentDay == schedule[index].weekday) {
                    openingTime =
                       schedule[index].opening_time
                    closingTime =
                        schedule[index].closing_time
                    var openingConvertTime: String? = null
                    var closingConvertTime: String? = null

                    if (openingTime.isNullOrEmpty() && closingTime.isNullOrEmpty()) {
                        Log.e("---1checkTimeStatus--", "------------" + checkTimeStatus)
                        toGrayScaleImage(iv,textClosed)
                    } else {
                        openingConvertTime = Utils.convertTime(openingTime!!)
                        closingConvertTime = Utils.convertTime(closingTime!!)

                        checkTimeStatus = Utils.checkTimeStatus(
                            openingConvertTime,
                            closingConvertTime,
                            currentTimeConvert!!
                        )
                        Log.e("---2checkTimeStatus--", "------------" + checkTimeStatus)
                        if (!checkTimeStatus!!) {
                            toGrayScaleImage(iv,textClosed)
                        }

                    }
                }
            }
        } else {
            Log.e("---NocheckTimeStatus--", "------------" + checkTimeStatus)
            toGrayScaleImage(iv,textClosed)

        }
    }

    private fun toGrayScaleImage(iv:ImageView,textClosed:TextView) {

        val matrix = ColorMatrix()
        matrix.setSaturation(0f)
        val cf = ColorMatrixColorFilter(matrix)
        iv.colorFilter = cf
        textClosed.visibility = View.VISIBLE
    }

    private fun notGreyScale(iv:ImageView,textClosed:TextView) {
        iv.colorFilter = null
        textClosed.visibility = View.GONE
    }
}
