package com.quedrop.customer.ui.cart.view.adapter

import android.content.Context
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.SimpleItemAnimator
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.db.AppDatabase
import com.quedrop.customer.model.*
import com.makeramen.roundedimageview.RoundedImageView
import com.quedrop.customer.utils.*
import java.util.*


class CartAdapter(
    var contextCart: Context,
    var arrayCartList: MutableList<UserCart>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {


    private var arrayNotesTermsList: MutableList<NotesResponse>? = null
    var arrayProductCartList: MutableList<Product>? = null
    var cartProductAdapter: CartProductsAdapter? = null
    var amountDetails: AmountDetails? = null
    var stringNote: String? = null
    var setRecurringInvoke: ((View) -> Unit)? = null
    var setCouponCartInvoke: ((View, String, String) -> Unit)? = null
    var isCheckInvoke: ((Boolean) -> Unit)? = null
    var cartRemoveClickInvoke: ((Int, Int) -> Unit)? = null
    var updateQuantityClickInvoke1: ((Int, Int, Int) -> Unit)? = null
    var minusDeleteFromProductClickInvoke1: ((Int, Int, Int) -> Unit)? = null
    var storeProductIntent: ((Int) -> Unit)? = null
    var storeWithoutProductIntent: ((Int) -> Unit)? = null
    var customiseCartInvoke: ((Int, Int, Int, Int, String, MutableList<AddOns>) -> Unit)? = null
    var showAlertChragesInvoke: ((String, String) -> Unit)? = null
    var checkStoreOpenInvoke: ((Boolean) -> Unit)? = null
    var viewAllNearDriversInvoke: ((Int) -> Unit)? = null
    var standardRadioInvoke: ((Int) -> Unit)? = null
    var expressRadioInvoke: ((Int) -> Unit)? = null


    var flagCheckStore: Boolean = false
    var flagCheckManual: Boolean = false
    var flagRecurring = false
    var saveMaxRsStringMain: String = ""
    var couponCodeMain: String = ""
    var checkTimeStatus: Boolean? = false
    var openingTime: String? = null
    var closingTime: String? = null
    var currentDay: String? = null
    var currentTimeConvert: String? = null
    var currentDate: String? = null
    var currentTime: String? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val v: View

        if (viewType == 1) {
            v = LayoutInflater.from(parent.context)
                .inflate(R.layout.layout_extra_item_cart_recycle, parent, false)
            return ExtraItemHolder(v)
        } else {
            v = LayoutInflater.from(parent.context)
                .inflate(R.layout.layout_cart_item_recycle, parent, false)
            return CartHolder(v)
        }
    }


    override fun getItemCount(): Int {
        return if (arrayCartList != null)
            return ((arrayCartList!!.size))
        else 0
    }

    override fun getItemViewType(position: Int): Int {

        var viewtype = 0

        if (position == (arrayCartList!!.size) - 1) {
            viewtype = 1
        } else {
            viewtype = 0
        }
        return viewtype
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        flagCheckManual = false
        try {
            val keyLatitude =
                SharedPrefsUtils.getStringPreference(contextCart, KeysUtils.KeyLatitude)
            val keyLongitude =
                SharedPrefsUtils.getStringPreference(contextCart, KeysUtils.KeyLongitude)
            currentDate = Utils.getCurrentDate()
            currentTime = Utils.getCurrentTime()
            currentTimeConvert = Utils.convertTime(currentTime!!)
            currentDay = Utils.getCurrentDay()

            if (holder is CartHolder) {

                holder.tvStoreNameRv.text = arrayCartList?.get(position)?.store_details?.store_name
                holder.tvStoreAddressRv.text =
                    arrayCartList?.get(position)?.store_details?.store_address
                (holder.rvProductsCart.itemAnimator as SimpleItemAnimator).supportsChangeAnimations =
                    false


                Utils.fetchRouteDistance(
                    contextCart,
                    keyLatitude!!.toDouble(),
                    keyLongitude!!.toDouble(),
                    arrayCartList?.get(position)?.store_details?.latitude?.toDouble()!!,
                    arrayCartList?.get(position)?.store_details?.longitude?.toDouble()!!,
                    holder.tvStoreDistanceRv
                )


                Glide.with(contextCart).load(
                    URLConstant.nearByStoreUrl + arrayCartList?.get(
                        position
                    )?.store_details!!.store_logo
                ).into(holder.ivStoreLogoRv)

                arrayProductCartList = arrayCartList?.get(position)?.products

                holder.rvProductsCart.layoutManager = LinearLayoutManager(
                    contextCart,
                    LinearLayoutManager.VERTICAL,
                    false
                )

                cartProductAdapter = CartProductsAdapter(
                    contextCart,
                    arrayProductCartList

                ).apply {
                    updateQuantityClickInvoke =
                        { sumQuantity: Int, cart_product_id: Int, position: Int ->
                            updateQuantity(sumQuantity, cart_product_id, position)
                        }
                    minusDeleteFromProductClickInvoke =
                        { cart_id: Int, cart_product_id: Int, position: Int ->
                            minusCart(cart_id, cart_product_id, position)
                        }
                    customiseInvoke =
                        { cartProductId: Int, productId: Int, optionId: Int, storeId: Int, hasAddOns: String, arrayAddOnsList: MutableList<AddOns> ->
                            customiseFunction(
                                cartProductId,
                                productId,
                                optionId,
                                storeId,
                                hasAddOns,
                                arrayAddOnsList
                            )

                        }
                }


                holder.rvProductsCart.adapter = cartProductAdapter



                if (arrayCartList?.get(position)?.store_details?.user_store_id!!.toInt() == ConstantUtils.ZERO) {

                    if (arrayCartList?.get(position)?.store_details?.can_provide_service!!.toInt() == ConstantUtils.ONE) {
                        flagCheckStore = false

                    } else {
                        flagCheckStore = true
                    }

                }

                cartProductAdapter?.setCartIdAdapter(
                    arrayCartList?.get(position)!!.cart_id,
                    arrayCartList?.get(position)!!.store_details.store_id,
                    flagCheckStore
                )
                holder.checkOpenOrCloseShop(position)
                cartProductAdapter?.notifyDataSetChanged()


            } else if (holder is ExtraItemHolder) {

                holder.tvRsRv.text =
                    contextCart.resources.getString(R.string.rs) + String.format(
                        "%.2f",
                        amountDetails?.total_items_price!!.toFloat()
                    )
                holder.tvFreeRv.text =
                    contextCart.resources.getString(R.string.rs) + String.format(
                        "%.2f",
                        amountDetails?.service_charge!!.toFloat()
                    )
                holder.tvPayRsRv.text =
                    contextCart.resources.getString(R.string.rs) + String.format(
                        "%.2f",
                        amountDetails?.grand_total!!.toFloat()
                    )
                holder.tvShoppingRs.text =
                    contextCart.resources.getString(R.string.rs) + String.format(
                        "%.2f",
                        amountDetails?.shopping_fee!!.toFloat()
                    )
                holder.tvDeliveryFeeRs.text =
                    contextCart.resources.getString(R.string.rs) + String.format(
                        "%.2f",
                        amountDetails?.delivery_charge!!.toFloat()
                    )


                if (amountDetails?.is_coupon_applied == "1") {
                    holder.tvMaxSaveCart.visibility = View.VISIBLE
                    holder.couponDetailsConstraint.visibility = View.VISIBLE
                    holder.tvMaxSaveCart.text =
                        contextCart.resources.getString(R.string.saveAdditionalDollar) +
                                saveMaxRsStringMain
                    // holder.tvOrderDiscountRs.text = amountDetails?.order_discount_value

                    holder.tvOrderDiscountRs.text =
                        contextCart.resources.getString(R.string.rs) + String.format(
                            "%.2f",
                            amountDetails?.order_discount_value!!.toFloat()
                        )
                    //holder.tvCouponDiscountFee.text = amountDetails?.coupon_discount_price

                    holder.tvCouponDiscountFee.text =
                        contextCart.resources.getString(R.string.rs) + String.format(
                            "%.2f",
                            amountDetails?.coupon_discount_price!!.toFloat()
                        )

                } else {
                    holder.tvMaxSaveCart.visibility = View.GONE
                    holder.couponDetailsConstraint.visibility = View.GONE
                }


                var db = AppDatabase.getAppDatabase(contextCart)
                arrayNotesTermsList = db.notesDao().getNotes()

                val sb = StringBuilder()

                for ((i, v) in arrayCartList?.withIndex()!!) {
                    if (v.store_details.can_provide_service == "0") {
                        flagCheckManual = true
                    }
                }
                if (flagCheckManual) {
                    holder.couponConstraintCart.visibility = View.GONE
                    holder.layoutCartBetween.visibility = View.GONE
                    holder.tvShoppingFee.visibility = View.VISIBLE
                    holder.tvShoppingRs.visibility = View.VISIBLE
                    holder.ivShoppingFeeInfo.visibility = View.VISIBLE
                } else {
                    holder.couponConstraintCart.visibility = View.VISIBLE
                    holder.layoutCartBetween.visibility = View.VISIBLE
                    holder.tvShoppingFee.visibility = View.GONE
                    holder.tvShoppingRs.visibility = View.GONE
                    holder.ivShoppingFeeInfo.visibility = View.GONE
                }



                for ((i, v) in arrayNotesTermsList?.withIndex()!!) {
                    if (i == 0) {
                        sb.append("- ")
                        sb.append(arrayNotesTermsList?.get(i)?.note).append("\n\n")
                    } else if (i == 1) {
                        if (flagCheckManual) {
                            sb.append("- ")
                            sb.append(arrayNotesTermsList?.get(i)?.note).append("\n\n")
                        } else {

                        }
                    } else {
                        if (flagRecurring) {
                            sb.append("- ")
                            sb.append(arrayNotesTermsList?.get(i)?.note).append("\n\n")
                        }
                    }
                }

                holder.textNotes.text = sb.toString()


            }
        } catch (e: Exception) {

        }
    }

    private fun customiseFunction(
        cart_product_id: Int,
        productId: Int,
        optionId: Int,
        storeId: Int,
        hasAddOns: String,
        arrayAddOnsList: MutableList<AddOns>
    ) {
        customiseCartInvoke?.invoke(
            cart_product_id,
            productId,
            optionId,
            storeId,
            hasAddOns,
            arrayAddOnsList
        )
    }

    private fun updateQuantity(sumQuantity: Int, cart_product_id: Int, position: Int) {
        updateQuantityClickInvoke1?.invoke(
            sumQuantity,
            cart_product_id,
            position
        )
    }

    private fun minusCart(cart_id: Int, cart_product_id: Int, position: Int) {
        minusDeleteFromProductClickInvoke1?.invoke(
            cart_id,
            cart_product_id,
            position
        )
    }

    inner class CartHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {


        var ivStoreLogoRv: ImageView
        var ivCartRemove: ImageView
        var tvStoreNameRv: TextView
        var tvStoreAddressRv: TextView
        var tvStoreDistanceRv: TextView
        var rvProductsCart: RecyclerView
        var firstConstraintCartRv: ConstraintLayout
        var textClosedRv: TextView


        init {
            this.ivStoreLogoRv = itemView.findViewById(R.id.ivStoreLogoRv) as RoundedImageView
            this.tvStoreNameRv = itemView.findViewById(R.id.tvStoreNameRv)
            this.tvStoreAddressRv = itemView.findViewById(R.id.tvStoreAddressRv)
            this.tvStoreDistanceRv = itemView.findViewById(R.id.tvStoreDistanceRv)
            this.textClosedRv = itemView.findViewById(R.id.textClosedRv)
            this.rvProductsCart = itemView.findViewById(R.id.rvProductsCart)
            this.ivCartRemove = itemView.findViewById(R.id.ivCartRemove)
            this.firstConstraintCartRv = itemView.findViewById(R.id.firstConstraintCartRv)



            (rvProductsCart.itemAnimator as SimpleItemAnimator).supportsChangeAnimations = false
            ivCartRemove.setOnClickListener {

                cartRemoveClickInvoke?.invoke(
                    arrayCartList?.get(adapterPosition)?.cart_id!!,
                    adapterPosition
                )
            }

            ivStoreLogoRv.setOnClickListener {
                if (arrayCartList?.get(adapterPosition)?.store_details?.user_store_id!!.toInt() == ConstantUtils.ZERO) {

                    if (arrayCartList?.get(adapterPosition)?.store_details?.can_provide_service!!.toInt() == ConstantUtils.ONE) {
                        storeProductIntent?.invoke(adapterPosition)
                    } else {
                        storeWithoutProductIntent?.invoke(adapterPosition)
                    }

                }
            }

            firstConstraintCartRv.setOnClickListener {

                if (arrayCartList?.get(adapterPosition)?.store_details?.user_store_id!!.toInt() == ConstantUtils.ZERO) {

                    if (arrayCartList?.get(adapterPosition)?.store_details?.can_provide_service!!.toInt() == ConstantUtils.ONE) {
                        storeProductIntent?.invoke(adapterPosition)
                    } else {
                        storeWithoutProductIntent?.invoke(adapterPosition)
                    }

                }
            }
            itemView.setOnClickListener {


            }
        }

        fun checkOpenOrCloseShop(positionMain: Int) {

            checkTimeStatus = false
            toGrayScaleImage()

            if (!arrayCartList?.get(positionMain)?.store_details?.schedule.isNullOrEmpty()) {

                for ((index, value) in arrayCartList?.get(positionMain)?.store_details?.schedule?.withIndex()!!) {
                    if (currentDay == arrayCartList?.get(positionMain)?.store_details?.schedule?.get(
                            index
                        )!!.weekday
                    ) {
                        openingTime =
                            arrayCartList?.get(positionMain)?.store_details?.schedule?.get(index)!!.opening_time
                        closingTime =
                            arrayCartList?.get(positionMain)?.store_details?.schedule?.get(index)!!.closing_time
                        var openingConvertTime: String? = null
                        var closingConvertTime: String? = null

                        if (openingTime.isNullOrEmpty() && closingTime.isNullOrEmpty()) {
                            Log.e("---1checkTimeStatus--", "------------" + checkTimeStatus)
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
                                Log.e("---1checkTimeStatus13--", "------------" + checkTimeStatus)
                                toGrayScaleImage()
                            } else {
                                notGreyScale()
                            }
                        }
                    }
                }
            } else {
                checkTimeStatus = true
                notGreyScale()
            }


            checkStoreOpenInvoke?.invoke(checkTimeStatus!!)

        }

        private fun toGrayScaleImage() {

            val matrix = ColorMatrix()
            matrix.setSaturation(0f)
            val cf = ColorMatrixColorFilter(matrix)
            ivStoreLogoRv.colorFilter = cf
            textClosedRv.visibility = View.VISIBLE
        }

        private fun notGreyScale() {
            ivStoreLogoRv.colorFilter = null
            textClosedRv.visibility = View.GONE
        }

    }

    inner class ExtraItemHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {

        var tvRsRv: TextView
        var textNotes: TextView
        var tvFreeRv: TextView
        var tvPayRsRv: TextView
        var tvChangeDateTimeRv: TextView
        var ivClearRv: ImageView

        //  var ivDeliverNowRv: ImageView
        var ivAdvanceOrderRv: ImageView
        var editNoteRv: EditText
        var chCartNotes: CheckBox
        var constraintCheckRv2: ConstraintLayout
        var couponDetailsConstraint: ConstraintLayout
        var couponConstraintCart: ConstraintLayout
        var layoutCartBetween: LinearLayout
        var tvCouponCart: TextView
        var tvMaxSaveCart: TextView
        var tvOrderDiscountRs: TextView
        var tvCouponDiscountFee: TextView
        var tvShoppingFee: TextView
        var tvShoppingRs: TextView
        var tvDeliveryFeeRs: TextView
        var ivStoreChargeInfo: ImageView
        var ivShoppingFeeInfo: ImageView
        var ivDeliveryFeeInfo: ImageView
        var constViewAllDrivers: ConstraintLayout
        var radioStandard: RadioButton
        var radioExpress: RadioButton

        init {

            this.tvRsRv = itemView.findViewById(R.id.tvRsRv)
            this.tvFreeRv = itemView.findViewById(R.id.tvFreeRv)
            this.tvPayRsRv = itemView.findViewById(R.id.tvPayRsRv)
            this.ivClearRv = itemView.findViewById(R.id.ivClearRv)
            this.editNoteRv = itemView.findViewById(R.id.editNoteRv)
            // this.ivDeliverNowRv = itemView.findViewById(R.id.ivDeliverNowRv)
            this.ivAdvanceOrderRv = itemView.findViewById(R.id.ivAdvanceOrderRv)
            this.tvChangeDateTimeRv = itemView.findViewById(R.id.tvChangeDateTimeRv)
            this.constraintCheckRv2 = itemView.findViewById(R.id.constraintCheckRv2)
            this.chCartNotes = itemView.findViewById(R.id.chCartNotes)
            this.textNotes = itemView.findViewById(R.id.textNotes)
            this.tvCouponCart = itemView.findViewById(R.id.tvCouponCart)
            this.couponDetailsConstraint = itemView.findViewById(R.id.couponDetailsConstraint)
            tvMaxSaveCart = itemView.findViewById(R.id.tvMaxSaveCart)
            tvOrderDiscountRs = itemView.findViewById(R.id.tvOrderDiscountRs)
            tvCouponDiscountFee = itemView.findViewById(R.id.tvCouponDiscountFee)
            couponConstraintCart = itemView.findViewById(R.id.couponConstraintCart)
            layoutCartBetween = itemView.findViewById(R.id.layoutCartBetween)
            ivStoreChargeInfo = itemView.findViewById(R.id.ivStoreChargeInfo)
            ivShoppingFeeInfo = itemView.findViewById(R.id.ivShoppingFeeInfo)
            ivDeliveryFeeInfo = itemView.findViewById(R.id.ivDeliveryFeeInfo)
            tvShoppingFee = itemView.findViewById(R.id.tvShoppingFee)
            tvShoppingRs = itemView.findViewById(R.id.tvShoppingRs)
            tvDeliveryFeeRs = itemView.findViewById(R.id.tvDeliveryFeeRs)
            constViewAllDrivers = itemView.findViewById(R.id.constViewAllDrivers)
            radioStandard = itemView.findViewById(R.id.radioStandard)
            radioExpress = itemView.findViewById(R.id.radioExpress)


            couponConstraintCart.setOnClickListener {
                setCouponCartInvoke?.invoke(it, amountDetails?.total_items_price!!, couponCodeMain)
            }

            textNotes.setOnClickListener {

            }

            editNoteRv.addTextChangedListener(object : TextWatcher {
                override fun afterTextChanged(s: Editable?) {
                    if (s.isNullOrBlank()) {
                        stringNote = ""
                    } else {
                        stringNote = s.toString()
                    }

                }

                override fun beforeTextChanged(
                    s: CharSequence?,
                    start: Int,
                    count: Int,
                    after: Int
                ) {

                }

                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

                }
            })

            ivClearRv.setOnClickListener {
                editNoteRv.setText("")
            }

            ivStoreChargeInfo.setOnClickListener {
                showAlertChragesInvoke?.invoke(
                    contextCart.resources.getString(R.string.storeChargeTitle),
                    contextCart.resources.getString(R.string.storeAlertMessage)
                )
            }

            ivShoppingFeeInfo.setOnClickListener {
                showAlertChragesInvoke?.invoke(
                    contextCart.resources.getString(R.string.shoppingChargeTitle),
                    contextCart.resources.getString(R.string.shoppingFeeAlertMessage)
                )
            }

            ivDeliveryFeeInfo.setOnClickListener {
                showAlertChragesInvoke?.invoke(
                    contextCart.resources.getString(R.string.deliveryChargeTitle),
                    contextCart.resources.getString(R.string.deliveryFeeAlertMessage)
                )
            }
//
//            ivDeliverNowRv.setOnClickListener {
//
//                ivDeliverNowRv.setImageResource(R.drawable.ic_done_press)
//                ivAdvanceOrderRv.setImageResource(R.drawable.ic_done_unpress)
//                val tz = TimeZone.getDefault().displayName
//                Toast.makeText(contextCart, tz, Toast.LENGTH_SHORT).show()
//
//            }
//            ivAdvanceOrderRv.setOnClickListener {
//                ivDeliverNowRv.setImageResource(R.drawable.ic_done_unpress)
//                ivAdvanceOrderRv.setImageResource(R.drawable.ic_done_press)
//                val tz = TimeZone.getDefault().displayName
//                Toast.makeText(contextCart, tz, Toast.LENGTH_SHORT).show()
//            }

            constraintCheckRv2.setOnClickListener {
                setRecurringInvoke?.invoke(it)
            }

            chCartNotes.setOnCheckedChangeListener { buttonView, isChecked ->
                isCheckInvoke?.invoke(isChecked)
            }

            constViewAllDrivers.setOnClickListener {
                viewAllNearDriversInvoke?.invoke(adapterPosition)
            }

            radioStandard.setOnClickListener {
                radioExpress.isChecked = false
                standardRadioInvoke?.invoke(adapterPosition)
            }

            radioExpress.setOnClickListener {
                radioStandard.isChecked = false
                expressRadioInvoke?.invoke(adapterPosition)
            }
        }
    }

    fun couponSetData(saveMaxRs: String, couponCode: String) {
        flagRecurring = true
        saveMaxRsStringMain = saveMaxRs
        couponCodeMain = couponCode
        notifyDataSetChanged()
    }

    fun setFlag() {
        flagRecurring = true
    }


    fun removeProduct(position: Int) {
        arrayProductCartList?.removeAt(position)
        cartProductAdapter?.notifyDataSetChanged()
    }

    fun setAllDetails(amountDetails1: AmountDetails) {
        amountDetails = amountDetails1
        notifyDataSetChanged()
    }


}