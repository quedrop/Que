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


class OrderRegisteredStoreAdapter(
    var arrayBill: MutableList<RegistedStore>
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem =
            layoutInflater.inflate(R.layout.viewholder_register_store_bill, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return arrayBill.size
    }

    @SuppressLint("SetTextI18n")
    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {
            if (arrayBill[position].storeAmount?.toInt() == 0) {
                holder.txtStoreTotal.visibility = View.GONE
                holder.txtStoreNameTotal.visibility = View.GONE
            } else {
                holder.txtStoreTotal.visibility = View.VISIBLE
                holder.txtStoreNameTotal.visibility = View.VISIBLE
                holder.txtStoreNameTotal.text = arrayBill[position].storeName + " Items Total"
                holder.txtStoreTotal.text =
                    CURRENCY + String.format("%.2f", arrayBill[position].storeAmount)
            }
            if (arrayBill[position].storeDiscount?.toInt() == 0) {
                holder.txtDiscount.visibility = View.GONE
                holder.txtStoreDiscount.visibility = View.GONE
            } else {
                holder.txtDiscount.visibility = View.VISIBLE
                holder.txtStoreDiscount.visibility = View.VISIBLE
                holder.txtStoreDiscount.text = arrayBill[position].storeName + " Disconnect"
                holder.txtDiscount.text =
                    CURRENCY + String.format("%.2f", arrayBill[position].storeDiscount)
            }


        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var txtStoreNameTotal: TextView = itemView.findViewById(R.id.txtStoreNameTotal)
        var txtStoreDiscount: TextView = itemView.findViewById(R.id.txtStoreDiscount)
        var txtStoreTotal: TextView = itemView.findViewById(R.id.txtStoreTotal)
        var txtDiscount: TextView = itemView.findViewById(R.id.txtDiscount)
    }
}