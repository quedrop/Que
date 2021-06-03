package com.quedrop.customer.base.extentions

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.view.View
import androidx.annotation.RequiresApi
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelProviders
import com.google.android.material.snackbar.Snackbar
import com.quedrop.customer.R
import com.quedrop.customer.base.view.ActivityManager

fun androidx.fragment.app.Fragment.startActivityWithDefaultAnimations(intent: Intent) {
    activity?.startActivityWithDefaultAnimations(intent)
}

fun androidx.fragment.app.Fragment.startActivityForResultWithDefaultAnimations(intent: Intent, requestCode: Int) {
    startActivityForResult(intent, requestCode)
    activity?.overridePendingTransition(R.anim.activity_move_in_from_right, R.anim.activity_move_out_to_left)
}

fun androidx.fragment.app.Fragment.startActivityForResultWithBottomInAnimation(intent: Intent, requestCode: Int) {
    startActivityForResult(intent, requestCode)
    activity?.overridePendingTransition(R.anim.activity_move_in_from_bottom, R.anim.default_exit)
}

fun androidx.fragment.app.Fragment.startActivityWithBottomInAnimation(intent: Intent) {
    activity?.startActivityWithBottomInAnimation(intent)
}

@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
fun androidx.fragment.app.Fragment.startActivityWithSharedElementTransition(intent: Intent, sharedElement: View) {
    activity?.startActivityWithSharedElementTransition(intent, sharedElement)
}

fun androidx.fragment.app.Fragment.buildSnackBar(rootView: View,
                                                 message: String,
                                                 snackBarLength: Int = com.google.android.material.snackbar.Snackbar.LENGTH_LONG,
                                                 snackBarTextColor: Int = Color.WHITE): Snackbar? {
    return activity?.buildSnackBar(rootView, message, snackBarLength, snackBarTextColor)
}

fun androidx.fragment.app.Fragment.safeLaunch(safeLaunch: (activity: Activity) -> Unit) {
    val activity = ActivityManager.getInstance().foregroundActivity
    fragmentManager?.executePendingTransactions()
    if (activity != null && isAdded) {
        safeLaunch(activity)
    }
}

inline fun <reified T : ViewModel> androidx.fragment.app.Fragment.getViewModel(
        crossinline factory: () -> T
): T {
    return createViewModel(factory)
}

@Suppress("UNCHECKED_CAST")
inline fun <reified T : ViewModel> androidx.fragment.app.Fragment.createViewModel(crossinline factory: () -> T): T {

    val vmFactory = object : ViewModelProvider.Factory {
        override fun <U : ViewModel> create(modelClass: Class<U>): U = factory() as U
    }

    return ViewModelProviders.of(this, vmFactory)[T::class.java]
}