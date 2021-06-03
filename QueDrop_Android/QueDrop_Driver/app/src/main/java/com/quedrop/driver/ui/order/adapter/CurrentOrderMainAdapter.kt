package com.quedrop.driver.ui.order.adapter

import android.annotation.SuppressLint
import android.app.Activity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.driver.R
import com.quedrop.driver.service.model.Orders
import com.quedrop.driver.service.model.Stores
import com.quedrop.driver.utils.CURRENCY
import com.quedrop.driver.utils.convertUTCDateToLocalDate
import io.reactivex.Observable
import io.reactivex.subjects.PublishSubject


class CurrentOrderMainAdapter(
    var context: Activity,
    var arrayOrderList: MutableList<Orders>?,
    var isFromManualPayment: Boolean,
    var isFromEarnPayment: Boolean
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var currentOrderAdapter: CurrentOrderStoreListAdapter? = null
    var arrayStoreOrderList: ArrayList<Stores>? = null

    private val itemMainClickResult: PublishSubject<String> = PublishSubject.create()
    var itemMainClick: Observable<String> = itemMainClickResult.hide()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem =
            layoutInflater.inflate(R.layout.viewholder_main_order, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayOrderList != null)
            return arrayOrderList!!.size
        else 0
    }

    @SuppressLint("SetTextI18n", "CheckResult")
    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        arrayStoreOrderList = arrayOrderList?.get(position)?.stores as ArrayList<Stores>?
        if (holder is ViewHolder) {
            holder.tvDateOrder.text =
                convertUTCDateToLocalDate(arrayOrderList?.get(position)?.orderDate!!)
//            holder.tvDateOrder.text = arrayOrderList?.get(position)?.orderDate!!
            holder.tvOTotalOrder.text =
                CURRENCY + String.format("%.2f", arrayOrderList?.get(position)?.orderTotalAmount)

            if (arrayOrderList?.get(position)?.orderStatus != null) {
                holder.tvStatusOrder.text = arrayOrderList?.get(position)?.orderStatus
            } else {
                if (arrayOrderList?.get(position)?.isPaymentDone != "") {
                    if (arrayOrderList?.get(position)?.isPaymentDone?.toInt() == 1) {
                        holder.tvStatusOrder.text = "Payment Received"
                        holder.tvStatusOrder.setTextColor(
                            ContextCompat.getColor(
                                context,
                                R.color.colorStatusGreen
                            )
                        )
                    } else {
                        holder.tvStatusOrder.text = "Payment Pending"
                        holder.tvStatusOrder.setTextColor(
                            ContextCompat.getColor(
                                context,
                                R.color.colorStatusOrange
                            )
                        )
                    }
                }
            }

            if (isFromEarnPayment) {
                holder.ivRating.visibility = View.GONE
                holder.ivDate.visibility = View.VISIBLE
                holder.ivDate.text = convertUTCDateToLocalDate(arrayOrderList?.get(position)?.orderDate.toString(), "dd/MM/yyyy")
            } else if (isFromManualPayment) {
                holder.ivRating.visibility = View.GONE
                holder.ivDate.visibility = View.VISIBLE
                holder.ivDate.setText(convertUTCDateToLocalDate(arrayOrderList?.get(position)?.orderDate.toString(), "HH:MM a"))
            } else {
                //change rating visivibility
                holder.ivRating.visibility = View.GONE
                holder.ivDate.visibility = View.GONE
                if (arrayOrderList?.get(position)?.rating?.toInt() == 0) {
                    holder.ivRating.text = "0.0"
                } else {
                    holder.ivRating.text = String.format("%.2f", arrayOrderList?.get(position)?.rating)
                }
            }

            holder.rvMainCartListCurrent.layoutManager = LinearLayoutManager(
                context,
                LinearLayoutManager.VERTICAL,
                false
            )

            currentOrderAdapter = CurrentOrderStoreListAdapter(
                false,
                context,
                arrayOrderList?.get(position)?.orderStatus,
                arrayStoreOrderList!!,
                arrayOrderList?.get(position)?.deliveryOption
            )

            currentOrderAdapter?.itemStoreClick?.subscribe {
                val orderID = arrayOrderList?.get(holder.adapterPosition)?.orderId.toString()
                itemMainClickResult.onNext(orderID)
            }
            holder.itemView.setOnClickListener {
                val orderID = arrayOrderList?.get(holder.adapterPosition)?.orderId.toString()
                itemMainClickResult.onNext(orderID)
            }
            holder.rvMainCartListCurrent.adapter = currentOrderAdapter
        }

    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var rvMainCartListCurrent: RecyclerView = itemView.findViewById(R.id.rvMainCartListCurrent) as RecyclerView
        var tvDateOrder: TextView = itemView.findViewById(R.id.tvDateOrder)
        var tvOTotalOrder: TextView = itemView.findViewById(R.id.tvOTotalOrder)
        var tvStatusOrder: TextView = itemView.findViewById(R.id.tvStatusOrder)
        var ivRating: TextView = itemView.findViewById(R.id.ivRating)
        var ivDate: TextView = itemView.findViewById(R.id.ivDate)
    }

    fun updateData(dataSet: MutableList<Orders>?) {
        this.arrayOrderList = dataSet
        notifyDataSetChanged()
    }
}