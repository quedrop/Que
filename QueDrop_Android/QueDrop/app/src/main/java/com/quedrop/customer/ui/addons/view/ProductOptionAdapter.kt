package com.quedrop.customer.ui.addons.view

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import android.widget.RadioButton
import android.widget.TextView
import com.quedrop.customer.R
import com.quedrop.customer.model.ProductOption


class ProductOptionAdapter(
    var context: Context,
    var arrayProductOptionList: MutableList<ProductOption>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var arrayAddCheckList: MutableList<ProductOption>? = mutableListOf()
    var selectedPrice1: Float = 0.0f
    var selectedPos: Int = 0
    var size: ((Int, View) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem = layoutInflater.inflate(R.layout.layout_radiobutton_item, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayProductOptionList != null)
            return arrayProductOptionList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {
            holder.rdAddOns1.text = arrayProductOptionList?.get(position)?.option_name
            holder.txtPrize.text =
                context.resources.getString(R.string.rs) + arrayProductOptionList?.get(position)?.price

            holder.rdAddOns1.isChecked = (selectedPos == position)

        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var rdAddOns1: RadioButton
        var txtPrize: TextView

        init {
            this.rdAddOns1 = itemView.findViewById(R.id.rdAddOns1)
            this.txtPrize = itemView.findViewById(R.id.txtPrize)

            rdAddOns1.setOnClickListener {
                selectedPos = adapterPosition
                size?.invoke(
                    adapterPosition, it
                )
                notifyDataSetChanged()
            }

        }
    }

    fun checkList(addCheckList: MutableList<ProductOption>?) {
        arrayAddCheckList?.clear()
        for ((item, value) in addCheckList?.withIndex()!!) {
            arrayAddCheckList?.add(addCheckList[item])
        }
        notifyDataSetChanged()

    }


    fun setPrice(selectedPrice: Float, position: Int) {
        selectedPrice1 = selectedPrice
        selectedPos = position
    }

}