package com.quedrop.driver.ui.mainFragment

import android.util.Log
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import androidx.viewpager.widget.ViewPager
import com.quedrop.driver.ui.earnings.view.EarningsFragment
import com.quedrop.driver.ui.homeFragment.view.HomeFragment
import com.quedrop.driver.ui.notificationFragment.NotificationFragment
import com.quedrop.driver.ui.order.view.OrderListFragment
import com.quedrop.driver.ui.profile.view.ProfileFragment
import io.reactivex.disposables.CompositeDisposable


class MainViewPagerAdapter(fm: FragmentManager) : FragmentPagerAdapter(
    fm,
    BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT
), ViewPager.OnPageChangeListener {

    protected val compositeDisposable = CompositeDisposable()

    override fun getItem(position: Int): Fragment {
        return mCurrentFragmentList[position]
    }

    override fun getCount(): Int {
        return mCurrentFragmentList.size
    }

    var mCurrentFragmentList: MutableList<Fragment> = mutableListOf()


    override fun instantiateItem(container: ViewGroup, position: Int): Any {
        val fragment = super.instantiateItem(container, position) as Fragment

        mCurrentFragmentList[position] = fragment
        return fragment
    }

    override fun destroyItem(container: ViewGroup, position: Int, `object`: Any) {
        mCurrentFragmentList.removeAt(position)
        super.destroyItem(container, position, `object`)
    }


    override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {
    }

    override fun onPageSelected(position: Int) {

        val fragment = getItem(position)
        Log.e("MainPagerAdapter: ", "==>$position")

        if (fragment is HomeFragment) {
            fragment.onPageSelected(position)

        } else if (fragment is NotificationFragment) {
            fragment.onPageSelected(position)

        } else if (fragment is OrderListFragment) {
            fragment.onPageSelected(position)

//        } else if (fragment is EarningsFragment) {
//            fragment.onPageSelected(position)

        } else if (fragment is ProfileFragment) {
            fragment.onPageSelected(position)
        }

    }


    override fun onPageScrollStateChanged(state: Int) {
    }


}