package com.quedrop.driver.ui.settings.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import com.quedrop.driver.service.model.BankDetails
import com.quedrop.driver.utils.ImageConstant.USER_BANK_DETAILS
import kotlinx.android.synthetic.main.item_control_end.view.*


class MangePaymentAdapter(
    var context: Context,
    var bankDetailArrayList: MutableList<BankDetails>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

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
        return if (bankDetailArrayList != null)
            return bankDetailArrayList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {

            if (!bankDetailArrayList?.get(position)?.bankLogo.isNullOrEmpty()) {
                Glide.with(context).load(
                    BuildConfig.BASE_URL + USER_BANK_DETAILS + bankDetailArrayList?.get(position)?.bankLogo
                ).centerInside().into(holder.ivBankLogo)
            }
            holder.txtBankName.text = bankDetailArrayList?.get(position)?.bankName
            val number = bankDetailArrayList?.get(position)?.accountNumber
            val mask = number?.replace("\\w(?=\\w{4})".toRegex(), "*")

            holder.tvBankNumber.text = mask

            if (bankDetailArrayList?.get(position)?.isPrimary == 0) {
                holder.txtAccountType.visibility = View.GONE
            } else {
                holder.txtAccountType.visibility = View.VISIBLE
            }
        }

    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {

            itemView.setOnClickListener {
                onItemClick?.invoke(
                    itemView,
                    adapterPosition,
                    bankDetailArrayList!![adapterPosition].bankName!!
                )
            }

            itemView.btnDelete.setOnClickListener {
                onClickDeleteBtn?.invoke(
                    btnDelete,
                    adapterPosition,
                    bankDetailArrayList!![adapterPosition].bankName!!
                )
            }
        }

        var ivBankLogo = itemView.findViewById(R.id.ivBankLogo) as ImageView
        var txtBankName = itemView.findViewById(R.id.txtBankName) as TextView
        var tvBankNumber = itemView.findViewById(R.id.tvBankNumber) as TextView
        var txtAccountType = itemView.findViewById(R.id.txtAccountType) as TextView
        var btnDelete = itemView.findViewById(R.id.btnDelete) as TextView


    }
}


