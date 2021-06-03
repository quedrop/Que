package com.quedrop.customer.ui.addaddress.view

import com.google.android.gms.common.api.ApiException
import com.google.android.gms.tasks.OnFailureListener
import com.google.android.gms.tasks.OnSuccessListener

import android.content.Context
import androidx.recyclerview.widget.RecyclerView
import android.view.LayoutInflater
import android.view.ViewGroup

import com.google.android.gms.tasks.Tasks
import android.graphics.Typeface
import android.text.style.StyleSpan
import android.text.style.CharacterStyle
import android.util.Log
import android.view.View
import android.widget.*
import com.quedrop.customer.R
import com.google.android.libraries.places.api.model.AutocompleteSessionToken
import com.google.android.libraries.places.api.net.FetchPlaceRequest
import com.google.android.libraries.places.api.net.FetchPlaceResponse
import com.google.android.libraries.places.api.net.FindAutocompletePredictionsRequest
import com.google.android.libraries.places.api.net.PlacesClient
import java.util.*
import java.util.concurrent.ExecutionException
import java.util.concurrent.TimeUnit
import java.util.concurrent.TimeoutException
import kotlin.collections.ArrayList


class PlacesAutoCompleteAdapter(private val mContext: Context) :
    RecyclerView.Adapter<PlacesAutoCompleteAdapter.PredictionHolder>(), Filterable {


    private var mResultList: ArrayList<PlaceAutocomplete>? = ArrayList()
    private val STYLE_BOLD: CharacterStyle
    private val STYLE_NORMAL: CharacterStyle
    private val placesClient: PlacesClient
    private var clickListener: ClickListener? = null

    override fun getFilter(): Filter {
        return object : Filter() {
            override fun performFiltering(constraint: CharSequence?): FilterResults {

                val results = FilterResults()

                if (constraint != null) {

                    mResultList = getPredictions(constraint)
                    if (mResultList != null) {
                        // The API successfully returned results.
                        results.values = mResultList
                        results.count = mResultList!!.size
                    }
                }
                return results
            }

            override fun publishResults(constraint: CharSequence, results: FilterResults?) {
                if (results != null && results.count > 0) {

                    notifyDataSetChanged()
                } else {

                    notifyDataSetChanged()
                }
            }
        }
    }


    init {
        STYLE_BOLD = StyleSpan(Typeface.BOLD)
        STYLE_NORMAL = StyleSpan(Typeface.NORMAL)
        com.google.android.libraries.places.api.Places.initialize(mContext, mContext.getString(R.string.mapApiKey))
        placesClient = com.google.android.libraries.places.api.Places.createClient(mContext)
    }

    fun setClickListener(clickListener: ClickListener) {
        this.clickListener = clickListener
    }

    interface ClickListener {
        fun click(place: com.google.android.libraries.places.api.model.Place)
    }


    private fun getPredictions(constraint: CharSequence): ArrayList<PlaceAutocomplete> {

        val resultList = ArrayList<PlaceAutocomplete>()


        val token = AutocompleteSessionToken.newInstance()


        val request = FindAutocompletePredictionsRequest.builder()

            .setSessionToken(token)
            .setQuery(constraint.toString())
            .build()

        val autocompletePredictions = placesClient.findAutocompletePredictions(request)

        // This method should have been called off the main UI thread. Block and wait for at most
        // 60s for a result from the API.
        try {
            Tasks.await(autocompletePredictions, 60, TimeUnit.SECONDS)
        } catch (e: ExecutionException) {
            e.printStackTrace()
        } catch (e: InterruptedException) {
            e.printStackTrace()
        } catch (e: TimeoutException) {
            e.printStackTrace()
        }

        if (autocompletePredictions.isSuccessful) {
            val findAutocompletePredictionsResponse = autocompletePredictions.result
            if (findAutocompletePredictionsResponse != null)
                for (prediction in findAutocompletePredictionsResponse.autocompletePredictions) {
                    Log.i(TAG, prediction.placeId)
                    resultList.add(
                        PlaceAutocomplete(
                            prediction.placeId,
                            prediction.getPrimaryText(STYLE_NORMAL).toString(),
                            prediction.getFullText(STYLE_BOLD).toString()
                        )
                    )
                }

            return resultList
        } else {
            return resultList
        }

    }

    override fun onCreateViewHolder(viewGroup: ViewGroup, i: Int): PredictionHolder {
        val layoutInflater =
            mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        val convertView =
            layoutInflater.inflate(R.layout.layout_list_item, viewGroup, false)
        return PredictionHolder(convertView)
    }

    override fun onBindViewHolder(mPredictionHolder: PredictionHolder, i: Int) {
        mPredictionHolder.tvName.text = mResultList!![i].area
        mPredictionHolder.tvAddress.text = mResultList!![i].address
    }

    override fun getItemCount(): Int {
        return mResultList!!.size
    }

    fun getItem(position: Int): PlaceAutocomplete {
        return mResultList!![position]
    }

    inner class PredictionHolder internal constructor(itemView: View) :
        RecyclerView.ViewHolder(itemView), View.OnClickListener {
        val ivImage: ImageView = itemView.findViewById<ImageView>(R.id.image)
        val tvName:TextView = itemView.findViewById<TextView>(R.id.name)
        val tvAddress: TextView = itemView.findViewById<TextView>(R.id.address)

        init {
            itemView.setOnClickListener(this)
        }

        override fun onClick(v: View) {
            val item = mResultList!![adapterPosition]
//            if (v.getId() === R.id.place_item_view) {

                val placeId = item.placeId.toString()

                val placeFields = Arrays.asList(
                    com.google.android.libraries.places.api.model.Place.Field.ID,
                    com.google.android.libraries.places.api.model.Place.Field.NAME,
                    com.google.android.libraries.places.api.model.Place.Field.LAT_LNG,
                    com.google.android.libraries.places.api.model.Place.Field.ADDRESS
                )
                val request = FetchPlaceRequest.builder(placeId, placeFields).build()
                placesClient.fetchPlace(request)
                    .addOnSuccessListener(OnSuccessListener<FetchPlaceResponse> { response ->
                        val place = response.getPlace()
                        clickListener!!.click(place)
                    }).addOnFailureListener(OnFailureListener { exception ->
                        if (exception is ApiException) {

                        }
                    })
//            }
        }
    }


    inner class PlaceAutocomplete internal constructor(
        var placeId: CharSequence,
        var area: CharSequence,
        var address: CharSequence
    ) {

        override fun toString(): String {
            return area.toString()
        }
    }

    companion object {
        private val TAG = "PlacesAutoAdapter"
    }
}