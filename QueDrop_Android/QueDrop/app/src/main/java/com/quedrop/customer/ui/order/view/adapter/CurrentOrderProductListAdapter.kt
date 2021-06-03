package com.quedrop.customer.ui.order.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.model.*
import java.lang.StringBuilder


class CurrentOrderProductListAdapter(
    var context: Context,
    var arrayProductOrderList: MutableList<ProductDetailsOrder>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var arrayAddOnsList: MutableList<AddOns>? = null
    var arrayProductOptionList: MutableList<ProductOption>? = null
    var productOptionId: Int = 0
    var productOptionName: String = ""
    var currentOrderListInvoke2: ((View) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
//        val listItem = layoutInflater.inflate(R.layout.list_item, parent, false)
//        val viewHolder = ViewHolder(listItem)
        var listItem =
            layoutInflater.inflate(R.layout.layout_products_current_order, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayProductOrderList != null)
            return arrayProductOrderList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {
            holder.tvProductNameCurrent.text = arrayProductOrderList?.get(position)?.product_name?.trim()
//            holder.tvPAddOnsCurrent.text = arrayProductOrderList?.get(position)?.product_description

            arrayProductOptionList = arrayProductOrderList?.get(position)?.product_option

            arrayAddOnsList = arrayProductOrderList?.get(position)?.addons
            productOptionId = arrayProductOrderList?.get(position)!!.option_id


            var sb = StringBuilder()
            for ((i, v) in arrayProductOptionList?.toMutableList()!!.withIndex()) {

                if (v.option_id == productOptionId) {
                    productOptionName = arrayProductOptionList?.get(i)!!.option_name
                    if (productOptionName == "Default") {

                    } else {
                        sb = sb.append(productOptionName)
                    }
                }
            }

            if (arrayAddOnsList?.size!! > 0) {
                if (productOptionName == "Default") {

                } else {
                    sb = sb.append(",")
                }
            }

            for ((item, value) in arrayAddOnsList?.toMutableList()!!.withIndex()) {

                sb = sb.append(value.addon_name)

                if (item == ((arrayAddOnsList?.size)!! - 1)) {
                    break
                }
                sb.append(",")
            }

            if (sb.isNullOrBlank()) {
                holder.tvPAddOnsCurrent.visibility = View.GONE
            } else {
                holder.tvPAddOnsCurrent.visibility = View.VISIBLE
                holder.tvPAddOnsCurrent.text = sb
            }

        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var tvProductNameCurrent: TextView
        var tvPAddOnsCurrent: TextView

        init {

            tvProductNameCurrent = itemView.findViewById(R.id.tvProductNameCurrent)
            tvPAddOnsCurrent = itemView.findViewById(R.id.tvPAddOnsCurrent)

            itemView.setOnClickListener {
                currentOrderListInvoke2?.invoke(it)
            }

        }
    }

}