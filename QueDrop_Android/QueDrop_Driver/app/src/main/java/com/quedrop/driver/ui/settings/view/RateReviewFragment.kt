package com.quedrop.driver.ui.settings.view

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseFragment
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.RateAndReviews
import com.quedrop.driver.service.request.RateReviewDriverRequest
import com.quedrop.driver.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.driver.ui.settings.adapter.RateReviewDriverAdapter
import com.quedrop.driver.utils.*
import kotlinx.android.synthetic.main.fragment_rate_review.*
import kotlinx.android.synthetic.main.toolbar_normal.*

class RateReviewFragment : BaseFragment() {

    companion object {
        fun newInstance(): RateReviewFragment {
            return RateReviewFragment()
        }
    }

    private var arrayReviewRateList: MutableList<RateAndReviews>? = null
    private var rateReviewDriverAdapter: RateReviewDriverAdapter? = null
    private lateinit var profileViewModel: ProfileViewModel


    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        return inflater.inflate(
            R.layout.fragment_rate_review,
            container, false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        profileViewModel = ProfileViewModel(appService)

        initViews()
    }

    private fun initViews() {
        setUpToolBar()

        rvReviewsDriverDetails.layoutManager = LinearLayoutManager(
            context,
            LinearLayoutManager.VERTICAL,
            false
        )

        arrayReviewRateList = mutableListOf()

        rateReviewDriverAdapter =
            RateReviewDriverAdapter(
                this.context!!,
                arrayReviewRateList!!

            )
        rvReviewsDriverDetails.adapter = rateReviewDriverAdapter

        observeViewModel()
        if (Utility.isNetworkAvailable(context)) {
            getRatingReviewApi()
        } else {
            showAlertMessage(activity, getString(R.string.no_internet_connection))
        }

    }

    private fun setUpToolBar() {
        tvTitle.text = resources.getString(R.string.rating_reviews)
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

    fun observeViewModel() {
        profileViewModel.rateReviewList.observe(viewLifecycleOwner, Observer { it ->
            hideProgress()
            if (it.isNotEmpty()) {
                arrayReviewRateList?.clear()
                arrayReviewRateList?.addAll(it.toMutableList())
                rateReviewDriverAdapter?.notifyDataSetChanged()
            } else {
                showAlertMessage(activity, getString(R.string.no_internet_connection))
            }

        })

        profileViewModel.errorMessage.observe(viewLifecycleOwner, Observer { error ->
            hideProgress()
        })

    }

    private fun getRateReview(): RateReviewDriverRequest {
        return RateReviewDriverRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            SharedPreferenceUtils.getInt(KEY_USERID)
        )
    }

    private fun getRatingReviewApi() {
        showProgress()
        profileViewModel.ratingReviewApi(getRateReview())

    }
}