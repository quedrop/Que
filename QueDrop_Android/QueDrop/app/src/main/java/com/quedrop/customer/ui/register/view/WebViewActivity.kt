package com.quedrop.customer.ui.register.view

import android.graphics.Bitmap
import android.os.Bundle
import android.util.Log
import android.webkit.WebView
import android.webkit.WebViewClient
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.utils.KeysUtils
import kotlinx.android.synthetic.main.activity_web_view.*

class WebViewActivity : BaseActivity() {

    var intentCheckLink: String? = null
    var isPrivacyPolicy: Boolean = false
    var isTermsAndCondition: Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_web_view)

        initViews()


    }

    private fun initViews() {

        intentCheckLink = intent.getStringExtra(KeysUtils.keyLink)
        isPrivacyPolicy = intent.getBooleanExtra(KeysUtils.isPrivacyPolicy, false)
        isTermsAndCondition = intent.getBooleanExtra(KeysUtils.isTermsAndCondition, false)

        setUpToolbar()

        Log.e("KayLink", "--" + intentCheckLink)

        if (!intentCheckLink.isNullOrEmpty()) {
            Log.e("KayLink2", "--" + intentCheckLink)
            if (isTermsAndCondition) {
                webView.loadUrl(intentCheckLink)
            } else {
                //webView.getSettings().setJavaScriptEnabled(true);
                //webView.loadUrl("https://drive.google.com/viewerng/viewer?embedded=true&url=" + intentCheckLink);

                showPdfFile(intentCheckLink!!)
            }
        }
    }

    private fun setUpToolbar() {

        if (isPrivacyPolicy) {
            tvTitle.text = "Privacy Policy"
        } else {
            tvTitle.text = "Terms and Condition"
        }

        ivBack.throttleClicks().subscribe {
            finish()
        }.autoDispose(compositeDisposable)
    }

    private fun showPdfFile(imageString: String) {
        showProgress()
        webView.invalidate()
        webView.settings.javaScriptEnabled = true
        webView.settings.setSupportZoom(true)
        webView.loadUrl("http://docs.google.com/gview?embedded=true&url=$imageString")
        webView.webViewClient = object : WebViewClient() {
            var checkOnPageStartedCalled = false
            override fun onPageStarted(
                view: WebView,
                url: String,
                favicon: Bitmap?
            ) {
                checkOnPageStartedCalled = true
            }

            override fun onPageFinished(view: WebView, url: String) {
                if (checkOnPageStartedCalled) {
                    hideProgress()
                } else {
                    showPdfFile(imageString)
                }
            }
        }
    }
}
