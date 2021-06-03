package com.quedrop.customer.api.authentication

import com.quedrop.customer.prefs.LocalPrefs
import dagger.Module
import dagger.Provides
import javax.inject.Singleton

@Module
class AuthenticationModule {

    @Provides
    @Singleton
    fun provideLoggedInUserCache(prefs: LocalPrefs): LoggedInUserCache {
        return LoggedInUserCache(prefs)
    }
}