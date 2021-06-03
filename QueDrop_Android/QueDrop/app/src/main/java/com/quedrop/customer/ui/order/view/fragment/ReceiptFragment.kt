package com.quedrop.customer.ui.order.view.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.utils.URLConstant
import kotlinx.android.synthetic.main.fragment_receipt.*


class ReceiptFragment(
    var receipt: String,
    var index: Int
) : BaseFragment() {
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        return inflater.inflate(
            R.layout.fragment_receipt,
            container, false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        initMethod()
        onClickMethod()
    }

    companion object {
        fun newInstance(receipt: String, index: Int): ReceiptFragment {
            return ReceiptFragment(receipt, index)
        }
    }

    fun onPageSelected(position: Int) {

    }

    private fun onClickMethod() {
        ivBackReceipt.throttleClicks().subscribe() {
            activity.onBackPressed()
        }.autoDispose(compositeDisposable)
    }

    fun initMethod() {

        tvReceipt.text=getString(R.string.receipt)+index

        Glide.with(this.context!!).load(
            URLConstant.urlOrderReceipt
                    + receipt
        ).into(ivReceiptMain)
    }
}