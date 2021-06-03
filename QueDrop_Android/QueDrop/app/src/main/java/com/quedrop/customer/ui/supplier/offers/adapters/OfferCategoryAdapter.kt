package com.quedrop.customer.ui.supplier.offers.adapters

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.getCategoryImage
import com.quedrop.customer.model.FoodCategory
import kotlinx.android.synthetic.main.list_item_selection.view.*

class OfferCategoryAdapter(val context: Context) :
    RecyclerView.Adapter<OfferCategoryAdapter.Viewholder>() {
    var categoryList:MutableList<FoodCategory> = mutableListOf()

    var onItemClick: ((Int, String) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): Viewholder {
        val view =
            LayoutInflater.from(context)
                .inflate(R.layout.list_item_selection, parent, false)
        return Viewholder(view)
    }

    override fun getItemCount(): Int {
        return categoryList.size
    }

    override fun onBindViewHolder(holder: Viewholder, position: Int) {
        holder.bindData(position)
    }

    inner class Viewholder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {

            itemView.setOnClickListener {
                onItemClick?.invoke(categoryList[adapterPosition].store_category_id,
                    categoryList[adapterPosition].store_category_title)
            }
        }

        fun bindData(position: Int) {
            itemView.tvName.text = categoryList[position].store_category_title
            Glide.with(context)
                .load(context.getCategoryImage(categoryList[position].store_category_image))
                .into(itemView.imgview)
        }
    }
}