package com.quedrop.customer.ui.home.view.adapter

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.viewpager.widget.ViewPager
import android.view.ViewGroup
import androidx.fragment.app.FragmentPagerAdapter
import com.quedrop.customer.ui.favourite.view.FavouriteCustomerFragment
import com.quedrop.customer.ui.home.view.fragment.*
import com.quedrop.customer.ui.notification.view.NotificationCustomFragment
import com.quedrop.customer.ui.order.view.fragment.OrderCustomerFragment
import com.quedrop.customer.ui.profile.view.ProfileCustomerFragment


class MainViewPagerAdapter(fm: FragmentManager) : FragmentPagerAdapter(fm),
    ViewPager.OnPageChangeListener {

    private val fragments = mutableListOf<Fragment>()

    override fun getItem(position: Int): Fragment {
        return fragments[position]
    }

    override fun getCount(): Int {
        return fragments.size
    }

    fun addFragment(fragment: Fragment) {
        fragments.add(fragment)
    }

    override fun instantiateItem(container: ViewGroup, position: Int): Any {
        val fragment = super.instantiateItem(container, position) as Fragment
        fragments[position] = fragment
        return fragment
    }

    override fun destroyItem(container: ViewGroup, position: Int, `object`: Any) {
        fragments.removeAt(position)
        super.destroyItem(container, position, `object`)
    }


    override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {
    }

    override fun onPageSelected(position: Int) {

        when (val fragment = getItem(position)) {
            is HomeCustomerFragment -> {
                fragment.onPageSelected(position)

            }
            is NotificationCustomFragment -> {
                fragment.onPageSelected(position)

            }
            is OrderCustomerFragment -> {
                fragment.onPageSelected(position)

            }
            is FavouriteCustomerFragment -> {
                fragment.onPageSelected(position)
            }
            is ProfileCustomerFragment -> {
                fragment.onPageSelected(position)
            }
        }
    }

    override fun getItemPosition(`object`: Any): Int {
        return POSITION_NONE
    }


    override fun onPageScrollStateChanged(state: Int) {
    }

}