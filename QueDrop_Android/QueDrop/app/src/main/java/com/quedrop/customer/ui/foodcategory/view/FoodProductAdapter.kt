package com.quedrop.customer.ui.foodcategory.view

import android.content.Context
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.model.ProductDetails
import com.makeramen.roundedimageview.RoundedImageView
import com.quedrop.customer.utils.URLConstant


class FoodProductAdapter(
    var context: Context,
    var arrayFoodProductList: MutableList<ProductDetails>?,
    var filterFlag: Boolean
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var dialogNoFeesInvoke: ((MutableList<ProductDetails>?, Int) -> Unit)? = null
    var addNewActivityInvoke: ((Int, MutableList<ProductDetails>?) -> Unit)? = null
    var addQuantityActivityInvoke: ((Int, MutableList<ProductDetails>?) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
//        val listItem = layoutInflater.inflate(R.layout.list_item, parent, false)
//        val viewHolder = ViewHolder(listItem)
        var listItem = layoutInflater.inflate(R.layout.layout_food_product, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayFoodProductList != null)
            return arrayFoodProductList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {


        if (holder is ViewHolder) {

            holder.textView.text = arrayFoodProductList?.get(position)?.store_category_title

            holder.tvTitleProductName.text = arrayFoodProductList?.get(position)?.product_name
            holder.tvProductPrice.text =
                context.resources.getString(R.string.rs) + arrayFoodProductList?.get(position)?.product_price

            Glide.with(context).load(
                URLConstant.urlProduct + arrayFoodProductList?.get(
                    position
                )?.product_image
            ).placeholder(R.drawable.placeholder_order_cart_product)
                .into(holder.ivProductImage)



            if (arrayFoodProductList?.get(position)?.is_product_selected == "1") {
                Log.e("Title", arrayFoodProductList?.get(position)?.product_name)
                holder.tvAdd.text = context.resources.getString(R.string.added)
                holder.tvAdd.setTextColor(ContextCompat.getColor(context, R.color.colorWhite))
                holder.tvAdd.background =
                    ContextCompat.getDrawable(context, R.drawable.bg_gradiant_rounded_btn)
            } else {
                holder.tvAdd.text = context.resources.getString(R.string.add)
                holder.tvAdd.setTextColor(ContextCompat.getColor(context, R.color.colorBlack))
                holder.tvAdd.background =
                    ContextCompat.getDrawable(context, R.drawable.view_rounded_search_image)
            }

            if (filterFlag) {
                holder.textView.visibility = View.GONE
            } else {
                if (arrayFoodProductList?.get(position)?.header!!) {
                    holder.textView.visibility = View.VISIBLE

                } else {
                    holder.textView.visibility = View.GONE

                }
            }

            if (arrayFoodProductList?.get(position)?.need_extra_fees!!.toInt() == 1) {
                holder.ivPriceTag.visibility = View.GONE

            } else {
                holder.ivPriceTag.visibility = View.VISIBLE
            }


        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var textView: TextView
        var tvTitleProductName: TextView
        var tvProductPrice: TextView
        var ivProductImage: RoundedImageView
        var ivPriceTag: ImageView
        var tvAdd: TextView

        //        var rvProductDescription:RecyclerView
        init {
            this.textView = itemView.findViewById(R.id.tvFoodItem)
            this.tvTitleProductName = itemView.findViewById(R.id.tvTitleProductName)
            this.tvProductPrice = itemView.findViewById(R.id.tvProductPrice)
            this.ivProductImage = itemView.findViewById(R.id.ivProductImage)
            this.ivPriceTag = itemView.findViewById(R.id.ivPriceTag)
            this.tvAdd = itemView.findViewById(R.id.tvAdd)

            ivPriceTag.setOnClickListener {

                dialogNoFeesInvoke?.invoke(arrayFoodProductList, adapterPosition)
            }

            tvAdd.setOnClickListener {


                if (arrayFoodProductList?.get(adapterPosition)?.product_option?.size!! <= 1) {
                    if (arrayFoodProductList?.get(adapterPosition)?.has_addons == "1") {

                        addNewActivityInvoke?.invoke(
                            adapterPosition,
                            arrayFoodProductList!!
                        )
                    } else {

                        //   Toast.makeText(context,arrayProductOptionList?.get(adapterPosition)?.option_id+"--"+arrayProductOptionList?.get(adapterPosition)?.option_name,Toast.LENGTH_SHORT).show()
                        addQuantityActivityInvoke?.invoke(
                            adapterPosition,
                            arrayFoodProductList!!
                        )
                    }
                } else {
                    addNewActivityInvoke?.invoke(
                        adapterPosition,
                        arrayFoodProductList!!
                    )


                }
            }
        }
    }

    fun filterFlag() {
        filterFlag = false
        notifyDataSetChanged()
    }


    fun filterList(filteredList: MutableList<ProductDetails>?) {
        filterFlag = true
        arrayFoodProductList = filteredList
        notifyDataSetChanged()
    }


}