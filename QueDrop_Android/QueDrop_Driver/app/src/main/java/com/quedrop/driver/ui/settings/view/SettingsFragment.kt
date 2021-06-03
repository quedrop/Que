package com.quedrop.driver.ui.settings.view

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseFragment
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.request.LogOutRequest
import com.quedrop.driver.ui.login.view.LoginActivity
import com.quedrop.driver.ui.mainActivity.view.MainActivity
import com.quedrop.driver.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.driver.utils.*
import kotlinx.android.synthetic.main.fragment_settings.*
import kotlinx.android.synthetic.main.toolbar_normal.*

class SettingsFragment : BaseFragment() {
    companion object {
        fun newInstance(): SettingsFragment {
            return SettingsFragment()
        }
    }

    lateinit var mContext: Context

    private lateinit var profileViewModel: ProfileViewModel

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        val view = inflater.inflate(
            R.layout.fragment_settings,
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
        observeViewModel()
        onClickViews()

    }

    private fun onClickViews() {

        btnLogOutSettings.throttleClicks().subscribe() {
            if(Utility.isNetworkAvailable(activity)){
                logOutApiCall()
            }else{
                hideProgress()
                showAlertMessage(activity, getString(R.string.no_internet_connection))
            }

        }.autoDispose(compositeDisposable)

        tvManagePaymentMethod.throttleClicks().subscribe() {
            (getActivity() as MainActivity).navigateToFragment(
                ManagePaymentFragment.newInstance()
            )
        }.autoDispose(compositeDisposable)

        tvChangePasswordSettings.throttleClicks().subscribe() {
            (getActivity() as MainActivity).navigateToFragment(
                ChangePasswordFragment.newInstance()
            )
        }.autoDispose(compositeDisposable)

        tvMyReferralCode.throttleClicks().subscribe() {
            (getActivity() as MainActivity).navigateToFragment(
                ReferralCodeFragment.newInstance()
            )
        }.autoDispose(compositeDisposable)

        tvReviewsRatings.throttleClicks().subscribe {
            (getActivity() as MainActivity).navigateToFragment(
                RateReviewFragment.newInstance()
            )
        }.autoDispose(compositeDisposable)

        tvIdentityDetails.throttleClicks().subscribe {
            (getActivity() as MainActivity).navigateToFragment(
                IdentityDetailsFragment.newInstance()
            )
        }.autoDispose(compositeDisposable)
    }

    private fun observeViewModel() {
        profileViewModel.logOutData.observe(viewLifecycleOwner, Observer { newToken ->
            hideProgress()

            val token=SharedPreferenceUtils.getString(DEVICE_TOKEN)
            val email=SharedPreferenceUtils.getString(KEY_EMAIL)
            val password=SharedPreferenceUtils.getString(
                KEY_PASSWORD
            )
            SharedPreferenceUtils.clear()
            SharedPreferenceUtils.setString(DEVICE_TOKEN, token)

            SharedPreferenceUtils.setString(KEY_EMAIL, email)
            SharedPreferenceUtils.setString(KEY_PASSWORD, password)

            val intent = Intent(this.context, LoginActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            startActivityWithDefaultAnimations(intent)
            activity.finish()
        })

        profileViewModel.errorMessage.observe(viewLifecycleOwner, Observer { error ->
            hideProgress()

        })

    }

    private fun setUpToolBar() {
        tvTitle.text = resources.getString(R.string.settings)
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

    private fun logOutApiCall() {
        showProgress()
        profileViewModel.logOutApiCall(getLogOutRequest())

    }

    private fun getLogOutRequest(): LogOutRequest {
        return LogOutRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            SharedPreferenceUtils.getInt(KEY_USERID),
            DEVICE_TOKEN,
            DEVICE_TYPE
        )
    }

    fun onPageSelected(position: Int) {

    }


}