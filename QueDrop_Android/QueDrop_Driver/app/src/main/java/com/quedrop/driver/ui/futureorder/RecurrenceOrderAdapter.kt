package com.quedrop.driver.ui.futureorder

import android.annotation.SuppressLint
import android.app.Activity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.driver.R
import com.quedrop.driver.service.model.RecurringOrderEntries
import com.quedrop.driver.utils.KEY_USERID
import com.quedrop.driver.utils.SharedPreferenceUtils
import com.quedrop.driver.utils.convertUTCDateToLocalDate


class RecurrenceOrderAdapter(
    var context: Activity,
    var arrayRecurringOrderList: MutableList<RecurringOrderEntries>
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var onAcceptClick: ((View, Int) -> Unit)? = null
    var onRejectClick: ((View, Int) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem =
            layoutInflater.inflate(R.layout.viewholder_recurrence_order, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return arrayRecurringOrderList.size
    }

    @SuppressLint("SetTextI18n", "CheckResult")
    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is ViewHolder) {
            holder.tvRecurrenceDate.text = convertUTCDateToLocalDate(arrayRecurringOrderList[position].order_place_datetime!!,"dd MMMM yyyy")
            val day=convertUTCDateToLocalDate(arrayRecurringOrderList[position].order_place_datetime!!,"EEEE")
            val time=convertUTCDateToLocalDate(arrayRecurringOrderList[position].order_place_datetime!!," hh:mm a")
            holder.tvRecurrenceTime.text = day+ " at"+time
            holder.tvRecurrenceType.text = arrayRecurringOrderList[position].recurring_type

            if (arrayRecurringOrderList[position].is_accepted == 1) {
                if (arrayRecurringOrderList[position].driver_id == SharedPreferenceUtils.getInt(KEY_USERID)
                ) {
                    holder.tvRecurrenceAccept.visibility = View.INVISIBLE
                    holder.tvRecurrenceAccepted.visibility = View.VISIBLE
                }

            } else {

            }

            if (arrayRecurringOrderList[position].rejected_drivers != null) {
                val str = arrayRecurringOrderList[position].rejected_drivers?.split(",")

                if (str?.contains<Any>(SharedPreferenceUtils.getInt(KEY_USERID).toString())!!) {
                    holder.tvRecurrenceReject.visibility = View.INVISIBLE
                    holder.tvRecurrenceRejected.visibility = View.VISIBLE
                    holder.tvRecurrenceAccept.visibility=View.GONE
                    holder.tvRecurrenceAccepted.visibility=View.GONE
                } else {
                    holder.tvRecurrenceReject.visibility = View.VISIBLE
                    holder.tvRecurrenceRejected.visibility = View.INVISIBLE
                }
            } else {
                holder.tvRecurrenceRejected.visibility = View.INVISIBLE
            }

            holder.tvRecurrenceAccept.setOnClickListener {
                onAcceptClick?.invoke(holder.tvRecurrenceAccept, position)
            }
            holder.tvRecurrenceReject.setOnClickListener {
                onRejectClick?.invoke(holder.tvRecurrenceReject, position)
            }
        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var tvRecurrenceTime: TextView = itemView.findViewById(R.id.tvRecurrenceTime)
        var tvRecurrenceDate: TextView = itemView.findViewById(R.id.tvRecurrenceDate)
        var tvRecurrenceType: TextView = itemView.findViewById(R.id.tvRecurrenceType)
        var tvRecurrenceAccept: TextView = itemView.findViewById(R.id.tvRecurrenceAccept)
        var tvRecurrenceReject: TextView = itemView.findViewById(R.id.tvRecurrenceReject)
        var tvRecurrenceAccepted: TextView = itemView.findViewById(R.id.tvRecurrenceAccepted)
        var tvRecurrenceRejected: TextView = itemView.findViewById(R.id.tvRecurrenceRejected)
    }
}