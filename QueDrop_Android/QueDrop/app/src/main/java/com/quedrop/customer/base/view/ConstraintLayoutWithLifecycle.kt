package com.quedrop.customer.base.view

import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.fragment.app.Fragment
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable

abstract class ConstraintLayoutWithLifecycle(context: Context) : ConstraintLayout(context), LifecycleObserver {
    protected val compositeDisposable = CompositeDisposable()

    init {
        when (context) {
            is AppCompatActivity -> context.lifecycle.addObserver(this)
            is Fragment -> context.lifecycle.addObserver(this)
            else -> throw Exception("Parent was not a lifecycle owner")
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    open fun onDestroy() {
        compositeDisposable.clear()
    }

    protected fun Disposable.autoDispose() {
        compositeDisposable.add(this)
    }
}