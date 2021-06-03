package com.quedrop.driver.ui.settings.view

import android.content.Context
import android.os.Bundle
import android.text.method.HideReturnsTransformationMethod
import android.text.method.PasswordTransformationMethod
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseFragment
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.request.ChangePasswordRequest
import com.quedrop.driver.ui.mainActivity.view.MainActivity
import com.quedrop.driver.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.driver.utils.*
import kotlinx.android.synthetic.main.fragment_change_password.*
import kotlinx.android.synthetic.main.toolbar_normal.*

class ChangePasswordFragment : BaseFragment() {

    companion object {
        fun newInstance(): ChangePasswordFragment {
            return ChangePasswordFragment()
        }
    }

    lateinit var mContext: Context

    lateinit var profileViewModel: ProfileViewModel

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        val view = inflater.inflate(
            R.layout.fragment_change_password,
            container, false
        )
        mContext = activity

        return view
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        profileViewModel = ProfileViewModel(appService)

        initViews()
    }

    private fun initViews() {
        setUpToolBar()
        onClickViews()
        observeViewModel()
    }

    private fun setUpToolBar() {
        tvTitle.text = resources.getString(R.string.change_password)
        ivBack.throttleClicks().subscribe {
            goBackToPreviousFragment()
        }.autoDispose(compositeDisposable)
    }

    private fun goBackToPreviousFragment() {
        val fm = getActivity()!!.supportFragmentManager
        if (fm.backStackEntryCount > 0) {
            fm.popBackStack()
        }
    }

    private fun onClickViews() {
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


        btnSavePwd.throttleClicks().subscribe {
            if (validateInput()) {
                if (Utility.isNetworkAvailable(activity)) {

                    getChangePasswordApiCall()
                } else {
                    hideProgress()
                    showAlertMessage(activity, getString(R.string.no_internet_connection))
                }
            }
        }.autoDispose(compositeDisposable)

    }


    private fun observeViewModel() {

        profileViewModel.changePasswordMessage.observe(
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                (getActivity() as MainActivity).hideProgress()
                activity.showToast(it)
                goBackToPreviousFragment()

            })

        profileViewModel.errorMessage.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            (getActivity() as MainActivity).hideProgress()

        })
    }

    private fun changePasswordRequest(): ChangePasswordRequest {
        return ChangePasswordRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            SharedPreferenceUtils.getInt(KEY_USERID),
            etCurrentPwd.text.toString(),
            etConfirmPwd.text.toString()
        )
    }


    private fun getChangePasswordApiCall() {
        (activity as MainActivity).showProgress()
        profileViewModel.changePasswordApiCall(changePasswordRequest())
    }

    private fun validateInput(): Boolean {

        if (etCurrentPwd.text?.isEmpty()!!) {
            activity.showToast(
                getString(R.string.current_password_required)
            )
            return false
        } else if (etNewPwd.text?.isEmpty()!!) {
            activity.showToast(
                getString(R.string.new_password_required)
            )
            return false
        } else if (etConfirmPwd.text?.isEmpty()!!) {
            activity.showToast(
                getString(R.string.confirm_password_required)
            )
            return false
        } else if (etConfirmPwd.text.toString() != etNewPwd.text.toString()) {
            activity.showToast(
                getString(R.string.confirm_password_not_matched)
            )
            return false
        }

        return true
    }

}