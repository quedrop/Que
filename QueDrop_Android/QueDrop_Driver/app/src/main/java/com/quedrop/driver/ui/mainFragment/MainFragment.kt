package com.quedrop.driver.ui.mainFragment

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseFragment
import com.quedrop.driver.service.model.User
import com.quedrop.driver.ui.chat.ChatActivity
import com.quedrop.driver.ui.earnings.view.EarningsFragment
import com.quedrop.driver.ui.homeFragment.view.HomeFragment
import com.quedrop.driver.ui.mainActivity.view.MainActivity
import com.quedrop.driver.ui.notificationFragment.NotificationFragment
import com.quedrop.driver.ui.order.view.OrderListFragment
import com.quedrop.driver.ui.orderDetailsFragment.view.OrderDetailActivity
import com.quedrop.driver.ui.profile.view.ProfileFragment
import com.quedrop.driver.utils.ENUMNotificationType
import com.quedrop.driver.utils.KEY_USER
import com.quedrop.driver.utils.NOTI_LOGS
import com.quedrop.driver.utils.SharedPreferenceUtils
import kotlinx.android.synthetic.main.fragment_main.*
import org.json.JSONException
import org.json.JSONObject


class MainFragment : BaseFragment() {

    private var remoteMessage: String = ""

    private val fragmentList: MutableList<Fragment> = mutableListOf()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_main, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        (activity as MainActivity).intent?.let { intent ->

            intent.getStringExtra("remote_message").let {
                if (it != null) {
                    Log.i(NOTI_LOGS,"Main Fragment"+ it.toString())
                    remoteMessage = it
                }
            }
        }
        globalUserId =
            (SharedPreferenceUtils.getModelPreferences(KEY_USER, User::class.java) as User).userId!!

        setTabLayout()
    }

    private fun setTabLayout() {
        val homeFragment = HomeFragment.newInstance(remoteMessage)
        // homeFragment.onPageSelected(0)
        fragmentList.add(homeFragment)
        fragmentList.add(NotificationFragment.newInstance())
        fragmentList.add(OrderListFragment.newInstance())
        //fragmentList.add(EarningsFragment.newInstance())
        fragmentList.add(ProfileFragment.newInstance())

        val viewPagerAdapter =
            MainViewPagerAdapter(
                childFragmentManager
            )
        viewPagerAdapter.mCurrentFragmentList = fragmentList

        viewpagerMain.adapter = viewPagerAdapter
        viewpagerMain.currentItem = 0
        viewpagerMain.offscreenPageLimit = 3
        viewpagerMain.addOnPageChangeListener(viewPagerAdapter)

        tabs.setupWithViewPager(viewpagerMain)
        tabs.getTabAt(0)?.setIcon(R.drawable.tab_home)!!.text = resources.getString(R.string.home)
        tabs.getTabAt(1)?.setIcon(R.drawable.tab_notification)!!.text = resources.getString(R.string.notification)
        tabs.getTabAt(2)?.setIcon(R.drawable.tab_order)!!.text = resources.getString(R.string.order)
        //tabs.getTabAt(3)?.setIcon(R.drawable.tab_earning)!!.text = resources.getString(R.string.earnings)
        tabs.getTabAt(3)?.setIcon(R.drawable.tab_profile)!!.text = resources.getString(R.string.profile)

        setNotificationData(remoteMessage)

    }


    fun openOderScreen() {
        viewpagerMain.currentItem = 2
    }

    fun openEarningScreen() {
        viewpagerMain.currentItem = 3
    }



    companion object {
        fun newInstance(): MainFragment {
            return MainFragment()
        }
    }

    private fun setNotificationData(remoteMessage: String?) {
        try {

            Log.i(NOTI_LOGS,"Main Fragment remoteMessage=>"+ remoteMessage)
            val jsonObject = JSONObject(remoteMessage!!)
            val notificationType = Integer.parseInt(jsonObject.getString("notification_type"))
//            if (notificationType == ENUMNotificationType.ORDER_REQUEST.posVal) {

//                val intent = Intent(context, RequestDetailActivity::class.java)
//                intent.putExtra("remote_message", remoteMessage)
////                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
//              //  intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                startActivity(intent)


//            } else

                if (notificationType == ENUMNotificationType.ORDER_DISPATCH.posVal) {
                val intent = Intent(context, OrderDetailActivity::class.java)
                intent.putExtra("remote_message", remoteMessage)
                startActivity(intent)

            } else if (notificationType == ENUMNotificationType.CHAT.posVal) {
                val intent = Intent(context, ChatActivity::class.java)
                intent.putExtra("remote_message", remoteMessage)
                startActivity(intent)
            }
        } catch (e: JSONException) {
            e.printStackTrace()
        }

    }

}
