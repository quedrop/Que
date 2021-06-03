package com.quedrop.driver.ui.homeFragment.view

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.quedrop.driver.R
import com.quedrop.driver.service.model.Product
import kotlinx.android.synthetic.main.raw_product_details.view.*

class ProductView(context: Context) : FrameLayout(context) {

    var position: Int = -1

    init {
        layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        )
        View.inflate(context, R.layout.raw_product_details, this)
    }


    fun bind(product: Product, isSideBorderShow :Boolean) {
        tvProductName.text = product.productName
        tvProductDesc.text = product.productDescription
        if(isSideBorderShow){
            borderLeft.visibility = View.VISIBLE
            borderRight.visibility = View.VISIBLE
        }else{
            borderLeft.visibility = View.GONE
            borderRight.visibility = View.GONE
        }
    }
}