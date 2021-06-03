package com.quedrop.customer.ui.cart.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.model.AddOns
import com.quedrop.customer.model.Product
import com.quedrop.customer.model.ProductOption
import java.lang.StringBuilder


class CartProductsAdapter(
    var context: Context,
    var arrayProductCartList: MutableList<Product>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var cartId: Int? = null
    var storeId: Int? = null
    var arrayAddOnsList: MutableList<AddOns>? = null
    var arrayProductOptionList: MutableList<ProductOption>? = null
    var productOptionId: Int = 0
    var productOptionName: String = ""
    var sumQuantity: Int = 0
    var updateQuantityClickInvoke: ((Int, Int, Int) -> Unit)? = null
    var minusDeleteFromProductClickInvoke: ((Int, Int, Int) -> Unit)? = null
    var customiseInvoke: ((Int,Int,Int,Int,String,MutableList<AddOns>) -> Unit)? = null
    var flagCheckStore: Boolean = false
    var hasAddOns: String = "0"

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)

        var listItem = layoutInflater.inflate(R.layout.layout_products_cart, parent, false)
        return ViewHolder(listItem)
    }


    override fun getItemCount(): Int {
        return if (arrayProductCartList != null)
            return arrayProductCartList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {

            holder.tvProductNameCart.text = arrayProductCartList?.get(position)?.product_name
            holder.tvQuantity1.text = arrayProductCartList?.get(position)?.quantity

            arrayProductOptionList = arrayProductCartList?.get(position)?.product_option
            arrayAddOnsList = arrayProductCartList?.get(position)?.addons
            productOptionId = arrayProductCartList?.get(position)!!.option_id
            hasAddOns = arrayProductCartList?.get(position)!!.has_addons

            var sb = StringBuilder()
            for ((i, v) in arrayProductOptionList?.toMutableList()!!.withIndex()) {

                if (v.option_id == productOptionId) {
                    productOptionName = arrayProductOptionList?.get(i)!!.option_name
                    if (productOptionName == "Default") {

                    } else {
                        sb = sb.append(productOptionName)
                    }
                }
            }

            if (arrayAddOnsList?.size!! > 0) {
                if (productOptionName == "Default") {

                } else {
                    sb = sb.append(",")
                }
            }

            for ((item, value) in arrayAddOnsList?.toMutableList()!!.withIndex()) {

                sb = sb.append(value.addon_name)

                if (item == ((arrayAddOnsList?.size)!! - 1)) {
                    break
                }
                sb.append(",")
            }

            if (flagCheckStore) {
                holder.tvCustomiseQuantity.visibility = View.GONE
                holder.tvPAddOnsCart.visibility = View.GONE
                holder.tvNoteQuantity.visibility = View.VISIBLE
                holder.tvNoteQuantity.text =
                    context.resources.getString(R.string.totalAmountPurchased)

            } else {

                if (hasAddOns == "1") {
                    holder.tvCustomiseQuantity.visibility = View.VISIBLE
                } else {
                    holder.tvCustomiseQuantity.visibility = View.GONE
                }

                if (sb.isNullOrBlank()) {
                    holder.tvPAddOnsCart.visibility = View.GONE
                } else {
                    holder.tvPAddOnsCart.visibility = View.VISIBLE
                    holder.tvPAddOnsCart.text = sb
                }
            }

            holder.tvProductPriceCart.text =
                context.resources.getString(R.string.rs) + arrayProductCartList?.get(position)?.product_final_price
        }
    }


    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {

        var tvProductPriceCart: TextView
        var tvProductNameCart: TextView
        var tvQuantity1: TextView
        var tvCustomiseQuantity: TextView
        var tvNoteQuantity: TextView
        var tvPAddOnsCart: TextView
        var minusCart1: ImageView
        var plusCart1: ImageView
        var ivBinCart: ImageView


        init {

            this.tvProductPriceCart = itemView.findViewById(R.id.tvProductPriceCart)
            this.tvCustomiseQuantity = itemView.findViewById(R.id.tvCustomiseQuantity)
            this.tvNoteQuantity = itemView.findViewById(R.id.tvNoteQuantity)
            this.tvProductNameCart = itemView.findViewById(R.id.tvProductNameCart)
            this.tvQuantity1 = itemView.findViewById(R.id.tvQuantity1)
            this.tvPAddOnsCart = itemView.findViewById(R.id.tvPAddOnsCart)
            this.minusCart1 = itemView.findViewById(R.id.minusCart1)
            this.plusCart1 = itemView.findViewById(R.id.plusCart1)
            this.ivBinCart = itemView.findViewById(R.id.ivBinCart)

            tvCustomiseQuantity.setOnClickListener {

                customiseInvoke?.invoke(
                    arrayProductCartList?.get(adapterPosition)?.cart_product_id!!,
                    arrayProductCartList?.get(adapterPosition)?.product_id!!,
                    arrayProductCartList?.get(adapterPosition)?.option_id!!,
                    storeId!!,
                    arrayProductCartList?.get(adapterPosition)?.has_addons!!,
                    arrayProductCartList?.get(adapterPosition)?.addons!!
                )
            }

            ivBinCart.setOnClickListener {
                minusDeleteFromProductClickInvoke?.invoke(
                    cartId!!,
                    arrayProductCartList?.get(adapterPosition)?.cart_product_id!!,
                    adapterPosition
                )
            }

            plusCart1.setOnClickListener {
                sumQuantity = arrayProductCartList?.get(adapterPosition)?.quantity!!.toInt()
                sumQuantity += 1
                updateQuantityClickInvoke?.invoke(
                    sumQuantity,
                    arrayProductCartList?.get(adapterPosition)?.cart_product_id!!,
                    adapterPosition
                )
            }

            minusCart1.setOnClickListener {
                sumQuantity = arrayProductCartList?.get(adapterPosition)?.quantity!!.toInt()
                if (tvQuantity1.text == "1") {

                    if (cartId.toString().isNullOrBlank()) {

                    } else {
                        minusDeleteFromProductClickInvoke?.invoke(
                            cartId!!,
                            arrayProductCartList?.get(adapterPosition)?.cart_product_id!!,
                            adapterPosition
                        )
                    }
                } else {

                    sumQuantity -= 1
                    updateQuantityClickInvoke?.invoke(
                        sumQuantity,
                        arrayProductCartList?.get(adapterPosition)?.cart_product_id!!,
                        adapterPosition
                    )
                }
            }
        }
    }

    fun setCartIdAdapter(cartMainId: Int, storeId1:Int,flagCheckStore1: Boolean) {
        cartId = cartMainId
        storeId = storeId1
        flagCheckStore = flagCheckStore1
        notifyDataSetChanged()
    }

}