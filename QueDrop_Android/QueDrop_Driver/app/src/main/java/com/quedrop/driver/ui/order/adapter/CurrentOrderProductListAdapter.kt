package com.quedrop.driver.ui.order.adapter

import android.app.Activity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.driver.R
import com.quedrop.driver.service.model.Products
import io.reactivex.subjects.PublishSubject


class CurrentOrderProductListAdapter(
    var context: Activity,
    var arrayProductOrderList: MutableList<Products>?) :
    RecyclerView.Adapter<CurrentOrderProductListAdapter.ViewHolder>() {


    private val itemProductClickResult: PublishSubject<Int> = PublishSubject.create()
    var itemProductClick = itemProductClickResult.hide()


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem = layoutInflater.inflate(R.layout.viewholder_product, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayProductOrderList != null)
            return arrayProductOrderList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.tvProductNameCurrent.text = arrayProductOrderList?.get(position)?.productName
        holder.tvPAddOnsCurrent.text = arrayProductOrderList?.get(position)?.productDescription

        holder.itemView.setOnClickListener {
            itemProductClickResult.onNext(holder.adapterPosition)
        }

    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var tvProductNameCurrent: TextView = itemView.findViewById(R.id.tvProductNameCurrent)
        var tvPAddOnsCurrent: TextView = itemView.findViewById(R.id.tvPAddOnsCurrent)
    }

}