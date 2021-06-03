package com.quedrop.customer.ui.nearby.view

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.model.NearByStores
import com.quedrop.customer.ui.storewithoutproduct.view.StoreWithoutProductActivity
import com.quedrop.customer.ui.storewithproduct.view.StoreDetailsActivity
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.Utils
import com.makeramen.roundedimageview.RoundedImageView
import com.quedrop.customer.utils.URLConstant
import kotlinx.android.synthetic.main.layout_listnearby_customer.view.*


class ListNearByCustomerAdapter(
    var context: Context,
    var arrayNearByStoreList: MutableList<NearByStores>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var kmDistance: String? = null
    var checkTimeStatus: Boolean? = false
    var openingTime: String? = null
    var closingTime: String? = null
    var currentDay: String? = null
    var currentTimeConvert: String? = null
    var currentDate: String? = null
    var currentTime: String? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val listItem = layoutInflater.inflate(R.layout.layout_listnearby_customer, parent, false)
        return ViewHolder(listItem)
    }

    override fun getItemCount(): Int {
        return if (arrayNearByStoreList != null)
            return arrayNearByStoreList!!.size
        else 0
    }

    @SuppressLint("SetTextI18n")
    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {

            currentDate = Utils.getCurrentDate()
            currentTime = Utils.getCurrentTime()
            currentTimeConvert = Utils.convertTime(currentTime!!)
            currentDay = Utils.getCurrentDay()

            if (arrayNearByStoreList?.get(position)?.latitude?.isEmpty()!!) {
                null
            } else {
                val latitude: Float = arrayNearByStoreList?.get(position)?.latitude!!.toFloat()
                if (arrayNearByStoreList?.get(position)?.longitude?.isEmpty()!!) {
                    null
                } else {
                    val longitude: Float =
                        arrayNearByStoreList?.get(position)?.longitude!!.toFloat()
                    Utils.fetchRouteDistance(
                        context,
                        Utils.keyLatitude.toDouble(), Utils.keyLongitude.toDouble(),
                        latitude.toDouble(), longitude.toDouble(), holder.textViewStoreDistance
                    )
                }
            }

            holder.textViewStoreName.text = arrayNearByStoreList?.get(position)?.store_name
            holder.textViewStoreAddress.text = arrayNearByStoreList?.get(position)?.store_address

            Glide.with(context).load(
                URLConstant.nearByStoreUrl + arrayNearByStoreList?.get(
                    position
                )?.store_logo
            )
                .into(holder.ivLogoStore)

            holder.checkOpenOrCloseShop(position)
        }

    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var ivLogoStore: RoundedImageView
        var textViewStoreName: TextView
        var textViewStoreAddress: TextView
        var textViewStoreDistance: TextView
        var textClosed: TextView

        init {
            this.ivLogoStore = itemView.findViewById(R.id.ivLogoStore)
            this.textViewStoreName = itemView.findViewById(R.id.textTitleStore)
            this.textViewStoreAddress = itemView.findViewById(R.id.textAddressStore)
            this.textViewStoreDistance = itemView.findViewById(R.id.textDistanceStore)
            this.textClosed = itemView.findViewById(R.id.textClosed)


            itemView.setOnClickListener {
                var position = adapterPosition

                if (arrayNearByStoreList?.get(adapterPosition)?.can_provide_service == "1") {
                    startActivityWithProduct(adapterPosition)
                } else {
                    startActivityWithOutProduct(adapterPosition)
                }
            }

        }

        fun checkOpenOrCloseShop(positionMain: Int) {
            checkTimeStatus = false
            toGrayScaleImage()

            if (!arrayNearByStoreList?.get(positionMain)?.schedule.isNullOrEmpty()) {

                for ((index, value) in arrayNearByStoreList?.get(positionMain)?.schedule?.withIndex()!!) {
                    if (currentDay == arrayNearByStoreList?.get(positionMain)?.schedule?.get(index)!!.weekday) {
                        openingTime =
                            arrayNearByStoreList?.get(positionMain)?.schedule?.get(index)!!.opening_time
                        closingTime =
                            arrayNearByStoreList?.get(positionMain)?.schedule?.get(index)!!.closing_time
                        var openingConvertTime: String? = null
                        var closingConvertTime: String? = null

                        if (openingTime.isNullOrEmpty() && closingTime.isNullOrEmpty()) {
                            toGrayScaleImage()
                        } else {
                            openingConvertTime = Utils.convertTime(openingTime!!)
                            closingConvertTime = Utils.convertTime(closingTime!!)

                            checkTimeStatus = Utils.checkTimeStatus(
                                openingConvertTime,
                                closingConvertTime,
                                currentTimeConvert!!
                            )
                            if (!checkTimeStatus!!) {
                                toGrayScaleImage()
                            } else {
                                notGreyScale()
                            }

                        }
                    }
                }
            } else {
                toGrayScaleImage()

            }
        }

        private fun toGrayScaleImage() {

            val matrix = ColorMatrix()
            matrix.setSaturation(0f)
            val cf = ColorMatrixColorFilter(matrix)
            itemView.ivLogoStore.colorFilter = cf
            itemView.textClosed.visibility = View.VISIBLE
        }

        private fun notGreyScale() {
            itemView.ivLogoStore.colorFilter = null
            itemView.textClosed.visibility = View.GONE
        }
    }


    private fun startActivityWithProduct(positionMain: Int) {
        val intentStore = Intent(context, StoreDetailsActivity::class.java)
        intentStore.putExtra(KeysUtils.keyStoreId, arrayNearByStoreList?.get(positionMain)?.store_id)
        intentStore.putExtra(KeysUtils.KeyFreshProduceCategoryId, arrayNearByStoreList?.get(positionMain)?.fresh_produce_category_id)
        (context as NearByRestaurantActivity).startActivityWithDefaultAnimations(intentStore)
    }

    private fun startActivityWithOutProduct(positionMain: Int) {
        val intentStore = Intent(context, StoreWithoutProductActivity::class.java)
        intentStore.putExtra(KeysUtils.keyStoreId, arrayNearByStoreList?.get(positionMain)?.store_id)
        (context as NearByRestaurantActivity).startActivityWithDefaultAnimations(intentStore)
    }

}