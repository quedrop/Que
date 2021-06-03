package com.quedrop.customer.ui.order.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.utils.URLConstant


class ReceiptAdapterPayment(
    var context: Context,
    var arrayReceiptList: MutableList<String>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var receiptInvoke: ((Int, ArrayList<Int>) -> Unit)? = null
    var arrayCounterList = ArrayList<Int>()
    var counter = 0

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        var listItem =
            layoutInflater.inflate(R.layout.layout_reciept_payment, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayReceiptList != null)
            return arrayReceiptList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {

            if (arrayReceiptList!![position].isNotEmpty()) {
                counter += 1
                arrayCounterList.add(counter)
                holder.ivReceipt.visibility = View.VISIBLE
                Glide.with(context).load(
                    URLConstant.urlOrderReceipt+ arrayReceiptList?.get(
                        position
                    )
                )
                    .centerCrop()
                    .placeholder(R.drawable.placeholder_order_cart_product)
                    .into(holder.ivReceipt)

            } else {
                holder.ivReceipt.visibility = View.GONE
            }
        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {

        var ivReceipt: ImageView = itemView.findViewById(R.id.ivReceipt)

        init {

            ivReceipt.setOnClickListener {
                receiptInvoke?.invoke(adapterPosition, arrayCounterList)
            }
        }
    }

}