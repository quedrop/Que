package com.quedrop.customer.ui.order.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.GetCurrentOrderResponse
import com.quedrop.customer.model.StoreDetailsOrder
import com.quedrop.customer.utils.ConstantUtils.Companion.EXPRESS_DELIVERY
import com.quedrop.customer.utils.ConstantUtils.Companion.STANDARD_DELIVERY
import io.reactivex.disposables.CompositeDisposable
import kotlinx.android.synthetic.main.layout_main_current_recycler_list.view.*
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.ArrayList


class CurrentOrderMainAdapter(
    var context: Context,
    var isOrder: String,
    var arrayOrderList: MutableList<GetCurrentOrderResponse>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var currentOrderAdapter: CurrentOrderStoreListAdapter? = null
    var arrayStoreOrderList: ArrayList<StoreDetailsOrder>? = null
    var currentOrderListInvoke: ((Int, Long, Int) -> Unit)? = null
    var rescheduleInvokeMain: ((Int) -> Unit)? = null
    var refereshTimer: ((Int) -> Unit)? = null
    var serverTime: String = ""
    var isDriverAcceptedMain: Boolean = false
    var isTimerStart: Boolean = false
    var isTimeRamining: Long = 0
    var timeMainRemaining1: Long = 0
    var timerVal: Long = 0

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem =
            layoutInflater.inflate(R.layout.layout_main_current_recycler_list, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayOrderList != null)
            return arrayOrderList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {
            holder.bind(position)
        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var rvMainCartListCurrent: RecyclerView
        var tvOrderOnOrder: TextView
        var tvDateOrder: TextView
        var tvOTotalOrder: TextView
        var tvStatusOrder: TextView
        var tvDeliveryType: TextView

        init {
            this.rvMainCartListCurrent = itemView.findViewById(R.id.rvMainCartListCurrent) as RecyclerView
            this.tvOrderOnOrder = itemView.findViewById(R.id.tvOrderOnOrder)
            this.tvDateOrder = itemView.findViewById(R.id.tvDateOrder)
            this.tvOTotalOrder = itemView.findViewById(R.id.tvOTotalOrder)
            this.tvStatusOrder = itemView.findViewById(R.id.tvStatusOrder)
            this.tvDeliveryType = itemView.findViewById(R.id.tvDeliveryType)

            itemView.throttleClicks().subscribe {

                currentOrderListInvokeMethod(adapterPosition)
            }.autoDispose(CompositeDisposable())

            rvMainCartListCurrent.throttleClicks().subscribe {
                currentOrderListInvokeMethod(adapterPosition)

            }.autoDispose(CompositeDisposable())
        }

        private fun currentOrderListInvokeMethod(adapterPosition: Int) {
            currentOrderListInvoke?.invoke(
                arrayOrderList?.get(adapterPosition)?.order_id!!,
                timeMainRemaining1,
                adapterPosition
            )
        }

        fun bind(position: Int) {
            arrayStoreOrderList = arrayOrderList?.get(position)?.stores

            val inputConverter = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.ENGLISH).parse(
                arrayOrderList?.get(position)?.order_date!!
            )

            inputConverter?.let {
                val simpleDateFormatDate =
                    SimpleDateFormat("dd MMM yyyy ", Locale.ENGLISH).format(it)
                val simpleDateFormatTime = SimpleDateFormat("HH:mm a", Locale.ENGLISH).format(it)
                itemView.tvDateOrder.text = simpleDateFormatDate + "at " + simpleDateFormatTime
            }

//            itemView.tvOTotalOrder.text = "$" + arrayOrderList?.get(position)?.order_amount
            itemView.tvOTotalOrder.text =
                "$" + String.format("%.2f", arrayOrderList?.get(position)?.order_amount!!.toFloat())
//            holder.tvStatusOrder.text = arrayOrderList?.get(position)?.order_status

            if (arrayOrderList?.get(position)?.delivery_option == STANDARD_DELIVERY) {
                itemView.tvDeliveryType.visibility = View.GONE
            } else if (arrayOrderList?.get(position)?.delivery_option == EXPRESS_DELIVERY) {
                itemView.tvDeliveryType.visibility = View.VISIBLE
            } else {
                itemView.tvDeliveryType.visibility = View.GONE
            }

            itemView.rvMainCartListCurrent.layoutManager = LinearLayoutManager(
                context,
                LinearLayoutManager.VERTICAL,
                false
            )

            timerVal = arrayOrderList?.get(position)?.timer_value!!

            // serverTime = arrayOrderList?.get(position)?.server_time!!


            currentOrderAdapter = CurrentOrderStoreListAdapter(
                position,
                context,
                isTimeRamining,
                arrayStoreOrderList!!,
                arrayOrderList?.get(position)?.order_date,
                arrayOrderList?.get(position)?.updated_server_time,
                arrayOrderList?.get(position)?.order_status!!,
                serverTime,
                timerVal

            ).apply {
                currentOrderListInvoke1 = { view: View, timeMainRemaining: Long ->
                    timeMainRemaining1 = timeMainRemaining
                    currentOrderListInvokeMethod(position)
                }
                rescheduleInvoke = {
                    rescheduleClick(it)
                }
                refreshTimer = {
                    refereshTimer?.invoke(arrayOrderList!![position].order_id)
                }
            }
            itemView.rvMainCartListCurrent.adapter = currentOrderAdapter

            if (isOrder == "1") {
                itemView.tvStatusOrder.visibility = View.GONE
            } else {
                itemView.tvStatusOrder.visibility = View.GONE
                currentOrderAdapter?.setPastOrder()
            }
        }

        private fun rescheduleClick(view: View) {
            rescheduleInvokeMain?.invoke(adapterPosition)
        }
    }


    fun setProgressDriver(isDriverAccepted: Boolean) {
        isDriverAcceptedMain = isDriverAccepted
        isTimerStart = true
        notifyDataSetChanged()

    }

    fun updateServerTimer(intentServerTime: String) {
        serverTime = intentServerTime

    }

    override fun getItemViewType(position: Int): Int {
        return position
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }
}