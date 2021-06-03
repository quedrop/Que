package com.quedrop.customer.ui.supplier

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityWithAnimation
import com.quedrop.customer.socket.SocketConstants
import com.quedrop.customer.ui.supplier.category.SupplierCategoryFragment
import com.quedrop.customer.ui.supplier.earnings.EarnPaymentFragment
import com.quedrop.customer.ui.supplier.myorders.SupplierOrderDetailActivity
import com.quedrop.customer.ui.supplier.myorders.SupplierOrderFragment
import com.quedrop.customer.ui.supplier.notifications.SupplierNotificationFragment
import com.quedrop.customer.ui.supplier.offers.SupplierOfferFragment
import com.quedrop.customer.ui.supplier.profile.ProfileSupplierFragment
import com.quedrop.customer.utils.*
import com.quedrop.customer.utils.localnotification.MyNotificationPublisher
import kotlinx.android.synthetic.main.activity_home_supplier.*
import org.json.JSONException
import org.json.JSONObject
import timber.log.Timber

class HomeSupplierActivity : BaseActivity() {

    private val fragmentList: MutableList<Fragment> = mutableListOf()
    private var remoteMessage: String = ""


    // get Socket event
    private val eventUpdate = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val events = intent.getStringExtra(BroadCastConstant.BROADCAST_KEY_EVENT)!!
            try {
                val jsonObject =
                    JSONObject(intent.getStringExtra(BroadCastConstant.BROADCAST_KEY_OBJ)!!)
                parseResponse(events, jsonObject)

            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }

    private fun parseResponse(event: String, argument: JSONObject) {
        val userId = SharedPrefsUtils.getIntegerPreference(this, KeysUtils.KeyUserSupplierId, 0)
        val storeId = SharedPrefsUtils.getIntegerPreference(this, KeysUtils.keySupplierStoreId, 0)

        when (event) {
            SocketConstants.SocketSupplierChangeAcknowledge -> {
                val messageJson = JSONObject(argument.toString())
                val store_id = messageJson.getString("store_id")
                val message = messageJson.getString("message")
                val user_id = messageJson.getString("user_id").toInt()
                val is_revoke = messageJson.getString("is_revoke")

                if (userId == user_id && storeId == store_id.toInt() && is_revoke.toInt() == 1) {
                    SharedPrefsUtils.setIntegerPreference(
                        mcontext,
                        KeysUtils.PREF_KEY_IS_REVOKE,
                        is_revoke.toInt()
                    )
                    SharedPrefsUtils.setStringPreference(
                        this,
                        KeysUtils.PREF_KEY_REVOKE_MESSAGE,
                        message
                    )
                    showAlert(message)
                } else {
                    SharedPrefsUtils.setIntegerPreference(
                        mcontext,
                        KeysUtils.PREF_KEY_IS_REVOKE,
                        is_revoke.toInt()
                    )
                }
            }


            SocketConstants.SocektSupplierWeeklyPaymentAcknowledge -> {
                val user_id = argument.getString("user_id")
                val store_id = argument.getString("store_id")
                val message = argument.getString("message")
                val title = argument.getString("title")

                if (user_id.toInt() == userId && store_id.toInt() == storeId)
                    MyNotificationPublisher.scheduleNotification(
                        this,
                        MyNotificationPublisher.getNotification(this, title, message), 100
                    )
            }
            SocketConstants.SocketSupplierStoreVerification -> {

                val user_id = argument.getString("user_id")
                val store_id = argument.getString("store_id")
                val is_verified = argument.getString("is_verfied")
                val strMessage = argument.getString("message")
                val title = argument.getString("title")

                if (user_id.toInt() == userId && store_id.toInt() == storeId) {
                    MyNotificationPublisher.scheduleNotification(
                        this,
                        MyNotificationPublisher.getNotification(this, title, strMessage), 100
                    )
                }
            }
        }
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_home_supplier)

        setTabLayout()

        intent.getStringExtra(KeysUtils.KeyRemoteMessage).let {
            if (it != null) {
                remoteMessage = it
            }
        }

        intent.getBooleanExtra(KeysUtils.isSuplplierWeeklyEarning, false).let {
            if (it) {
                viewpager.currentItem = 2
            }
        }

        LocalBroadcastManager.getInstance(applicationContext).registerReceiver(
            eventUpdate,
            IntentFilter(BroadCastConstant.BROADCAST_EVENT_CHANGE)
        )

        Utils.Supplier.supplierUserId =
            SharedPrefsUtils.getIntegerPreference(this, KeysUtils.KeyUserSupplierId, 0)
        Utils.seceretKey = SharedPrefsUtils.getStringPreference(this, KeysUtils.keySecretKey)!!
        Utils.Supplier.supplierAccessKey =
            SharedPrefsUtils.getStringPreference(this, KeysUtils.KeySupplierAccessKey)!!
        Utils.Supplier.supplierStoreID =
            SharedPrefsUtils.getIntegerPreference(this, KeysUtils.keySupplierStoreId, 0)

        //**********************************************************//
        joinSupplierSocket()
        //**********************************************************//

        if (remoteMessage.isNotEmpty()) {
            val jsonObject = JSONObject(remoteMessage)
            val orderId = jsonObject.getString("order_id").toInt()
            val notificationType = jsonObject.getString("notification_type").toInt()
            this.startActivityWithAnimation<SupplierOrderDetailActivity> {
                putExtra("order_id", orderId)
            }
            if (notificationType == ENUMNotificationType.NOTIFICATION_SUPPLIER_WEEKLY_PAYMENT.posVal) {
                viewpager.currentItem = 2
            }
        }
    }

    private fun setTabLayout() {
        val homeFragment = SupplierCategoryFragment.newInstance()
        fragmentList.add(homeFragment)
        fragmentList.add(SupplierOrderFragment.newInstance())
        //fragmentList.add(EarnPaymentFragment.newInstance())
        fragmentList.add(SupplierNotificationFragment.newInstance())
        fragmentList.add(SupplierOfferFragment.newInstance())
        fragmentList.add(ProfileSupplierFragment.newInstance())

        val viewPagerAdapter = SupplierMainViewPagerAdapter(supportFragmentManager)
        viewPagerAdapter.mCurrentFragmentList = fragmentList

        viewpager.adapter = viewPagerAdapter
        viewpager.currentItem = 0
        viewpager.offscreenPageLimit = 4
        viewpager.addOnPageChangeListener(viewPagerAdapter)

        tabs.setupWithViewPager(viewpager)
        tabs.getTabAt(0)?.setIcon(R.drawable.supplier_tab_category)!!.text =
            resources.getString(R.string.S_Category_Tab)
        tabs.getTabAt(1)?.setIcon(R.drawable.supplier_tab_order)!!.text =
            resources.getString(R.string.S_Order_Tab)
//        tabs.getTabAt(2)?.setIcon(R.drawable.supplier_tab_earnings)!!.text =
//          resources.getString(R.string.S_Earnings_Tab)
        tabs.getTabAt(2)?.setIcon(R.drawable.supplier_tab_notification)!!.text =
            resources.getString(R.string.S_Notification_Tab)
        tabs.getTabAt(3)?.setIcon(R.drawable.supplier_tab_offer)!!.text =
            resources.getString(R.string.S_Offers_Tab)
        tabs.getTabAt(4)?.setIcon(R.drawable.supplier_tab_profile)!!.text =
            resources.getString(R.string.S_Profile_Tab)

    }

    class PageAdapter(fragmentActivity: FragmentActivity, private val fragments: List<Fragment>) :
        FragmentStateAdapter(fragmentActivity) {

        override fun getItemCount(): Int {
            return fragments.size
        }

        override fun createFragment(position: Int): Fragment {
            return fragments[position]
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        LocalBroadcastManager.getInstance(applicationContext).unregisterReceiver(eventUpdate)
    }
}
