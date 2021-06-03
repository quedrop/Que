package com.quedrop.customer.ui.cart.view.timepicker

import android.content.Context
import android.graphics.drawable.BitmapDrawable
import android.util.DisplayMetrics
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.PopupWindow


import com.quedrop.customer.R

import java.util.ArrayList
import java.util.Calendar
import android.view.WindowManager
import android.util.TypedValue


class TimePickerPopWin(builder: Builder) : PopupWindow() {


    private var hourLoopView: LoopView? = null
    private var minuteLoopView: LoopView? = null
    private var meridianLoopView: LoopView? = null
    private var pickerContainerV: View? = null


    private var hourPos = 0
    private var minutePos = 0
    private var meridianPos = 0
    var widthPixel:Int = 0
    var heightPixel:Int = 0

    private val mContext: Context


    internal var hourList: MutableList<String> = ArrayList()
    internal var minList: MutableList<String> = ArrayList()
    internal var meridianList: MutableList<String> = ArrayList()

    private val mListener: OnTimePickListener?


    class Builder(val context: Context, val listener: OnTimePickListener) {

        fun build(): TimePickerPopWin {
            return TimePickerPopWin(this)
        }
    }

    init {

        this.mContext = builder.context
        this.mListener = builder.listener

        val displayMetrics = DisplayMetrics()
        var wm = mContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        wm.defaultDisplay.getMetrics(displayMetrics)

        widthPixel = displayMetrics.widthPixels
        heightPixel = displayMetrics.heightPixels

        initView()
    }

    private fun initView() {



        var contentView =
            LayoutInflater.from(mContext).inflate(R.layout.layout_time_picker, null) as View
        hourLoopView = contentView.findViewById<View>(R.id.picker_hour) as LoopView
        minuteLoopView = contentView.findViewById<View>(R.id.picker_minute) as LoopView
        meridianLoopView = contentView.findViewById<View>(R.id.picker_meridian) as LoopView
        pickerContainerV = contentView.findViewById(R.id.container_picker)
        initPickerViews()

        hourLoopView!!.setLoopListener(object : LoopScrollListener {
            override fun onItemSelect(item: Int) {

                hourPos = item
                if (null != mListener) {
                    val amPm = meridianList[meridianPos]

                    val sb = StringBuffer()
                    sb.append(hourList[hourPos])
                    mListener.onTimePickCompleted(hourPos + 1, minutePos, amPm, sb.toString())
                }
            }
        })

        minuteLoopView!!.setLoopListener(object : LoopScrollListener {
            override fun onItemSelect(item: Int) {

                minutePos = item
                if (null != mListener) {
                    val amPm = meridianList[meridianPos]
                    val sb = StringBuffer()
                    sb.append(minList[minutePos])
                    mListener.onTimePickCompleted(hourPos + 1, minutePos, amPm, sb.toString())
                }

            }
        })

        meridianLoopView!!.setLoopListener(object : LoopScrollListener {
            override fun onItemSelect(item: Int) {

                meridianPos = item
                if (null != mListener) {
                    val amPm = meridianList[meridianPos]

                    val sb = StringBuffer()
                    sb.append(amPm)
                    mListener.onTimePickCompleted(hourPos + 1, minutePos, amPm, sb.toString())
                }
            }
        })



         // init hour and minute loop view


//        cancelBtn!!.setOnClickListener(this)
//        confirmBtn!!.setOnClickListener(this)
//        contentView!!.setOnClickListener(this)

//        if (!TextUtils.isEmpty(textConfirm)) {
//            confirmBtn!!.text = textConfirm
//        }
//
//        if (!TextUtils.isEmpty(textCancel)) {
//            cancelBtn!!.text = textCancel
//        }


        setBackgroundDrawable(BitmapDrawable())
        animationStyle = R.style.FadeInPopWin
        setContentView(contentView)
        width = ViewGroup.LayoutParams.MATCH_PARENT
        height = ViewGroup.LayoutParams.WRAP_CONTENT
    }

    private fun initPickerViews() {

        hourPos = Calendar.getInstance().get(Calendar.HOUR)
        minutePos = Calendar.getInstance().get(Calendar.MINUTE)
        meridianPos = Calendar.getInstance().get(Calendar.AM_PM)

        for (i in 1..12) {
//            hourPos=i
            hourList.add(format2LenStr(i))
        }

        for (j in 0..59) {
//            minutePos = j
            minList.add(format2LenStr(j))
        }

        meridianList.add("AM")
        meridianList.add("PM")

        hourLoopView!!.setDataList(hourList)
        hourLoopView!!.setInitPosition(hourPos)

        minuteLoopView!!.setDataList(minList)
        minuteLoopView!!.setInitPosition(minutePos)

        meridianLoopView!!.setDataList(meridianList)
        meridianLoopView!!.setInitPosition(meridianPos)
    }


//    override fun onClick(v: View) {
//
//        if (v === contentView || v === cancelBtn) {
////            dismissPopWin()
//        } else if (v === confirmBtn) {
//
//            if (null != mListener) {
//                val amPm = meridianList[meridianPos]
//
//                val sb = StringBuffer()
//                sb.append(hourList[hourPos])
//                sb.append(":")
//                sb.append(minList[minutePos])
//                sb.append(amPm)
//                mListener.onTimePickCompleted(hourPos + 1, minutePos, amPm, sb.toString())
//            }
////            dismissPopWin()
//        }
//    }


    fun showPopWin(view: View?) {

        if (null != view) {

            var actionBarHeight:Int = 0

            val tv = TypedValue()
            if (mContext.getTheme().resolveAttribute(android.R.attr.actionBarSize, tv, true)) {
                actionBarHeight = TypedValue.complexToDimensionPixelSize(
                    tv.data,mContext.resources.getDisplayMetrics()
                )
            }

            view.post {
                showAtLocation(
                    view, Gravity.TOP,
                    0, actionBarHeight+60
                )
            }

            Log.e("actionBarHeight","---"+actionBarHeight.toFloat()).toInt()
        }
    }

    fun convertDipToPixels(dips: Float): Float {
        return dips * mContext.resources.displayMetrics.density + 0.5f
    }


//    fun dismissPopWin() {
//
//        val trans = TranslateAnimation(
//            Animation.RELATIVE_TO_SELF, 0f, Animation.RELATIVE_TO_SELF, 0f,
//            Animation.RELATIVE_TO_SELF, 0f, Animation.RELATIVE_TO_SELF, 1f
//        )
//
//        trans.duration = 400
//        trans.interpolator = AccelerateInterpolator()
//        trans.setAnimationListener(object : Animation.AnimationListener {
//
//            override fun onAnimationStart(animation: Animation) {
//
//            }
//
//            override fun onAnimationRepeat(animation: Animation) {}
//
//            override fun onAnimationEnd(animation: Animation) {
//
//                dismiss()
//            }
//        })
//
//        pickerContainerV!!.startAnimation(trans)
//    }

    interface OnTimePickListener {


        fun onTimePickCompleted(hour: Int, minute: Int, AM_PM: String, time: String)
    }

    companion object {


        fun format2LenStr(num: Int): String {

            return if (num < 10) "0$num" else num.toString()
        }
    }
}
