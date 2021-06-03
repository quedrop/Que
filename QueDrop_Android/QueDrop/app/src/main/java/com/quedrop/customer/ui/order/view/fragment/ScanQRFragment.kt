package com.quedrop.customer.ui.order.view.fragment


import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.quedrop.customer.R
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.utils.Utility
import com.google.zxing.integration.android.IntentIntegrator
import com.google.zxing.integration.android.IntentResult

/**
 * A simple [Fragment] subclass.
 */
class ScanQRFragment(var orderId: Int) : Fragment() {

    companion object {
        fun newInstance(orderId: Int): ScanQRFragment {
            return ScanQRFragment(orderId)
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_scan_qr, container, false)
    }


    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        IntentIntegrator.forSupportFragment(this).initiateScan()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode != Activity.RESULT_CANCELED) {
            val result: IntentResult =
                IntentIntegrator.parseActivityResult(requestCode, resultCode, data)!!
            if (data != null && result.contents == null) {
                //Utility.toastLong(activity, "Cancelled from fragment")
            } else {
                //Utility.toastLong(activity, "Scanned from fragment" + result.contents)
                if (result.contents == orderId.toString()) {
                    addConfirmOrderNavigate(orderId)
                }else{
                    Utility.toastLong(activity, "Order doesn't matched")
                }

            }
        } else {
            //Utility.toastLong(activity, "Cancelled from fragment")

        }
    }

    private fun addConfirmOrderNavigate(orderId: Int) {
        val orderIdMain = orderId
        (activity as CustomerMainActivity).navigateToFragment(
            ConfirmOrderFragment.newInstance(
                orderIdMain
            )
        )
    }


}
