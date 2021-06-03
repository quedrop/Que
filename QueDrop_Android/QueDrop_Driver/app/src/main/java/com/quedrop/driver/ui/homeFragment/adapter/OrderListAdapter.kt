package com.quedrop.driver.ui.homeFragment.adapter

import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.Product
import com.quedrop.driver.service.model.StoreDetail
import com.quedrop.driver.ui.homeFragment.view.ProductView
import com.quedrop.driver.ui.homeFragment.view.StoreView

class OrderListAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    private val adapterItems: MutableList<AdapterItem> = mutableListOf()

    var orderList: MutableList<StoreDetail> = mutableListOf()
        set(value) {
            field = value
            updateAdapterItem()
        }

    private fun updateAdapterItem() {
        orderList.forEach { store ->
            adapterItems.add(
                AdapterItem.StoreItem(store)
            )
            store.products!!.forEach { product ->
                adapterItems.add(AdapterItem.ProductItem(product))
            }
        }
        notifyDataSetChanged()
    }


    override fun onCreateViewHolder(viewGroup: ViewGroup, viewType: Int): RecyclerView.ViewHolder {

        return when (ViewType.values()[viewType]) {
            ViewType.STORE -> CategoriesViewHolder(
                StoreView(
                    viewGroup.context
                )
            )
            ViewType.PRODUCT -> CategoriesViewHolder(
                ProductView(
                    viewGroup.context
                ).apply {
                throttleClicks().subscribe {
                   // isSelectedPosition = if (isSelectedPosition == position) position else position
                 //   notifyDataSetChanged()
                }
            })
        }
    }

    override fun getItemCount(): Int {
        return adapterItems.size
    }

    override fun onBindViewHolder(viewHolder: RecyclerView.ViewHolder, position: Int) {

        when (val adapterItem = adapterItems[position]) {
            is AdapterItem.ProductItem ->
                (viewHolder.itemView as ProductView).bind(
                    adapterItem.product,false
                )
            is AdapterItem.StoreItem -> {
                (viewHolder.itemView as StoreView).bind(
                    adapterItem.store
                )
            }
        }
    }

    fun getAdapterItem(position: Int): Product? {
        when (val adapterItem = adapterItems[position]) {
            is AdapterItem.ProductItem ->
                return adapterItem.product
            else -> return null
        }

    }

    override fun getItemViewType(position: Int): Int {
        return adapterItems[position].type
    }

    private class CategoriesViewHolder(view: View) : RecyclerView.ViewHolder(view)

    sealed class AdapterItem(val type: Int) {
        data class ProductItem(val product: Product) : AdapterItem(ViewType.PRODUCT.ordinal)
        data class StoreItem(val store: StoreDetail) : AdapterItem(ViewType.STORE.ordinal)
    }

    private enum class ViewType {
        STORE, PRODUCT
    }


}