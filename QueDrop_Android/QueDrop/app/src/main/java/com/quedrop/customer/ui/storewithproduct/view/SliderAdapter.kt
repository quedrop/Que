package com.quedrop.customer.ui.storewithproduct.view


import android.content.Context
import com.smarteist.autoimageslider.SliderViewAdapter
import com.bumptech.glide.Glide
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import com.quedrop.customer.R
import com.quedrop.customer.model.SliderImages
import com.quedrop.customer.utils.URLConstant


class SliderAdapter(var context: Context, var arraySliderList: MutableList<SliderImages>?) :
    SliderViewAdapter<SliderAdapter.SliderAdapterVH>() {

    override fun onCreateViewHolder(parent: ViewGroup): SliderAdapterVH {
        val inflate =
            LayoutInflater.from(parent.context).inflate(R.layout.layout_slider_item, null)
        return SliderAdapterVH(inflate)
    }

    override fun onBindViewHolder(viewHolder: SliderAdapterVH, position: Int) {


        Glide.with(context).load(
            URLConstant.urlStoreSliderImages + arraySliderList?.get(
                position
            )?.slider_image
        ).placeholder(R.drawable.placeholder_product_supplier)
            .into(viewHolder.imageViewBackground)

    }

    override fun getCount(): Int {
        return if (arraySliderList != null)
            return arraySliderList!!.size
        else 0
    }

    inner class SliderAdapterVH(var itemView: View) :
        SliderViewAdapter.ViewHolder(itemView) {
        var imageViewBackground: ImageView

        init {
            imageViewBackground = itemView.findViewById(R.id.ivSliderImage)
        }
    }
}