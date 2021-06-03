package com.quedrop.customer.ui.home.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R



class TodayDealRecyclerAdapter(var context: Context, var arrayTodayDeal: MutableList<String>?) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem = layoutInflater.inflate(R.layout.layout_homecustomer_recycle,parent,false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayTodayDeal != null)
            return arrayTodayDeal!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

    }

    class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
//        var imageView: ImageView
//        var textView: TextView
//        var relativeLayout: RelativeLayout
//
//        init {
//            this.imageView = itemView.findViewById(R.id.imageView) as ImageView
//            this.textView = itemView.findViewById(R.id.textView)
//            relativeLayout = itemView.findViewById(R.id.relativeLayout)
//        }
    }

}