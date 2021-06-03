package com.quedrop.driver.ui.settings.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.fuzzproductions.ratingbar.RatingBar
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import com.quedrop.driver.service.model.RateAndReviews
import com.quedrop.driver.utils.*
import org.ocpsoft.prettytime.PrettyTime

class RateReviewDriverAdapter(
    var context: Context,
    var arrayRateReviewList: MutableList<RateAndReviews>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private var profileImagePath: String = ""

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem = layoutInflater.inflate(R.layout.layout_review_driver, parent, false)
        return ViewHolder(
            listItem
        )
    }

    override fun getItemCount(): Int {
        return if (arrayRateReviewList != null)
            return arrayRateReviewList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val dataSet = arrayRateReviewList?.get(position)
        if (holder is ViewHolder) {
            val cal = dataSet?.created_at?.getCalenderDate(dateFormat)
            val time = PrettyTime()

            holder.driverProfileNameTv.text = dataSet?.first_name + " " + dataSet?.last_name
            holder.driverProfileTimeTv.text = time.format(cal)
            holder.driverProfileRB.rating = dataSet?.rating!!

            if (dataSet.review != "" && dataSet.review != null) {
                holder.driverProfileDetailsTV.visibility = View.VISIBLE
                holder.driverProfileDetailsTV.text = dataSet.review
            } else {
                holder.driverProfileDetailsTV.visibility = View.GONE
            }

            if (!dataSet.user_image.isNullOrEmpty()) {
                if (!isNetworkUrl(dataSet.user_image!!)) {
                    profileImagePath =
                        BuildConfig.BASE_URL + ImageConstant.PROFILE_DATA + dataSet.user_image
                } else {
                    profileImagePath = dataSet.user_image!!
                }

                Utility.loadGlideImage(
                    context,
                    profileImagePath,
                    R.drawable.ic_user_placeholder,
                    holder.driverProfileRIV
                )
            }
        }

    }

    class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {

        var driverProfileRIV = itemView.findViewById(R.id.driverProfileRIV) as ImageView
        var driverProfileNameTv = itemView.findViewById(R.id.driverProfileNameTv) as TextView
        var driverProfileTimeTv = itemView.findViewById(R.id.driverProfileTimeTv) as TextView
        var driverProfileDetailsTV = itemView.findViewById(R.id.driverProfileDetailsTV) as TextView
        var driverProfileRB = itemView.findViewById(R.id.driverProfileRB) as RatingBar

    }
}


