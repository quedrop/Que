package com.quedrop.customer.ui.order.view.adapter

import android.content.Context
import android.os.CountDownTimer
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.model.ProductDetailsOrder
import com.quedrop.customer.model.StoreSingleDetails
import com.quedrop.customer.utils.EnumUtils
import com.quedrop.customer.utils.URLConstant
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.layout_store_details_order.view.*
import java.text.SimpleDateFormat
import java.util.*


class CurrentOrderDetailsStoreAdapter(
    var context: Context,
    var timeRemaining: Long,
    var orderStatus: String,
    var orderDate: String,
    var updatedServerTime: String,
    var arrayStoreAdapterList: MutableList<StoreSingleDetails>?,
    var timerVal: Int
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var currentOrderAdapter: CurrentOrderProductListAdapter? = null
    var arrayProductList: MutableList<ProductDetailsOrder>? = null
    var removeTimerInvoke: ((Long) -> Unit)? = null
    var removeTimerInvokeCheckVisibilty: ((Long) -> Unit)? = null
    var refreshDataFromSocketResponse: ((Long) -> Unit)? = null


    private var timer: CountDownTimer? = null
    val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        var listItem =
            layoutInflater.inflate(R.layout.layout_store_details_order, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayStoreAdapterList != null)
            return arrayStoreAdapterList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {
            holder.bindViewHolder(position)
        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var rvProductsOrder: RecyclerView = itemView.findViewById(R.id.rvProductsOrder)
        var tvStoreNameOrder: TextView = itemView.findViewById(R.id.tvStoreNameOrder)
        var tvStoreAddressOrder: TextView = itemView.findViewById(R.id.tvStoreAddressOrder)
        var tvTime: TextView = itemView.findViewById(R.id.tvTime)
        var timerBackground: View = itemView.findViewById(R.id.timerBackground)
        var ivStoreLogoOrder: ImageView = itemView.findViewById(R.id.ivStoreLogoOrder)
        var tvRemainingTime: TextView = itemView.findViewById(R.id.tvRemainingTime)

        fun navigationVisibility() {
            tvTime.visibility = View.GONE
            timerBackground.visibility = View.GONE
            tvRemainingTime.visibility = View.GONE
            removeTimerInvoke?.invoke(timeRemaining)
        }

        fun bindViewHolder(position: Int) {

            itemView.tvStoreNameOrder.text = arrayStoreAdapterList?.get(position)?.store_name
            itemView.tvStoreAddressOrder.text = arrayStoreAdapterList?.get(position)?.store_address

            Glide.with(context).load(URLConstant.nearByStoreUrl + arrayStoreAdapterList?.get(position)?.store_logo)
                .placeholder(R.drawable.placeholder_order_cart_product)
                .into(itemView.ivStoreLogoOrder)

            if (position == 0) {
                if (timeRemaining.toString().isEmpty()) {
                    if (orderStatus == EnumUtils.PLACED.stringVal) {
                        navigationVisibility()
                    } else if (orderStatus == EnumUtils.DELIVERED.stringVal) {
                        itemView.timerBackground.visibility = View.GONE
                        itemView.tvTime.visibility = View.GONE
                        itemView.tvRemainingTime.visibility = View.GONE
                    } else {
                        itemView.timerBackground.visibility = View.VISIBLE
                        itemView.tvTime.visibility = View.VISIBLE
                        itemView.tvRemainingTime.visibility = View.VISIBLE
                        doSecondWork()
                    }
                } else {

                    if (orderStatus == EnumUtils.PLACED.stringVal) {
                        removeTimerInvokeCheckVisibilty?.invoke(timeRemaining)
                        itemView.timerBackground.visibility = View.VISIBLE
                        itemView.tvTime.visibility = View.VISIBLE
                        itemView.tvRemainingTime.visibility = View.VISIBLE
                        bind()
                    } else if (orderStatus == EnumUtils.DELIVERED.stringVal) {
                        itemView.timerBackground.visibility = View.GONE
                        itemView.tvTime.visibility = View.GONE
                        itemView.tvRemainingTime.visibility = View.GONE
                    } else {
                        itemView.timerBackground.visibility = View.VISIBLE
                        itemView.tvTime.visibility = View.VISIBLE
                        itemView.tvRemainingTime.visibility = View.VISIBLE
                        doSecondWork()

                    }
                }
            } else {
                itemView.timerBackground.visibility = View.GONE
                itemView.tvTime.visibility = View.GONE
                itemView.tvRemainingTime.visibility = View.GONE

            }

            arrayProductList = arrayStoreAdapterList?.get(position)?.products

            itemView.rvProductsOrder.layoutManager = LinearLayoutManager(
                context,
                LinearLayoutManager.VERTICAL,
                false
            )
            currentOrderAdapter = CurrentOrderProductListAdapter(
                context,
                arrayProductList!!

            )
            itemView.rvProductsOrder.adapter = currentOrderAdapter
        }


        private fun bind() {


            timer?.cancel()
            val calendar = Calendar.getInstance()

            //Need to set order placed time in local

            //val orderPlacedTimeString = "09-04-2020 18:20:00"
            val orderDateConvertString = Utils.convertServerDateToUserTimeZone(orderDate)
            val orderPlacedTimeString = orderDateConvertString

            val orderPlacedDate = dateFormat.parse(orderPlacedTimeString)
            // using current time for logic set up so comment it when using for specific date
            //orderPlacedDate.time = calendar.timeInMillis

            val currentTime = calendar.time
            calendar.timeInMillis = orderPlacedDate!!.time

            calendar.add(Calendar.MINUTE, 3)
//            calendar.add(Calendar.SECOND, ((timeRemaining / 1000) % 60).toInt())

            if (currentTime.before(calendar.time)) {
                val remainingTime = calendar.timeInMillis - currentTime.time

                timer = object : CountDownTimer(remainingTime, 1000) {
                    override fun onFinish() {
                        navigationVisibility()
                    }

                    override fun onTick(millisUntilFinished: Long) {
                        itemView.tvTime.text = Utils.msToString1(millisUntilFinished)
                        println("****** timer remining  time text" + itemView.tvTime.text)

                    }

                }.start()
            } else {
                navigationVisibility()

            }

        }


        private fun doSecondWork() {
            timer?.cancel()
            val calendar = Calendar.getInstance()


            //Need to set order placed time in local

            //val orderPlacedTimeString = "09-04-2020 18:20:00"
//            var orderDateConvertString = Utils.convertServerDateToUserTimeZone(orderDate)
            //zp changes
            var orderDateConvertString = Utils.convertServerDateToUserTimeZone(updatedServerTime)
            val orderPlacedTimeString = orderDateConvertString

            val orderPlacedDate = dateFormat.parse(orderPlacedTimeString)
            // using current time for logic set up so comment it when using for specific date
            //orderPlacedDate.time = calendar.timeInMillis

            val currentTime = calendar.time
            calendar.timeInMillis = orderPlacedDate!!.time

            calendar.add(Calendar.SECOND, timerVal)

            if (currentTime.before(calendar.time)) {
                val remainingTime = calendar.timeInMillis - currentTime.time

                if (remainingTime <= 180000) {
                    //Api call
                    refreshDataFromSocketResponse?.invoke(remainingTime)
                }

                timer = object : CountDownTimer(remainingTime, 1000) {
                    override fun onFinish() {
//                        itemView.tvTime.text = context.resources.getString(R.string.timeFinish)
                        tvTime.visibility = View.GONE
                        timerBackground.visibility = View.GONE
                        tvRemainingTime.visibility = View.GONE
                    }

                    override fun onTick(millisUntilFinished: Long) {
                        itemView.tvTime.text = Utils.msToString(millisUntilFinished)
                        if (millisUntilFinished <= 180000) {
                            //Api call
                            timer?.cancel()
                            refreshDataFromSocketResponse?.invoke(remainingTime)
                        }

                    }

                }.start()

            } else {
                /* tvTime.visibility = View.GONE
                 timerBackground.visibility = View.GONE
                 tvRemainingTime.visibility = View.GONE*/
                val remainingTime = calendar.timeInMillis - currentTime.time
                refreshDataFromSocketResponse?.invoke(remainingTime)
            }

        }

    }


}