package com.quedrop.driver.ui.order.adapter

import android.app.Activity
import android.graphics.Bitmap
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.widget.AppCompatImageView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import com.quedrop.driver.service.model.*
import com.quedrop.driver.ui.orderDetailsFragment.view.OrderDetailObserver
import com.quedrop.driver.ui.orderDetailsFragment.view.OrderObserverModel
import com.quedrop.driver.utils.EXPRESS_DELIVERY
import com.quedrop.driver.utils.ImageConstant
import com.quedrop.driver.utils.ORDER_STATUS_ACCEPTED
import io.reactivex.Observable
import io.reactivex.subjects.PublishSubject


class CurrentOrderStoreListAdapter(
    var detailScreen: Boolean,
    var context: Activity,
    var orderStatus: String? = "",
    var arrayStoreAdapterList: MutableList<Stores>?,
    var deliveryOption: String?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var currentProductListAdapter: CurrentOrderProductListAdapter? = null
    var arrayProductList: MutableList<Products>? = null

    private val itemStoreClickResult: PublishSubject<Int> = PublishSubject.create()
    var itemStoreClick: Observable<Int> = itemStoreClickResult.hide()

    var selectedPosition = -1
    var updatePosition = -1
    var selectedBitmap: Bitmap? = null
    var isSetImage = false
    var isAdapterOnce = false

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        var listItem =
            layoutInflater.inflate(R.layout.viewholder_store, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayStoreAdapterList != null)
            return arrayStoreAdapterList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {
            holder.tvStoreNameOrder.text = arrayStoreAdapterList?.get(position)?.storeName
            holder.tvStoreAddressOrder.text = arrayStoreAdapterList?.get(position)?.storeAddress
            Glide.with(context).load(
                BuildConfig.BASE_URL + ImageConstant.STORE_LOGO + arrayStoreAdapterList?.get(
                    position
                )?.storeLogo
            ).placeholder(R.drawable.placeholder_store).centerCrop().into(holder.ivStoreLogoOrder)
            arrayProductList =
                arrayStoreAdapterList?.get(position)?.products


            if (detailScreen) {
                holder.receiptFrame.visibility = View.VISIBLE
                holder.ivExpressView.visibility = View.GONE
                if (arrayStoreAdapterList?.get(position)?.orderReceipt != "") {
                    if (orderStatus == ORDER_STATUS_ACCEPTED) {
                        holder.ivRemoveReceipt.visibility = View.VISIBLE
                    } else {
                        holder.ivRemoveReceipt.visibility = View.GONE
                    }
                    Glide.with(context).load(
                        BuildConfig.BASE_URL + ImageConstant.USER_STORE_PRODUCT_RECEIPT + arrayStoreAdapterList?.get(
                            position
                        )?.orderReceipt
                    )
                        .centerCrop().into(holder.ivAddReceipt)

                } else {
                    holder.ivRemoveReceipt.visibility = View.GONE
                }
            } else {
                holder.receiptFrame.visibility = View.GONE

                if (position == 0) {
                    if (deliveryOption == EXPRESS_DELIVERY) {
                        holder.ivExpressView.visibility = View.VISIBLE
                    } else {
                        holder.ivExpressView.visibility = View.GONE
                    }
                } else {
                    holder.ivExpressView.visibility = View.GONE
                }
            }

            holder.rvProductsOrder.layoutManager =
                LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false)
            currentProductListAdapter =
                CurrentOrderProductListAdapter(context, arrayProductList!!)
            holder.rvProductsOrder.adapter = currentProductListAdapter
            isAdapterOnce = true


            currentProductListAdapter?.itemProductClick?.subscribe {
                itemStoreClickResult.onNext(holder.adapterPosition)
            }

            //if(!isSetImage) {
            if (selectedPosition == updatePosition && selectedBitmap != null) {
                holder.ivAddReceipt.setImageBitmap(selectedBitmap)
                holder.ivRemoveReceipt.visibility = View.VISIBLE
            }
            //isSetImage=true
            //}

            holder.itemView.setOnClickListener {
                itemStoreClickResult.onNext(holder.adapterPosition)
            }


            holder.ivAddReceipt.setOnClickListener {
                Log.e("Accept click", "==>")
                selectedPosition = holder.adapterPosition
                isSetImage = false
                OrderDetailObserver.itemReceiptClickResult.onNext(
                    OrderObserverModel(
                        selectedPosition,
                        arrayStoreAdapterList!![position]
                    )
                )
            }

            holder.ivRemoveReceipt.setOnClickListener {
                Log.e("remove click", "==>")
                OrderDetailObserver.itemReceiptRemoveClickResult.onNext(
                    OrderObserverModel(
                        selectedPosition,
                        arrayStoreAdapterList!![position]
                    )
                )
                if (selectedPosition == updatePosition && selectedBitmap != null) {
                    holder.ivAddReceipt.setImageResource(R.drawable.ic_add_receipt)
                    holder.ivRemoveReceipt.visibility = View.GONE
                } else {
                    holder.ivAddReceipt.setImageResource(R.drawable.ic_add_receipt)
                    holder.ivRemoveReceipt.visibility = View.GONE
                }
            }
        }
    }


    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var rvProductsOrder: RecyclerView = itemView.findViewById(R.id.rvProductsOrder)
        var tvStoreNameOrder: TextView = itemView.findViewById(R.id.tvStoreNameOrder)
        var tvStoreAddressOrder: TextView = itemView.findViewById(R.id.tvStoreAddressOrder)
        var ivStoreLogoOrder: ImageView = itemView.findViewById(R.id.ivStoreLogoOrder)
        var ivAddReceipt: ImageView = itemView.findViewById(R.id.ivAddReceipt)
        var ivRemoveReceipt: ImageView = itemView.findViewById(R.id.ivRemoveReceipt)
        var receiptFrame: FrameLayout = itemView.findViewById(R.id.receiptFrame)
        var ivExpressView: AppCompatImageView = itemView.findViewById(R.id.ivExpressView)
    }

    fun currentReceipt(bitmap: Bitmap, updatePosition: Int) {
        this.selectedBitmap = bitmap
        this.updatePosition = updatePosition
        notifyItemChanged(updatePosition)
    }
}