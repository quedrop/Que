package com.quedrop.driver.ui.orderDetailsFragment.adapter

import android.annotation.SuppressLint
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.driver.R
import com.quedrop.driver.service.model.RegistedStore
import com.quedrop.driver.utils.CURRENCY


class OrderManualStoreAdapter(
    var arrayBill: MutableList<RegistedStore>
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem =
            layoutInflater.inflate(R.layout.viewholder_manual_store_bill, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayBill != null)
            return arrayBill!!.size
        else 0
    }

    @SuppressLint("SetTextI18n")
    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {
            if (arrayBill[position].storeAmount?.toInt() == 0) {
                holder.txtManualStoreName.visibility = View.GONE
                holder.txtManualStoreAmount.visibility = View.GONE
            } else {
                holder.txtManualStoreName.visibility = View.VISIBLE
                holder.txtManualStoreAmount.visibility = View.VISIBLE
                holder.txtManualStoreName.text = arrayBill[position].storeName + " Items Total"
                holder.txtManualStoreAmount.text =
                    CURRENCY + String.format("%.2f", arrayBill[position].storeAmount)
            }
        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var txtManualStoreName: TextView = itemView.findViewById(R.id.txtManualStoreName)
        var txtManualStoreAmount: TextView = itemView.findViewById(R.id.txtManualStoreAmount)
    }
}