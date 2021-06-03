package com.quedrop.customer.ui.order.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.model.ManualStore


class ManualStoreAdapter(var context: Context, var arrayManualStoreList: MutableList<ManualStore>?) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var isManualStoreFlag = true
    var manualStoreInvoke:((Boolean)->Unit)?=null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {


        val layoutInflater = LayoutInflater.from(parent.context)
//        val listItem = layoutInflater.inflate(R.layout.list_item, parent, false)
//        val viewHolder = ViewHolder(listItem)
        var listItem = layoutInflater.inflate(R.layout.item_manual_store,parent,false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayManualStoreList != null)
            return arrayManualStoreList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {
            holder.tvStoreNameItemTotal.text =
                arrayManualStoreList?.get(position)?.store_name + " " +
                        context.resources.getString(R.string.itemsTotal)

            if(arrayManualStoreList?.get(position)?.store_amount == "0"){
                isManualStoreFlag = false
                holder.tvStoreItemFeeRs.text = context.resources.getString(R.string.pendingStatus)
                manualStoreInvoke?.invoke(isManualStoreFlag)
            }else{
                isManualStoreFlag = true
                holder.tvStoreItemFeeRs.text =
                    context.resources.getString(R.string.rs) + String.format(
                        "%.2f",
                        arrayManualStoreList?.get(position)?.store_amount!!.toFloat()
                    )
                manualStoreInvoke?.invoke(isManualStoreFlag)
            }


        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var tvStoreNameItemTotal = itemView.findViewById<TextView>(R.id.tvStoreNameItemTotal)
        var tvStoreItemFeeRs = itemView.findViewById<TextView>(R.id.tvStoreItemFeeRs)

        init{

        }
    }
}