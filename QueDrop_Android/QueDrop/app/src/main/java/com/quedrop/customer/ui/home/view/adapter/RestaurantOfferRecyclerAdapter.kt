package com.quedrop.customer.ui.home.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.model.StoreOfferList
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.URLConstant
import com.quedrop.customer.utils.Utils

class RestaurantOfferRecyclerAdapter(
    var context: Context,
    var arrayRestaurantOfferList: MutableList<StoreOfferList>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem =
            layoutInflater.inflate(R.layout.layout_homecustomer_recycle_offers, parent, false)
        return ViewHolder(
            listItem
        )
    }

    override fun getItemCount(): Int {
        return if (arrayRestaurantOfferList != null)
            return arrayRestaurantOfferList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {
            val KeyLaititude: Float =
                SharedPrefsUtils.getStringPreference(context, KeysUtils.KeyLatitude)!!.toFloat()
            val KeyLongitude: Float =
                SharedPrefsUtils.getStringPreference(context, KeysUtils.KeyLongitude)!!.toFloat()
            Glide.with(context)
                .load(
                    URLConstant.nearByStoreUrl + arrayRestaurantOfferList?.get(
                        position
                    )?.store_logo
                )
                .placeholder(R.drawable.placeholder_store_in_category)
                .into(holder.ivPicOffers)

            holder.textNameOffers.text = arrayRestaurantOfferList?.get(position)?.store_name
            holder.textDescriptionOffers.text =
                arrayRestaurantOfferList?.get(position)?.offer_description

            holder.textCouponCodeOffers.text =
                arrayRestaurantOfferList?.get(position)?.discount_percentage + "% Off"

            if(arrayRestaurantOfferList?.get(position)!!.coupon_code.isEmpty()) {

            } else {
                holder.textCouponCodeOffers.text =
                    arrayRestaurantOfferList?.get(position)?.discount_percentage + "% Off | " + arrayRestaurantOfferList?.get(
                        position
                    )?.coupon_code
            }

            holder.textRateOffers.text = arrayRestaurantOfferList?.get(position)?.store_rating
            holder.textPriceOffers.text = arrayRestaurantOfferList?.get(position)?.discount_price
            if(!arrayRestaurantOfferList?.get(position)?.latitude.isNullOrEmpty() &&
                !arrayRestaurantOfferList?.get(position)?.longitude.isNullOrEmpty()) {


                Utils.fetchRouteTime(
                    context,
                    KeyLaititude.toDouble(),
                    KeyLongitude.toDouble(),
                    arrayRestaurantOfferList?.get(position)?.latitude!!.toDouble(),
                    arrayRestaurantOfferList?.get(position)?.longitude!!.toDouble(),
                    holder.textTimeOffers
                )
            }


        }
    }

    class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var ivPicOffers: ImageView
        var textNameOffers: TextView
        var textDescriptionOffers: TextView
        var textCouponCodeOffers: TextView
        var textRateOffers: TextView
        var textTimeOffers: TextView
        var textPriceOffers: TextView


        init {
            this.ivPicOffers = itemView.findViewById(R.id.ivPicOffers) as ImageView
            this.textNameOffers = itemView.findViewById(R.id.textNameOffers) as TextView
            this.textDescriptionOffers =
                itemView.findViewById(R.id.textDescriptionOffers) as TextView
            this.textCouponCodeOffers = itemView.findViewById(R.id.textCouponCodeOffers) as TextView
            this.textRateOffers = itemView.findViewById(R.id.textRateOffers) as TextView
            this.textTimeOffers = itemView.findViewById(R.id.textTimeOffers) as TextView
            this.textPriceOffers = itemView.findViewById(R.id.textPriceOffers) as TextView

        }
    }

//    private fun fetchRoute(
//        sourceLatitude: Double,
//        sourceLongitude: Double,
//        destinationLatitude: Double,
//        destinationLongitude: Double,
//        textMain: TextView
//    ) {
//        val path: MutableList<List<LatLng>> = ArrayList()
//        val urlDirections =
//            context!!.resources.getString(R.string.urlDirection) + "origin=" + sourceLatitude + "," + sourceLongitude +
//                    "&destination=" + destinationLatitude + "," + destinationLongitude +
//                    "&key=" + context!!.resources.getString(
//                R.string.mapApiKey
//            )
//        val directionsRequest = object : StringRequest(
//            Request.Method.GET,
//            urlDirections,
//            com.android.volley.Response.Listener<String> { response ->
//
//                try{
//
//                    val jsonResponse = JSONObject(response)
//                    // Get routes
//                    val routes = jsonResponse.getJSONArray("routes")
//                    val legs = routes.getJSONObject(0).getJSONArray("legs")
//                    val steps = legs.getJSONObject(0).getJSONArray("steps")
//                    var jDistance = (legs.get(0) as JSONObject).getJSONObject("distance")
//                    var jDuration = (legs.get(0) as JSONObject).getJSONObject("duration")
//                    var time = jDuration.getString("text")
//
//                    textMain.text = time
//                }catch(e: JSONException){
//
//                }
//            },
//            com.android.volley.Response.ErrorListener { _ ->
//            }) {}
//
//        val requestQueue = Volley.newRequestQueue(context)
//        requestQueue.add(directionsRequest)
//    }

}