package com.quedrop.customer.ui.nearby.view

import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import androidx.fragment.app.Fragment
import com.quedrop.customer.R
import kotlinx.android.synthetic.main.activity_near_by_restaurant.*
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.ui.nearby.viewmodel.ListNearByViewModel
import com.quedrop.customer.utils.*


class NearByRestaurantActivity : BaseActivity() {

    var id: Int? = null
    var name: String? = null
    var bundle: Bundle? = null
    var flagAddStore = false
    var flagSearchClick: Boolean = false
    var flagMapFragment: Boolean = false
    var freshProduceCatId: Int? = 0
    lateinit var listNearByViewModel: ListNearByViewModel


    private var fragmentListNearBy: ListCustomerNearByFragment? = null
    private var fragmentMapNearBy: Fragment? = null

    var stringSearch: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_near_by_restaurant)

        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyGuestId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyAccessKey)!!
        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyUserId, 0)
        Utils.keyLatitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLatitude)!!
        Utils.keyLongitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLongitude)!!

        var intent = intent
        id = intent.getIntExtra(KeysUtils.KeyServiceCategoryId, 0)
        name = intent.getStringExtra(KeysUtils.KeyServiceCategoryName)
        if(intent.hasExtra(KeysUtils.KeyFreshProduceCategoryId)) {
            freshProduceCatId = intent.getIntExtra(KeysUtils.KeyFreshProduceCategoryId,0)
        }

        flagAddStore = false
        SharedPrefsUtils.setBooleanPreference(
            applicationContext,
            KeysUtils.keyAddStoreFlag,
            flagAddStore
        )

        bundle = Bundle()

        bundle!!.putInt(KeysUtils.KeyServiceCategoryId, id!!)
        bundle!!.putString(KeysUtils.KeyServiceCategoryName, name)
        bundle!!.putInt(KeysUtils.KeyFreshProduceCategoryId, freshProduceCatId!!)

        flagSearchClick = false
        flagMapFragment = false
        listNearByViewModel = ListNearByViewModel(appService)
        initMethod()
        onClickMethod()
    }

    private fun initMethod() {

        if (name?.isEmpty()!!) {
        } else {
            textTitleNearBy.text = name
        }


        nearByTabUnpress()
        ivListNear.setBackgroundResource(R.drawable.view_round_lnear_press)
        ivListNear.setImageResource(R.drawable.listnearicon_press)

        loadListNearFragment()

        ivListNear.setOnClickListener {

            flagMapFragment = false
            ivListNear.setBackgroundResource(R.drawable.view_round_lnear_press)
            ivListNear.setImageResource(R.drawable.listnearicon_press)
            ivMapNear.setImageResource(R.drawable.mapnearicon_unpress)
//            ivMapNear.setBackgroundResource(R.drawable.view_round_near_unpress)
            ivMapNear.background = null

            loadListNearFragment()
        }

        ivMapNear.setOnClickListener {

            flagMapFragment = true
            ivMapNear.setBackgroundResource(R.drawable.view_round_lnear_press)
            ivMapNear.setImageResource(R.drawable.mapnearicon_press)

            ivListNear.setImageResource(R.drawable.listnearicon_unpress)
//            ivListNear.setBackgroundResource(R.drawable.view_round_near_unpress)
            ivListNear.background = null

            loadMapNearFragment()
        }
    }

    private fun onClickMethod() {

        ivBack.throttleClicks().subscribe {
            if (!Utils.isKeyboardShown(applicationContext, constraintMain)) {
                onBackPressed()
            }
        }.autoDispose(compositeDisposable)

        editNearBy.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                stringSearch = null

                if (!s.toString().isNullOrEmpty()) {
                    flagSearchClick = true
                    stringSearch = s.toString()
                    bundle!!.putString(KeysUtils.KeyStringSearch, stringSearch)


                } else {
                    editNearBy.text.clear()
                    flagSearchClick = false
                    stringSearch = null
                    bundle!!.putString(KeysUtils.KeyStringSearch, stringSearch)
                }

                if (flagMapFragment) {
                    loadMapNearFragment()
                } else {
                    loadListNearFragment()
                }
            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

            }
        })

        clearText1.throttleClicks().subscribe {
            editNearBy.text.clear()
            flagSearchClick = false
            stringSearch = null
            bundle!!.putString(KeysUtils.KeyStringSearch, stringSearch)
            if (flagMapFragment) {
                loadMapNearFragment()
            } else {
                loadListNearFragment()
            }

        }.autoDispose(compositeDisposable)
    }

    private fun nearByTabUnpress() {
        ivListNear.setImageResource(R.drawable.listnearicon_press)
        ivListNear.setImageResource(R.drawable.mapnearicon_press)

    }

    private fun loadListNearFragment() {
        searchConstraint.isFocusableInTouchMode = true

        val transaction = supportFragmentManager.beginTransaction()

        fragmentListNearBy = ListCustomerNearByFragment()
        fragmentListNearBy!!.arguments = bundle
        transaction.replace(R.id.fragmentListView, fragmentListNearBy!!)
        transaction.commit()
    }

    private fun loadMapNearFragment() {

        searchConstraint.isFocusableInTouchMode = true

        val transaction = supportFragmentManager.beginTransaction()

        fragmentMapNearBy = MapCustomerNearByFragment()
        fragmentMapNearBy!!.arguments = bundle
        transaction.replace(R.id.fragmentListView, fragmentMapNearBy!!)
        transaction.commit()

    }
}
