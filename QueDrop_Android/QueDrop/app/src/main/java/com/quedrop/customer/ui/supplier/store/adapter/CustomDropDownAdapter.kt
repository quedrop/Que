package com.quedrop.customer.ui.supplier.store.adapter

import android.content.Context
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.appcompat.widget.AppCompatTextView
import com.quedrop.customer.R
import com.quedrop.customer.model.Categories

class CustomDropDownAdapter(val context: Context, var dataSource: List<Categories>) :
    BaseAdapter() {

    private val inflater: LayoutInflater =
        context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater

    override fun getView(position: Int, convertView: View?, parent: ViewGroup?): View {

        val view: View
        val vh: ItemHolder
        if (convertView == null) {
            view = inflater.inflate(R.layout.list_item_servicecategory, parent, false)
            vh = ItemHolder(view)
            view?.tag = vh
        } else {
            view = convertView
            vh = view.tag as ItemHolder
        }
        vh.tvServiceCategoryName.text = dataSource[position].service_category_name

        return view
    }

    override fun getItem(position: Int): Any? {
        Log.e("dataSource", "==>" + dataSource[position].service_category_id)
        return dataSource[position]
    }

    override fun getCount(): Int {
        return dataSource.size
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    private class ItemHolder(row: View?) {
        val tvServiceCategoryName: AppCompatTextView =
            row?.findViewById(R.id.tvServiceCategoryName)!!

    }

}