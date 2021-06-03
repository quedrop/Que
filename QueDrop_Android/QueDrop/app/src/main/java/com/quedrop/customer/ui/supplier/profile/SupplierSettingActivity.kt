package com.quedrop.customer.ui.supplier.profile

import android.content.Intent
import android.os.Bundle
import androidx.lifecycle.Observer
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityWithAnimation
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.LogOutRequest
import com.quedrop.customer.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.customer.ui.selectaddress.view.SelectAddressActivity
import com.quedrop.customer.ui.selectuser.SelectUserActivity
import com.quedrop.customer.ui.supplier.payment.ManagePaymentActivity
import com.quedrop.customer.utils.ConstantUtils
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.activity_supplier_setting.*
import kotlinx.android.synthetic.main.activity_toolbar.*

class SupplierSettingActivity : BaseActivity() {

    private lateinit var profileViewModel: ProfileViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_supplier_setting)

        Utils.Supplier.supplierUserId =
            SharedPrefsUtils.getIntegerPreference(this, KeysUtils.KeyUserSupplierId, 0)
        Utils.seceretKey = SharedPrefsUtils.getStringPreference(this, KeysUtils.keySecretKey)!!
        Utils.Supplier.supplierAccessKey =
            SharedPrefsUtils.getStringPreference(this, KeysUtils.KeySupplierAccessKey)!!
        profileViewModel = ProfileViewModel(appService)

        initViews()


    }

    private fun initViews() {

        ivSettingBack.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        tvChangePasswordSettings.setOnClickListener {
            startActivityWithAnimation<SupplierChangePasswordActivity> { }
        }

        tvManagePayment.setOnClickListener {
            startActivityWithAnimation<ManagePaymentActivity> { }
        }

        tvSwitchAccount.setOnClickListener {
            Utils.isCallOnceMap = false
            SharedPrefsUtils.setBooleanPreference(
                this,
                KeysUtils.keyMap,
                Utils.isCallOnceMap
            )
            switchUser()
        }

        btnLogOutSettings.throttleClicks().subscribe {
            logOutModule()
        }.autoDispose(compositeDisposable)

        profileViewModel.logOutData.observe(this, Observer { newToken ->

            logOut()
        })

    }

    private fun logOutModule() {

        SharedPrefsUtils.removeSharedPreference(this, KeysUtils.KeySupplierUser)
        SharedPrefsUtils.setBooleanPreference(
            this,
            KeysUtils.keySession,
            false
        )
        SharedPrefsUtils.setBooleanPreference(
            this,
            KeysUtils.keyMap,
            false
        )

        SharedPrefsUtils.setIntegerPreference(
            this,
            KeysUtils.KeyUserSupplierId,
            0
        )

        SharedPrefsUtils.setIntegerPreference(
            applicationContext,
            KeysUtils.keyUserType,
            ConstantUtils.USER_TYPE_CUSTOMER
        )


        logOutApiCall()
    }

    private fun logOutApiCall() {
        profileViewModel.logOutApiCall(getLogOutRequest())

    }

    private fun getLogOutRequest(): LogOutRequest {
        return LogOutRequest(
            Utils.seceretKey,
            Utils.Supplier.supplierAccessKey,
            Utils.Supplier.supplierUserId,
            Utils.deviceToken,
            ConstantUtils.DEVICE_TYPE,
            ConstantUtils.USER_TYPE_S
        )
    }

    private fun switchUser() {

        var intent = Intent(this, SelectUserActivity::class.java)
//        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        startActivityWithDefaultAnimations(intent)
//        finish()
    }

    private fun logOut() {

        var intent = Intent(this, SelectAddressActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        startActivityWithDefaultAnimations(intent)
        finish()
    }


}
