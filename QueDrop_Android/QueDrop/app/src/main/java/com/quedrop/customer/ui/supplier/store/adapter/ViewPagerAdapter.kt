package com.quedrop.customer.ui.supplier.store.adapter

import android.content.Context
import android.graphics.drawable.Drawable
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.ProgressBar
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
import com.quedrop.customer.model.StoreImages


class ViewPagerAdapter(context: Context) : PagerAdapter() {

    private val context: Context
    private var layoutInflater: LayoutInflater? = null
    private val imagesData: ArrayList<StoreImages> = arrayListOf()

    override fun isViewFromObject(view: View, `object`: Any): Boolean {
        return view == `object`
    }

    override fun getCount(): Int {
        return imagesData.size
    }

    override fun instantiateItem(container: ViewGroup, position: Int): Any {
        layoutInflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater?
        val view: View? = layoutInflater?.inflate(R.layout.item_view_pager, null)
        val imageView: ImageView = view?.findViewById(R.id.imageView) as ImageView
        val progressBar = view.findViewById<ProgressBar>(R.id.progressBar)

        if (!imagesData[position].slider_image.isNullOrEmpty()) {
            Glide.with(context).applyDefaultRequestOptions(
                RequestOptions().diskCacheStrategy(
                    DiskCacheStrategy.ALL
                ).skipMemoryCache(true)
            ).load(context.getStoreSlideImage(imagesData[position].slider_image))
                .format(DecodeFormat.PREFER_ARGB_8888)
                .listener(object : RequestListener<Drawable> {
                    override fun onLoadFailed(
                        e: GlideException?,
                        model: Any?,
                        target: Target<Drawable>?,
                        isFirstResource: Boolean
                    ): Boolean {
                        progressBar.visibility = View.VISIBLE
                        return false
                    }

                    override fun onResourceReady(
                        resource: Drawable?,
                        model: Any?,
                        target: Target<Drawable>?,
                        dataSource: DataSource?,
                        isFirstResource: Boolean
                    ): Boolean {
                        progressBar.visibility = View.GONE
                        return false
                    }

                })
                .apply(RequestOptions().centerCrop().apply(RequestOptions.centerCropTransform()))
                .placeholder(R.drawable.addstore)
                .into(imageView)
        }

        val vp = container as ViewPager
        vp.addView(view, 0)
        return view
    }

    fun updateImages(images: ArrayList<StoreImages>) {
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
}