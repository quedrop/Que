package com.quedrop.driver.ui.deliveryRoute.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import com.quedrop.driver.service.model.Stores
import com.quedrop.driver.utils.ImageConstant


class DeliveryRouteAdapter(
    var context: Context,
    var arrayOrderList: MutableList<Stores>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem =
            layoutInflater.inflate(R.layout.viewholder_delivery_route, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayOrderList != null)
            return arrayOrderList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is ViewHolder) {
            holder.tvRestName.text = arrayOrderList?.get(position)?.storeName
            holder.tvRestAddress.text = arrayOrderList?.get(position)?.storeAddress
//              holder.tvRestKm.text = arrayOrderList?.get(position)?.
            Glide.with(context)
                .load(
                    BuildConfig.BASE_URL + ImageConstant.STORE_LOGO + arrayOrderList?.get(position)?.storeLogo
                ).centerCrop()
                .into(holder.ivRestImage)

        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var tvRestName: TextView = itemView.findViewById(R.id.tvRestName)
        var tvRestAddress: TextView = itemView.findViewById(R.id.tvRestAddress)
        var tvRestKm: TextView = itemView.findViewById(R.id.tvRestKm)
        var ivRestImage: ImageView = itemView.findViewById(R.id.ivRestImage)
    }
}