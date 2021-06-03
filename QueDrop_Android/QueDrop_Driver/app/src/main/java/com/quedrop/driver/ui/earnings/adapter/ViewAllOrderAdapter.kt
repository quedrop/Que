package com.quedrop.driver.ui.earnings.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.driver.R
import com.quedrop.driver.service.model.Orders
import com.quedrop.driver.utils.CURRENCY
import com.quedrop.driver.utils.dateFormat
import com.quedrop.driver.utils.getCalenderDate
import kotlinx.android.synthetic.main.viewholder_view_all_order.view.*
import org.ocpsoft.prettytime.PrettyTime


class ViewAllOrderAdapter(val context: Context) :
    RecyclerView.Adapter<ViewAllOrderAdapter.ViewHolder>() {

    var viewAllOrderList: MutableList<Orders>? = null
    var onItemClick: ((View, Int, Int) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(context).inflate(R.layout.viewholder_view_all_order, parent, false)
        return ViewHolder(view)
    }

    override fun getItemCount(): Int {
        return viewAllOrderList?.size!!
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bindData(position)
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {

        init {
            itemView.setOnClickListener {
                onItemClick?.invoke(
                    itemView,
                    adapterPosition,
                    viewAllOrderList?.get(adapterPosition)?.orderId!!
                )
            }
        }

        fun bindData(position: Int) {
            itemView.tvViewOrderId.text =
                "Order #" + viewAllOrderList?.get(position)?.orderId.toString()
            itemView.tvViewOrderAmount.text =
                "Order Amount : " + CURRENCY + viewAllOrderList?.get(position)?.orderAmount.toString()
            itemView.tvViewOrderFrom.text =
                "From: " + viewAllOrderList?.get(position)?.customerDetail?.firstName.toString()+" "+viewAllOrderList?.get(position)?.customerDetail?.lastName.toString()
            itemView.txtViewOrderDate.text =
                "From: " + viewAllOrderList?.get(position)?.orderAmount.toString()

            val cal =
                viewAllOrderList?.get(position)?.orderDate.toString().getCalenderDate(dateFormat)
            val time = PrettyTime()
            itemView.txtViewOrderDate.text = time.format(cal)

        }
    }
}