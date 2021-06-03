package com.quedrop.driver.ui.register.view

import android.os.Bundle
import android.util.Log
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.base.extentions.finishWithAnimation
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import kotlinx.android.synthetic.main.activity_web_view.*
import kotlinx.android.synthetic.main.toolbar_normal.*

class WebViewActivity : BaseActivity() {

    private var intentCheckLink: String? = null
    private var isPrivacyPolicy: Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_web_view)


        intentCheckLink = intent.getStringExtra("Link")
        isPrivacyPolicy = intent.getBooleanExtra("isPrivacyPolicy", false)

        setUpToolBar()

        if (!intentCheckLink.isNullOrEmpty()) {
            Log.e("KayLink2", "--" + intentCheckLink)
            if(isPrivacyPolicy) {
                webView.loadUrl(intentCheckLink)
            }else{
                webView.getSettings().setJavaScriptEnabled(true);
                webView.loadUrl("https://drive.google.com/viewerng/viewer?embedded=true&url=" + intentCheckLink);
            }
        }
    }

    private fun setUpToolBar() {
        if (isPrivacyPolicy) {
            tvTitle.text = resources.getString(R.string.privacy_policy)
        } else {
            tvTitle.text = resources.getString(R.string.termsConditions)
        }
        ivBack.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)
    }

    override fun onBackPressed() {
        super.onBackPressed()
        finishWithAnimation()
    }
}