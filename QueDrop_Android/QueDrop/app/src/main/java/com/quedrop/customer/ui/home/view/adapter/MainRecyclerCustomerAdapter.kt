package com.quedrop.customer.ui.home.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager.widget.ViewPager
import com.quedrop.customer.R
import com.quedrop.customer.model.*
import com.quedrop.customer.utils.EnumHomeOfferCategoriesList
import kotlinx.android.synthetic.main.activity_store_detail.*


class MainRecyclerCustomerAdapter(
    var context: Context,
    var arrayMainRecycleList: MutableList<String>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var nearByStoreActivityInvoke: ((Int, Boolean) -> Unit)? = null
    var addStoreActivityInvoke: ((View) -> Unit)? = null

    var todayDalAdapter: TodayDealRecyclerAdapter? = null

    //    var paymentAdapter: PaymentOfferAdapter? = null
    var paymentAdapter: PaymentOfferNewAdapter? = null
    var productOfferAdapter: ProductOfferRecyclerAdapter? = null
    var restaurantOfferAdapter: RestaurantOfferRecyclerAdapter? = null
    var allCategoriesAdapter: AllCategarioesRecyclerAdapter? = null
    var freshProduceRecyclerAdapter: FreshProduceRecyclerAdapter? = null

    var arrayTodayDealList: MutableList<String>? = mutableListOf()
    var arrayPaymentOfferList: MutableList<String>? = mutableListOf()
    var arrayProductOfferList: MutableList<ProfuctOfferList>? = mutableListOf()
    var arrayRestaurantOfferList: MutableList<StoreOfferList>? = mutableListOf()
    var arrayCategoriesList: MutableList<Categories>? = mutableListOf()
    var arrayPaymentOrderOffer: MutableList<OrderOffer>? = mutableListOf()
    var arrayFreshProduceCategories: MutableList<FreshProduceCategories>? = mutableListOf()


    var getAllOfferListInvoke: ((Int) -> Unit)? = null
    var allCategoriesInvoke: ((Int) -> Unit)? = null

    private var dots: Array<ImageView?>? = null
    private var dotscount: Int = 0


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        var listItem =
            layoutInflater.inflate(R.layout.layout_main_customer_home_recycle, parent, false)
        return ViewHolder(
            listItem
        )
    }

    override fun getItemCount(): Int {
        return if (arrayMainRecycleList != null)
            return arrayMainRecycleList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is ViewHolder) {
            holder.bindView(position)
        }

    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {

        var textView: TextView
        var mRecyclerView: RecyclerView
        var vpCouponsImages: ViewPager
        var SliderDots: LinearLayout

        init {
            this.mRecyclerView = itemView.findViewById(R.id.mainRecyclerViewCustomer)
            this.textView = itemView.findViewById(R.id.textTitleCustomer)
            this.vpCouponsImages = itemView.findViewById(R.id.vpCouponsImages)
            this.SliderDots = itemView.findViewById(R.id.SliderDots)

            getAllOfferListInvoke?.invoke(adapterPosition)
            allCategoriesInvoke?.invoke(adapterPosition)

        }

        fun bindView(position: Int) {

            textView.visibility = View.GONE
//            arrayTodayDealList =
//                context?.resources?.getStringArray(R.array.todayDealItem)
//                    ?.toMutableList()
//
            arrayPaymentOfferList =
                context?.resources?.getStringArray(R.array.paymentOffers)
                    ?.toMutableList()


            mRecyclerView.setHasFixedSize(true)

            when (position) {

                EnumHomeOfferCategoriesList.PAYMENT_OFFER_LIST.posVal -> {

//                    arrayPaymentOfferList = mutableListOf()


                    mRecyclerView.layoutManager = LinearLayoutManager(
                        context.applicationContext!!,
                        LinearLayoutManager.HORIZONTAL,
                        false
                    )
                    if (!arrayPaymentOrderOffer.isNullOrEmpty()) {
                        textView.visibility = View.VISIBLE
                        textView.text = "Payment offers/Coupon"
                    }

                    paymentAdapter = PaymentOfferNewAdapter(
                        context.applicationContext!!

                    )
                    paymentAdapter?.updateImages(arrayPaymentOrderOffer!!)
                    vpCouponsImages.adapter = paymentAdapter

                    if (!arrayPaymentOrderOffer.isNullOrEmpty()) {
                        textView.visibility = View.VISIBLE
                        textView.text = arrayMainRecycleList?.get(EnumHomeOfferCategoriesList.PAYMENT_OFFER_LIST.posVal)

                        vpCouponsImages.visibility = View.VISIBLE
                        SliderDots.visibility = View.VISIBLE
                        mRecyclerView.visibility = View.GONE

                    }

                    SliderDots.removeAllViews()
                    if (!arrayPaymentOfferList.isNullOrEmpty()) {
                        paymentAdapter?.updateImages(arrayPaymentOrderOffer!!)
                        dotscount = paymentAdapter?.count!!
                        dots = arrayOfNulls(dotscount)

                        for (i in 0 until dotscount) {
                            dots!![i] = ImageView(context)
                            dots!![i]!!.setImageDrawable(
                                ContextCompat.getDrawable(
                                    context,
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

                        if (dots?.size!! > 0) {
                            dots!![0]!!.setImageDrawable(
                                ContextCompat.getDrawable(
                                    context,
                                    R.drawable.active_dot
                                )
                            )
                        }

                        vpCouponsImages.addOnPageChangeListener(object :
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
                                            context,
                                            R.drawable.non_active_dot
                                        )
                                    )
                                }
                                dots!![position]!!.setImageDrawable(
                                    ContextCompat.getDrawable(
                                        context,
                                        R.drawable.active_dot
                                    )
                                )
                            }

                            override fun onPageScrollStateChanged(state: Int) {
                            }
                        })
                    }

                }

                EnumHomeOfferCategoriesList.PRODUCT_OFFER_LIST.posVal -> {

                    mRecyclerView.layoutManager = LinearLayoutManager(
                        context.applicationContext!!,
                        LinearLayoutManager.HORIZONTAL,
                        false
                    )

                    productOfferAdapter =
                        ProductOfferRecyclerAdapter(
                            context.applicationContext!!,
                            arrayProductOfferList

                        )
                    mRecyclerView.adapter = productOfferAdapter

                    if (!arrayProductOfferList.isNullOrEmpty()) {
                        textView.visibility = View.VISIBLE
                        textView.text = arrayMainRecycleList?.get(EnumHomeOfferCategoriesList.PRODUCT_OFFER_LIST.posVal)
                    }

                }

                EnumHomeOfferCategoriesList.RESTAURANT_LIST.posVal -> {

                    mRecyclerView.layoutManager = LinearLayoutManager(
                        context.applicationContext!!,
                        LinearLayoutManager.HORIZONTAL,
                        false
                    )

                    restaurantOfferAdapter =
                        RestaurantOfferRecyclerAdapter(
                            context.applicationContext!!,
                            arrayRestaurantOfferList

                        )
                    mRecyclerView.adapter = restaurantOfferAdapter

                    if (!arrayRestaurantOfferList.isNullOrEmpty()) {
                        textView.visibility = View.VISIBLE
                        textView.text =
                            arrayMainRecycleList?.get(EnumHomeOfferCategoriesList.RESTAURANT_LIST.posVal)
                    }
                }

                EnumHomeOfferCategoriesList.FRESH_PRODUCE_LIST.posVal -> {

                    mRecyclerView.layoutManager = LinearLayoutManager(
                        context.applicationContext!!,
                        LinearLayoutManager.HORIZONTAL,
                        false
                    )

                    freshProduceRecyclerAdapter =
                        FreshProduceRecyclerAdapter(
                            context.applicationContext!!,
                            arrayFreshProduceCategories

                        ).apply {
                            nearByStoreActivity = { it: Int, fromFreshProduce: Boolean ->
                                nearByStoreActivity(it, fromFreshProduce)
                            }
                        }
                    mRecyclerView.adapter = freshProduceRecyclerAdapter

                    if (!arrayFreshProduceCategories.isNullOrEmpty()) {
                        textView.visibility = View.VISIBLE
                        textView.text = arrayMainRecycleList?.get(EnumHomeOfferCategoriesList.FRESH_PRODUCE_LIST.posVal)
                    }
                }

                EnumHomeOfferCategoriesList.ALL_CATEGORIES_LIST.posVal -> {

                    mRecyclerView.layoutManager = GridLayoutManager(
                        context.applicationContext!!,
                        2
                    )

                    allCategoriesAdapter =
                        AllCategarioesRecyclerAdapter(
                            context.applicationContext!!,
                            arrayCategoriesList

                        ).apply {
                            //zp changes
//                            addStoreActivity = {
//                                addStoreActivity(it)
//                            }
                            nearByStoreActivity = {
                                nearByStoreActivity(it, false)
                            }
                        }

                    mRecyclerView.adapter = allCategoriesAdapter
                    if (!arrayCategoriesList.isNullOrEmpty()) {
                        textView.visibility = View.VISIBLE
                        textView.text =
                            arrayMainRecycleList?.get(EnumHomeOfferCategoriesList.ALL_CATEGORIES_LIST.posVal)
                    }

                }

                else -> {
                }
            }
        }
    }

    private fun addStoreActivity(it: View) {
        addStoreActivityInvoke?.invoke(it)
    }

    private fun nearByStoreActivity(it: Int, fromFreshProduce: Boolean) {
        nearByStoreActivityInvoke?.invoke(it, fromFreshProduce)
    }

    fun paymentOfferNotified(arrayCategoriesList1: MutableList<OrderOffer>) {
        arrayPaymentOrderOffer = arrayCategoriesList1
        paymentAdapter?.notifyDataSetChanged()
        notifyDataSetChanged()
    }

    fun allCategoriesNotified(arrayCategoriesList1: MutableList<Categories>) {
        arrayCategoriesList = arrayCategoriesList1
        allCategoriesAdapter?.notifyDataSetChanged()
        notifyDataSetChanged()
    }

    fun restaurantOffersNotified(arrayRestaurantOfferList1: MutableList<StoreOfferList>) {
        arrayRestaurantOfferList = arrayRestaurantOfferList1
        restaurantOfferAdapter?.notifyDataSetChanged()
        notifyDataSetChanged()
    }

    fun productOffersNotified(arrayProductOfferList1: MutableList<ProfuctOfferList>) {
        arrayProductOfferList = arrayProductOfferList1
        productOfferAdapter?.notifyDataSetChanged()
        notifyDataSetChanged()
    }

    fun freshProduceNotified(arrayFreshProduceCategories1: MutableList<FreshProduceCategories>) {
        arrayFreshProduceCategories = arrayFreshProduceCategories1
        freshProduceRecyclerAdapter?.notifyDataSetChanged()
        notifyDataSetChanged()
    }

}