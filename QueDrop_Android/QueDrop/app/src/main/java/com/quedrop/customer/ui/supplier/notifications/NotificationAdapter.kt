package com.quedrop.customer.ui.supplier.notifications

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.getCalenderDate
import com.quedrop.customer.model.NotificationModel
import kotlinx.android.synthetic.main.list_item_notification.view.*
import org.ocpsoft.prettytime.PrettyTime


class NotificationAdapter(val context: Context) :
    RecyclerView.Adapter<NotificationAdapter.ViewHolder>() {
    var notificationList : MutableList<NotificationModel> = mutableListOf()
    val dateFormat = "yyyy-MM-dd HH:mm:ss"


    var orderInvoke : ((Int,Int,Int) ->Unit)?=null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view =
            LayoutInflater.from(context)
                .inflate(R.layout.list_item_notification, parent, false)
        return ViewHolder(view)
    }

    override fun getItemCount(): Int {
        return notificationList.size
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bindData(position)
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {

            itemView.setOnClickListener {
                orderInvoke?.invoke(adapterPosition, notificationList[adapterPosition].data_id,notificationList[adapterPosition].notification_type)
            }

        }

        fun bindData(position: Int) {
            itemView.tvNotificationText.setText(notificationList[position].notification)
            val cal = notificationList[position].notification_datetime.getCalenderDate(dateFormat)
            val time = PrettyTime()
            itemView.tvDate.setText(time.format(cal))
        }
    }
}