package com.quedrop.driver.ui.settings.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import com.quedrop.driver.utils.ImageConstant
import com.quedrop.driver.service.model.BankDetailModel
import kotlinx.android.synthetic.main.list_item_selection.view.*

class BankListAdapter(val context: Context) :
    RecyclerView.Adapter<BankListAdapter.Viewholder>() {
    var bankList: MutableList<BankDetailModel> = mutableListOf()

    var onItemClick: ((Int, String) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): Viewholder {
        val view =
            LayoutInflater.from(context)
                .inflate(R.layout.list_item_selection, parent, false)
        return Viewholder(view)
    }

    override fun getItemCount(): Int {
        return bankList.size
    }

    override fun onBindViewHolder(holder: Viewholder, position: Int) {
        holder.bindData(position)
    }

    inner class Viewholder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {

            itemView.setOnClickListener {
                onItemClick?.invoke(
                    bankList[adapterPosition].bank_id,
                    bankList[adapterPosition].bank_name
                )
            }
        }

        fun bindData(position: Int) {
            itemView.tvName.text = bankList[position].bank_name
            Glide.with(context)
                .load(BuildConfig.BASE_URL + ImageConstant.USER_BANK_DETAILS + bankList[position].bank_logo)
                .into(itemView.imgview)
        }
    }
}