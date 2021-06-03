package com.quedrop.customer.ui.supplier.myorders.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.getProductImage
import com.quedrop.customer.base.extentions.startActivityWithAnimation
import com.quedrop.customer.model.ProductOrder
import com.quedrop.customer.ui.supplier.myorders.SupplierOrderDetailActivity
import com.quedrop.customer.ui.supplier.myorders.SupplierOrderItemDetailActivity
import kotlinx.android.synthetic.main.list_item_product_order_detail.view.*

class OrderDetailProductAdapter(val context: Context) :
    RecyclerView.Adapter<OrderDetailProductAdapter.ViewHolder>() {
    var orderItemList: MutableList<ProductOrder> = mutableListOf()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view =
            LayoutInflater.from(context)
                .inflate(R.layout.list_item_product_order_detail, parent, false)
        return ViewHolder(view)
    }

    override fun getItemCount(): Int {
        return orderItemList.size
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bindData(position)
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {
            itemView.setOnClickListener {
                (context as SupplierOrderDetailActivity)
                    .startActivityWithAnimation<SupplierOrderItemDetailActivity> {
                        putExtra("product",orderItemList[adapterPosition])
                    }
            }
        }

        fun bindData(position: Int) {

            Glide.with(context).load(
                context.getProductImage(orderItemList[position].product_image))
                .centerCrop()
                .placeholder(R.drawable.placeholder_product_supplier)
                .into(itemView.imgProduct)
            itemView.tvProductName.text = orderItemList[position].product_name
            itemView.tvQty.setText("Qty:${orderItemList[position].quantity}")
        }
    }
}