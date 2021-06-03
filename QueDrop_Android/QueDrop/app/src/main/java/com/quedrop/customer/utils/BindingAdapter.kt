package com.quedrop.customer.utils

import android.util.Log
import android.widget.TextView
import androidx.databinding.BindingAdapter
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
import com.quedrop.customer.extension.getParentActivity

object AppBindAdapter{
    @BindingAdapter("timeValue")
    @JvmStatic
    fun setTimeValue(view: TextView, timerValue: MutableLiveData<Long>) {

        val parentActivity = view.getParentActivity()

        timerValue.observe(parentActivity!!, Observer {
            Log.e("tagTime",timerValue.value.toString())
            Log.e("tagTime",timerValue.toString())
            view.text = Utils.msToString(it)

        })

    }
}


