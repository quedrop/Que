package com.quedrop.customer.di

import android.app.Application
import com.quedrop.customer.ui.chat.ChatActivity
import com.quedrop.customer.ui.login.view.LoginActivity
import com.quedrop.customer.ui.register.view.RegisterActivity
import com.quedrop.customer.ui.register.view.SocialRegisterEmailActivity
import com.quedrop.customer.ui.supplier.suppplierLogin.SupplierLoginActivity

abstract class BaseUiApp : Application() {

    abstract fun getAppComponent(): BaseAppComponent
    abstract fun setAppComponent(baseAppComponent: BaseAppComponent)
}

interface BaseAppComponent {
    fun inject(app: Application)
    fun inject(loginActivity: LoginActivity)
    fun inject(registerActivity: RegisterActivity)
    fun inject(socialRegisterEmailActivity: SocialRegisterEmailActivity)
    fun inject(chatActivity: ChatActivity)
    fun inject(supplierLoginActivity: SupplierLoginActivity)
}

/**
 * Extension for getting component more easily
 */
fun BaseUiApp.getComponent(): BaseAppComponent {
    return this.getAppComponent()
}