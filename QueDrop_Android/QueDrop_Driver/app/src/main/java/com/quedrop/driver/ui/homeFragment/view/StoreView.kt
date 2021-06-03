package com.quedrop.driver.ui.homeFragment.view

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.bumptech.glide.Glide
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import com.quedrop.driver.service.model.StoreDetail
import com.quedrop.driver.utils.ImageConstant
import kotlinx.android.synthetic.main.raw_store_details.view.*

class StoreView(context: Context) : FrameLayout(context) {
    var position: Int = -1

    init {
        layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        )
        View.inflate(context, R.layout.raw_store_details, this)
    }


    fun bind(store: StoreDetail) {
        tvUserName.text = store.storeName
        tvAddress.text = store.storeAddress
        Glide.with(context).load(BuildConfig.BASE_URL + ImageConstant.STORE_LOGO + store.storeLogo)
            .centerCrop().into(ivProfileImage)
    }
}