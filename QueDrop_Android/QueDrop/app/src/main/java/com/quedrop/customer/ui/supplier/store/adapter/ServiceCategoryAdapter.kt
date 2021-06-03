package com.quedrop.customer.ui.supplier.store.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.model.Categories
import kotlinx.android.synthetic.main.list_item_servicecategory.view.*

class ServiceCategoryAdapter(val context: Context) :
    RecyclerView.Adapter<ServiceCategoryAdapter.Viewholder>() {

    var categoriesList: MutableList<Categories> = mutableListOf()
    var onItemClick: ((Int, String) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): Viewholder {
        val view =
            LayoutInflater.from(context)
                .inflate(R.layout.list_item_servicecategory, parent, false)
        return Viewholder(view)
    }

    override fun getItemCount(): Int {
        return categoriesList.size
    }

    override fun onBindViewHolder(holder: Viewholder, position: Int) {
        holder.bindData(position)
    }

    inner class Viewholder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {

            itemView.tvServiceCategoryName.setOnClickListener {
                onItemClick?.invoke(
                    categoriesList[adapterPosition].service_category_id,
                    categoriesList[adapterPosition].service_category_name
                )
            }
        }

        fun bindData(position: Int) {
            itemView.tvServiceCategoryName.text = categoriesList[position].service_category_name
        }
    }
}