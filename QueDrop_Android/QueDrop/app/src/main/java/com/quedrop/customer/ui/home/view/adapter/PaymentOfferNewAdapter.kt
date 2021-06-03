package com.quedrop.customer.ui.home.view.adapter

import android.content.Context
import android.graphics.drawable.Drawable
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.TextView
import androidx.appcompat.widget.AppCompatImageView
import androidx.viewpager.widget.PagerAdapter
import androidx.viewpager.widget.ViewPager
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DataSource
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.load.engine.GlideException
import com.bumptech.glide.request.RequestListener
import com.bumptech.glide.request.RequestOptions
import com.bumptech.glide.request.target.Target
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.getStoreSlideImage
import com.quedrop.customer.model.OrderOffer
import com.quedrop.customer.model.StoreImages
import com.quedrop.customer.utils.EnumOfferUtils
import com.quedrop.customer.utils.Utils


class PaymentOfferNewAdapter(context: Context) : PagerAdapter() {

    private val context: Context
    private var layoutInflater: LayoutInflater? = null
    private var imagesData: ArrayList<OrderOffer> = arrayListOf()

    override fun isViewFromObject(view: View, `object`: Any): Boolean {
        return view == `object`
    }

    override fun getCount(): Int {
        return imagesData.size
    }

    override fun instantiateItem(container: ViewGroup, position: Int): Any {
        layoutInflater =
            context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater?

        val view: View? = layoutInflater?.inflate(R.layout.layout_payment_recycler, null)

        val textCouponCode = view?.findViewById<TextView>(R.id.textCouponCode)
        val txtOfferType = view?.findViewById<TextView>(R.id.txtOfferType)
        val txtOfferDescription = view?.findViewById<TextView>(R.id.txtOfferDescription)
        val txtOfferDes2 = view?.findViewById<TextView>(R.id.txtOfferDes2)
        val discountPrice = view?.findViewById<TextView>(R.id.discountPrice)
        val bgDotted = view?.findViewById<AppCompatImageView>(R.id.bgDotted)

        txtOfferType?.text = imagesData[position].offer_type
//        txtOfferDescription?.text = imagesData[position].offer_description
        txtOfferDescription?.text = title(imagesData[position], 1)
        txtOfferDes2?.text = title(imagesData[position], 2)


        if (imagesData[position].discount_percentage != 0) {
            discountPrice?.text =
                "Flat\n" + imagesData[position].discount_percentage.toString() + "% \noff"
        } else {
            discountPrice?.visibility = View.GONE
            bgDotted?.visibility = View.GONE
        }

        if (!imagesData.isNullOrEmpty()) {
            textCouponCode?.setText(imagesData[position].coupon_code)
        }

        val vp = container as ViewPager
        vp.addView(view, 0)
        return view!!
    }

    fun updateImages(images: MutableList<OrderOffer>) {
        imagesData.clear()
        imagesData.addAll(images)
        notifyDataSetChanged()
    }

    override fun destroyItem(container: ViewGroup, position: Int, `object`: Any) {
        val vp = container as ViewPager
        val view: View? = `object` as View?
        vp.removeView(view)
    }

    init {
        this.context = context
    }


    private fun title(obj: OrderOffer, type: Int): String {

        var topTitle = ""
        var bottomTitle = ""

        if (obj.offer_range > 0) {
            topTitle = "All items on"
            bottomTitle = "Order above " + Utils.CURRENCY + obj.offer_range
        }

        if (obj.offer_type == EnumOfferUtils.FreeDelivery.stringVal || obj.offer_type == EnumOfferUtils.FreeServiceCharge.stringVal) {
            if (obj.offer_range > 0) {
                topTitle = if (obj.offer_type == EnumOfferUtils.FreeDelivery.stringVal) {
                    "Free Delivery on"
                } else {
                    "Free Service Charge on"
                }
                bottomTitle = "Order above " + Utils.CURRENCY + obj.offer_range
            } else {
                topTitle = "All items on"

                bottomTitle = if (obj.offer_type == EnumOfferUtils.FreeDelivery.stringVal) {
                    "Free Delivery on"
                } else {
                    "Free Service Charge on"
                }
            }

        } else if (obj.offer_type == EnumOfferUtils.Delivery.stringVal || obj.offer_type == EnumOfferUtils.ServiceCharge.stringVal) {
            if (obj.offer_range > 0) {
                topTitle = if (obj.offer_type == EnumOfferUtils.Delivery.stringVal) {
                    "Delivery discount on"
                } else {
                    "Service charge discount on"
                }

                bottomTitle = "Order above " + Utils.CURRENCY + obj.offer_range
            } else {
                topTitle = "All items on"
                bottomTitle = if (obj.offer_type == EnumOfferUtils.Delivery.stringVal) {
                    "Delivery Discount"
                } else {
                    "Service charge discount"
                }
            }
        }

        return if (type == 1) {
            topTitle
        } else {
            bottomTitle
        }
    }
}