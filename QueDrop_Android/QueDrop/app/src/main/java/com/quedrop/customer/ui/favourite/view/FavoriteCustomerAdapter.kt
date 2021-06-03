package com.quedrop.customer.ui.favourite.view

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.model.NearByStores
import com.quedrop.customer.utils.URLConstant
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.item_favorite_customer.view.*


class FavoriteCustomerAdapter(
    val context: Context,
    var favouriteList: MutableList<NearByStores>
) :
    RecyclerView.Adapter<FavoriteCustomerAdapter.ViewHolder>() {


    var unFavoriteInvoke: ((Int) -> Unit)? = null
    var storeDetailsNavigate: ((Int) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view =
            LayoutInflater.from(context)
                .inflate(R.layout.item_favorite_customer, parent, false)
        return ViewHolder(view)
    }

    override fun getItemCount(): Int {
        return favouriteList.size
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bindData(position)
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {

            itemView.ivFavouriteIcon.setOnClickListener {
                unFavoriteInvoke?.invoke(adapterPosition)
            }

            itemView.setOnClickListener {
                storeDetailsNavigate?.invoke(adapterPosition)
            }

        }

        fun bindData(position: Int) {
            itemView.textTitleStoreFav.text = favouriteList[position].store_name
            itemView.textAddressStoreFav.text = favouriteList[position].store_address

            if (!favouriteList[position].latitude.isNullOrEmpty() && !favouriteList[position].longitude.isNullOrEmpty()) {
                Utils.fetchRouteDistance(
                    context,
                    Utils.keyLatitude.toDouble(),
                    Utils.keyLongitude.toDouble(),
                    favouriteList[position].latitude.toDouble(),
                    favouriteList[position].longitude.toDouble(),
                    itemView.textDistanceStoreFav
                )
            }
            if(!favouriteList[position].store_logo.isEmpty())
            {
                Glide.with(context).load(
                    URLConstant.nearByStoreUrl+ favouriteList.get(
                        position
                    ).store_logo
                ).placeholder(R.drawable.placeholder_order_cart_product)
                    .into(itemView.ivLogoStoreFav)
            }

        }

    }
}