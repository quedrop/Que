package com.quedrop.customer.ui.supplier.profile

import android.os.Bundle
import android.text.method.HideReturnsTransformationMethod
import android.text.method.PasswordTransformationMethod
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.ChangePasswordRequest
import com.quedrop.customer.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.activity_toolbar.*
import kotlinx.android.synthetic.main.fragment_change_password.*

class SupplierChangePasswordActivity : BaseActivity() {

    lateinit var profileViewModel: ProfileViewModel
    private var errorMessage = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.change_password_activity)

        Utils.Supplier.supplierUserId =
            SharedPrefsUtils.getIntegerPreference(this, KeysUtils.KeyUserSupplierId, 0)
        Utils.seceretKey = SharedPrefsUtils.getStringPreference(this, KeysUtils.keySecretKey)!!
        Utils.Supplier.supplierAccessKey =
            SharedPrefsUtils.getStringPreference(this, KeysUtils.KeySupplierAccessKey)!!
        profileViewModel = ProfileViewModel(appService)
        initMethod()

    }

    private fun initMethod() {
        onClickMethod()
        observeViewModel()
    }

    private fun onClickMethod() {

        ivChangePwdBack.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        ivCurrentShowPwd.throttleClicks().subscribe {
            if (ivCurrentShowPwd.contentDescription == "Hide") {
                etCurrentPwd.transformationMethod =
                    HideReturnsTransformationMethod.getInstance()
                ivCurrentShowPwd.contentDescription = "Show"
                ivCurrentShowPwd.setImageDrawable(
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.ic_eye_visible
                    )
                )
            } else {
                etCurrentPwd.transformationMethod = PasswordTransformationMethod.getInstance()
                ivCurrentShowPwd.contentDescription = "Hide"
                ivCurrentShowPwd.setImageDrawable(
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.ic_eye_hide
                    )
                )
            }

        }.autoDispose(compositeDisposable)

        ivNewShowPwd.throttleClicks().subscribe {
            if (ivNewShowPwd.contentDescription == "Hide") {
                etNewPwd.transformationMethod =
                    HideReturnsTransformationMethod.getInstance()
                ivNewShowPwd.contentDescription = "Show"
                ivNewShowPwd.setImageDrawable(
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.ic_eye_visible
                    )
                )
            } else {
                etNewPwd.transformationMethod = PasswordTransformationMethod.getInstance()
                ivNewShowPwd.contentDescription = "Hide"
                ivNewShowPwd.setImageDrawable(
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.ic_eye_hide
                    )
                )
            }

        }.autoDispose(compositeDisposable)

        ivConfirmShowPwd.throttleClicks().subscribe {
            if (ivConfirmShowPwd.contentDescription == "Hide") {
                etConfirmPwd.transformationMethod =
                    HideReturnsTransformationMethod.getInstance()
                ivConfirmShowPwd.contentDescription = "Show"
                ivConfirmShowPwd.setImageDrawable(
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.ic_eye_visible
                    )
                )
            } else {
                etConfirmPwd.transformationMethod = PasswordTransformationMethod.getInstance()
                ivConfirmShowPwd.contentDescription = "Hide"
                ivConfirmShowPwd.setImageDrawable(
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.ic_eye_hide
                    )
                )
            }

        }.autoDispose(compositeDisposable)


        btnNextChangePwd.throttleClicks().subscribe() {

            if (validateInputs()) {
                getChangePasswordApiCall()
            }
        }.autoDispose(compositeDisposable)

    }

    private fun observeViewModel() {


        profileViewModel.changePasswordMessage.observe(
            this,
            androidx.lifecycle.Observer {
                Toast.makeText(this, it, Toast.LENGTH_SHORT).show()
                onBackPressed()
            })

        profileViewModel.errorMessage.observe(this, androidx.lifecycle.Observer {
            Toast.makeText(this, it, Toast.LENGTH_SHORT).show()
        })
    }

    private fun getChangePassword(): ChangePasswordRequest {
        return ChangePasswordRequest(
            Utils.seceretKey,
            Utils.Supplier.supplierAccessKey,
            Utils.Supplier.supplierUserId,
            etCurrentPwd.text.toString(),
            etConfirmPwd.text.toString()
        )
    }


    private fun getChangePasswordApiCall() {
        profileViewModel.changePasswordApiCall(getChangePassword())
    }


    private fun validateInputs(): Boolean {
        if (etCurrentPwd.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.oldPasswordVal)
            showErrorMessage()
            return false
        } else if (etNewPwd.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.newPasswordVal)
            showErrorMessage()
            return false
        } else if (etConfirmPwd.text!!.trim().isEmpty()) {
            errorMessage = resources.getString(R.string.confirmPasswordVal)
            showErrorMessage()
            return false
        } else if (etCurrentPwd.text.toString().length < 6) {
            errorMessage = resources.getString(R.string.passwordDigitVal)
            showErrorMessage()
            return false
        } else if (etNewPwd.text.toString().length < 6) {
            errorMessage = resources.getString(R.string.passwordDigitVal)
            showErrorMessage()
            return false
        } else if (etConfirmPwd.text.toString().length < 6) {
            errorMessage = resources.getString(R.string.passwordDigitVal)
            showErrorMessage()
            return false
        } else if (etConfirmPwd.text!!.trim()
                .toString() != etNewPwd.text!!.trim().toString()
        ) {
            errorMessage = resources.getString(R.string.passwordNotMatchVal)
            showErrorMessage()
            return false
        } else {
            errorMessage = ""
            return true
        }
    }

    private fun showErrorMessage() {
        Toast.makeText(this, errorMessage, Toast.LENGTH_SHORT).show()
    }
}