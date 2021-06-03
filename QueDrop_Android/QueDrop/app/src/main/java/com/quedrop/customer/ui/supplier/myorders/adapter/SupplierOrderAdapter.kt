package com.quedrop.customer.ui.supplier.myorders.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.startActivityWithAnimation
import com.quedrop.customer.model.SupplierOrder
import com.quedrop.customer.ui.supplier.HomeSupplierActivity
import com.quedrop.customer.ui.supplier.myorders.SupplierOrderDetailActivity
import kotlinx.android.synthetic.main.list_item_order.view.*

class SupplierOrderAdapter(val context: Context, val fromEarning: Boolean) :
    RecyclerView.Adapter<SupplierOrderAdapter.ViewHolder>() {
    var _orderList: MutableList<SupplierOrder> = mutableListOf()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view =
            LayoutInflater.from(context)
                .inflate(R.layout.list_item_order, parent, false)
        return ViewHolder(view)
    }

    override fun getItemCount(): Int {
        return _orderList.size
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bindData(position)
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {

        }

        fun bindData(position: Int) {
            itemView.rvOrderItem.layoutManager = LinearLayoutManager(context)
            val lastName: String = _orderList[position].customer_detail.last_name
            val first: Char = lastName[0]
            if(fromEarning){
                itemView.tvCustomerName.text=com.quedrop.customer.utils.Utility.convertUTCDateToLocalDate(_orderList[position].created_at,"dd/MM/yyyy")
                itemView.tvCustomerName.setTextColor(ContextCompat.getColor(context,R.color.colorBlack))
            }
            else{
                itemView.tvCustomerName.text =
                    _orderList[position].customer_detail.first_name + " " + first + "." + " - " + _orderList[position]
                        .distance + " away"
                itemView.tvCustomerName.setTextColor(ContextCompat.getColor(context,R.color.colorThemeGreen))
            }

            val adapter = SupplierOrderItemAdapter(
                context,
                _orderList[position].products,
                _orderList[position].distance,
                _orderList[position].created_at,
                _orderList[position].driver_detail,
                _orderList[position].customer_detail,
                fromEarning,
                _orderList[position].order_amount
            ).apply {
                onClick = { childPosition, view ->
                    (context as HomeSupplierActivity).startActivityWithAnimation<SupplierOrderDetailActivity> {
                        putExtra("order_id", _orderList[position].order_id)
                    }
                }
            }
            itemView.rvOrderItem.adapter = adapter
        }
    }
}