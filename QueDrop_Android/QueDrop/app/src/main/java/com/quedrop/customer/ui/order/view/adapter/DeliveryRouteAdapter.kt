package com.quedrop.customer.ui.order.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.model.StoreSingleDetails
import com.quedrop.customer.utils.URLConstant
import com.quedrop.customer.utils.Utils


class DeliveryRouteAdapter(
    var context: Context,
    var arrayOrderList: MutableList<StoreSingleDetails>?,
    var deliveryLatitude: String,
    var deliveryLongitude: String
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var storeExploreInvoke: ((Int) -> Unit)? = null

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
            holder.tvRestName.text = arrayOrderList?.get(position)?.store_name
            holder.tvRestAddress.text = arrayOrderList?.get(position)?.store_address

            if (!arrayOrderList?.get(position)?.latitude.isNullOrEmpty()
                && !arrayOrderList?.get(position)?.longitude.isNullOrEmpty() && !deliveryLatitude.isNullOrEmpty()
            ) {
                Utils.fetchRouteDistance(
                    context,
                    deliveryLatitude.toDouble(),
                    deliveryLongitude.toDouble(),
                    arrayOrderList?.get(position)?.latitude!!.toDouble(),
                    arrayOrderList?.get(position)?.longitude!!.toDouble(),
                    holder.tvRestKm
                )

            }
            Glide.with(context)
                .load(URLConstant.nearByStoreUrl + arrayOrderList?.get(position)?.store_logo)
                .centerCrop()
                .into(holder.ivRestImage)

        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var tvRestName: TextView = itemView.findViewById(R.id.tvRestName)
        var tvRestAddress: TextView = itemView.findViewById(R.id.tvRestAddress)
        var tvRestKm: TextView = itemView.findViewById(R.id.tvRestKm)
        var ivRestImage: ImageView = itemView.findViewById(R.id.ivRestImage)

        init {
            itemView.setOnClickListener {
                storeExploreInvoke?.invoke(adapterPosition)
            }
        }
    }
}
