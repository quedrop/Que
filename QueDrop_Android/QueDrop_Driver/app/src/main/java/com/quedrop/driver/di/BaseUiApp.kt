package com.quedrop.driver.di

import android.app.Application
import com.quedrop.driver.ui.chat.ChatActivity
import com.quedrop.driver.ui.homeFragment.view.HomeFragment
import com.quedrop.driver.ui.login.view.LoginActivity
import com.quedrop.driver.ui.register.view.SocialRegisterEmailActivity

abstract class BaseUiApp : Application() {
    abstract fun getAppComponent(): BaseAppComponent
    abstract fun setAppComponent(baseAppComponent: BaseAppComponent)
}

interface BaseAppComponent {
    fun inject(app: Application)
    fun inject(loginActivity: LoginActivity)
    fun inject(socialRegisterEmailActivity: SocialRegisterEmailActivity)
    fun inject(homeFragment: HomeFragment)
    fun inject(chatActivity: ChatActivity)
}

/**
 * Extension for getting component more easily
 */
fun BaseUiApp.getComponent(): BaseAppComponent {
    return this.getAppComponent()
}