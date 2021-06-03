package com.quedrop.customer.ui.supplier.myorders

import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.getProductImage
import com.quedrop.customer.model.ProductOrder
import com.quedrop.customer.model.SupplierAddOn
import kotlinx.android.synthetic.main.activity_supplier_order_item_detail.*
import kotlinx.android.synthetic.main.list_item_product_addon.view.*

class SupplierOrderItemDetailActivity : AppCompatActivity() {

    private lateinit var product: ProductOrder
    private var adapter:CustomAddonAdapter?=null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_supplier_order_item_detail)
        product = intent.getSerializableExtra("product") as ProductOrder
        init()
        setData()
    }

    private fun init(){
        rvAddOns.layoutManager = LinearLayoutManager(this)
        ivBack.setOnClickListener {
            onBackPressed()
        }
    }

    private fun setData(){
        Glide.with(this).load(getProductImage(product.product_image))
            .centerCrop().into(ivProduct)
        tvProductName.text = product.product_name
        tvQty.text = product.quantity.toString()
        tvPrice.text = product.product_price.toString()
        if(adapter==null){
            adapter = CustomAddonAdapter(this)
            rvAddOns.adapter = adapter
        }
        adapter?.addOnList = product.addons
        adapter?.notifyDataSetChanged()
    }

    inner class CustomAddonAdapter(val context: Context) :
        RecyclerView.Adapter<CustomAddonAdapter.ViewHolder>() {

        var addOnList : MutableList<SupplierAddOn> = mutableListOf()

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
            val view =
                LayoutInflater.from(context)
                    .inflate(R.layout.list_item_product_addon, parent, false)
            return ViewHolder(view)
        }

        override fun getItemCount(): Int {
            return addOnList.size
        }

        override fun onBindViewHolder(holder: ViewHolder, position: Int) {
            holder.bindData(position)
        }

        inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
            init {

            }

            fun bindData(position: Int) {

                itemView.tvAddons.text = addOnList[position].addon_name
            }
        }
    }
}
