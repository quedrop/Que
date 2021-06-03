package com.quedrop.customer.ui.home.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.model.Categories
import com.makeramen.roundedimageview.RoundedImageView
import com.quedrop.customer.network.ApiUtils
import com.quedrop.customer.utils.URLConstant


class AllCategarioesRecyclerAdapter(
    var context: Context,
    var arrayCategoriesList: MutableList<Categories>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    var nearByStoreActivity: ((Int) -> Unit)? = null
    var addStoreActivity: ((View) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem =
            layoutInflater.inflate(R.layout.layout_allcategories_recycler_ustomer, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayCategoriesList != null)
            return ((arrayCategoriesList!!.size))
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {
            //zp changes to remove add store
            // if ((position + 1) == ((arrayCategoriesList?.size)!!)) {
            //   holder.imageView.setImageResource(R.drawable.addstore)
            //  } else {

            Glide.with(context)
                .load(URLConstant.serviceCategoryUrl + arrayCategoriesList?.get(position)?.service_category_image)
                .placeholder(R.drawable.placeholder_home_category)
                .into(holder.imageView)

            // }
        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var imageView: ImageView = itemView.findViewById(R.id.ivPicCategories) as RoundedImageView

        init {
            itemView.setOnClickListener {
                val position = adapterPosition
                //if ((adapterPosition + 1) == arrayCategoriesList?.size) {
                // addStoreActivity?.invoke(it)
                //} else {
                nearByStoreActivity?.invoke(
                    position
                )
                // }
            }
        }
    }
}