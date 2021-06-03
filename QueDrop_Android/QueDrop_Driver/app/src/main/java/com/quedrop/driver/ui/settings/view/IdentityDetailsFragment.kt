package com.quedrop.driver.ui.settings.view


import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.bumptech.glide.Glide
import com.quedrop.driver.BuildConfig
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseFragment
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.DriverDetails
import com.quedrop.driver.service.request.RateReviewDriverRequest
import com.quedrop.driver.ui.identityverification.IdentityVerificationActivity
import com.quedrop.driver.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.driver.utils.*
import com.google.gson.Gson
import kotlinx.android.synthetic.main.activity_identity_verification.*
import kotlinx.android.synthetic.main.fragment_identity_details.*
import kotlinx.android.synthetic.main.fragment_identity_details.tvAddLicense
import kotlinx.android.synthetic.main.fragment_identity_details.tvAddNumberPlate
import kotlinx.android.synthetic.main.fragment_identity_details.tvAddRegProof
import kotlinx.android.synthetic.main.toolbar_normal.*

/**
 * A simple [Fragment] subclass.
 */
class IdentityDetailsFragment : BaseFragment() {

    companion object {
        fun newInstance(): IdentityDetailsFragment {
            return IdentityDetailsFragment()
        }
    }

    lateinit var mContext: Context
    lateinit var profileViewModel: ProfileViewModel
    var driverDeatails: DriverDetails? = null

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        val view = inflater.inflate(R.layout.fragment_identity_details, container, false)
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
        if (Utility.isNetworkAvailable(context)) {
            btnEdit.isEnabled = true
            getIdentityDetails()
        } else {
            hideProgress()
            btnEdit.isEnabled = false
            showAlertMessage(activity, getString(R.string.no_internet_connection))
        }

        observeViewModel()
        onClickViews()
    }

    private fun onClickViews() {
        btnEdit.throttleClicks().subscribe {
            startActivityWithDefaultAnimations(
                Intent(
                    mContext,
                    IdentityVerificationActivity::class.java
                ).putExtra(KEY_EDIT_IDENTITY, Gson().toJson(driverDeatails))
                    .putExtra(KEY_FROM_EDIT_IDENTITY, true)
            )
        }.autoDispose(compositeDisposable)
    }

    private fun setUpToolBar() {
        tvTitle.text = resources.getString(R.string.identity_details)
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

    private fun observeViewModel() {

        profileViewModel.identityDetails.observe(
            viewLifecycleOwner,
            androidx.lifecycle.Observer {
                driverDeatails = it
                hideProgress()
                setUpData(driverDeatails!!)
            })

        profileViewModel.errorMessage.observe(viewLifecycleOwner, androidx.lifecycle.Observer {
            hideProgress()

        })
    }

    private fun setUpData(it: DriverDetails) {
        val imageExtension: String = BuildConfig.BASE_URL + ImageConstant.DRIVER_DETAILS
        Glide.with(this).load(imageExtension + it.licencePhoto).placeholder(R.drawable.ic_add_photo).into(ivEditLicense)
        Glide.with(this).load(imageExtension + it.driverPhoto).placeholder(R.drawable.ic_add_photo).into(ivEditProfile)
        Glide.with(this).load(imageExtension + it.registrationProof).placeholder(R.drawable.ic_add_photo).into(ivEditRegProof)
        Glide.with(this).load(imageExtension + it.numberPlate).placeholder(R.drawable.ic_add_photo).into(ivEditAddNumberPlate)

        when (it.vehicleType) {
            TYPE_CAR -> {
                whenCycle(false)
                ivEditCar.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_car_selected
                    )
                )
                ivEditBike.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_scooter_normal
                    )
                )
                ivEditCycle.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_cycle_normal
                    )
                )
            }
            TYPE_BIKE -> {
                whenCycle(false)
                ivEditCar.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_car_normal
                    )
                )
                ivEditBike.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_scooter_selected
                    )
                )
                ivEditCycle.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_cycle_normal
                    )
                )
            }
            TYPE_CYCLE -> {
                whenCycle(true)
                ivEditCar.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_car_normal
                    )
                )
                ivEditBike.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_scooter_normal
                    )
                )
                ivEditCycle.setImageDrawable(
                    ContextCompat.getDrawable(
                        mContext,
                        R.drawable.ic_cycle_selected
                    )
                )
            }
        }

    }

    private fun identityRequest(): RateReviewDriverRequest {
        return RateReviewDriverRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            SharedPreferenceUtils.getInt(KEY_USERID)
        )
    }

    private fun getIdentityDetails() {
        showProgress()
        profileViewModel.getIdentityDetails(identityRequest())

    }


    fun whenCycle(hide:Boolean){
        if(hide) {
            tvAddLicense.visibility = View.GONE
            ivEditLicense.visibility = View.GONE
            tvAddRegProof.visibility = View.GONE
            ivEditRegProof.visibility = View.GONE
            tvAddNumberPlate.visibility = View.GONE
            ivEditAddNumberPlate.visibility = View.GONE
        }else{
            tvAddLicense.visibility = View.VISIBLE
            ivEditLicense.visibility = View.VISIBLE
            tvAddRegProof.visibility = View.VISIBLE
            ivEditRegProof.visibility = View.VISIBLE
            tvAddNumberPlate.visibility = View.VISIBLE
            ivEditAddNumberPlate.visibility = View.VISIBLE
        }
    }

}
