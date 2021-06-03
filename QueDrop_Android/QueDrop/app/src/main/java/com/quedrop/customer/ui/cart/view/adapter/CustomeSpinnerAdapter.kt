package com.quedrop.customer.ui.cart.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import com.quedrop.customer.R
import com.quedrop.customer.model.GetRecurringTypeResponse
import android.widget.TextView


class CustomeSpinnerAdapter(
    var context: Context,
    var arrayList: MutableList<GetRecurringTypeResponse>
) : BaseAdapter() {

    override fun getItem(p0: Int): Any {
        return arrayList[p0]
    }

    override fun getItemId(p0: Int): Long {
        return p0.toLong()
    }

    override fun getCount(): Int {
        return arrayList.size
    }


    override fun getView(p0: Int, p1: View?, p2: ViewGroup?): View {
        var inflater: LayoutInflater? = LayoutInflater.from(context)
        val holder: ViewHolder
        var view1=p1
        if (view1 == null) {
            holder = ViewHolder()
            view1= inflater?.inflate(R.layout.layout_custom_spinner, p2, false)
            holder.tvItemName = view1?.findViewById(R.id.tvItemName)
            view1!!.tag = holder
        } else {
            holder = view1.tag as ViewHolder
        }

        holder.tvItemName?.text = arrayList?.get(p0).recurring_type


        return view1
    }

    inner class ViewHolder {
        internal var tvItemName: TextView? = null
//        internal var logo: ImageView? = null
    }
}