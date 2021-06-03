package com.quedrop.customer.ui.notification.view

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.getCalenderDate
import com.quedrop.customer.model.NotificationModel
import com.quedrop.customer.utils.ENUMNotificationType
import kotlinx.android.synthetic.main.list_item_notification.view.*
import org.ocpsoft.prettytime.PrettyTime


class NotificationCustomerAdapter(val context: Context) :
    RecyclerView.Adapter<NotificationCustomerAdapter.ViewHolder>() {
    var notificationList: MutableList<NotificationModel> = mutableListOf()
    val dateFormat = "yyyy-MM-dd HH:mm:ss"

    var orderInvoke : ((Int,Int) ->Unit)?=null

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
                orderInvoke?.invoke(adapterPosition, notificationList[adapterPosition].data_id)
            }

        }

        fun bindData(position: Int) {
            itemView.tvNotificationText.text = notificationList[position].notification
            val cal = notificationList[position].notification_datetime.getCalenderDate(dateFormat)
            val time = PrettyTime()
            itemView.tvDate.text = time.format(cal)
            setImage(notificationList[position].notification_type)
        }


        private fun setImage(position: Int) {
            when (position) {

                ENUMNotificationType.ORDER_REQUEST.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_notification_box)
                }
                ENUMNotificationType.ORDER_ACCEPT.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_notification_box)
                }
                ENUMNotificationType.ORDER_REJECT.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_notification_box)
                }
                ENUMNotificationType.ORDER_REQUEST_TIMEOUT.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_notification_box)
                }
                ENUMNotificationType.RECURRING_ORDER_PLACED.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_notification_box)
                }
                ENUMNotificationType.ORDER_DISPATCH.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_notification_box)
                }
                ENUMNotificationType.ORDER_RECEIPT.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_notification_box)
                }
                ENUMNotificationType.ORDER_CANCELLED.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_notification_box)
                }
                ENUMNotificationType.ORDER_DELIVERED.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_fav_noti)
                }
                ENUMNotificationType.DRIVER_VERIFICATION.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_like_noti)
                }
                ENUMNotificationType.RATING.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_like_noti)
                }
                ENUMNotificationType.NEAR_BY_PLACE.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_notification_box)
                }
                ENUMNotificationType.UNKNOWN_TYPE.posVal -> {
                    itemView.ivNotification.setImageResource(R.drawable.ic_notification_box)
                }

            }
        }
    }
}