package com.quedrop.customer.ui.home.view.fragment

import android.app.Activity.RESULT_OK
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.model.User
import com.quedrop.customer.ui.explore.view.ExploreFragment
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.home.view.adapter.MainViewPagerAdapter
import com.quedrop.customer.ui.login.view.LoginActivity
import com.quedrop.customer.ui.notification.view.NotificationCustomFragment
import com.quedrop.customer.ui.order.view.fragment.OrderCustomerFragment
import com.quedrop.customer.ui.profile.view.ProfileCustomerFragment
import com.quedrop.customer.utils.*
import kotlinx.android.synthetic.main.activity_home_supplier.*
import kotlinx.android.synthetic.main.fragment_customer_main.*


class CustomerMainFragment : BaseFragment() {

    private val TAG = CustomerMainFragment::class.java.simpleName

    private var tempString: String? = null
    private var favIntent: String? = null
    var flagAddStore = false
    var orderId: Int = 0

    private lateinit var adapter: MainViewPagerAdapter
    private var tabPosition: Int? = null
    private var remoteMessage: String = ""

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_customer_main, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        favIntent = (activity as CustomerMainActivity).intent.getStringExtra(KeysUtils.keyFavViewPager)
        flagAddStore = false
        SharedPrefsUtils.setBooleanPreference(
            this.requireContext(),
            KeysUtils.keyAddStoreFlag,
            flagAddStore
        )

        try {
            val user: User = SharedPrefsUtils.getModelPreferences(
                this.requireContext(),
                KeysUtils.keyUser,
                User::class.java
            ) as User
            if (user.is_guest == 0) {
                Utils.userId = user.user_id
                Utils.guestId = 0

                SharedPrefsUtils.setIntegerPreference(
                    this.requireContext(),
                    KeysUtils.keyUserId,
                    Utils.userId
                )

                SharedPrefsUtils.setIntegerPreference(
                    this.requireContext(),
                    KeysUtils.keyGuestId,
                    Utils.guestId
                )
                SharedPrefsUtils.setIntegerPreference(
                    this.requireContext(),
                    KeysUtils.keyIsGuest,
                    user.is_guest
                )

            }


        } catch (e: Exception) {
        }
        initMethod()

    }

    private fun initMethod() {
        setTabLayout()
    }

    private fun setTabLayout() {
        try {

            (activity as CustomerMainActivity).intent?.let { intent ->
                intent.getStringExtra(KeysUtils.keyCustomer)?.let {
                    Log.e(TAG, it)
                    tempString = it
                }
                intent.getIntExtra(KeysUtils.keyOrderId, 0).let {
                    Log.e(TAG, it.toString())
                    orderId = it
                }
                intent.getStringExtra(KeysUtils.KeyRemoteMessage).let {
                    if (it != null) {
                        Log.e(TAG, it.toString())
                        remoteMessage = it
                    }
                }
            }


            adapter = MainViewPagerAdapter(parentFragmentManager)

            adapter.addFragment(HomeCustomerFragment.newInstance())
            //adapter.addFragment(NotificationCustomFragment.newInstance())
            adapter.addFragment(OrderCustomerFragment.newInstance(orderId, remoteMessage))
            adapter.addFragment(ExploreFragment.newInstance())
            //adapter.addFragment(FavouriteCustomerFragment.newInstance())
            adapter.addFragment(ProfileCustomerFragment.newInstance())

            Utils.userId =
                SharedPrefsUtils.getIntegerPreference(this.requireContext(), KeysUtils.keyUserId, 0)
            viewPager.adapter = adapter

            when (tempString) {
                resources.getString(R.string.orderScreen) -> {
                    viewPager.currentItem = ConstantUtils.TWO
                }
                resources.getString(R.string.favouriteScreen) ->
                    viewPager.currentItem = ConstantUtils.THREE

                getString(R.string.fromSettingAddress) ->
                    viewPager.currentItem = ConstantUtils.FOUR

                resources.getString(R.string.chat_remote_message) ->
                    viewpager.currentItem = ConstantUtils.TWO
            }

            viewPager.offscreenPageLimit = 3
            viewPager.addOnPageChangeListener(adapter)
            tabLayout.setupWithViewPager(viewPager)
            tabUndressed()
//            setupTabs()

        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun tabUndressed() {
        tabLayout.getTabAt(ConstantUtils.ZERO)!!.setIcon(R.drawable.tab_home).text = resources.getString(R.string.homeTab)
        //tabLayout.getTabAt(ConstantUtils.ONE)!!.setIcon(R.drawable.tab_notification).text = resources.getString(R.string.notificationTab)
        tabLayout.getTabAt(ConstantUtils.ONE)!!.setIcon(R.drawable.tab_order).text = resources.getString(R.string.orderTab)
        tabLayout.getTabAt(ConstantUtils.TWO)!!.setIcon(R.drawable.tab_explore).text = resources.getString(R.string.exploreTab)
        // tabLayout.getTabAt(ConstantUtils.FOUR)!!.setIcon(R.drawable.tab_fav).text = resources.getString(R.string.favoriteTab)
        tabLayout.getTabAt(ConstantUtils.THREE)!!.setIcon(R.drawable.tab_profile).text = resources.getString(R.string.profileTab)
    }


    private fun setupTabs() {
        for (i in 0 until tabLayout.tabCount) {
            val tab = tabLayout.getTabAt(i)

            @Suppress("INACCESSIBLE_TYPE")
            (tab?.view as? View)?.setOnTouchListener(object : View.OnTouchListener {

                override fun onTouch(p0: View?, event: MotionEvent): Boolean {

                    if (Utils.userId == 0) {

                        if (event.action == MotionEvent.ACTION_DOWN) {
                            return true
                        } else if (event.action == MotionEvent.ACTION_UP) {
                            tabPosition = i

                            if (i == TabEnums.DASHBOARD.posVal || i == TabEnums.PROFILE.posVal) {
                                viewPager.currentItem = tabPosition!!
                            } else {

                                startActivityForResult(
                                    Intent(context, LoginActivity::class.java),
                                    ConstantUtils.REQUEST_LOGIN_ORDER
                                )
                            }

                        }
                        return false
                    }
                    return false
                }
            })


        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        // In fragment class callback
        if (resultCode == RESULT_OK) {
            when (requestCode) {

                ConstantUtils.REQUEST_LOGIN_ORDER -> {
                    Utils.userId =
                        SharedPrefsUtils.getIntegerPreference(
                            this.requireContext(),
                            KeysUtils.keyUserId,
                            0
                        )

                    viewPager.currentItem = tabPosition!!
                }
            }
        }
    }
}