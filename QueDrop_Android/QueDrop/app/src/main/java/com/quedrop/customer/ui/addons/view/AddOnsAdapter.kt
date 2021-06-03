package com.quedrop.customer.ui.addons.view

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.CheckBox
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.model.AddOns


class AddOnsAdapter(
    var context: Context,
    var arrayAddOnsList: MutableList<AddOns>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var arrayAddCheckList: MutableList<AddOns>? = mutableListOf()
    var sumOfTwo: ((Float, Int) -> Unit)? = null
    var minusOfTwo: ((Float, Int) -> Unit)? = null
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem = layoutInflater.inflate(R.layout.layout_checkbox_item, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayAddOnsList != null)
            return arrayAddOnsList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {
            holder.chAddOns.text = arrayAddOnsList?.get(position)?.addon_name
            holder.txtPrize.text =
                context.resources.getString(R.string.rs) + arrayAddOnsList?.get(position)?.addon_price

            for ((item, value) in arrayAddCheckList?.withIndex()!!) {
                if (value.addon_id == arrayAddOnsList?.get(position)?.addon_id) {
                    holder.chAddOns.isChecked = true

                }
            }
        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var chAddOns: CheckBox
        var txtPrize: TextView

        init {
            this.chAddOns = itemView.findViewById(R.id.chAddOns)
            this.txtPrize = itemView.findViewById(R.id.txtPrize)

            chAddOns.setOnCheckedChangeListener { buttonView, isChecked ->
                if (isChecked) {
                    sumOfTwo?.invoke(
                        arrayAddOnsList?.get(
                            adapterPosition
                        )?.addon_price!!.toFloat(), adapterPosition
                    )
                } else {
                    minusOfTwo?.invoke(
                        arrayAddOnsList?.get(
                            adapterPosition
                        )?.addon_price!!.toFloat(), adapterPosition
                    )
                }
            }


        }
    }

    fun checkList(addCheckList: MutableList<AddOns>?) {
        arrayAddCheckList?.clear()
        for ((item, value) in arrayAddOnsList?.withIndex()!!) {
            for ((item1, value1) in addCheckList?.withIndex()!!) {
                if (value.addon_id == addCheckList.get(item1).addon_id) {
                    arrayAddCheckList?.add(arrayAddOnsList?.get(item)!!)
                }
            }
        }
        notifyDataSetChanged()

    }

}