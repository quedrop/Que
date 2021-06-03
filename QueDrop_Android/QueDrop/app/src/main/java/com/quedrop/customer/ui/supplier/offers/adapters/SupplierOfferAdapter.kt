package com.quedrop.customer.ui.supplier.offers.adapters

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.getProductImage
import com.quedrop.customer.base.extentions.startActivityWithAnimation
import com.quedrop.customer.model.SupplierProductOffer
import com.quedrop.customer.ui.supplier.HomeSupplierActivity
import com.quedrop.customer.ui.supplier.offers.OfferDetailActivity
import kotlinx.android.synthetic.main.list_item_supplier_offer.view.*


class SupplierOfferAdapter(val context: Context) :
    RecyclerView.Adapter<SupplierOfferAdapter.ViewHolder>() {
    var offerList : MutableList<SupplierProductOffer> = mutableListOf()
    var onActionMenuClick: ((Int, View) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view =
            LayoutInflater.from(context)
                .inflate(R.layout.list_item_supplier_offer, parent, false)
        return ViewHolder(view)
    }

    override fun getItemCount(): Int {
        return offerList.size
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bindData(position)
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {
            itemView.iv_action.setOnClickListener {
                onActionMenuClick?.invoke(adapterPosition, it)
            }
            itemView.setOnClickListener {
                (context as HomeSupplierActivity).startActivityWithAnimation<OfferDetailActivity> {
                    putExtra("offer", offerList[adapterPosition])
                }
            }
        }

        fun bindData(position: Int) {
            Glide.with(context)
                .load(context.getProductImage(offerList[position].product_image))
                .placeholder(R.drawable.placeholder_offer_supplier)
                .centerCrop()
                .into(itemView.ivProductImage)
            itemView.tvProductName.text = offerList[position].product_name
            itemView.tvCategoryName.text = offerList[position].store_category_title
            var offer: String  = offerList[position].offer_percentage + "% off"
            if(offerList[position].offer_code.isNotEmpty()){
                offer = offer.plus(" | Use coupon "+ offerList[position].offer_code)
            }
            itemView.tvCouponCode.text = offer
        }
    }
}