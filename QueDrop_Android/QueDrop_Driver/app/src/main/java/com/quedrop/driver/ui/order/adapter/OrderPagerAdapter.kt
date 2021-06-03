package com.quedrop.driver.ui.order.adapter

import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import androidx.viewpager.widget.ViewPager
import com.quedrop.driver.ui.order.view.CurrentOrderFragment
import com.quedrop.driver.ui.order.view.PastOrderFragment
import io.reactivex.disposables.CompositeDisposable


class OrderPagerAdapter(
    fm: FragmentManager,
    var viewpagerOrder: ViewPager
) : FragmentPagerAdapter(
    fm,
    BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT
),
    ViewPager.OnPageChangeListener {

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
        viewpagerOrder.currentItem=position
        val fragment = getItem(position)

        if (fragment is CurrentOrderFragment) {
            fragment.onPageSelected(position)

        } else if (fragment is PastOrderFragment) {
            fragment.onPageSelected(position)

        }
    }

    override fun onPageScrollStateChanged(state: Int) {
    }


}