package com.quedrop.customer.ui.home.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.model.ProfuctOfferList
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.URLConstant
import com.quedrop.customer.utils.Utils

class ProductOfferRecyclerAdapter(
    var context: Context,
    var arrayProductOfferList: MutableList<ProfuctOfferList>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem = layoutInflater.inflate(R.layout.layout_homecustomer_recycle_product_offer, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayProductOfferList != null)
            return arrayProductOfferList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is ViewHolder) {
            val KeyLaititude: Float =
                SharedPrefsUtils.getStringPreference(context, KeysUtils.KeyLatitude)!!.toFloat()
            val KeyLongitude: Float =
                SharedPrefsUtils.getStringPreference(context, KeysUtils.KeyLongitude)!!.toFloat()
            Glide.with(context)
                .load(
                    URLConstant.urlProduct + arrayProductOfferList?.get(
                        position
                    )?.product_image
                )
                .placeholder(R.drawable.placeholder_store_in_category)
                .into(holder.ivPicOffersProduct)

            holder.textProductNameOffersProduct.text =
                arrayProductOfferList?.get(position)?.product_name
            holder.textNameOffersProduct.text = arrayProductOfferList?.get(position)?.store_name
            holder.textDescriptionOffersProduct.text =
                arrayProductOfferList?.get(position)?.store_category_title

            holder.textCouponCodeOffersProduct.text =
                arrayProductOfferList?.get(position)?.offer_percentage + "% Off"

            if (arrayProductOfferList?.get(position)!!.offer_code.isEmpty()) {

            } else {
                holder.textCouponCodeOffersProduct.text =
                    arrayProductOfferList?.get(position)?.offer_percentage + "% Off | " + arrayProductOfferList?.get(
                        position
                    )?.offer_code
            }



            if (!arrayProductOfferList?.get(position)?.latitude.isNullOrEmpty() &&
                !arrayProductOfferList?.get(position)?.longitude.isNullOrEmpty()
            ) {

                Utils.fetchRouteTime(
                    context,
                    KeyLaititude.toDouble(),
                    KeyLongitude.toDouble(),
                    arrayProductOfferList?.get(position)?.latitude!!.toDouble(),
                    arrayProductOfferList?.get(position)?.longitude!!.toDouble(),
                    holder.textTimeOffersProduct
                )
            }


        }
    }

    class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var ivPicOffersProduct: ImageView
        var textProductNameOffersProduct: TextView
        var textNameOffersProduct: TextView
        var textDescriptionOffersProduct: TextView
        var textCouponCodeOffersProduct: TextView
        var textTimeOffersProduct: TextView


        init {
            this.textProductNameOffersProduct =
                itemView.findViewById(R.id.textProductNameOffersProduct)
            this.ivPicOffersProduct = itemView.findViewById(R.id.ivPicOffersProduct) as ImageView
            this.textNameOffersProduct =
                itemView.findViewById(R.id.textNameOffersProduct) as TextView
            this.textDescriptionOffersProduct =
                itemView.findViewById(R.id.textDescriptionOffersProduct) as TextView
            this.textCouponCodeOffersProduct =
                itemView.findViewById(R.id.textCouponCodeOffersProduct) as TextView
            this.textTimeOffersProduct =
                itemView.findViewById(R.id.textTimeOffersProduct) as TextView


        }
    }


}