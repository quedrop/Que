package com.quedrop.customer.ui.order.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.model.RegisteredStore


class RegisteredStoreAdapter(
    var context: Context,
    var arrayRegisteredStoreList: MutableList<RegisteredStore>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
//        val listItem = layoutInflater.inflate(R.layout.list_item, parent, false)
//        val viewHolder = ViewHolder(listItem)
        var listItem = layoutInflater.inflate(R.layout.item_registered_store, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayRegisteredStoreList != null)
            return arrayRegisteredStoreList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {
            holder.tvStoreNameItemTotal.text =
                arrayRegisteredStoreList?.get(position)?.store_name + " " +
                        context.resources.getString(R.string.itemsTotal)
            holder.tvStoreItemFeeRs.text =
                context.resources.getString(R.string.rs) + String.format(
                    "%.2f",
                    arrayRegisteredStoreList?.get(position)?.store_amount!!.toFloat()
                )

            if (arrayRegisteredStoreList?.get(position)?.store_discount != "0") {
                holder.tvStoreDiscountItemTotal.visibility = View.VISIBLE
                holder.tvDiscountCouponRs.visibility = View.VISIBLE
                holder.tvStoreDiscountItemTotal.text =
                    arrayRegisteredStoreList?.get(position)?.store_name + " " +
                            context.resources.getString(R.string.discount)
                holder.tvDiscountCouponRs.text =
                    context.resources.getString(R.string.rs) + String.format(
                        "%.2f",
                        arrayRegisteredStoreList?.get(position)?.store_discount!!.toFloat()
                    )
            } else {
                holder.tvStoreDiscountItemTotal.visibility = View.GONE
                holder.tvDiscountCouponRs.visibility = View.GONE
            }
        }

    }

    class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {


        var tvStoreNameItemTotal = itemView.findViewById<TextView>(R.id.tvStoreNameItemTotal)
        var tvStoreItemFeeRs = itemView.findViewById<TextView>(R.id.tvStoreItemFeeRs)
        var tvStoreDiscountItemTotal =
            itemView.findViewById<TextView>(R.id.tvStoreDiscountItemTotal)
        var tvDiscountCouponRs = itemView.findViewById<TextView>(R.id.tvDiscountCouponRs)


    }
}