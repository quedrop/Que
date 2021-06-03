package com.quedrop.customer.di

import android.app.Application
import android.content.Context
import com.quedrop.customer.QueDrop
import com.quedrop.customer.api.authentication.AuthenticationModule
import com.quedrop.customer.api.socketmanager.SocketManagerModule
import com.quedrop.customer.prefs.PrefsModule
import dagger.Component
import dagger.Module
import dagger.Provides
import javax.inject.Singleton

@Module
class QueDropAppModule(val app: Application) {
    @Provides
    @Singleton
    fun provideApplication(): Application {
        return app
    }

    @Provides
    @Singleton
    fun provideContext(): Context {
        return app
    }
}

@Singleton
@Component(
    modules = [
        QueDropAppModule::class,
        PrefsModule::class,
        AuthenticationModule::class,
        SocketManagerModule::class
    ]
)
public interface QueDropAppComponent : BaseAppComponent {
    fun inject(app: QueDrop)
}