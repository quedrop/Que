package com.quedrop.driver.ui.earnings.view

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup

import com.quedrop.driver.R
import com.quedrop.driver.ui.earnings.adapter.EarningPagerAdapter
import kotlinx.android.synthetic.main.fragment_earnings.*
import kotlinx.android.synthetic.main.toolbar_login.*

/**
 * A simple [Fragment] subclass.
 */
class EarningsFragment : Fragment() {
    private val fragmentList: MutableList<Fragment> = mutableListOf()

    companion object {
        fun newInstance(): EarningsFragment {
            return EarningsFragment()
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_earnings, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setUpToolbar()
        setTabLayout()
    }

    private fun setUpToolbar() {
        tvTitleLogin.text = getString(R.string.earnings)
    }

    private fun setTabLayout() {
        fragmentList.add(ManualStoreFragment.newInstance())
        fragmentList.add(EarnPaymentFragment.newInstance())

        val viewPagerAdapter =
            EarningPagerAdapter(
                childFragmentManager, vpEarning
            )
        viewPagerAdapter.mCurrentFragmentList = fragmentList

        vpEarning.currentItem = 0
        vpEarning.offscreenPageLimit = 2

        vpEarning.adapter = viewPagerAdapter
        vpEarning.addOnPageChangeListener(viewPagerAdapter)

        tabEarning.setupWithViewPager(vpEarning)
        tabEarning.getTabAt(0)!!.text = resources.getString(R.string.manual_store_payment)
        tabEarning.getTabAt(1)?.text = resources.getString(R.string.earn_payment)

    }


    fun onPageSelected(position: Int) {
        Log.e("OrderFragment: ", "==>$position")

    }

    fun openEarningPaymentScreen() {
        vpEarning.currentItem = 1
    }
}
