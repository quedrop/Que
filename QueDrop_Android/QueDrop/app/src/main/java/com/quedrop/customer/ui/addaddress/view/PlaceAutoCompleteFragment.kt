package com.quedrop.customer.ui.addaddress.view

import android.app.Activity.RESULT_OK
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.LinearLayoutManager
import com.quedrop.customer.R
import android.text.Editable
import android.text.TextWatcher
import android.widget.EditText
import android.widget.ImageView
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.utils.Utils
import com.google.android.libraries.places.api.model.Place
import com.quedrop.customer.ui.selectaddress.view.SelectAddressActivity
import com.quedrop.customer.utils.ConstantUtils
import com.quedrop.customer.utils.RxBus


open class PlaceAutoCompleteFragment : BaseFragment(), PlacesAutoCompleteAdapter.ClickListener {

    var mAutoCompleteAdapter: PlacesAutoCompleteAdapter? = null
    lateinit var mRecyclerView: RecyclerView
    lateinit var clearText: ImageView
    lateinit var editAddress: EditText
    var isFromHomeScreen: Boolean = false

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        val view = inflater.inflate(
            R.layout.fragment_place_autocomplete,
            container, false
        )

        initMethod(view)
        onClickMethod()

        return view
    }

    private fun initMethod(view: View) {

        mRecyclerView = view.findViewById(R.id.mRecyclerView) as RecyclerView
        editAddress = view.findViewById(R.id.editAddress) as EditText
        clearText = view.findViewById(R.id.clearText1) as ImageView

        editAddress.setText(Utils.textAddress)

        editAddress.isCursorVisible = true
        editAddress.isFocusable = true
        mRecyclerView.setHasFixedSize(true)
        val llm = LinearLayoutManager(this.context)
        mRecyclerView.layoutManager = llm

        mAutoCompleteAdapter = PlacesAutoCompleteAdapter(activity)
        mRecyclerView.adapter = mAutoCompleteAdapter

        mAutoCompleteAdapter!!.setClickListener(this)

    }

    private fun onClickMethod() {

        editAddress.addTextChangedListener(filterTextWatcher)

        clearText.throttleClicks().subscribe {
            editAddress.setText("")
            if (mAutoCompleteAdapter != null) {
                mRecyclerView.adapter = null
            }
            mRecyclerView.adapter = mAutoCompleteAdapter
        }.autoDispose(compositeDisposable)

    }


    private val filterTextWatcher = object : TextWatcher {

        override fun afterTextChanged(s: Editable) {

            if (s.toString() != "") {
                mAutoCompleteAdapter?.filter?.filter(s.toString())
                if (mRecyclerView.visibility == View.GONE) {
                    mRecyclerView.visibility = View.VISIBLE
                }
            }
        }

        override fun beforeTextChanged(s: CharSequence, start: Int, count: Int, after: Int) {}
        override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {

        }
    }

    override fun click(place: Place) {
        if (isFromHomeScreen) {
            val intent = Intent()
            intent.putExtra("place", place)
            activity.setResult(ConstantUtils.REQUEST_CODE_SEARCH_ADDRESS, intent)
            activity.finish()
        } else {
            (activity as AddAddressActivity).updateDataInLocationPicker(place)
        }
    }

    fun setEditData(text: String, isFromHome: Boolean) {
        isFromHomeScreen = isFromHome
        editAddress.setText(text)
    }
}