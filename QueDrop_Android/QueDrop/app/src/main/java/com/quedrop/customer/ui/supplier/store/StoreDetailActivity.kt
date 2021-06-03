package com.quedrop.customer.ui.supplier.store

import android.os.Bundle
import android.view.View
import android.widget.ImageView
import android.widget.LinearLayout
import androidx.core.content.ContextCompat
import androidx.viewpager.widget.ViewPager
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityWithAnimation
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.SupplierStoreDetail
import com.quedrop.customer.ui.supplier.store.adapter.DaysAdapter
import com.quedrop.customer.ui.supplier.store.adapter.ViewPagerAdapter
import com.quedrop.customer.utils.RxBus
import com.quedrop.customer.utils.URLConstant
import io.reactivex.disposables.Disposable
import kotlinx.android.synthetic.main.activity_store_detail.*
import kotlinx.android.synthetic.main.activity_toolbar.*

class StoreDetailActivity : BaseActivity() {

    private var adapter: DaysAdapter? = null
    private lateinit var storeDetail: SupplierStoreDetail
    private lateinit var personDisposable: Disposable
    lateinit var viewPagerAdapter: ViewPagerAdapter
    private var dotscount: Int = 0
    private var dots: Array<ImageView?>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_store_detail)
        storeDetail = intent.getSerializableExtra("store") as SupplierStoreDetail
        init()
        setData()
    }


    private fun init() {

        if (adapter == null) {
            adapter =
                DaysAdapter(this, tvViewDayEmpty, false)
            rvViewDays.adapter = adapter

        }

        personDisposable = RxBus.instance?.listen(SupplierStoreDetail::class.java)?.subscribe {
            storeDetail = it
            setData()

            setUpImages()
        }!!

        tvEditStore.throttleClicks().subscribe {

            startActivityWithAnimation<SupplierEditStoreProfileActivity> {
                putExtra("storeDetail", storeDetail)
            }

        }.autoDispose(compositeDisposable)

        ivBackStoreDetail.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        viewPagerAdapter = ViewPagerAdapter(this)
        vpProfileImages.adapter = viewPagerAdapter
        setUpImages()


    }

    private fun setUpImages() {
        SliderDots.removeAllViews()
        if (!storeDetail.slider_images.isNullOrEmpty()) {
            viewPagerAdapter.updateImages(storeDetail.slider_images)
            dotscount = viewPagerAdapter.count
            dots = arrayOfNulls(dotscount)

            for (i in 0 until dotscount) {
                dots!![i] = ImageView(this)
                dots!![i]!!.setImageDrawable(
                    ContextCompat.getDrawable(
                        applicationContext,
                        R.drawable.non_active_dot
                    )
                )

                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(2, 0, 2, 0)
                SliderDots?.addView(dots!![i], params)
            }

            dots!![0]!!.setImageDrawable(
                ContextCompat.getDrawable(
                    applicationContext,
                    R.drawable.active_dot
                )
            )

            vpProfileImages?.addOnPageChangeListener(object :
                ViewPager.OnPageChangeListener {
                override fun onPageScrolled(
                    position: Int,
                    positionOffset: Float,
                    positionOffsetPixels: Int
                ) {

                }

                override fun onPageSelected(position: Int) {
                    for (i in 0 until dotscount) {
                        dots!![i]!!.setImageDrawable(
                            ContextCompat.getDrawable(
                                applicationContext,
                                R.drawable.non_active_dot
                            )
                        )
                    }
                    dots!![position]!!.setImageDrawable(
                        ContextCompat.getDrawable(
                            applicationContext,
                            R.drawable.active_dot
                        )
                    )
                }

                override fun onPageScrollStateChanged(state: Int) {
                }
            })
        }
    }

    private fun setData() {

        Glide.with(this)
            .load(URLConstant.nearByStoreUrl + storeDetail.store_logo)
            .placeholder(R.drawable.placeholder_order_cart_product)
            .diskCacheStrategy(DiskCacheStrategy.ALL)
            .into(ivViewProfileImage)

        viewStoreName.setText(storeDetail.store_name)
        viewStoreAddress.setText(storeDetail.store_address)
        viewStoreCategory.setText(storeDetail.service_category_name)
        adapter?.dayList = storeDetail.schedule
        adapter?.notifyDataSetChanged()
    }

    override fun onResume() {
        super.onResume()

    }

    override fun onDestroy() {
        super.onDestroy()
        if (!personDisposable.isDisposed) personDisposable.dispose()
    }

    override fun onBackPressed() {
        super.onBackPressed()
        // RxBus.instance?.publish(storeDetail)
    }
}
