package com.quedrop.driver.ui.order.view

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.quedrop.driver.R
import com.quedrop.driver.ui.order.adapter.OrderPagerAdapter
import kotlinx.android.synthetic.main.fragment_order_list.*
import kotlinx.android.synthetic.main.toolbar_login.*

/**
 * A simple [Fragment] subclass.
 */
class OrderListFragment : Fragment() {
    private val fragmentList: MutableList<Fragment> = mutableListOf()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.fragment_order_list, container, false)
        return view
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setUpToolbar()
        setTabLayout()
    }

    private fun setUpToolbar() {
        tvTitleLogin.text = getString(R.string.order)
    }

    private fun setTabLayout() {
        val currentOrderFragment = CurrentOrderFragment.newInstance()
//        currentOrderFragment.onPageSelected(0)
        fragmentList.add(currentOrderFragment)
        fragmentList.add(PastOrderFragment.newInstance())

        val viewPagerAdapter =
            OrderPagerAdapter(
                childFragmentManager, viewpagerOrder
            )
        viewPagerAdapter.mCurrentFragmentList = fragmentList

        viewpagerOrder.currentItem = 0
        viewpagerOrder.offscreenPageLimit = 2

        viewpagerOrder.adapter = viewPagerAdapter
        viewpagerOrder.addOnPageChangeListener(viewPagerAdapter)

        orderTabs.setupWithViewPager(viewpagerOrder)
        orderTabs.getTabAt(0)!!.text = resources.getString(R.string.current_order)
        orderTabs.getTabAt(1)?.text = resources.getString(R.string.past_order)

    }

    fun onPageSelected(position: Int) {
        Log.e("OrderFragment: ", "==>$position")
    }

    companion object {
        fun newInstance(): OrderListFragment {
            return OrderListFragment()
        }
    }
}
