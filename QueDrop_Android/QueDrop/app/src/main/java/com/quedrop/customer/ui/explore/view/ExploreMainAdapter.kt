package com.quedrop.customer.ui.explore.view

import com.quedrop.customer.ui.home.view.adapter.*

import android.content.Context
import android.content.Intent
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.model.*
import com.quedrop.customer.ui.order.view.adapter.DeliveryRouteAdapter
import com.quedrop.customer.ui.storewithproduct.view.StoreDetailsActivity
import com.quedrop.customer.ui.supplier.product.SupplierProductAdapter
import com.quedrop.customer.utils.EnumExploreCategoriesList
import com.quedrop.customer.utils.KeysUtils


class ExploreMainAdapter(
    var context: Context,
    var arrayExploreRecycleList: MutableList<String>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var storeExploreMainInvoke: ((Int, MutableList<StoreSingleDetails>) -> Unit)? = null
    var productExploreMainInvoke: ((Int, MutableList<SupplierProduct>) -> Unit)? = null

    var exploreStoreAdapter: DeliveryRouteAdapter? = null
    var exploreProductAdapter: SupplierProductAdapter? = null

    var arrayStoreExploreList: MutableList<StoreSingleDetails>? = mutableListOf()
    var arrayProductExploreList: MutableList<SupplierProduct>? = mutableListOf()

    var latitude: String = ""
    var longitude: String = ""


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)

        val listItem =
            layoutInflater.inflate(R.layout.layout_main_customer_home_recycle, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayExploreRecycleList != null)
            return arrayExploreRecycleList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is ViewHolder) {
            holder.bindView(position)
        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {

        var textView: TextView = itemView.findViewById(R.id.textTitleCustomer)
        var mRecyclerView: RecyclerView = itemView.findViewById(R.id.mainRecyclerViewCustomer)

        init {
            //TODO add clicks
        }

        fun bindView(position: Int) {
            mRecyclerView.setHasFixedSize(true)

            when (position) {
                EnumExploreCategoriesList.STORE_LIST.posVal -> {
                    mRecyclerView.layoutManager = LinearLayoutManager(
                        context.applicationContext!!, LinearLayoutManager.HORIZONTAL, false
                    )

                    if (!arrayStoreExploreList.isNullOrEmpty()) {
                        latitude = arrayStoreExploreList?.get(position)?.latitude.toString()
                        longitude = arrayStoreExploreList?.get(position)?.longitude.toString()
                    }

                    exploreStoreAdapter =
                        DeliveryRouteAdapter(
                            context.applicationContext!!,
                            arrayStoreExploreList,
                            latitude,
                            longitude
                        )
                            .apply {
                                storeExploreInvoke = {
                                    storeExploreMainInvoke?.invoke(it, arrayStoreExploreList!!)
                                }
                            }

                    mRecyclerView.adapter = exploreStoreAdapter

                    if (!arrayStoreExploreList.isNullOrEmpty()) {
                        textView.visibility = View.VISIBLE
                        textView.text =
                            arrayExploreRecycleList?.get(EnumExploreCategoriesList.STORE_LIST.posVal)
                                .toString()
                    } else {
                        textView.visibility = View.GONE
                    }

                }


                EnumExploreCategoriesList.PRODUCT_LIST.posVal -> {
                    mRecyclerView.layoutManager = GridLayoutManager(context.applicationContext!!, 3)

                    exploreProductAdapter =
                        SupplierProductAdapter(context.applicationContext!!, true)
                            .apply {
                                productExploreInvoke = {
                                  productExploreMainInvoke?.invoke(it,arrayProductExploreList!!)
                                }
                            }

                    exploreProductAdapter?.productList?.addAll(arrayProductExploreList!!)
                    mRecyclerView.adapter = exploreProductAdapter

                    if (!arrayProductExploreList.isNullOrEmpty()) {
                        textView.visibility = View.VISIBLE
                        textView.text =
                            arrayExploreRecycleList?.get(EnumExploreCategoriesList.PRODUCT_LIST.posVal)
                                .toString()
                    } else {
                        textView.visibility = View.GONE
                    }

                }

                else -> {
                }
            }
        }
    }

    fun exploreStoreNotified(arrayExploreStore: MutableList<StoreSingleDetails>) {
        arrayStoreExploreList = arrayExploreStore
        exploreStoreAdapter?.notifyDataSetChanged()
        notifyDataSetChanged()
    }

    fun exploreProductNotified(arrayExploreProduct: MutableList<SupplierProduct>) {
        arrayProductExploreList = arrayExploreProduct
        exploreProductAdapter?.notifyDataSetChanged()
        notifyDataSetChanged()
    }
}