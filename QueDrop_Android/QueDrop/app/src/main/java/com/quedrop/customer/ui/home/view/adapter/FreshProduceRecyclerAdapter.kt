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
import com.quedrop.customer.model.FreshProduceCategories
import com.quedrop.customer.utils.URLConstant

class FreshProduceRecyclerAdapter(
    var context: Context,
    var arrayFreshProduceCategoryList: MutableList<FreshProduceCategories>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var nearByStoreActivity: ((Int,Boolean) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem =
            layoutInflater.inflate(
                R.layout.layout_homecustomer_recycle_freshproduces,
                parent,
                false
            )
        return ViewHolder(
            listItem
        )
    }

    override fun getItemCount(): Int {
        return if (arrayFreshProduceCategoryList != null)
            return arrayFreshProduceCategoryList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {
            Glide.with(context)
                .load(URLConstant.urlStoreCategories + arrayFreshProduceCategoryList?.get(position)?.fresh_produce_image)
                .placeholder(R.drawable.placeholder_store_in_category)
                .into(holder.ivPicFreshProduce)

            holder.txtFreshProduceName.text =
                arrayFreshProduceCategoryList?.get(position)?.fresh_produce_title
        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var ivPicFreshProduce: ImageView
        var txtFreshProduceName: TextView

        init {
            this.ivPicFreshProduce = itemView.findViewById(R.id.ivPicFreshProduce) as ImageView
            this.txtFreshProduceName = itemView.findViewById(R.id.txtFreshProduceName) as TextView

            itemView.setOnClickListener {
                val position = adapterPosition
                nearByStoreActivity?.invoke(
                    position,
                    true
                )
            }
        }
    }
}