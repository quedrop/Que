package com.quedrop.customer.ui.supplier.myorders.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.getBankLogo
import com.quedrop.customer.model.BankDetailModel
import com.quedrop.customer.model.FreshProduce
import kotlinx.android.synthetic.main.list_fresh_item_selection.view.*
import kotlinx.android.synthetic.main.list_item_selection.view.*

class FreshProduceCategoryAdapter(val context: Context) :
    RecyclerView.Adapter<FreshProduceCategoryAdapter.Viewholder>() {
    var freshProduceList:MutableList<FreshProduce> = mutableListOf()

    var onItemClick: ((Int, String) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): Viewholder {
        val view = LayoutInflater.from(context).inflate(R.layout.list_fresh_item_selection, parent, false)
        return Viewholder(view)
    }

    override fun getItemCount(): Int {
        return freshProduceList.size
    }

    override fun onBindViewHolder(holder: Viewholder, position: Int) {
        holder.bindData(position)
    }

    inner class Viewholder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {

            itemView.tvFreshProduceName.setOnClickListener {
                onItemClick?.invoke(freshProduceList[adapterPosition].fresh_category_id,
                    freshProduceList[adapterPosition].fresh_produce_title)
            }
        }

        fun bindData(position: Int) {
            itemView.tvFreshProduceName.text = freshProduceList[position].fresh_produce_title
//            Glide.with(context)
//                .load(context.getBankLogo(freshProduceList[position].bank_logo))
//                .into(itemView.imgview)
        }
    }
}