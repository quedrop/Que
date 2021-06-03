package com.quedrop.driver.base

import android.annotation.SuppressLint
import android.content.Context
import androidx.multidex.MultiDex
import com.facebook.FacebookSdk
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.di.BaseAppComponent
import com.quedrop.driver.di.BaseUiApp
import timber.log.Timber

open class QueDropDriverApplication : BaseUiApp() {
    override fun onCreate() {
        super.onCreate()
        context = this
        MultiDex.install(this)
        FacebookSdk.sdkInitialize(context)
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