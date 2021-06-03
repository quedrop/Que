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


class CustomerProductListAdapter(
    var context: Context,
    var arrayProductCustomerList: MutableList<ProductDetailsOrder>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var arrayAddOnsList: MutableList<AddOns>? = null
    var arrayProductOptionList: MutableList<ProductOption>? = null
    var productOptionId: Int = 0
    var productOptionName: String = ""
    var hasAddOns: String = "0"

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
//        val listItem = layoutInflater.inflate(R.layout.list_item, parent, false)
//        val viewHolder = ViewHolder(listItem)
        var listItem =
            layoutInflater.inflate(R.layout.item_products_customer_support, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayProductCustomerList != null)
            return arrayProductCustomerList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {

            arrayProductOptionList = arrayProductCustomerList?.get(position)?.product_option
            arrayAddOnsList = arrayProductCustomerList?.get(position)?.addons
            productOptionId = arrayProductCustomerList?.get(position)!!.option_id.toInt()
//            hasAddOns = arrayProductCustomerList?.get(position)!!.has_addons


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

            holder.tvProductNameCustomer.text = arrayProductCustomerList?.get(position)?.product_name
            if (sb.isNullOrBlank()) {
                holder.tvPAddOnsCustomer.visibility = View.GONE
            } else {
                holder.tvPAddOnsCustomer.visibility = View.VISIBLE
                holder.tvPAddOnsCustomer.text = sb
            }


        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var tvProductNameCustomer: TextView
        var tvPAddOnsCustomer: TextView

        init {

            tvProductNameCustomer = itemView.findViewById(R.id.tvProductNameCustomer)
            tvPAddOnsCustomer = itemView.findViewById(R.id.tvPAddOnsCustomer)



        }
    }

}