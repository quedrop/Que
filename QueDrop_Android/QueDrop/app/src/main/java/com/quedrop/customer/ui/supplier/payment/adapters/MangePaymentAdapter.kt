package com.quedrop.customer.ui.supplier.payment.adapters

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.getBankLogo
import com.quedrop.customer.model.BankDetails
import kotlinx.android.synthetic.main.item_control_end.view.*


class MangePaymentAdapter(
    var context: Context
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var bankDetailArrayList: MutableList<BankDetails> = mutableListOf()

    var onItemClick: ((View, Int, String) -> Unit)? = null
    var onClickDeleteBtn: ((View, Int, String) -> Unit)? = null


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        var listItem = layoutInflater.inflate(R.layout.swipe_layout_list, parent, false)
        return ViewHolder(
            listItem
        )
    }

    override fun getItemCount(): Int {
        return bankDetailArrayList.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {

            if (!bankDetailArrayList.get(position).bank_logo.isNullOrEmpty()) {
                Glide.with(context)
                    .load(context.getBankLogo(bankDetailArrayList.get(position).bank_logo!!))
                    .placeholder(R.drawable.placeholder_product_supplier)
                    .centerInside()
                    .into(holder.ivBankLogo)
            }
            holder.txtBankName.text = bankDetailArrayList.get(position).bank_name
            val number = bankDetailArrayList.get(position).account_number
            val mask = number?.replace("\\w(?=\\w{4})".toRegex(), "*")

            holder.tvBankNumber.text = mask

            if (bankDetailArrayList[position].is_primary == 0) {
                holder.ivPrimary.setImageResource(R.drawable.ic_no_primary)
            } else {
                holder.ivPrimary.setImageResource(R.drawable.ic_primary)
            }
        }

    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {

            itemView.setOnClickListener {
                onItemClick?.invoke(
                    itemView,
                    adapterPosition,
                    bankDetailArrayList[adapterPosition].bank_name!!
                )
            }

            itemView.btnDelete.setOnClickListener {
                onClickDeleteBtn?.invoke(
                    btnDelete,
                    adapterPosition,
                    bankDetailArrayList[adapterPosition].bank_name!!
                )
            }
        }

        var ivBankLogo = itemView.findViewById(R.id.ivBankLogo) as ImageView
        var txtBankName = itemView.findViewById(R.id.txtBankName) as TextView
        var tvBankNumber = itemView.findViewById(R.id.tvBankNumber) as TextView
        var ivPrimary = itemView.findViewById(R.id.ivPrimary) as ImageView
        var btnDelete = itemView.findViewById(R.id.btnDelete) as TextView


    }

    fun updateData(bankDataArrayList: MutableList<BankDetails>) {
        this.bankDetailArrayList = bankDataArrayList
        notifyDataSetChanged()
    }
}


