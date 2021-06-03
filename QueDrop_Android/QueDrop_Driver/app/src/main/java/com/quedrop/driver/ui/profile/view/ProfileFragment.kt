package com.quedrop.driver.ui.profile.view


import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import com.bumptech.glide.Glide
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseFragment
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.User
import com.quedrop.driver.service.request.RateReviewDriverRequest
import com.quedrop.driver.ui.enterphonenumber.EnterPhoneNumberActivity
import com.quedrop.driver.ui.mainActivity.view.MainActivity
import com.quedrop.driver.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.driver.ui.settings.view.SettingsFragment
import com.quedrop.driver.utils.*
import com.google.gson.Gson
import kotlinx.android.synthetic.main.fragment_profile.*
import kotlinx.android.synthetic.main.toolbar_login.*


class ProfileFragment : BaseFragment() {

    companion object {
        fun newInstance(): ProfileFragment {
            return ProfileFragment()
        }
    }


    private lateinit var mContext: Context
    private lateinit var user: User

    private lateinit var profileViewModel: ProfileViewModel
    private var profileImagePath: String = ""


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        val view = inflater.inflate(R.layout.fragment_profile, container, false)
        mContext = activity
        return view
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        user = SharedPreferenceUtils.getModelPreferences(KEY_USER, User::class.java) as User

        profileViewModel = ProfileViewModel(appService)

        initViews()

    }

    private fun initViews() {
        setUpToolbar()
        setUpData(user)
        onClickView()
        observeViewModel()

    }

    private fun observeViewModel() {
        profileViewModel.userData.observe(viewLifecycleOwner, Observer {
            user = it
            setUpData(it)
        })

        profileViewModel.errorMessage.observe(viewLifecycleOwner, Observer { error ->

        })

    }

    private fun onClickView() {

        ivToolbar.throttleClicks().subscribe {
            (getActivity() as MainActivity).navigateToFragment(SettingsFragment.newInstance())
        }.autoDispose(compositeDisposable)

        ivEditProfile.throttleClicks().subscribe {
            startActivityWithDefaultAnimations(
                Intent(
                    mContext,
                    EditProfileActivity::class.java
                ).putExtra(KEY_EDIT_IDENTITY, Gson().toJson(user))
                    .putExtra(KEY_FROM_EDIT_IDENTITY, true)
            )
        }.autoDispose(compositeDisposable)

        phoneNumAddEdit.throttleClicks().subscribe {

            startActivityWithDefaultAnimations(
                Intent(context, EnterPhoneNumberActivity::class.java)
                    .putExtra("PhoneNumber", etMobileProfile.text.toString())
                    .putExtra("CountryCode", user.countryCode)
                    .putExtra("isFromProfile", true)
            )

        }.autoDispose(compositeDisposable)


    }

    private fun setUpData(user: User) {
        if (!isNetworkUrl(user.userImage!!)) {
            profileImagePath =
                BuildConfig.BASE_URL + ImageConstant.PROFILE_DATA + user.userImage
        } else {
            profileImagePath = user.userImage!!
        }

        Glide.with(this)
            .load(profileImagePath)
            .placeholder(R.drawable.ic_user_placeholder)
            .circleCrop()
            .into(ivProfilePic)

        tvFullName.text = user.userName
        tvUsername.text = user.firstName + " " + user.lastName
        tvEmail.text = user.email
        userRating.rating = user.rating?.toFloat()!!
        etMobileProfile.text = user.phoneNumber
        countryCodeSpinner.setCountryForPhoneCode(user.countryCode!!)

    }

    private fun setUpToolbar() {
        tvTitleLogin.text = "Profile"
        Glide.with(this).load(R.drawable.ic_setting_gray).into(ivToolbar)
    }

    fun onPageSelected(position: Int) {

    }


    private fun getUserProfileDetail() {
        profileViewModel.getUserProfileDetail(getUserProfileDetailRequest())

    }

    private fun getUserProfileDetailRequest(): RateReviewDriverRequest {
        return RateReviewDriverRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            SharedPreferenceUtils.getInt(KEY_USERID)
        )
    }

    override fun onResume() {
        super.onResume()
        if (Utility.isNetworkAvailable(context)) {
            getUserProfileDetail()
        } else {
            showAlertMessage(activity, getString(R.string.no_internet_connection))
        }

    }

}
