package com.quedrop.customer.ui.supplier.offers.adapters

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.getProductImage
import com.quedrop.customer.model.SupplierProduct
import kotlinx.android.synthetic.main.list_item_selection.view.*

class OfferProductAdapter(val context: Context) :
    RecyclerView.Adapter<OfferProductAdapter.Viewholder>() {
    var productList: MutableList<SupplierProduct> = mutableListOf()

    var onItemClick: ((Int, String) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): Viewholder {
        val view =
            LayoutInflater.from(context)
                .inflate(R.layout.list_item_selection, parent, false)
        return Viewholder(view)
    }

    override fun getItemCount(): Int {
        return productList.size
    }

    override fun onBindViewHolder(holder: Viewholder, position: Int) {
        holder.bindData(position)
    }

    inner class Viewholder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {

            itemView.setOnClickListener {
                onItemClick?.invoke(Integer.parseInt(productList[adapterPosition].product_id),
                    productList[adapterPosition].product_name)
            }
        }

        fun bindData(position: Int) {
            itemView.tvName.text = productList[position].product_name
            Glide.with(context)
                .load(context.getProductImage(productList[position].product_image))
                .into(itemView.imgview)
        }
    }
}