package com.quedrop.customer.ui.storewithproduct.view

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.model.FoodCategory
import com.makeramen.roundedimageview.RoundedImageView
import com.quedrop.customer.utils.URLConstant


class CategoriesFoodAdapter(
    var context: Context,
    var arrayFoodCategoryList: MutableList<FoodCategory>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var adItemClickFood : ((Int, View) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem = layoutInflater.inflate(R.layout.layout_category_food_recycle, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayFoodCategoryList != null)
            return arrayFoodCategoryList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {

            Glide.with(context).load(
                URLConstant.urlStoreCategories + arrayFoodCategoryList?.get(
                    position)?.store_category_image
            ).placeholder(R.drawable.placeholder_order_cart_product)
                .into(holder.imageView)

            holder.textView.text = arrayFoodCategoryList?.get(position)!!.store_category_title
        }

    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var imageView: RoundedImageView
        var textView: TextView


        init {
            this.imageView = itemView.findViewById(R.id.ivPicFood)
            this.textView = itemView.findViewById(R.id.tvItemNameFood)

            itemView.setOnClickListener {
                val position=adapterPosition
                adItemClickFood?.invoke(position,it)
            }

        }
    }

}