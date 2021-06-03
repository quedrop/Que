package com.quedrop.customer.ui.profile.view

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.LogOutRequest
import com.quedrop.customer.ui.selectuser.SelectUserActivity
import com.quedrop.customer.utils.ConstantUtils
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import androidx.lifecycle.Observer
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.User
import com.quedrop.customer.ui.favourite.view.FavouriteCustomerFragment
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.customer.ui.selectaddress.view.SelectAddressActivity
import kotlinx.android.synthetic.main.activity_toolbar.*
import kotlinx.android.synthetic.main.fragment_settings_customer.*

class SettingsFragment : BaseFragment() {

    lateinit var profileViewModel: ProfileViewModel
    private var loginType: String = ""

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        return inflater.inflate(
            R.layout.fragment_settings_customer,
            container, false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)


        val userData = (SharedPrefsUtils.getModelPreferences(
            activity,
            KeysUtils.keyUser,
            User::class.java
        )) as User?

        if (userData != null) {
            loginType = userData.login_type
        }

        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyGuestId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keyAccessKey)!!
        Utils.deviceToken =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keyDeviceToken)!!
        profileViewModel =
            ProfileViewModel(appService)

        initMethod()
        observeViewModel()
        onClickMethod()

    }

    companion object {
        fun newInstance(): SettingsFragment {
            return SettingsFragment()
        }
    }


    fun initMethod() {

        if (Utils.userId == 0) {
            tvChangePasswordSettings.visibility = View.GONE
            horizontalLineSetting1.visibility = View.GONE
            tvMyReferralCode.visibility = View.GONE
            horizontalLineSetting3.visibility = View.GONE
            tvReviewsRatings.visibility = View.GONE
            horizontalLineSetting4.visibility = View.GONE
            tvFavourites.visibility = View.GONE
            horizontalLineSetting5.visibility = View.GONE
            btnLogOutSettings.visibility = View.GONE

        } else if (loginType.toLowerCase() != "standard") {
            tvChangePasswordSettings.visibility = View.GONE
            horizontalLineSetting1.visibility = View.GONE
            tvMyReferralCode.visibility = View.VISIBLE
            horizontalLineSetting3.visibility = View.VISIBLE
            tvReviewsRatings.visibility = View.VISIBLE
            horizontalLineSetting4.visibility = View.VISIBLE
            tvFavourites.visibility = View.VISIBLE
            horizontalLineSetting5.visibility = View.VISIBLE
            btnLogOutSettings.visibility = View.VISIBLE
        } else {
            tvChangePasswordSettings.visibility = View.VISIBLE
            horizontalLineSetting1.visibility = View.VISIBLE
            tvMyReferralCode.visibility = View.VISIBLE
            horizontalLineSetting3.visibility = View.VISIBLE
            tvReviewsRatings.visibility = View.VISIBLE
            horizontalLineSetting4.visibility = View.VISIBLE
            tvFavourites.visibility = View.VISIBLE
            horizontalLineSetting5.visibility = View.VISIBLE
            btnLogOutSettings.visibility = View.VISIBLE
        }

    }

    fun onClickMethod() {

        ivSettingBack.throttleClicks().subscribe {
            activity.onBackPressed()
        }.autoDispose(compositeDisposable)

        btnLogOutSettings.throttleClicks().subscribe() {
            logOutModule()
        }.autoDispose(compositeDisposable)

        tvSwitchAccount.throttleClicks().subscribe() {
            Utils.isCallOnceMap = false
            SharedPrefsUtils.setBooleanPreference(
                activity,
                KeysUtils.keyMap,
                Utils.isCallOnceMap
            )
            switchUser()
//            logOutModule()
        }.autoDispose(compositeDisposable)

        tvManageAddress.throttleClicks().subscribe() {
            manageAddressModule()
        }.autoDispose(compositeDisposable)

        tvChangePasswordSettings.throttleClicks().subscribe() {
            navigationChangePasswordScreen()
        }.autoDispose(compositeDisposable)

        tvMyReferralCode.throttleClicks().subscribe() {
            navigateReferralScreen()
        }.autoDispose(compositeDisposable)

        tvReviewsRatings.throttleClicks().subscribe() {
            navigateReviewDriverScreen()
        }.autoDispose(compositeDisposable)

        tvFavourites.throttleClicks().subscribe {
            navigationFavouriteScreen()
        }.autoDispose(compositeDisposable)
    }

    private fun navigationFavouriteScreen() {
        (getActivity() as CustomerMainActivity).navigateToFragment(
            FavouriteCustomerFragment.newInstance()
        )
    }

    private fun navigationChangePasswordScreen() {
        (getActivity() as CustomerMainActivity).navigateToFragment(
            ChangePasswordFragment.newInstance()
        )
    }

    private fun navigateReviewDriverScreen() {
        (getActivity() as CustomerMainActivity).navigateToFragment(
            RateReviewFragment.newInstance()
        )
    }

    private fun navigateReferralScreen() {
        (getActivity() as CustomerMainActivity).navigateToFragment(
            ReferralCodeFragment.newInstance()
        )
    }

    private fun manageAddressModule() {

        Utils.isCallOnceMap = false

        SharedPrefsUtils.setBooleanPreference(
            activity,
            KeysUtils.keyMap,
            Utils.isCallOnceMap
        )
        val intent = Intent(activity, SelectAddressActivity::class.java)
        intent.putExtra(KeysUtils.keySettingAddress, getString(R.string.fromSettingAddress))
        startActivityWithDefaultAnimations(intent)
//        activity.finish()
    }


    private fun logOutModule() {
        Utils.isPlaceOrderBoolean = false
        Utils.guestId = 0
        Utils.userId = 0
        SharedPrefsUtils.removeSharedPreference(activity, KeysUtils.keyUser)
        SharedPrefsUtils.setBooleanPreference(
            activity,
            KeysUtils.keySession,
            false
        )
        SharedPrefsUtils.setBooleanPreference(
            activity,
            KeysUtils.keyMap,
            false
        )
        SharedPrefsUtils.setBooleanPreference(
            activity,
            KeysUtils.keyIsCheckGuest,
            false
        )
        SharedPrefsUtils.setIntegerPreference(
            activity,
            KeysUtils.keyGuestId,
            Utils.guestId
        )
        SharedPrefsUtils.setIntegerPreference(
            activity,
            KeysUtils.keyUserId,
            Utils.userId
        )
        SharedPrefsUtils.setBooleanPreference(
            activity,
            KeysUtils.keyCheckVerify,
            Utils.isPlaceOrderBoolean
        )

        if (Utils.userId == 0) {

            logOut()
        } else {
            logOutApiCall()
        }
    }

    private fun observeViewModel() {
        profileViewModel.logOutData.observe(viewLifecycleOwner, Observer { newToken ->
            logOut()
        })

        profileViewModel.errorMessage.observe(viewLifecycleOwner, Observer { error ->
            //            logOut()
            // Toast.makeText(this, error, Toast.LENGTH_SHORT).show()
        })


    }


    private fun logOutApiCall() {
        profileViewModel.logOutApiCall(getLogOutRequest())

    }

    private fun getLogOutRequest(): LogOutRequest {
        return LogOutRequest(
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId,
            Utils.deviceToken,
            ConstantUtils.DEVICE_TYPE,
            ConstantUtils.USER_TYPE_C
        )
    }

    private fun switchUser() {

        val intent = Intent(this.context, SelectUserActivity::class.java)
//        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        startActivityWithDefaultAnimations(intent)
//        activity?.finish()
    }

    private fun logOut() {

        val intent = Intent(this.context, SelectAddressActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        startActivityWithDefaultAnimations(intent)
        activity.finish()
    }
}