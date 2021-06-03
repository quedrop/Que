package com.quedrop.customer.ui.home.view.adapter

import android.content.Context
import android.os.Build
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.annotation.RequiresApi
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.model.OrderOffer
import com.quedrop.customer.utils.ConstantUtils


class PaymentOfferAdapter(
    var context: Context,
    var arrayPaymentOfferList: MutableList<OrderOffer>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        var listItem = layoutInflater.inflate(R.layout.layout_payment_recycler, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayPaymentOfferList != null)
            return arrayPaymentOfferList!!.size
        else 0
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {

            when (position) {
                ConstantUtils.ZERO -> {
                   // holder.mainBg.backgroundTintList = context.resources.getColorStateList(R.color.colorPaymentBlue)
                    holder.textDescriptionOffer.setTextColor(
                        ContextCompat.getColor(
                            context,
                            R.color.colorWhite
                        )
                    )
                    holder.textPercentageToday.setTextColor(
                        ContextCompat.getColor(
                            context,
                            R.color.colorWhite
                        )
                    )
                    holder.textPromoCode.setTextColor(
                        ContextCompat.getColor(
                            context,
                            R.color.colorWhite
                        )
                    )
                    holder.textCouponCode.setTextColor(
                        ContextCompat.getColor(
                            context,
                            R.color.colorWhite
                        )
                    )
                }
                ConstantUtils.ONE -> {
                   // holder.mainBg.backgroundTintList = context.resources.getColorStateList(R.color.colorMagenta)
                    holder.textDescriptionOffer.setTextColor(
                        ContextCompat.getColor(
                            context,
                            R.color.colorWhite
                        )
                    )
                    holder.textPercentageToday.setTextColor(
                        ContextCompat.getColor(
                            context,
                            R.color.colorWhite
                        )
                    )
                    holder.textPromoCode.setTextColor(
                        ContextCompat.getColor(
                            context,
                            R.color.colorWhite
                        )
                    )
                    holder.textCouponCode.setTextColor(
                        ContextCompat.getColor(
                            context,
                            R.color.colorWhite
                        )
                    )
                }
                ConstantUtils.TWO -> {
                  // holder.mainBg.backgroundTintList = context.resources.getColorStateList(R.color.colorWhite)
                    holder.textCouponCode.backgroundTintList =
                        context.resources.getColorStateList(R.color.colorBlack)
                    holder.textDescriptionOffer.setTextColor(
                        ContextCompat.getColor(
                            context,
                            R.color.colorBlack
                        )
                    )
                    holder.textPercentageToday.setTextColor(
                        ContextCompat.getColor(
                            context,
                            R.color.colorBlack
                        )
                    )
                    holder.textPromoCode.setTextColor(
                        ContextCompat.getColor(
                            context,
                            R.color.colorBlack
                        )
                    )
                    holder.textCouponCode.setTextColor(
                        ContextCompat.getColor(
                            context,
                            R.color.colorBlack
                        )
                    )
                }
            }

            val paymentArray = arrayPaymentOfferList?.get(position)
            holder.textDescriptionOffer.text = paymentArray?.offer_description.toString()

            if (paymentArray?.discount_percentage!! > 0) {
                holder.textPercentageToday.visibility = View.VISIBLE
                holder.textPercentageToday.text =
                    paymentArray.discount_percentage.toString() + "% off"
            } else {
                holder.textPercentageToday.visibility = View.GONE
            }

            if (paymentArray.coupon_code > "") {
                holder.textCouponCode.visibility = View.VISIBLE
                holder.textPromoCode.visibility = View.VISIBLE
                holder.textCouponCode.text =
                    arrayPaymentOfferList?.get(position)?.coupon_code.toString()
            } else {
                holder.textCouponCode.visibility = View.GONE
                holder.textPromoCode.visibility = View.GONE
            }

//            if (paymentArray?.offer_range!! > 0 && paymentArray.discount_percentage > 0) {
//                holder.textPercentageToday.text = paymentArray.discount_percentage.toString() + "% OFF on order above $" + paymentArray.offer_range
//            } else if (paymentArray.offer_range > 0 && paymentArray.discount_percentage == 0) {
//                holder.textPercentageToday.text = "On order above $" + paymentArray.offer_range
//            } else if (paymentArray.offer_range == 0 && paymentArray.discount_percentage > 0) {
//                holder.textPercentageToday.text =  paymentArray.discount_percentage.toString() + "% OFF"
//            } else {
//                holder.textPercentageToday.text =""
//            }

            //holder.textPromoCode.text= arrayPaymentOfferList?.get(position)?.coupon_code.toString()
        }

        /*   cell.lblDescription3.text = obj.offerDescription
           if obj.offerRange! > 0 && obj.discountPercentage! > 0 {
               cell.lblpercentage3.text = "\(obj.discountPercentage!)% OFF on order above \(Currency)\(obj.offerRange!)"
           }else if obj.offerRange! > 0 && obj.discountPercentage == 0 {
               cell.lblpercentage3.text = "On order above \(Currency)\(obj.offerRange!)"
           } else if obj.offerRange! == 0 && obj.discountPercentage! > 0 {
               cell.lblpercentage3.text = "\(obj.discountPercentage!)% OFF"
           } else {
               cell.lblpercentage3.text = ""
           }


           if obj.couponCode!.count > 0 {
               cell.btnCouponCode3.isHidden = false
               cell.btnCouponCode3.setTitle(obj.couponCode, for: .normal)
           }else {
               cell.btnCouponCode1.isHidden = true
           }*/

    }

    class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {

        //var mainBg: ConstraintLayout
        var textDescriptionOffer: TextView
        var textPercentageToday: TextView
        var textCouponCode: TextView
        var textPromoCode: TextView

        init {
           // this.mainBg = itemView.findViewById(R.id.mainBg) as ConstraintLayout
            this.textDescriptionOffer = itemView.findViewById(R.id.txtOfferType)
            this.textPercentageToday = itemView.findViewById(R.id.txtOfferType)
            this.textCouponCode = itemView.findViewById(R.id.textCouponCode)
            this.textPromoCode = itemView.findViewById(R.id.textPromoCode)
        }
    }

}