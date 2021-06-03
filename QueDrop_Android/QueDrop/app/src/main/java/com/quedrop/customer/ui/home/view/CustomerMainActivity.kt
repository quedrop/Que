package com.quedrop.customer.ui.home.view

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.widget.Toast
import androidx.fragment.app.Fragment
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.navigation.FragmentNavigation
import com.quedrop.customer.ui.home.view.fragment.CustomerMainFragment


class CustomerMainActivity : BaseActivity(), FragmentNavigation {


    var SCAN_FRAGMENT_TAG = "com.quedrop.customer.ui.order.view.fragment.ScanQRFragment"


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_customer_home)

        setInitialFragment()

    }

    private fun setInitialFragment() {
        setFragmentAsRoot(CustomerMainFragment())
    }


    fun navigateToFragment(fragment: Fragment, frag: Fragment? = null, requestCode: Int? = null) {

        addNew(fragment, transition = true, targetFragment = frag, requestCode = requestCode)
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        val fragment = supportFragmentManager.findFragmentById(R.id.container_main)

        if (fragment?.tag.equals(SCAN_FRAGMENT_TAG)) {
        } else {
            fragment!!.onActivityResult(requestCode, resultCode, data)
        }
    }
}
