package com.quedrop.customer.ui.supplier

import android.util.Log
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import androidx.viewpager.widget.ViewPager
import io.reactivex.disposables.CompositeDisposable


class SupplierMainViewPagerAdapter(fm: FragmentManager) : FragmentPagerAdapter(
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

    }


    override fun onPageScrollStateChanged(state: Int) {
    }


}