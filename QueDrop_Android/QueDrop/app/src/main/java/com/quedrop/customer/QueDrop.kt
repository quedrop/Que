package com.quedrop.customer

import android.app.Activity
import android.app.Application
import com.facebook.drawee.backends.pipeline.Fresco
import com.quedrop.customer.di.QueDropAppComponent
import com.quedrop.customer.di.QueDropAppModule
import com.quedrop.customer.di.DaggerQueDropAppComponent

class QueDrop : SocketApplication() {

    companion object {

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

            // the following line is important
            Fresco.initialize(applicationContext)

            super.setAppComponent(componentLegacy)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        super.onCreate()
    }
}