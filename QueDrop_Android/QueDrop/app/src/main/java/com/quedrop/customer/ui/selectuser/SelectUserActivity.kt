package com.quedrop.customer.ui.selectuser

import android.content.Intent
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.core.content.ContextCompat
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.User
import com.quedrop.customer.ui.selectaddress.view.SelectAddressActivity
import com.quedrop.customer.ui.supplier.suppplierLogin.SupplierLoginActivity
import com.quedrop.customer.utils.ConstantUtils
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.activity_select_user2.*


class SelectUserActivity : BaseActivity() {

    var flagCheck: Boolean = false
    var image: Drawable? = null
    private var image_press: Drawable? = null
    var supplier: Drawable? = null
    private var supplier_press: Drawable? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_select_user2)


        Utils.deviceToken =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyDeviceToken)!!

        flagCheck = false


        initMethod()
        onClickMethod()
    }

    private fun initMethod() {
        textQue.text = " " + resources.getString(R.string.textQue)
        image = ContextCompat.getDrawable(applicationContext, R.drawable.customer_unpress)
        image_press = ContextCompat.getDrawable(applicationContext, R.drawable.customer_press)
        supplier = ContextCompat.getDrawable(applicationContext, R.drawable.supplier_unpress)
        supplier_press = ContextCompat.getDrawable(applicationContext, R.drawable.supplier_press)

        textCustomer.setCompoundDrawablesWithIntrinsicBounds(null, image, null, null)
        textSupplier.setCompoundDrawablesWithIntrinsicBounds(null, supplier, null, null)

        btnShowUser.visibility = View.INVISIBLE

    }

    private fun onClickMethod() {
        textCustomer.throttleClicks().subscribe {

            flagCheck = false

            btnShowUser.visibility = View.VISIBLE

            textCustomer.setCompoundDrawablesWithIntrinsicBounds(null, image_press, null, null)
            textSupplier.setCompoundDrawablesWithIntrinsicBounds(null, supplier, null, null)

            btnShowUser.text = resources.getString(R.string.textCustomerCheck)
        }.autoDispose(compositeDisposable)

        textSupplier.throttleClicks().subscribe {

            flagCheck = true

            btnShowUser.visibility = View.VISIBLE

            textCustomer.setCompoundDrawablesWithIntrinsicBounds(null, image, null, null)
            textSupplier.setCompoundDrawablesWithIntrinsicBounds(null, supplier_press, null, null)

            btnShowUser.text = resources.getString(R.string.textSupplierCheck)
        }.autoDispose(compositeDisposable)

        btnShowUser.throttleClicks().subscribe {

            //**********************************************************//

            val userData = (SharedPrefsUtils.getModelPreferences(
                applicationContext,
                KeysUtils.keyUser,
                User::class.java
            )) as User?
            if (userData != null) {
                val customerUserId = (SharedPrefsUtils.getModelPreferences(
                    applicationContext, KeysUtils.keyUser,
                    User::class.java
                ) as User).user_id

                if (customerUserId !== null) {
                    disconnectSocketManually(customerUserId)
                }
                Log.d("SocketZP", "Customer disconnected==>" + customerUserId)

            }

            //**********************************************************//


            //**********************************************************//
            val supplierUserId =
                SharedPrefsUtils.getIntegerPreference(this, KeysUtils.KeyUserSupplierId, 0)

            if (supplierUserId !== null) {
                disconnectSocketManually(supplierUserId)
            }

            Log.d("SocketZP", "Supplier disconnected==>" + supplierUserId)
            //**********************************************************//


            if (flagCheck) {

                SharedPrefsUtils.setIntegerPreference(
                    applicationContext,
                    KeysUtils.keyUserType,
                    ConstantUtils.USER_TYPE_SUPPLIER
                )

                startActivityWithDefaultAnimations(Intent(this, SupplierLoginActivity::class.java))
                finish()

            } else {

                SharedPrefsUtils.setIntegerPreference(
                    applicationContext,
                    KeysUtils.keyUserType,
                    ConstantUtils.USER_TYPE_CUSTOMER
                )

                val intent = Intent(this, SelectAddressActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                startActivityWithDefaultAnimations(intent)
                finish()

            }

        }.autoDispose(compositeDisposable)
    }
}

