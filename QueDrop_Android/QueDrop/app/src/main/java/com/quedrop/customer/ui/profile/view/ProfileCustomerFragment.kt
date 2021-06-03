package com.quedrop.customer.ui.profile.view

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Bundle
import android.text.SpannableStringBuilder
import android.text.method.LinkMovementMethod
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.glide.makeClickSpannable
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.GetUserProfileDetailRequest
import com.quedrop.customer.model.User
import com.quedrop.customer.ui.enterphonenumber.EnterPhoneNumberActivity
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.login.view.LoginActivity
import com.quedrop.customer.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.customer.utils.*
import kotlinx.android.synthetic.main.fragment_profile_customer.*
import kotlinx.android.synthetic.main.fragment_profile_customer.countryCodeSpinner
import kotlinx.android.synthetic.main.fragment_profile_customer.etFirstNameProfile
import kotlinx.android.synthetic.main.fragment_profile_customer.etLastNameProfile
import kotlinx.android.synthetic.main.fragmnet_toolbar.*


class ProfileCustomerFragment : BaseFragment() {
    private lateinit var profileViewModel: ProfileViewModel
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {


        return inflater.inflate(
            R.layout.fragment_profile_customer,
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
        Utils.selectAddress =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeySelectAddress)!!

        profileViewModel =
            ProfileViewModel(appService)

        observeViewModel()
        initMethod()
        onClickMethod()

        setSpanToAgreementText()

        try {
            val pInfo: PackageInfo =
                activity.packageManager.getPackageInfo(activity.packageName, 0)
            val version = pInfo.versionName
            tvVersion.text = getString(R.string.versionName) + "(" + version + ")"
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
        }


    }

    private fun initMethod() {
        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)
        Log.e("usrId",Utils.userId.toString())
        if (Utils.userId == 0) {


            tvNameProfile.visibility = View.VISIBLE
            tvProfileAddress.visibility = View.VISIBLE
            tvRatingBarProfile.visibility = View.GONE
            mainConstraintProfile.visibility = View.GONE
            editProfileIV.visibility = View.GONE
            tvLoginProfile.visibility = View.VISIBLE
            tvVersion.visibility = View.VISIBLE

            tvNameProfile.text = SharedPrefsUtils.getStringPreference(activity, KeysUtils.keyGuestUser)
            tvProfileAddress.text = Utils.selectAddress

        } else {

            Log.e("usrId1",Utils.userId.toString())
            tvNameProfile.visibility = View.VISIBLE
            tvProfileAddress.visibility = View.VISIBLE
            tvRatingBarProfile.visibility = View.VISIBLE
            mainConstraintProfile.visibility = View.VISIBLE
            editProfileIV.visibility = View.VISIBLE
            tvLoginProfile.visibility = View.GONE
            tvVersion.visibility = View.VISIBLE
            getUserProfileApi()
        }
    }

    private fun onClickMethod() {
        ivSettings.visibility=View.VISIBLE

        ivSettings.throttleClicks().subscribe {
            navigateSettingInvoke()
        }.autoDispose(compositeDisposable)

        editProfileIV.throttleClicks().subscribe() {
            navigateEditProfileInvoke()
        }.autoDispose(compositeDisposable)

        phoneNumAdd.throttleClicks().subscribe() {
            navigateToPhoneNumberActivity()
        }.autoDispose(compositeDisposable)

    }

    private fun navigateToPhoneNumberActivity() {
        val intent = Intent(activity, EnterPhoneNumberActivity::class.java)
        startActivityForResultWithDefaultAnimations(
            intent,
            ConstantUtils.LOGIN_ENTER_PHONE_REQUEST_CODE
        )
    }

    private fun navigateSettingInvoke() {

        (getActivity() as CustomerMainActivity).navigateToFragment(
            SettingsFragment.newInstance()
        )
    }

    private fun navigateEditProfileInvoke() {

        (getActivity() as CustomerMainActivity).navigateToFragment(
            EditProfileFragment.newInstance(),this,ConstantUtils.PROFILE_MANAGE_CODE
        )
    }


    companion object {
        fun newInstance(): ProfileCustomerFragment {
            return ProfileCustomerFragment()
        }
    }

    fun onPageSelected(position: Int) {


        //getFragmentManager()?.beginTransaction()?.detach(this)?.attach(this)?.commit()
        if (Utils.userId != 0) {
            initMethod()
        }
    }


    private fun observeViewModel() {
        profileViewModel.user.observe(viewLifecycleOwner, Observer {
            (activity as CustomerMainActivity).hideProgress()
            setAllUserDetails(it)
        })

        profileViewModel.errorMessage.observe(viewLifecycleOwner, Observer { error ->
            (activity as CustomerMainActivity).hideProgress()
            //            logOut()
            // Toast.makeText(this, error, Toast.LENGTH_SHORT).show()
        })


    }


    private fun getUserProfileApi() {
        (activity as CustomerMainActivity).showProgress()
        profileViewModel.getUserProfileApi(
            GetUserProfileDetailRequest(
                Utils.seceretKey,
                Utils.accessKey,
                Utils.userId
            )
        )
    }

    private fun setAllUserDetails(user: User) {


        tvNameProfile.text = user.first_name + " " + user.last_name
        tvProfileAddress.text = Utils.selectAddress
        tvRatingBarProfile.rating = user.rating.toFloat()
        etUserNameProfile.text = user.user_name
        etEmailProfile.text = user.email
        etMobileProfile.text = user.phone_number
        if (!user.user_image.isEmpty()) {

            if (ValidationUtils.isCheckUrlOrNot(user.user_image)) {
                Glide.with(activity).load(
                    user.user_image
                ).centerCrop().into(ivProfileImage)
            } else {

                Glide.with(activity)
                    .load(URLConstant.urlUser + user.user_image
                ).centerCrop()
                    .placeholder(R.drawable.customer_unpress)
                    .into(ivProfileImage)
            }
        }

        etFirstNameProfile.text = user.first_name
        etLastNameProfile.text = user.last_name
        countryCodeSpinner.setCountryForPhoneCode(user.country_code.toInt())

        if(etMobileProfile.text.toString().isEmpty()){
            phoneNumAdd.text = getString(R.string.addPhoneNumber)
        }else{
            phoneNumAdd.text = getString(R.string.changePhoneNumber)
        }
    }

    private fun setSpanToAgreementText() {

        val registerSpan = SpannableStringBuilder()

        registerSpan.append(getRegisterSpan())
        registerSpan.append(" ")
        registerSpan.append(resources.getString(R.string.logInSentence))


        tvLoginProfile.text = registerSpan
        tvLoginProfile.movementMethod = LinkMovementMethod.getInstance()
    }


    private fun getRegisterSpan() = getString(R.string.logInMain).makeClickSpannable(
        {
            try {
                val intent = Intent(activity, LoginActivity::class.java)
                startActivityForResultWithDefaultAnimations(
                    intent,
                    ConstantUtils.LOGIN_PROFILE
                )
            } catch (e: ActivityNotFoundException) {
                e.printStackTrace()
            }
        },
        ContextCompat.getColor(activity, R.color.colorBlue),
        true,
        false,
        resources.getString(R.string.logInMain),
        null
    )

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == ConstantUtils.LOGIN_PROFILE && resultCode == Activity.RESULT_OK && data != null) {
            Utils.userId =
                SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)
            initMethod()
            getUserProfileApi()
        }
        else if(requestCode == ConstantUtils.PROFILE_MANAGE_CODE && resultCode == Activity.RESULT_OK){
            getUserProfileApi()
        }
        else if(requestCode == ConstantUtils.PROFILE_MANAGE_CODE && resultCode == Activity.RESULT_CANCELED){

        }
        else if (requestCode == ConstantUtils.LOGIN_ENTER_PHONE_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            if (data != null) {
//              activity.finish()

                getUserProfileApi()
                phoneNumAdd.text = getString(R.string.changePhoneNumber)
//                onBackPress(Activity.RESULT_OK)

            }
        }
    }


}