package com.quedrop.customer.ui.profile.view

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.RateReviewDriverRequest
import com.quedrop.customer.model.RateReviewResponse
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.order.view.fragment.CurrentOrderDetailsFragment
import com.quedrop.customer.ui.profile.view.adapter.RateReviewDriverAdapter
import com.quedrop.customer.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.activity_toolbar.*
import kotlinx.android.synthetic.main.fragment_rate_review.*

class RateReviewFragment : BaseFragment() {

    var arrayReviewRateList: MutableList<RateReviewResponse>? = null
    var rateReviewDriverAdapter: RateReviewDriverAdapter? = null
    lateinit var profileViewModel: ProfileViewModel


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

        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyGuestId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keyAccessKey)!!

        profileViewModel = ProfileViewModel(appService)

        setUpToolbar()
        initMethod()
        observeViewModel()
        getRatingReviewApi()

    }

    private fun setUpToolbar() {
        tvTitle.text = getString(R.string.rateReview)

        ivBack.throttleClicks().subscribe {
            activity.onBackPressed()
        }.autoDispose(compositeDisposable)
    }


    companion object {
        fun newInstance(): RateReviewFragment {
            return RateReviewFragment()
        }
    }

    fun initMethod() {
        rvReviewsDriverDetails.layoutManager = LinearLayoutManager(
            context,
            LinearLayoutManager.VERTICAL,
            false
        )

        arrayReviewRateList = mutableListOf()

        rateReviewDriverAdapter = RateReviewDriverAdapter(
            activity,
            arrayReviewRateList!!

        ).apply {
            driverDetailsInvoke = {
                onClickDetailsFragment(it)
            }
        }
        rvReviewsDriverDetails.adapter = rateReviewDriverAdapter
    }

    fun observeViewModel() {
        profileViewModel.rateReviewList.observe(viewLifecycleOwner, Observer { it ->
            (activity as CustomerMainActivity).hideProgress()
            textEmptyReviews.visibility = View.GONE
            arrayReviewRateList?.clear()
            arrayReviewRateList?.addAll(it.toMutableList())
            rateReviewDriverAdapter?.notifyDataSetChanged()

        })

        profileViewModel.errorMessage.observe(viewLifecycleOwner, Observer { error ->
            (activity as CustomerMainActivity).hideProgress()
            textEmptyReviews.visibility = View.VISIBLE
            textEmptyReviews.text = error
        })

    }

    private fun onClickDetailsFragment(position: Int) {
        (getActivity() as CustomerMainActivity).navigateToFragment(
            CurrentOrderDetailsFragment.newInstance(
                arrayReviewRateList?.get(position)?.order_id!!,
                0,
                ""
            )
        )
    }

    private fun getRateReview(): RateReviewDriverRequest {
        return RateReviewDriverRequest(
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId
        )
    }

    private fun getRatingReviewApi() {
        (activity as CustomerMainActivity).showProgress()
        profileViewModel.ratingReviewApi(getRateReview())

    }
}