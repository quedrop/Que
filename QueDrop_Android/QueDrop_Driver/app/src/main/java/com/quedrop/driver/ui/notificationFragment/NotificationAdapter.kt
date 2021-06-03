package com.quedrop.driver.ui.notificationFragment

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.driver.R
import com.quedrop.driver.service.model.Notifications
import com.quedrop.driver.utils.ENUMNotificationType
import com.quedrop.driver.utils.dateFormat
import com.quedrop.driver.utils.getCalenderDate
import kotlinx.android.synthetic.main.list_item_notification.view.*
import org.ocpsoft.prettytime.PrettyTime


class NotificationAdapter(val context: Context) :
    RecyclerView.Adapter<NotificationAdapter.ViewHolder>() {

    var notificationList: MutableList<Notifications> = mutableListOf()
    var onItemClick: ((View, Int, Int,Int) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(context).inflate(R.layout.list_item_notification, parent, false)
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
                onItemClick?.invoke(
                    itemView,
                    adapterPosition,
                    notificationList[adapterPosition].notificationType!!,
                    notificationList[adapterPosition].dataId!!
                )
            }
        }

        fun bindData(position: Int) {
            itemView.tvNotificationText.text = notificationList[position].notification
            val cal = notificationList[position].notificationDatetime?.getCalenderDate(dateFormat)
            val time = PrettyTime()
            itemView.tvDate.text = time.format(cal)

            setImage(notificationList[position].notificationType!!)
        }

        private fun setImage(position: Int) {
            when (position) {

                ENUMNotificationType.ORDER_REQUEST.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_noti_store)
                }
                ENUMNotificationType.ORDER_ACCEPT.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_noti_store)
                }
                ENUMNotificationType.ORDER_REJECT.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_noti_store)
                }
                ENUMNotificationType.ORDER_REQUEST_TIMEOUT.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_noti_store)
                }
                ENUMNotificationType.RECURRING_ORDER_PLACED.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_noti_store)
                }
                ENUMNotificationType.ORDER_DISPATCH.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_noti_store)
                }
                ENUMNotificationType.ORDER_RECEIPT.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_noti_store)
                }
                ENUMNotificationType.ORDER_CANCELLED.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_noti_store)
                }
                ENUMNotificationType.ORDER_DELIVERED.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_noti_placed)
                }
                ENUMNotificationType.DRIVER_VERIFICATION.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_noti_rating)
                }
                ENUMNotificationType.RATING.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_noti_rating)
                }
                ENUMNotificationType.NEAR_BY_PLACE.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_noti_store)
                }
                ENUMNotificationType.UNKNOWN_TYPE.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_noti_store)
                }

            }
        }
    }
}