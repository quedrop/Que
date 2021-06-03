package com.quedrop.customer.ui.supplier.myorders.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.getProductImage
import com.quedrop.customer.model.CustomerDetails
import com.quedrop.customer.model.DriverDetails
import com.quedrop.customer.model.ProductOrder
import com.quedrop.customer.utils.Utility
import kotlinx.android.synthetic.main.list_item_order_product.view.*

class SupplierOrderItemAdapter(
    val context: Context,
    products: ArrayList<ProductOrder>,
    var distance: String,
    var created_at: String,
    var driver_detail: DriverDetails,
    var customer_detail: CustomerDetails,
    var fromEarning:Boolean,
    var orderAmount:String
) :
    RecyclerView.Adapter<SupplierOrderItemAdapter.ViewHolder>() {
    val orderItemList: MutableList<ProductOrder> = products
    var onClick: ((Int, View) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view =
            LayoutInflater.from(context)
                .inflate(R.layout.list_item_order_product, parent, false)
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
                onClick?.invoke(adapterPosition, itemView)

            }
        }

        fun bindData(position: Int) {

            if (position == (orderItemList.size - 1)) {
                itemView.dividerDetail.visibility = View.GONE
            } else {
                itemView.dividerDetail.visibility = View.VISIBLE
            }

            Glide.with(context)
                .load(context.getProductImage(orderItemList[position].product_image))
                .placeholder(R.drawable.placeholder_order_cart_product)
                .centerCrop()
                .into(itemView.ivProductImage)
            itemView.tvProductName.text = orderItemList[position].product_name
            itemView.tvDriverName.text = "${driver_detail.first_name} ${driver_detail.last_name}"



            if(fromEarning){
                itemView.tvQty.setText("$"+orderAmount)
                itemView.tvQty.setTextColor(ContextCompat.getColor(context,R.color.colorThemeGreen))
                itemView.tvDateOrder.setText("Qty: ${orderItemList[position].quantity}")
            }else {
                itemView.tvQty.setText("Qty: ${orderItemList[position].quantity}")
                itemView.tvQty.setTextColor(ContextCompat.getColor(context,R.color.colorGreenStatus))
                itemView.tvDateOrder.setText(Utility.convertUTCDateToLocalDate(created_at,"dd MMMM yyyy"))
            }
        }
    }
}