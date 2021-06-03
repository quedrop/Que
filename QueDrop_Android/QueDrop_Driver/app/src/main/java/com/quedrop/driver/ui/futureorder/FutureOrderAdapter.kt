package com.quedrop.driver.ui.futureorder

import android.annotation.SuppressLint
import android.app.Activity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.driver.R
import com.quedrop.driver.service.model.Orders
import com.quedrop.driver.service.model.Stores
import com.quedrop.driver.ui.order.adapter.CurrentOrderStoreListAdapter
import com.quedrop.driver.utils.CURRENCY
import com.quedrop.driver.utils.convertUTCDateToLocalDate
import io.reactivex.Observable
import io.reactivex.subjects.PublishSubject


class FutureOrderAdapter(
    var context: Activity,
    var arrayFutureOrderList: MutableList<Orders>
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var currentOrderAdapter: CurrentOrderStoreListAdapter? = null
    var arrayStoreOrderList: ArrayList<Stores>? = null

    private val itemMainClickResult: PublishSubject<String> = PublishSubject.create()
    var itemMainClick: Observable<String> = itemMainClickResult.hide()
    var onCalenderClick: ((View, Int) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem =
            layoutInflater.inflate(R.layout.viewholder_future_order, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return arrayFutureOrderList.size
    }

    @SuppressLint("SetTextI18n", "CheckResult")
    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        arrayStoreOrderList = arrayFutureOrderList[position].stores as ArrayList<Stores>?

        if (holder is ViewHolder) {


            if (arrayFutureOrderList[position].recurringType == "Once") {
                holder.ivMonthlyCalender.visibility = View.GONE
                holder.tvFutureOrderDate.text = convertUTCDateToLocalDate(arrayFutureOrderList[position].repeatUntilDate.toString())
            } else if (arrayFutureOrderList[position].recurringType == "Weekly") {
                holder.ivMonthlyCalender.visibility = View.GONE
                val time = convertUTCDateToLocalDate(
                    arrayFutureOrderList[position].repeatUntilDate.toString(),
                    "hh:mm a"
                )
                holder.tvFutureOrderDate.text =
                    arrayFutureOrderList[position].recurredOn + " at " + time

            } else if (arrayFutureOrderList[position].recurringType == "Monthly") {
                holder.ivMonthlyCalender.visibility = View.VISIBLE
                val time = convertUTCDateToLocalDate(
                    arrayFutureOrderList[position].repeatUntilDate.toString(),
                    " hh:mm a"
                )
                holder.tvFutureOrderDate.text = "Monthly at " + time
            } else {
                holder.ivMonthlyCalender.visibility = View.GONE
                holder.tvFutureOrderDate.text = "Everyday"
            }

            holder.tvOTotalOrder.text =
                CURRENCY + String.format("%.2f", arrayFutureOrderList[position].orderTotalAmount)

            currentOrderAdapter = CurrentOrderStoreListAdapter(
                false,
                context,
                "",
                arrayStoreOrderList!!,
               ""
            )

            currentOrderAdapter?.itemStoreClick?.subscribe {
                val orderID =
                    arrayFutureOrderList[holder.adapterPosition].recurringOrderId.toString()
                itemMainClickResult.onNext(orderID)
            }
            holder.itemView.setOnClickListener {
                val orderID =
                    arrayFutureOrderList[holder.adapterPosition].recurringOrderId.toString()
                itemMainClickResult.onNext(orderID)
            }
            holder.ivMonthlyCalender.setOnClickListener {
                onCalenderClick?.invoke(holder.ivMonthlyCalender, position)
            }
            holder.rvFutureOrderStore.adapter = currentOrderAdapter
        }

    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var rvFutureOrderStore: RecyclerView =
            itemView.findViewById(R.id.rvFutureOrderStore) as RecyclerView
        var tvFutureOrderDate: TextView = itemView.findViewById(R.id.tvFutureOrderDate)
        var tvOTotalOrder: TextView = itemView.findViewById(R.id.tvOTotalOrder)
        var ivMonthlyCalender: ImageView = itemView.findViewById(R.id.ivMonthlyCalender)
        var tvAccept: TextView = itemView.findViewById(R.id.tvAccept)
        var tvReject: TextView = itemView.findViewById(R.id.tvReject)
    }
}