package com.quedrop.customer.ui.profile.view

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.User
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import kotlinx.android.synthetic.main.activity_toolbar.*
import kotlinx.android.synthetic.main.fragment_referral_code.*
import java.lang.Exception

class ReferralCodeFragment : BaseFragment() {

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
        initMethod()
        onclickMethod()
    }

    companion object {
        fun newInstance(): ReferralCodeFragment {
            return ReferralCodeFragment()
        }
    }

    private fun initMethod() {

        val user: User = SharedPrefsUtils.getModelPreferences(
            activity,
            KeysUtils.keyUser,
            User::class.java
        ) as User


        referralCode = user.refferal_code

        mainReferrals.text = referralCode
    }

    private fun onclickMethod() {

        ivRefferalBack.throttleClicks().subscribe {
            activity.onBackPressed()
        }.autoDispose(compositeDisposable)

        btnInviteReferral.throttleClicks().subscribe() {
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
            //e.toString();
        }
    }
}