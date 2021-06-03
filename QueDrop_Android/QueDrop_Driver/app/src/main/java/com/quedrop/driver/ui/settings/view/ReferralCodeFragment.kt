package com.quedrop.driver.ui.settings.view

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseFragment
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.User
import com.quedrop.driver.utils.KEY_USER
import com.quedrop.driver.utils.SharedPreferenceUtils
import kotlinx.android.synthetic.main.fragment_referral_code.*
import kotlinx.android.synthetic.main.toolbar_normal.*


class ReferralCodeFragment : BaseFragment() {

    companion object {
        fun newInstance(): ReferralCodeFragment {
            return ReferralCodeFragment()
        }
    }

    var referralCode: String? = null

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        return inflater.inflate(
            R.layout.fragment_referral_code,
            container, false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        initViews()
    }

    private fun initViews() {

        val user = (SharedPreferenceUtils.getModelPreferences(KEY_USER, User::class.java)) as User?

        referralCode = user?.refferalCode

        mainReferrals.text = referralCode

        setUpToolBar()
        onClickViews()
    }

    private fun setUpToolBar() {
        tvTitle.text = resources.getString(R.string.my_referral_code)
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
        btnInviteReferral.throttleClicks().subscribe {
            shareReferralCode()
        }.autoDispose(compositeDisposable)
    }

    private fun shareReferralCode() {

        try {
            val intent = Intent().apply {
                action = Intent.ACTION_SEND
                type = "text/plain"
                putExtra(
                    Intent.EXTRA_TEXT,
                    getString(R.string.shareCode) + " : <" + referralCode + ">"
                )
            }
            startActivity(Intent.createChooser(intent, "Share"))

        } catch (e: Exception) {
            e.toString()
        }
    }


}