package com.quedrop.customer.ui.profile.view

import android.os.Bundle
import android.text.method.HideReturnsTransformationMethod
import android.text.method.PasswordTransformationMethod
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.ChangePasswordRequest
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.customer.utils.*
import kotlinx.android.synthetic.main.activity_toolbar.*
import kotlinx.android.synthetic.main.fragment_change_password.*

class ChangePasswordFragment : BaseFragment() {

    lateinit var profileViewModel: ProfileViewModel
    private var errorMessage = ""
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        return inflater.inflate(
            R.layout.fragment_change_password,
            container, false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyGuestId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keyAccessKey)!!

        profileViewModel = ProfileViewModel(appService)
        onClickMethod()
        observeViewModel()
    }

    companion object {
        fun newInstance(): ChangePasswordFragment {
            return ChangePasswordFragment()
        }
    }


    private fun onClickMethod() {

        ivChangePwdBack.throttleClicks().subscribe {
            activity.onBackPressed()
        }.autoDispose(compositeDisposable)

        ivCurrentShowPwd.throttleClicks().subscribe {
            if (ivCurrentShowPwd.contentDescription == "Hide") {
                etCurrentPwd.transformationMethod =
                    HideReturnsTransformationMethod.getInstance()
                ivCurrentShowPwd.contentDescription = "Show"
                ivCurrentShowPwd.setImageDrawable(
                    ContextCompat.getDrawable(
                        activity,
                        R.drawable.ic_eye_visible
                    )
                )
            } else {
                etCurrentPwd.transformationMethod = PasswordTransformationMethod.getInstance()
                ivCurrentShowPwd.contentDescription = "Hide"
                ivCurrentShowPwd.setImageDrawable(
                    ContextCompat.getDrawable(
                        activity,
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
                        activity,
                        R.drawable.ic_eye_visible
                    )
                )
            } else {
                etNewPwd.transformationMethod = PasswordTransformationMethod.getInstance()
                ivNewShowPwd.contentDescription = "Hide"
                ivNewShowPwd.setImageDrawable(
                    ContextCompat.getDrawable(
                        activity,
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
                        activity,
                        R.drawable.ic_eye_visible
                    )
                )
            } else {
                etConfirmPwd.transformationMethod = PasswordTransformationMethod.getInstance()
                ivConfirmShowPwd.contentDescription = "Hide"
                ivConfirmShowPwd.setImageDrawable(
                    ContextCompat.getDrawable(
                        activity,
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
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                (getActivity() as CustomerMainActivity).hideProgress()
                Toast.makeText(context, it, Toast.LENGTH_SHORT).show()
                activity.onBackPressed()
            })

        profileViewModel.errorMessage.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (getActivity() as CustomerMainActivity).hideProgress()
            Toast.makeText(context, it, Toast.LENGTH_SHORT).show()
        })
    }

    private fun getChangePassword(): ChangePasswordRequest {
        return ChangePasswordRequest(
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId,
            etCurrentPwd.text.toString(),
            etConfirmPwd.text.toString()
        )
    }


    private fun getChangePasswordApiCall() {
        (activity as CustomerMainActivity).showProgress()
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
        } else if (etNewPwd.text.toString().length < 6) {
            errorMessage = resources.getString(R.string.passwordDigitVal)
            showErrorMessage()
            return false
        } else if (etConfirmPwd.text.toString().length < 6) {
            errorMessage = resources.getString(R.string.passwordDigitVal)
            showErrorMessage()
            return false
        }
//        else if (!ValidationUtils.isValidPassword(etNewPwd.text!!.trim().toString())) {
//            errorMessage = resources.getString(R.string.validPasswordVal)
//            showErrorMessage()
//            return false
//        } else if (!ValidationUtils.isValidPassword(etConfirmPwd.text!!.trim().toString())) {
//            errorMessage = resources.getString(R.string.validPasswordVal)
//            showErrorMessage()
//            return false
//        }
        else if (etConfirmPwd.text!!.trim()
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
        Toast.makeText(activity, errorMessage, Toast.LENGTH_SHORT).show()
    }
}