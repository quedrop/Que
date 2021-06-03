package com.quedrop.customer.base

import android.annotation.SuppressLint
import android.content.Context
import androidx.multidex.MultiDex
import com.quedrop.customer.BuildConfig
import com.quedrop.customer.di.BaseAppComponent
import com.quedrop.customer.di.BaseUiApp
import timber.log.Timber


open class QueDropApplication : BaseUiApp() {
    override fun onCreate() {
        super.onCreate()
        context = this
        MultiDex.install(this)
        setupLog()
    }

    private fun setupLog() {
        if (BuildConfig.DEBUG) {
            Timber.plant(Timber.DebugTree())
        }
    }

    override fun getAppComponent(): BaseAppComponent {
        return component
    }

    override fun setAppComponent(baseAppComponent: BaseAppComponent) {
        component = baseAppComponent
    }

    companion object {
        lateinit var component: BaseAppComponent

        @SuppressLint("StaticFieldLeak")
        lateinit var context: Context

        fun getAppComponent(): BaseAppComponent {
            return component
        }
    }
}