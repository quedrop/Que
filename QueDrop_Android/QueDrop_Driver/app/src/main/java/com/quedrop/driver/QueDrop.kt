package com.quedrop.driver

import android.app.Activity
import android.app.Application
import com.quedrop.driver.di.DaggerQueDropAppComponent
import com.quedrop.driver.di.QueDropAppComponent
import com.quedrop.driver.di.QueDropAppModule

class QueDrop : SocketApplication() {

    companion object {

        var remoteMessage =  ""

        operator fun get(app: Application): QueDrop {
            return app as QueDrop
        }

        operator fun get(activity: Activity): QueDrop {
            return activity.application as QueDrop
        }

        lateinit var componentLegacy: QueDropAppComponent
            private set
    }

    override fun onCreate() {
        try {
            componentLegacy = DaggerQueDropAppComponent.builder()
                .queDropAppModule(QueDropAppModule(this))
                .build()
            componentLegacy.inject(this)
            super.setAppComponent(componentLegacy)
        } catch (e: Exception) {
            e.printStackTrace()
        }

        super.onCreate()
    }
}