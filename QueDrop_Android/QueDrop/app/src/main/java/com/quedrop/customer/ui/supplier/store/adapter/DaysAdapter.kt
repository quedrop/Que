package com.quedrop.customer.ui.supplier.store.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.model.StoreSchedule
import kotlinx.android.synthetic.main.list_item_days.view.*


class DaysAdapter(val context: Context, val emptyView: View? = null, val isFromeditStore: Boolean) :
    RecyclerView.Adapter<DaysAdapter.ViewHolder>() {
    var dayList: MutableList<StoreSchedule> = mutableListOf()
    var onClick: ((Int, Int, MutableList<StoreSchedule>) -> Unit)? = null
    var onSwitchClick: ((Int, Boolean) -> Unit)? = null
    var onSwitchClickListener: ((Int, MutableList<StoreSchedule>, Int) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view =
            LayoutInflater.from(context)
                .inflate(R.layout.list_item_days, parent, false)
        return ViewHolder(view)
    }

    override fun getItemCount(): Int {
        if (dayList.isEmpty()) {
            emptyView?.visibility = View.VISIBLE
        } else {
            emptyView?.visibility = View.GONE
        }
        return dayList.size
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bindData(position)

    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {
            if (isFromeditStore) {
                itemView.etOpenTime.isFocusable = true
                itemView.etOpenTime.isClickable = true

                itemView.etCloseTime.isFocusable = true
                itemView.etCloseTime.isClickable = true
            }


            itemView.etOpenTime.setOnClickListener {
                onClick?.invoke(adapterPosition, 0, dayList)
            }
            itemView.etCloseTime.setOnClickListener {
                onClick?.invoke(adapterPosition, 1, dayList)
            }

//            itemView.switchDays.setOnCheckedChangeListener { compoundButton, b ->
//                onSwitchClick?.invoke(adapterPosition, b)
//
//            }


            itemView.switchDays.setOnClickListener {
                onSwitchClickListener?.invoke(adapterPosition, dayList, dayList[position].is_closed)
            }

        }

        fun bindData(position: Int) {
            itemView.tvDays.text = dayList[position].weekday
            itemView.etOpenTime.setText(dayList[position].opening_time)
            itemView.etCloseTime.setText(dayList[position].closing_time)

            if (dayList[position].is_closed == 0) {
                itemView.etOpenTime.visibility = View.GONE
                itemView.etCloseTime.visibility = View.GONE
                itemView.etClosed.visibility = View.VISIBLE
            } else {
                itemView.etOpenTime.visibility = View.VISIBLE
                itemView.etCloseTime.visibility = View.VISIBLE
                itemView.etClosed.visibility = View.GONE
            }

            if (isFromeditStore) {
                itemView.switchDays.visibility = View.VISIBLE

                itemView.switchDays.isChecked = dayList[position].is_closed != 0

            } else {
                itemView.switchDays.visibility = View.GONE

            }

        }

    }
}