package com.quedrop.customer.ui.addaddress.view

import android.os.Bundle
import androidx.fragment.app.Fragment
import com.quedrop.customer.R
import com.google.android.libraries.places.api.model.Place
import kotlinx.android.synthetic.main.activity_add_address.*


import android.view.MenuItem
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.ui.addaddress.viewmodel.AddAddressViewModel
import com.quedrop.customer.utils.ConstantUtils
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils


class AddAddressActivity : BaseActivity() {
    private var fragmentLocationPicker: Fragment? = null
    private var placeAutoCompleteFragment1: Fragment? = null
    private var isPlaceFragment = false

    var addressId: String = ""
    var addressTitle: String = ""
    var latitude: String = ""
    var longitude: String = ""
    var unitNumber: String = ""
    var addressType: String = ""
    var address: String = ""
    var editFlag: Boolean = false
    var fromHomeSearchClick: Boolean = false
    lateinit var addAddressViewModel: AddAddressViewModel


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_address)

        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyGuestId, 0)
        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyUserId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyAccessKey)!!
        Utils.is_default = SharedPrefsUtils.getIntegerPreference(
            applicationContext,
            KeysUtils.keyIsDefault,
            ConstantUtils.ONE
        )

        addAddressViewModel = AddAddressViewModel(appService)
        editFlag = intent.getBooleanExtra(KeysUtils.keyEdit, false)
        fromHomeSearchClick = intent.getBooleanExtra(KeysUtils.KeyIsFromHomeScreenSearch, false)
        placeAutoCompleteFragment1 =
            supportFragmentManager.findFragmentById(R.id.placeAutoCompleteFragment)

        if (editFlag) {
            tvTitle.text = getString(R.string.edit_address)
            val extras: Bundle? = intent.extras
            if (extras != null) {
                addressId = extras.getString(KeysUtils.address_id)!!
                addressTitle = extras.getString(KeysUtils.address_title)!!
                latitude = extras.getString(KeysUtils.latitude)!!
                longitude = extras.getString(KeysUtils.longitude)!!
                unitNumber = extras.getString(KeysUtils.unit_number)!!
                addressType = extras.getString(KeysUtils.address_type)!!
                address = extras.getString(KeysUtils.address)!!

                openLocationPickerFragment()
            }
        } else if (fromHomeSearchClick) {
            tvTitle.text = getString(R.string.addAddress)
            val extras: Bundle? = intent.extras
            if (extras != null) {
                address = extras.getString(KeysUtils.address)!!
                addressTitle = extras.getString(KeysUtils.address_title)!!

                showPlaceSearchFragment(true, address)
            }
        } else {
            val extras: Bundle? = intent.extras
            if (extras != null) {
                tvTitle.text = getString(R.string.addAddress)
                latitude = extras.getString(KeysUtils.latitude)!!
                longitude = extras.getString(KeysUtils.longitude)!!
                address = extras.getString(KeysUtils.address)!!
                addressTitle = extras.getString(KeysUtils.address_title)!!

                openLocationPickerFragment()
            }
        }


        ivBack.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

    }

    private fun openLocationPickerFragment() {
        val transaction = supportFragmentManager.beginTransaction()
        fragmentLocationPicker = LocationPickerFragment()
        transaction.replace(R.id.fragmentLocationPicker, fragmentLocationPicker!!)
        transaction.commit()
    }

    fun showPlaceSearchFragment(isVisible: Boolean, text: String) {
        val transaction = supportFragmentManager.beginTransaction()
        if (isVisible) {
            isPlaceFragment = true
            (placeAutoCompleteFragment1 as PlaceAutoCompleteFragment).setEditData(text, true)
            transaction.show(placeAutoCompleteFragment1!!)
        } else {
            isPlaceFragment = false
            (placeAutoCompleteFragment1 as PlaceAutoCompleteFragment).setEditData(text, false)
            transaction.hide(placeAutoCompleteFragment1!!)
        }
        transaction.commit()
    }


    fun updateDataInLocationPicker(place: Place) {
        showPlaceSearchFragment(false, Utils.textAddress)
        (fragmentLocationPicker as LocationPickerFragment).updateData(place)
    }


    override fun onBackPressed() {
        if (!isPlaceFragment) {
            finish()
        } else if (fromHomeSearchClick) {
            finish()
        } else {
            showPlaceSearchFragment(false, Utils.textAddress)
        }
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            android.R.id.home -> {
                onBackPressed()
                return false
            }
            else -> super.onOptionsItemSelected(item)
        }
    }
}
