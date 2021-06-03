package com.quedrop.customer.ui.order.view.adapter

import android.content.Context
import android.os.CountDownTimer
import android.util.Log
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
import com.quedrop.customer.model.StoreDetailsOrder
import com.quedrop.customer.utils.URLConstant
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.layout_store_order_recycle.view.*
import java.text.SimpleDateFormat
import java.util.*


class CurrentOrderStoreListAdapter(
    var positionMain: Int,
    var context: Context,
    var remainingMisFromCart: Long,
    var arrayStoreAdapterList: MutableList<StoreDetailsOrder>?,
    var orderDate: String?,
    var updatedServerTime: String?,
    var orderStatus: String?,
    var serverTime: String?,
    var timerVal: Long
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private var flagPastOrder: Boolean = false
    var currentOrderAdapter: CurrentOrderProductListAdapter? = null
    var arrayProductList: MutableList<ProductDetailsOrder>? = null
    var currentOrderListInvoke1: ((View, Long) -> Unit)? = null
    var rescheduleInvoke: ((View) -> Unit)? = null
    var refreshTimer: ((Long) -> Unit)? = null

    private var timer: CountDownTimer? = null
    private var timer2: CountDownTimer? = null
    val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        var listItem = layoutInflater.inflate(R.layout.layout_store_order_recycle, parent, false)
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
        var rvProductsOrder: RecyclerView
        var tvStoreNameOrder: TextView
        var tvStoreAddressOrder: TextView
        var tvRemainingTime: TextView
        var tvRescedule: TextView
        var ivStoreLogoOrder: ImageView
        var tvTime: TextView
        var timerBackground: View

        init {

            this.tvStoreNameOrder = itemView.findViewById(R.id.tvStoreNameOrder)
            this.tvStoreAddressOrder = itemView.findViewById(R.id.tvStoreAddressOrder)
            this.tvTime = itemView.findViewById(R.id.tvTime)
            this.timerBackground = itemView.findViewById(R.id.timerBackground)
            this.ivStoreLogoOrder = itemView.findViewById(R.id.ivStoreLogoOrder)
            rvProductsOrder = itemView.findViewById(R.id.rvProductsOrder)
            tvRemainingTime = itemView.findViewById(R.id.tvRemainingTime)
            tvRescedule = itemView.findViewById(R.id.tvRescedule)

            itemView.setOnClickListener {
                currentOrderListInvoke1?.invoke(it, remainingMisFromCart)
            }

            rvProductsOrder.setOnClickListener {
                currentOrderListInvoke1?.invoke(it, remainingMisFromCart)
            }

            tvRescedule.setOnClickListener {
                rescheduleInvoke?.invoke(it)
            }
        }

        fun bindViewHolder(position: Int) {
            itemView.tvStoreNameOrder.text = arrayStoreAdapterList?.get(position)?.store_name
            itemView.tvStoreAddressOrder.text = arrayStoreAdapterList?.get(position)?.store_address
            Glide.with(context).load(URLConstant.nearByStoreUrl+ arrayStoreAdapterList?.get(position)?.store_logo)
                .placeholder(R.drawable.placeholder_order_cart_product)
                .into(itemView.ivStoreLogoOrder)

            arrayProductList = arrayStoreAdapterList?.get(position)?.products

            itemView.rvProductsOrder.layoutManager = LinearLayoutManager(
                context,
                LinearLayoutManager.VERTICAL,
                false
            )

            if (position == 0) {
                if (flagPastOrder) {
                    itemView.timerBackground.visibility = View.GONE
                    itemView.tvTime.visibility = View.GONE
                    itemView.tvRemainingTime.visibility = View.GONE
                    itemView.tvRescedule.visibility = View.GONE
                } else {

//                        if (positionMain == 0) {
                    if (remainingMisFromCart.toString().isEmpty()) {


                        if (orderStatus == "Placed") {

                            itemView.timerBackground.visibility = View.GONE
                            itemView.tvTime.visibility = View.GONE
                            itemView.tvRemainingTime.visibility = View.GONE
                            itemView.tvRescedule.visibility = View.VISIBLE

                        } else {
                            itemView.timerBackground.visibility = View.VISIBLE
                            itemView.tvTime.visibility = View.VISIBLE
                            itemView.tvRemainingTime.visibility = View.VISIBLE
                            itemView.tvRescedule.visibility = View.GONE
                            Log.e("position", "==" + position)
                            doSecondWork()
                        }
                    } else {

                        if (orderStatus == "Placed") {
                            itemView.timerBackground.visibility = View.VISIBLE
                            itemView.tvTime.visibility = View.VISIBLE
                            itemView.tvRemainingTime.visibility = View.VISIBLE
                            itemView.tvRescedule.visibility = View.GONE
                            bind()

                        } else {
                            itemView.timerBackground.visibility = View.VISIBLE
                            itemView.tvTime.visibility = View.VISIBLE
                            itemView.tvRemainingTime.visibility = View.VISIBLE
                            itemView.tvRescedule.visibility = View.GONE
                            Log.e("position2", "==" + position)
                            doSecondWork()
                        }
                    }

                }

            } else {
                itemView.timerBackground.visibility = View.GONE
                itemView.tvTime.visibility = View.GONE
                itemView.tvRemainingTime.visibility = View.GONE
                itemView.tvRescedule.visibility = View.GONE

            }


            currentOrderAdapter = CurrentOrderProductListAdapter(
                context,
                arrayProductList!!

            ).apply {
                currentOrderListInvoke2 = {
                    currentOrderListInvoke2(it)
                }
            }
            itemView.rvProductsOrder.adapter = currentOrderAdapter
        }

        private fun currentOrderListInvoke2(view: View) {
            currentOrderListInvoke1?.invoke(view, remainingMisFromCart)
        }

        private fun bind() {


            timer?.cancel()
            val calendar = Calendar.getInstance()

            //Need to set order placed time in local

            //val orderPlacedTimeString = "09-04-2020 18:20:00"
            val orderDateConvertString = Utils.convertServerDateToUserTimeZone(orderDate)


            val orderPlacedDate = dateFormat.parse(orderDateConvertString)
            // using current time for logic set up so comment it when using for specific date
            //orderPlacedDate.time = calendar.timeInMillis

            val serverTime = Utils.convertServerDateToUserTimeZone(serverTime)
            val serverTimeDate = dateFormat.parse(serverTime)

            val currentTime = calendar.time
            calendar.timeInMillis = orderPlacedDate!!.time

            calendar.add(Calendar.MINUTE, 3)


            if (currentTime.before(calendar.time)) {

                val remainingTime = calendar.timeInMillis - currentTime.time

                timer = object : CountDownTimer(remainingTime, 1000) {
                    override fun onFinish() {
                        navigationVisibility()
                    }

                    override fun onTick(millisUntilFinished: Long) {
                        itemView.tvTime.text = Utils.msToString1(millisUntilFinished)

                    }

                }.start()
            } else {
                navigationVisibility()

            }

        }

        private fun doSecondWork() {
            timer2?.cancel()
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

            calendar.add(Calendar.SECOND, timerVal.toInt())

            if (currentTime.before(calendar.time)) {
                val remainingTime = calendar.timeInMillis - currentTime.time

                if (remainingTime < 180000) {
                    refreshTimer?.invoke(remainingTime)
                }
                timer2 = object : CountDownTimer(remainingTime, 1000) {
                    override fun onFinish() {
                        itemView.tvTime.text = context.resources.getString(R.string.timeFinish)
                        itemView.tvTime.visibility = View.GONE
                        itemView.timerBackground.visibility = View.GONE
                        itemView.tvRemainingTime.visibility = View.GONE
//                        navigationVisibility()
                    }

                    override fun onTick(millisUntilFinished: Long) {
                        itemView.tvTime.visibility = View.VISIBLE
                        itemView.tvTime.text = Utils.msToString(millisUntilFinished)
                        if (millisUntilFinished <= 180000) {
                            //Api call
                            timer2?.cancel()
                            refreshTimer?.invoke(remainingTime)
                        }

                    }

                }.start()
            } else {
//                itemView.tvTime.visibility = View.GONE
//                itemView.timerBackground.visibility = View.GONE
//                itemView.tvRemainingTime.visibility = View.GONE


//                navigationVisibility()
                val remainingTime = calendar.timeInMillis - currentTime.time
                refreshTimer?.invoke(remainingTime)

            }

        }


        fun navigationVisibility() {
            itemView.tvTime.visibility = View.GONE
            itemView.timerBackground.visibility = View.GONE
            itemView.tvRemainingTime.visibility = View.GONE
            itemView.tvRescedule.visibility = View.VISIBLE

        }
    }

    fun setPastOrder() {
        flagPastOrder = true
        notifyDataSetChanged()
    }


    override fun getItemViewType(position: Int): Int {
        return position
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

}