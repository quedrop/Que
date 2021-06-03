package com.quedrop.driver.ui.settings.adapter

import android.graphics.Canvas
import android.util.Log
import android.view.View
import androidx.recyclerview.widget.ItemTouchHelper

internal class ItemControlHelper(
    recyclerView: androidx.recyclerview.widget.RecyclerView,
    private val controlInterface: ItemControlInterface,
    private val vertical: Boolean
) : ItemTouchHelper.Callback() {
    private var flagDragFromStart: Int = 0
    private var flagDragFromEnd: Int = 0
    private var flagSwipeFromStart: Int = 0
    private var flagSwipeFromEnd: Int = 0
    // For swiping
    private var flags: Int = 0
    private var swipingViewHolder: androidx.recyclerview.widget.RecyclerView.ViewHolder? = null
    private var swipingView: View? = null
    private var controlView: View? = null
    private var pullControls: Boolean = false
    private var swipingFromStart: Boolean = false
    private var controlSize: Float = 0.toFloat()
    private var xLeft: Float = 0.toFloat()
    private var xLeftTarget: Float = 0.toFloat()
    private var animationProportionAndSign: Float = 0.toFloat()
    private var dXOld: Float = 0.toFloat()

    internal interface ItemControlInterface {
        fun getItemMovementFlags(position: Int): Int

        fun getSwipeAndControlViews(
            swipeAndControlViews: Array<View?>,
            viewHolder: androidx.recyclerview.widget.RecyclerView.ViewHolder,
            fromStart: Boolean
        ): Boolean

        fun onItemDragged(position: Int, toPosition: Int): Boolean
    }

    init {
        if (vertical) {
            flagDragFromStart = ItemTouchHelper.DOWN
            flagDragFromEnd = ItemTouchHelper.UP
            flagSwipeFromStart = ItemTouchHelper.RIGHT
            flagSwipeFromEnd = ItemTouchHelper.LEFT
        } else {
            flagDragFromStart = ItemTouchHelper.RIGHT
            flagDragFromEnd = ItemTouchHelper.LEFT
            flagSwipeFromStart = ItemTouchHelper.DOWN
            flagSwipeFromEnd = ItemTouchHelper.UP
        }
        ItemTouchHelper(this).attachToRecyclerView(recyclerView)
        recyclerView.addOnScrollListener(object :
            androidx.recyclerview.widget.RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(
                recyclerView: androidx.recyclerview.widget.RecyclerView,
                newState: Int
            ) {
                if (swipingViewHolder != null && newState == androidx.recyclerview.widget.RecyclerView.SCROLL_STATE_DRAGGING)
                    finishSwiping()
            }
        })
    }

    fun finishSwiping() {
        finishDrawingSwiping()
        controlView = null
        swipingView = null
        swipingViewHolder = null
        if (DEBUG) Log.d(TAG, "Control CLOSED")
    }

    override fun onMove(
        recyclerView: androidx.recyclerview.widget.RecyclerView,
        viewHolder: androidx.recyclerview.widget.RecyclerView.ViewHolder,
        target: androidx.recyclerview.widget.RecyclerView.ViewHolder
    ): Boolean {
        if (DEBUG)
            Log.d(
                TAG,
                "onMove() from: " + viewHolder.adapterPosition + " to: " + target.adapterPosition
            )
        val from = viewHolder.adapterPosition
        val to = target.adapterPosition
        return from != -1 && to != -1 && to != from && controlInterface.onItemDragged(from, to)
    }

    /**
     * Off swipe threshold
     */
    override fun getSwipeThreshold(viewHolder: androidx.recyclerview.widget.RecyclerView.ViewHolder): Float {
        return java.lang.Float.MAX_VALUE
    }

    /**
     * Off swipe velocity
     */
    override fun getSwipeEscapeVelocity(defaultValue: Float): Float {
        return java.lang.Float.MAX_VALUE
    }

    /**
     * Swipe always Off
     */
    override fun onSwiped(
        viewHolder: androidx.recyclerview.widget.RecyclerView.ViewHolder,
        direction: Int
    ) {
    }

    override fun getMovementFlags(
        recyclerView: androidx.recyclerview.widget.RecyclerView,
        viewHolder: androidx.recyclerview.widget.RecyclerView.ViewHolder
    ): Int {
        if (DEBUG) Log.d(TAG, "getMovementFlags() on position: " + viewHolder.adapterPosition)
        if (viewHolder.adapterPosition == -1) return 0
        if (swipingViewHolder != null && viewHolder !== swipingViewHolder) finishSwiping()
        var dragFlags = 0
        var swipeFlags = 0
        if (viewHolder === swipingViewHolder)
            swipeFlags = flagSwipeFromStart or flagSwipeFromEnd
        else {
            flags = controlInterface.getItemMovementFlags(viewHolder.adapterPosition)
            if (flags and DRAG_FROM_START != 0) dragFlags = dragFlags or flagDragFromStart
            if (flags and DRAG_FROM_END != 0) dragFlags = dragFlags or flagDragFromEnd
            if (flags and SWIPE_FROM_START != 0) swipeFlags = swipeFlags or flagSwipeFromStart
            if (flags and SWIPE_FROM_END != 0) swipeFlags = swipeFlags or flagSwipeFromEnd
        }
        return ItemTouchHelper.Callback.makeMovementFlags(dragFlags, swipeFlags)
    }

    override fun onChildDraw(
        c: Canvas,
        recyclerView: androidx.recyclerview.widget.RecyclerView,
        viewHolder: androidx.recyclerview.widget.RecyclerView.ViewHolder,
        dX: Float,
        dY: Float,
        actionState: Int,
        isCurrentlyActive: Boolean
    ) {
        var dX = dX
        if (DEBUG)
            Log.d(
                TAG,
                "onChildDraw() isCurrentlyActive: $isCurrentlyActive actionState: $actionState dX: $dX dY: $dY"
            )

        if (actionState != ItemTouchHelper.ACTION_STATE_SWIPE) { // Not swiping
            super.onChildDraw(c, recyclerView, viewHolder, dX, dY, actionState, isCurrentlyActive)
            return
        }

        // Swiping

        if (viewHolder == null || viewHolder.adapterPosition == -1) return

        if (swipingViewHolder != null && viewHolder !== swipingViewHolder)
            return  // Another viewHolder

        dX = if (vertical) dX else dY

        if (isCurrentlyActive) { // Swipe manually

            if (swipingViewHolder == null) { // First touch
                if (dX == 0f) return  // While direction undetected
                startSwiping(viewHolder, dX)
                dXOld = 0f
                xLeft = dXOld
            }

            xLeft += dX - dXOld

            if (swipingFromStart && xLeft < 0f || !swipingFromStart && xLeft > 0f) { // Direction changed
                finishSwiping()
                startSwiping(viewHolder, xLeft)
            }

            if (Math.abs(xLeft) > controlSize * .5f)
            // Opened > 50% of controlView
                xLeftTarget = if (swipingFromStart) controlSize else -controlSize
            else
                xLeftTarget = 0f

            // To automatically open the controlView, use a simple proportion,
            // although this changes the speed of the animation
            if (dX != 0f) animationProportionAndSign = (xLeft - xLeftTarget) / dX

        } else { // Swipe animation

            if (dX == 0f)
                xLeft = xLeftTarget
            else
                xLeft += (dX - dXOld) * animationProportionAndSign

        }

        dXOld = dX

        if (xLeft == 0f && swipingViewHolder != null)
            finishSwiping() // Now controlView fully closed
        else
            drawSwiping(xLeft)
    }

    private fun startSwiping(
        viewHolder: androidx.recyclerview.widget.RecyclerView.ViewHolder,
        dX: Float
    ) {
        swipingViewHolder = viewHolder
        swipingFromStart = dX > 0f
        val swipeAndControlViews = arrayOfNulls<View>(2)
        if (swipingFromStart && flags and SWIPE_FROM_START != 0 || !swipingFromStart && flags and SWIPE_FROM_END != 0)
            pullControls = controlInterface.getSwipeAndControlViews(
                swipeAndControlViews,
                viewHolder,
                swipingFromStart
            )
        swipingView = swipeAndControlViews[0]
        controlView = swipeAndControlViews[1]
        prepareDrawingSwiping()
        if (DEBUG) Log.d(TAG, "Control OPENED from " + if (swipingFromStart) "START" else "END")
    }

    /**
     * Good place for experiments with animation
     */

    private fun prepareDrawingSwiping() {
        if (controlView != null) {
            controlView!!.visibility = View.VISIBLE
            controlSize = (if (vertical) controlView!!.width else controlView!!.height).toFloat()
        } else
            controlSize = java.lang.Float.MAX_VALUE
    }

    private fun drawSwiping(x: Float) {
        if (swipingView != null) {
            if (vertical)
                swipingView!!.translationX = x
            else
                swipingView!!.translationY = x
        }
        if (controlView != null && pullControls) {
            val size = if (swipingFromStart) -controlSize else controlSize
            if (vertical)
                controlView!!.translationX = size + x
            else
                controlView!!.translationY = size + x
        }
    }

    private fun finishDrawingSwiping() {
        if (controlView != null) {
            if (pullControls) {
                if (vertical)
                    controlView!!.translationX = 0f
                else
                    controlView!!.translationY = 0f
            }
            controlView!!.visibility = View.INVISIBLE
        }
        if (swipingView != null) {
            if (vertical)
                swipingView!!.translationX = 0f
            else
                swipingView!!.translationY = 0f
        }
    }

    companion object {
        val DRAG_FROM_START = 1
        val DRAG_FROM_END = 2
        val SWIPE_FROM_START = 4
        val SWIPE_FROM_END = 8

        private val DEBUG = false
        private val TAG = "__ItemControlHelper"
    }
}
