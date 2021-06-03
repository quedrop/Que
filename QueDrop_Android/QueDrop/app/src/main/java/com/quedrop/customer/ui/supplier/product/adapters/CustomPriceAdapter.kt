package com.quedrop.customer.ui.supplier.product.adapters

import android.content.Context
import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.model.SupplierProductOptions
import kotlinx.android.synthetic.main.list_item_price.view.*

class CustomPriceAdapter(val context: Context, val isFromDetailPage: Boolean = false) :
    RecyclerView.Adapter<CustomPriceAdapter.ViewHolder>() {
    var _productOptionList: MutableList<SupplierProductOptions> = mutableListOf()
    var onDeleteClick: ((Int, View) -> Unit)? = null
    var onRadioClick: ((Int, View) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view =
            LayoutInflater.from(context)
                .inflate(R.layout.list_item_price, parent, false)
        return ViewHolder(view)
    }

    override fun getItemCount(): Int {
        return _productOptionList.size
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bindData(position)
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        init {
            if (!isFromDetailPage) {

                itemView.editOptionName.isEnabled = true
                itemView.editOptionPrice.isEnabled = true
                itemView.radioDefault.isClickable = true
                itemView.radioDefault.isFocusable = true

                itemView.imgDelete.setOnClickListener {
                    onDeleteClick?.invoke(adapterPosition, it)
                }

                itemView.radioDefault.setOnClickListener {
                    onRadioClick?.invoke(adapterPosition, it)
                }

                itemView.editOptionName.addTextChangedListener(object : TextWatcher {
                    override fun afterTextChanged(p0: Editable?) {}
                    override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                    override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
                        _productOptionList[adapterPosition].option_name = p0.toString()
                    }
                })

                itemView.editOptionPrice.addTextChangedListener(object : TextWatcher {
                    override fun afterTextChanged(p0: Editable?) {}
                    override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}
                    override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
                        _productOptionList[adapterPosition].price = p0.toString()
                    }
                })
            }
        }

        fun bindData(position: Int) {
            itemView.editOptionName.setText(_productOptionList[position].option_name)
            itemView.editOptionPrice.setText(_productOptionList[position].price)
            itemView.radioDefault.isChecked = _productOptionList[position].is_default == 1
            if (!isFromDetailPage) {
                itemView.imgDelete.visibility = View.VISIBLE
            }
        }
    }
}