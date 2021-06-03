package com.quedrop.customer.ui.storeadd.view

import android.app.Activity
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.ui.addaddress.view.PlacesAutoCompleteAdapter
import com.quedrop.customer.utils.KeysUtils
import com.google.android.libraries.places.api.model.Place
import kotlinx.android.synthetic.main.activity_placeauto_complete_search.*

class PlaceAutoCompleteSearchActivity : BaseActivity(),
    PlacesAutoCompleteAdapter.ClickListener {

    var mAutoCompleteAdapter: PlacesAutoCompleteAdapter? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_placeauto_complete_search)

        initMethod()
        onClickMethod()
    }

    private fun initMethod(){

        mRecyclerView!!.setHasFixedSize(true)
        val llm = LinearLayoutManager(applicationContext)
        mRecyclerView!!.layoutManager = llm
        mAutoCompleteAdapter = PlacesAutoCompleteAdapter(
            applicationContext
        )
        mRecyclerView!!.adapter = mAutoCompleteAdapter


        mAutoCompleteAdapter!!.setClickListener(this)
    }

    private fun onClickMethod(){

        editAddressPlace.addTextChangedListener(filterTextWatcher)

        ivCrossPlace.throttleClicks().subscribe {

            onBackPressed()
        }.autoDispose(compositeDisposable)

        ivClearPlace.throttleClicks().subscribe {
            editAddressPlace.setText("")
            if (mAutoCompleteAdapter != null) {
                mRecyclerView.adapter = null
            }
            mRecyclerView!!.adapter = mAutoCompleteAdapter
        }.autoDispose(compositeDisposable)

    }

    private val filterTextWatcher = object : TextWatcher {

        override fun afterTextChanged(s: Editable) {

            if (s.toString() != "") {
                mAutoCompleteAdapter?.filter?.filter(s.toString())
                if (mRecyclerView.visibility == View.GONE) {
                    mRecyclerView.visibility = View.VISIBLE
                }
            } else {
                if (mRecyclerView.visibility == View.VISIBLE) {
                    mRecyclerView.visibility = View.GONE
                }
            }
        }

        override fun beforeTextChanged(s: CharSequence, start: Int, count: Int, after: Int) {}
        override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {}
    }

    override fun click(place: Place) {
        val intent = intent
        intent.putExtra(KeysUtils.keyPlaceId, place.id)
        intent.putExtra(KeysUtils.keyPlaceTitle, place.name)
        intent.putExtra(KeysUtils.keyPlaceAddress, place.address)
        intent.putExtra(KeysUtils.keyPlaceLatitude, place.latLng?.latitude)
        intent.putExtra(KeysUtils.keyPlaceLongitude,place.latLng?.longitude)
        setResult(Activity.RESULT_OK, intent)
        finish()
    }

}
