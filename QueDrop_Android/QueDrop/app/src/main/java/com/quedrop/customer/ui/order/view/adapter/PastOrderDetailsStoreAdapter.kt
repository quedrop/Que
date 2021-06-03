package com.quedrop.customer.ui.order.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.model.ProductDetailsOrder
import com.quedrop.customer.model.StoreSingleDetails
import com.quedrop.customer.utils.URLConstant


class PastOrderDetailsStoreAdapter(
    var context: Context,
    var arrayStoreAdapterList: MutableList<StoreSingleDetails>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var currentOrderAdapter: CurrentOrderProductListAdapter? = null
    var arrayProductList: MutableList<ProductDetailsOrder>? = null


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
//        val listItem = layoutInflater.inflate(R.layout.list_item, parent, false)
//        val viewHolder = ViewHolder(listItem)
        val listItem =
            layoutInflater.inflate(R.layout.layout_store_details_order, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayStoreAdapterList != null)
            return arrayStoreAdapterList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {


            holder.tvStoreNameOrder.text = arrayStoreAdapterList?.get(position)?.store_name
            holder.tvStoreAddressOrder.text = arrayStoreAdapterList?.get(position)?.store_address
            Glide.with(context).load(URLConstant.nearByStoreUrl + arrayStoreAdapterList?.get(position)?.store_logo)
                .placeholder(R.drawable.placeholder_order_cart_product)
                .into(holder.ivStoreLogoOrder)

            holder.timerBackground.visibility = View.GONE
            holder.tvTime.visibility = View.GONE
            holder.tvRemainingTime.visibility = View.GONE

            arrayProductList = arrayStoreAdapterList?.get(position)?.products

            holder.rvProductsOrder.layoutManager = LinearLayoutManager(
                context,
                LinearLayoutManager.VERTICAL,
                false
            )
            currentOrderAdapter = CurrentOrderProductListAdapter(
                context,
                arrayProductList!!

            )
            holder.rvProductsOrder.adapter = currentOrderAdapter
        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var rvProductsOrder: RecyclerView = itemView.findViewById(R.id.rvProductsOrder)
        var tvStoreNameOrder: TextView = itemView.findViewById(R.id.tvStoreNameOrder)
        var tvStoreAddressOrder: TextView = itemView.findViewById(R.id.tvStoreAddressOrder)
        var tvTime: TextView = itemView.findViewById(R.id.tvTime)
        var timerBackground: View = itemView.findViewById(R.id.timerBackground)
        var ivStoreLogoOrder: ImageView = itemView.findViewById(R.id.ivStoreLogoOrder)
        var tvRemainingTime: TextView = itemView.findViewById(R.id.tvRemainingTime)
    }


}