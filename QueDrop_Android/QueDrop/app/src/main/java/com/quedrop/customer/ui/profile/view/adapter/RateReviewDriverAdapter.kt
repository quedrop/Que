package com.quedrop.customer.ui.profile.view.adapter

import android.widget.ImageView
import android.widget.TextView
import com.fuzzproductions.ratingbar.RatingBar
import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.getCalenderDate
import com.quedrop.customer.model.RateReviewResponse
import com.quedrop.customer.utils.URLConstant
import com.quedrop.customer.utils.ValidationUtils
import org.ocpsoft.prettytime.PrettyTime

class RateReviewDriverAdapter(
    var context: Context,
    var arrayRateReviewList: MutableList<RateReviewResponse>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var driverDetailsInvoke: ((Int) -> Unit)? = null
    val dateFormat = "yyyy-MM-dd HH:mm:ss"

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        var listItem = layoutInflater.inflate(R.layout.layout_review_driver, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayRateReviewList != null)
            return arrayRateReviewList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {


            holder.driverProfileNameTv.text = arrayRateReviewList?.get(position)?.first_name + " " +
                    arrayRateReviewList?.get(position)?.last_name

            val cal = arrayRateReviewList?.get(position)?.created_at!!.getCalenderDate(dateFormat)
            val time = PrettyTime()
            holder.driverProfileTimeTv.text = time.format(cal)

            holder.driverProfileRB.rating = arrayRateReviewList?.get(position)?.rating!!
            holder.driverProfileDetailsTV.text = arrayRateReviewList?.get(position)?.review


            if (!arrayRateReviewList?.get(position)?.user_image.isNullOrEmpty()) {

                if (ValidationUtils.isCheckUrlOrNot(arrayRateReviewList?.get(position)?.user_image!!)) {
                    Glide.with(this.context).load(
                        arrayRateReviewList?.get(position)?.user_image
                    ).centerCrop()
                        .placeholder(R.drawable.customer_unpress)
                        .into(holder.driverProfileRIV)
                } else {

                    Glide.with(this.context).load(
                        URLConstant.urlUser
                                + arrayRateReviewList?.get(position)?.user_image
                    ).centerCrop()
                        .placeholder(R.drawable.customer_unpress)
                        .into(holder.driverProfileRIV)
                }
            }

        }

    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {

        var driverProfileRIV = itemView.findViewById(R.id.driverProfileRIV) as ImageView
        var driverProfileNameTv = itemView.findViewById(R.id.driverProfileNameTv) as TextView
        var driverProfileTimeTv = itemView.findViewById(R.id.driverProfileTimeTv) as TextView
        var driverProfileDetailsTV = itemView.findViewById(R.id.driverProfileDetailsTV) as TextView
        var driverProfileRB = itemView.findViewById(R.id.driverProfileRB) as RatingBar

        init {
            itemView.setOnClickListener {
                driverDetailsInvoke?.invoke(adapterPosition)
            }
        }

    }
}


