package com.quedrop.customer.ui.order.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.model.*
import kotlinx.android.synthetic.main.item_customer_support.view.*


class CustomerStoreSupportAdapter(
    var context: Context,
    var arrayStoreCustomerSupportList: MutableList<StoreSingleDetails>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var arrayProductCartList: MutableList<ProductDetailsOrder>? = null
    var cartProductAdapter:CustomerProductListAdapter?=null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        var listItem =
            layoutInflater.inflate(R.layout.item_customer_support, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayStoreCustomerSupportList != null)
            return arrayStoreCustomerSupportList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {
                holder.bind(position)

        }


    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {

        init {

        }

        fun bind(position: Int){
            itemView.textStoreTitleSupport.text = arrayStoreCustomerSupportList?.get(position)?.store_name!!

            arrayProductCartList = arrayStoreCustomerSupportList?.get(position)?.products

            itemView.customerProductSupportRv.layoutManager = LinearLayoutManager(
                context,
                LinearLayoutManager.VERTICAL,
                false
            )

            cartProductAdapter = CustomerProductListAdapter(
                context,
                arrayProductCartList

            )
            itemView.customerProductSupportRv.adapter = cartProductAdapter
          //  itemView.textProductSupport.text = arrayStoreCustomerSupportList?.get(position)?.products?.product_name!!
            //itemView.textSizeProductSupport.text =
        }

    }

}