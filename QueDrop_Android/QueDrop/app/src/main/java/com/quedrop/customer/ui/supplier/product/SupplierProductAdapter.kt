package com.quedrop.customer.ui.supplier.product


import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.getProductImage
import com.quedrop.customer.base.extentions.startActivityWithAnimation
import com.quedrop.customer.model.SupplierProduct
import kotlinx.android.synthetic.main.list_item_supplier_product.view.*
import java.io.Serializable

class SupplierProductAdapter(val context: Context, val fromExplore: Boolean) :
    RecyclerView.Adapter<SupplierProductAdapter.ViewHolder>() {

    var productList: MutableList<SupplierProduct> = mutableListOf()
    var onActionMenuClick: ((Int, View) -> Unit)? = null

     var productExploreInvoke: ((Int) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view =
            LayoutInflater.from(context).inflate(R.layout.list_item_supplier_product, parent, false)
        return ViewHolder(view)
    }

    override fun getItemCount(): Int {
        return productList.size
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bindData(position)
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {
            itemView.imgAction.setOnClickListener {
                onActionMenuClick?.invoke(adapterPosition, it)
            }

            itemView.setOnClickListener {
                if (fromExplore) {
                      productExploreInvoke?.invoke(adapterPosition)
                } else {
                    (context as SupplierProductActivity)
                        .startActivityWithAnimation<SupplierProductDetailActivity> {
                            putExtra("product", productList[adapterPosition] as Serializable)
                        }
                }
            }
        }

        fun bindData(position: Int) {

            if (fromExplore) {
                itemView.imgAction.visibility = View.GONE
            } else {
                itemView.imgAction.visibility = View.VISIBLE
            }
           
            itemView.tvProductName.text = productList[position].product_name
            itemView.tvProductPrice.text = "Rs.${productList[position].product_price}"
            Glide.with(context)
                .load(context.getProductImage(productList[position].product_image))
                .placeholder(R.drawable.placeholder_order_cart_product)
                .into(itemView.imgProduct)
        }
    }
}