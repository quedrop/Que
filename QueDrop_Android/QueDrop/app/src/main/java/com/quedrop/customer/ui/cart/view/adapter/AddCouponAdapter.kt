package com.quedrop.customer.ui.cart.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.RadioButton
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.model.GetCouponCodeResponse
import com.quedrop.customer.utils.Utils


class AddCouponAdapter(
    var context: Context,
    var intentCouponCode:String,
    var arrayAddCouponList: MutableList<GetCouponCodeResponse>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var arrayAddCouponInvoke:((Int)->Unit)?=null
    var selectedPos :Int=-1


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        var listItem = layoutInflater.inflate(R.layout.layout_coupon_adapter, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayAddCouponList != null)
            return arrayAddCouponList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {


            if(intentCouponCode == arrayAddCouponList?.get(position)?.coupon_code){
                holder.chAddCoupon.isChecked = true
            }else{
                if(selectedPos == -1){
                    holder.chAddCoupon.isChecked = false
                }else{
                    holder.chAddCoupon.isChecked = (selectedPos == position)
                }
            }
            holder.tvCouponCode.text = arrayAddCouponList?.get(position)?.coupon_code
            holder.tvPercentage.text = arrayAddCouponList?.get(position)?.discount_percentage + context.resources.getString(R.string.percentageCoupon)
            holder.tvOfferDescription.text = arrayAddCouponList?.get(position)?.offer_description

            var originalStringDate = arrayAddCouponList?.get(position)?.expiration_date
            if(originalStringDate.isNullOrBlank()){

                holder.tvExpire.visibility = View.GONE
            }else{
                holder.tvExpire.visibility = View.VISIBLE
                val convertDate = Utils.getConvertDate(originalStringDate)
                holder.tvExpire.text = context.resources.getString(R.string.expiresCoupon)+
                        convertDate
            }

//            holder.chAddOns.text =
//                arrayAddOnsList?.get(position)?.addon_name + " " + context.resources.getString(R.string.rs) + arrayAddOnsList?.get(
//                    position
//                )?.addon_price
//
//            for ((item, value) in arrayAddCheckList?.withIndex()!!) {
//                if (value.addon_id == arrayAddOnsList?.get(position)?.addon_id) {
//                    holder.chAddOns.isChecked = true
//
//                }
//            }
        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var chAddCoupon: RadioButton
        var tvPercentage: TextView
        var tvOfferDescription: TextView
        var tvCouponCode :TextView
        var tvExpire :TextView

        init {
//            this.imageView = itemView.findViewById(R.id.imageView) as ImageView
            this.chAddCoupon = itemView.findViewById(R.id.chAddCoupon)
            this.tvCouponCode =itemView.findViewById(R.id.tvCouponCode)
            this.tvPercentage = itemView.findViewById(R.id.tvPercentage)
            this.tvOfferDescription = itemView.findViewById(R.id.tvOfferDescription)
            this.tvExpire = itemView.findViewById(R.id.tvExpire)

            chAddCoupon.setOnClickListener {
                intentCouponCode = ""
                selectedPos =adapterPosition
                arrayAddCouponInvoke?.invoke(adapterPosition)
                notifyDataSetChanged()
            }


//            chAddCoupon.setOnCheckedChangeListener { buttonView, isChecked ->
//                if (isChecked) {
//
//                    arrayAddCouponInvoke?.invoke(adapterPosition,isChecked)
//
//                }else{
//                    arrayAddCouponInvoke?.invoke(adapterPosition,isChecked)
//                }
//            }

        }
    }

//    fun checkList(addCheckList:MutableList<AddOns>?){
//        arrayAddCheckList?.clear()
//       for((item,value) in arrayAddOnsList?.withIndex()!!){
//           for((item1,value1) in addCheckList?.withIndex()!!){
//               if(value.addon_id == addCheckList?.get(item1)?.addon_id){
//                   arrayAddCheckList?.add(arrayAddOnsList?.get(item)!!)
//               }
//           }
//       }
//        notifyDataSetChanged()
//
//    }

}