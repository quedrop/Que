package com.quedrop.customer.ui.supplier.profile

import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.extentions.getStoreLogo
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.extentions.startActivityWithAnimation
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.GetUserProfileDetailRequest
import com.quedrop.customer.model.SupplierStoreDetail
import com.quedrop.customer.model.User
import com.quedrop.customer.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.customer.ui.supplier.store.StoreDetailActivity
import com.quedrop.customer.ui.supplier.supplierverifyphone.SupplierEnterPhoneNumberActivity
import com.quedrop.customer.utils.*
import com.google.gson.JsonObject
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.profile_supplier_fragment.*
import kotlinx.android.synthetic.main.profile_supplier_fragment.countryCodeSpinner
import kotlinx.android.synthetic.main.profile_supplier_fragment.etEmailProfile
import kotlinx.android.synthetic.main.profile_supplier_fragment.etFirstNameProfile
import kotlinx.android.synthetic.main.profile_supplier_fragment.etLastNameProfile
import kotlinx.android.synthetic.main.profile_supplier_fragment.etMobileProfile
import kotlinx.android.synthetic.main.profile_supplier_fragment.etUserNameProfile
import kotlinx.android.synthetic.main.profile_supplier_fragment.ivProfileImage
import timber.log.Timber


class ProfileSupplierFragment : BaseFragment() {

    private lateinit var profileViewModel: ProfileViewModel
    private lateinit var personDisposable: Disposable
    private lateinit var user:User

    companion object {
        fun newInstance() = ProfileSupplierFragment()
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.profile_supplier_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initMethod()
    }

    private fun initMethod() {

        Utils.Supplier.supplierUserId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.KeyUserSupplierId, 0)

        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.Supplier.supplierAccessKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeySupplierAccessKey)!!

        profileViewModel =
            ProfileViewModel(appService)

        observeViewModel()
        onClickMethod()
        getUserProfileApi()

        RxBus.instance?.listen()?.subscribe {
            if (it == "refreshSupplierProfile") {
                getUserProfileApi()
            }
        }?.autoDispose(compositeDisposable)

        try {
            val pInfo: PackageInfo =
                requireContext().packageManager.getPackageInfo(activity.packageName, 0)
            val version = pInfo.versionName
            tvVersion.text = getString(R.string.versionName) + " " + version
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
        }

        profileViewModel.storeDetail.observe(viewLifecycleOwner, Observer {
            setUpStoreData(it)
        })

        callGetStoreDetails()

        personDisposable = RxBus.instance?.listen(SupplierStoreDetail::class.java)?.subscribe {
//            setUpStoreData(it)
            callGetStoreDetails()
        }!!
    }

    private fun setUpStoreData(it: SupplierStoreDetail) {
        Glide.with(activity).load(activity.getStoreLogo(it.store_logo))
            .centerCrop().into(imgStore)
        tvStoreName.text = it.store_name
        tvStoreAddress.text = it.store_address
    }

    private fun onClickMethod() {

        ivSettingsProfile.throttleClicks().subscribe {

            navigateSettingInvoke()

        }.autoDispose(compositeDisposable)

        editProfileIV.throttleClicks().subscribe() {
            navigateEditProfileInvoke()
        }.autoDispose(compositeDisposable)

        btnChangeProfilePhn.throttleClicks().subscribe() {
            var intent = Intent(context, SupplierEnterPhoneNumberActivity::class.java)
                .putExtra("PhoneNumber", etMobileProfile.text.toString())
                .putExtra("CountryCode", user.country_code)
            startActivityForResultWithDefaultAnimations(
                intent,
                ConstantUtils.LOGIN_ENTER_PHONE_REQUEST_CODE
            )
        }.autoDispose(compositeDisposable)

        cardStoreDetail.throttleClicks().subscribe {
            activity.startActivityWithAnimation<StoreDetailActivity> {
                putExtra("store", profileViewModel.storeDetail.value)
            }
        }.autoDispose(compositeDisposable)

    }

    private fun navigateSettingInvoke() {
        activity.startActivityWithAnimation<SupplierSettingActivity> { }
    }

    private fun navigateEditProfileInvoke() {
        activity.startActivityWithAnimation<SupplierEditProfileActivity> { }
    }


    fun onPageSelected(position: Int) {
        getUserProfileApi()
    }

    private fun observeViewModel() {
        profileViewModel.user.observe(viewLifecycleOwner, Observer {
            user=it
            setAllUserDetails(it)
        })
    }

    private fun getUserProfileApi() {
        profileViewModel.getUserProfileApi(
            GetUserProfileDetailRequest(
                Utils.seceretKey,
                Utils.Supplier.supplierAccessKey,
                Utils.Supplier.supplierUserId
            )
        )
    }

    private fun setAllUserDetails(user: User) {
        etFirstNameProfile.text = user.first_name
        etLastNameProfile.text = user.last_name
        etUserNameProfile.text = user.user_name
        etEmailProfile.text = user.email
        etMobileProfile.text = user.phone_number
        if (user.user_image.isNotEmpty()) {

            if (ValidationUtils.isCheckUrlOrNot(user.user_image)) {
                Glide.with(activity).load(
                    user.user_image
                ).centerCrop().into(ivProfileImage)
            } else {

                Glide.with(activity)
                    .load(URLConstant.urlUser+ user.user_image)
                    .centerCrop()
                    .placeholder(R.drawable.customer_unpress)
                    .into(ivProfileImage)
            }

        }

        countryCodeSpinner.setCountryForPhoneCode(user.country_code.toInt())
    }


    private fun callGetStoreDetails(){
        val jsonObject = JsonObject()
        jsonObject.addProperty("store_id", Utils.Supplier.supplierStoreID)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        profileViewModel.getStoreDetails(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({
                if (it.status) {
                    profileViewModel.storeDetail.value = it.data?.get("store_detail")
                }else{
                   // activity.showToast(it.message)
                }
            }, {
                Timber.e(it.localizedMessage)
               // activity.showToast(it.localizedMessage ?: "")
            }).autoDispose(compositeDisposable)
    }

    override fun onResume() {
        super.onResume()

    }

    override fun onDestroy() {
        super.onDestroy()
        if (!personDisposable.isDisposed) personDisposable.dispose()
    }
}
