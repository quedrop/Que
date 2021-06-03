package com.quedrop.customer.ui.cart.view.timepicker

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Paint.Align
import android.graphics.Paint.Style
import android.os.Handler
import android.os.Message
import android.text.TextUtils
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.View

import java.util.ArrayList
import java.util.Timer
import java.util.TimerTask


@SuppressLint("ClickableViewAccessibility")
class PickerView : View {

    private var isInit = false
    private var requestCode = 0
    private val txtColor = 0x333333
//    var height:Int = 0
//    var width:Int = 0
    private var curSelectedPos: Int = 0
    private var lastDownY: Float = 0.toFloat()
    private var moveDistance = 0f
    private var maxTxtSize = 80f
    private var minTxtSize = 40f
    private var maxTxtAlpha = 255f
    private val minTxtAlpha = 120f
    private var mDataList: MutableList<PickerItem>? = null
    private var mPaint: Paint? = null
    private var mTimer: Timer? = null
    private var mTask: MyTimerTask? = null
    private var mListener: OnPickedListener? = null

    @SuppressLint("HandlerLeak")
    private val updateHandler = object : Handler() {

        override fun handleMessage(msg: Message) {

            if (Math.abs(moveDistance) < SPEED) {

                moveDistance = 0f

                if (null != mTask) {

                    mTask!!.cancel()
                    mTask = null
                    performSelect()
                }
            } else {

                // 这里moveDistance /
                // Math.abs(moveDistance)是为了保有moveDistance的正负号，以实现上滚或下滚
                moveDistance = moveDistance - moveDistance / Math.abs(moveDistance) * SPEED
            }

            invalidate()
        }
    }

    constructor(context: Context) : super(context) {

        init()
    }

    constructor(context: Context, attrs: AttributeSet) : super(context, attrs) {

        init()
    }


    private fun init() {

        mTimer = Timer()
        mDataList = ArrayList()
        mPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        mPaint!!.style = Style.FILL
        mPaint!!.textAlign = Align.CENTER
        mPaint!!.color = txtColor
    }


    fun setRequestCode(reqCode: Int) {

        this.requestCode = reqCode
    }


    fun setOnPickedListener(listener: OnPickedListener) {

        mListener = listener
    }


    private fun performSelect() {

        if (null != mListener && curSelectedPos >= 0
            && curSelectedPos < mDataList!!.size
        )
            mListener!!.onPicked(requestCode, mDataList!![curSelectedPos])
    }


    fun setMaxTextAlpha(alpha: Int) {
        if (alpha > 0 && alpha <= 255) {
            maxTxtAlpha = alpha.toFloat()
            invalidate()
        }
    }


    fun setMinTextAlpha(alpha: Int) {
        if (alpha > 0) {
            minTxtSize = alpha.toFloat()
            invalidate()
        }
    }


    fun setTextColor(textColor: Int) {
        mPaint!!.color = textColor
        invalidate()
    }


    fun setData(datas: MutableList<PickerItem>?) {

        val size = datas?.size ?: 0

        if (size == 0)
            return

        mDataList = datas
        curSelectedPos = size / 2

        invalidate()
    }


    fun setSelected(selected: Int) {

        curSelectedPos = selected

        val distance = mDataList!!.size / 2 - curSelectedPos

        if (distance < 0) {

            for (i in 0 until -distance) {

                moveHeadToTail()
                curSelectedPos--
            }
        } else if (distance > 0) {

            for (i in 0 until distance) {

                moveTailToHead()
                curSelectedPos++
            }
        }

        invalidate()
    }


    private fun moveHeadToTail() {

        val head = mDataList!![0]

        mDataList!!.removeAt(0)
        mDataList!!.add(head)
    }


    private fun moveTailToHead() {

        val tail = mDataList!![mDataList!!.size - 1]

        mDataList!!.removeAt(mDataList!!.size - 1)
        mDataList!!.add(0, tail)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {

        super.onMeasure(widthMeasureSpec, heightMeasureSpec)

        var height = measuredHeight
        var width = measuredWidth
        maxTxtSize = height / 4.0f
        minTxtSize = maxTxtSize / 2f
        isInit = true

        invalidate()
    }

    override fun onDraw(canvas: Canvas) {

        super.onDraw(canvas)


        if (isInit)
            drawData(canvas)
    }


    private fun drawData(canvas: Canvas) {

        if (curSelectedPos < 0 || null == mDataList
            || curSelectedPos >= mDataList!!.size
        )
            return


        val scale = parabola(height / 4.0f, moveDistance)
        val size = (maxTxtSize - minTxtSize) * scale + minTxtSize
        mPaint!!.textSize = size
        mPaint!!.alpha = ((maxTxtAlpha - minTxtAlpha) * scale + minTxtAlpha).toInt()
        val x = (width / 2.0).toFloat()
        val y = (height / 2.0 + moveDistance).toFloat()
        val fmi = mPaint!!.fontMetricsInt
        val baseline = (y - (fmi.bottom / 2.0 + fmi.top / 2.0)).toFloat()
        val text = mDataList!![curSelectedPos].text

        canvas.drawText(formatText(text, size), x, baseline, mPaint!!)

        run {
            var i = 1
            while (curSelectedPos - i >= 0) {

                drawOtherText(canvas, i, -1)
                i++
            }
        }


        var i = 1
        while (curSelectedPos + i < mDataList!!.size) {

            drawOtherText(canvas, i, 1)
            i++
        }
    }


    private fun drawOtherText(canvas: Canvas, position: Int, type: Int) {

        val d = MARGIN_ALPHA * minTxtSize * position.toFloat() + type * moveDistance
        val scale = parabola(height / 4.0f, d)
        val size = (maxTxtSize - minTxtSize) * scale + minTxtSize
        mPaint!!.textSize = size
        mPaint!!.alpha = ((maxTxtAlpha - minTxtAlpha) * scale + minTxtAlpha).toInt()
        val y = (height / 2.0 + type * d).toFloat()
        val fmi = mPaint!!.fontMetricsInt
        val baseline = (y - (fmi.bottom / 2.0 + fmi.top / 2.0)).toFloat()
        val text = mDataList!![curSelectedPos + type * position].text

        canvas.drawText(
            formatText(text, size), (width / 2.0).toFloat(),
            baseline, mPaint!!
        )
    }


    private fun parabola(zero: Float, x: Float): Float {

        val f = (1 - Math.pow((x / zero).toDouble(), 2.0)).toFloat()

        return if (f < 0) 0f else f
    }


    private fun formatText(text: String?, size: Float): String {

        if (null == text)
            return ""

        if (TextUtils.isDigitsOnly(text)) {

            return text
        } else {

            if (size * text.length > width) {

                val maxLen = (width / size).toInt()

                return text.substring(0, maxLen - 1) + "..."
            }
        }

        return text
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {

        if (null == mDataList || mDataList!!.isEmpty())
            return true

        when (event.actionMasked) {

            MotionEvent.ACTION_DOWN -> doDown(event)
            MotionEvent.ACTION_MOVE -> doMove(event)
            MotionEvent.ACTION_UP -> doUp(event)
        }

        return true
    }


    private fun doDown(event: MotionEvent) {

        if (mTask != null) {

            mTask!!.cancel()
            mTask = null
        }

        lastDownY = event.y
    }


    private fun doMove(event: MotionEvent) {

        moveDistance += event.y - lastDownY

        if (moveDistance > MARGIN_ALPHA * minTxtSize / 2) {

            moveTailToHead()
            moveDistance = moveDistance - MARGIN_ALPHA * minTxtSize
        } else if (moveDistance < -MARGIN_ALPHA * minTxtSize / 2) {

            moveHeadToTail()
            moveDistance = moveDistance + MARGIN_ALPHA * minTxtSize
        }

        lastDownY = event.y

        invalidate()
    }


    private fun doUp(event: MotionEvent) {


        if (Math.abs(moveDistance) < 0.0001) {

            moveDistance = 0f
            return
        }

        if (null != mTask) {

            mTask!!.cancel()
            mTask = null
        }

        mTask = MyTimerTask(updateHandler)
        mTimer!!.schedule(mTask, 0, 10)
    }


    internal inner class MyTimerTask(var handler: Handler) : TimerTask() {

        override fun run() {

            handler.sendMessage(handler.obtainMessage())
        }
    }


    interface OnPickedListener {


        fun onPicked(pickerId: Int, item: PickerItem)
    }

    companion object {

        val TAG = "PickerView"


        val MARGIN_ALPHA = 1.5f

        val SPEED = 2f
    }
}
