package com.quedrop.customer.ui.foodcategory.view

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.model.StoreCategoryProduct

class FoodTitleAdapter(
    var context: Context,
    var arrayFoodTitleList: MutableList<StoreCategoryProduct>?,
    var pos: Int
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    var itemClickIvoke : ((Int)->Unit)?=null
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
//        val listItem = layoutInflater.inflate(R.layout.list_item, parent, false)
//        val viewHolder = ViewHolder(listItem)
        val listItem = layoutInflater.inflate(R.layout.layout_food_title, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayFoodTitleList != null)
            return arrayFoodTitleList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {



        if (holder is ViewHolder) {
            if(pos == position){
                holder.textView.setTextColor(ContextCompat.getColor(context,R.color.colorBlueText))
                holder.predictedRow.background = ContextCompat.getDrawable(context, R.drawable.view_title_seletcted)
            }else{
                holder.textView.setTextColor(ContextCompat.getColor(context,R.color.colorWhite))
                holder.predictedRow.background = ContextCompat.getDrawable(context, R.drawable.view_title_unseletcted)
            }
            holder.textView.text = arrayFoodTitleList?.get(position)?.store_category_title
        }

    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        //        var imageView: ImageView
        var textView: TextView
        var predictedRow:ConstraintLayout

        init {
//            this.imageView = itemView.findViewById(R.id.imageView) as ImageView
            this.textView = itemView.findViewById(R.id.foodTitle)
            this.predictedRow = itemView.findViewById(R.id.predictedRow)

            itemView.setOnClickListener {
                pos = adapterPosition
                itemClickIvoke?.invoke(arrayFoodTitleList?.get(adapterPosition)?.store_category_id!!)
            }

        }
    }

    fun filterList(filteredList: MutableList<StoreCategoryProduct>?) {
        pos = 0
        arrayFoodTitleList = filteredList
        notifyDataSetChanged()
    }

    fun setPosMain(posMain:Int) {
        pos = posMain
        notifyDataSetChanged()
    }

}