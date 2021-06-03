package com.quedrop.driver.ui.settings.view

import android.app.Dialog
import android.os.Bundle
import android.view.View
import android.view.Window
import android.widget.*
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.base.extentions.finishWithAnimation
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.BankDetails
import com.quedrop.driver.ui.settings.adapter.BankListAdapter
import com.quedrop.driver.ui.settings.viewModel.AddEditPaymentViewModel
import com.quedrop.driver.utils.*
import com.quedrop.driver.utils.RxBus
import com.google.gson.JsonObject
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_add_edit_payment.*
import kotlinx.android.synthetic.main.toolbar_normal.*
import timber.log.Timber

class AddEditPaymentActivity : BaseActivity() {

    private lateinit var viewModel: AddEditPaymentViewModel
    private var adapter: BankListAdapter? = null
    private var selectedBankId = 0
    private var bankAccountType: String? = null
    private var isEditMode: Boolean = false
    private var orderDetail: BankDetails? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_edit_payment)
        viewModel = AddEditPaymentViewModel(appService)
        isEditMode = intent.hasExtra("isEditMode")
        init()
        setUpToolBar()
        getAllBankList()

    }

    private fun setUpToolBar() {
        if (isEditMode) {
            orderDetail = intent.getSerializableExtra("payment") as BankDetails
            tvTitle.text = "Edit Bank Details"
            btnAdd.text = "Save"
            setData()
        } else {
            tvTitle.text = resources.getString(R.string.add_bank_account)
        }
        ivBack.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)
    }


    private fun init() {

        btnAdd.setOnClickListener {
            if (validateData()) {
                callAddPaymentMethodApi()
            }
        }

        etBankName.setOnClickListener {
            openBankChooserDialog()
        }

        radioGroup.setOnCheckedChangeListener(object : RadioGroup.OnCheckedChangeListener {
            override fun onCheckedChanged(p0: RadioGroup?, p1: Int) {
                when (p1) {
                    radioSaving.id -> {
                        bankAccountType = BANK_ACCOUNT_SAVING

                    }
                    radioCurrent.id -> {
                        bankAccountType = BANK_ACCOUNT_CURRENT
                    }
                }
            }

        })

        viewModel.bankList.observe(this, androidx.lifecycle.Observer {
            if (adapter != null) {
                adapter?.bankList = it
                adapter?.notifyDataSetChanged()
            }
        })
    }

    private fun setData() {
        orderDetail?.let {
            etBankName.setText(it.bankName)
            etAccountNumber.setText(it.accountNumber)
            etIfscCode.setText(it.ifsc_code)
            etAdditionalInfo.setText(it.otherDetail)
            when (it.accountType) {
                BANK_ACCOUNT_SAVING -> {
                    radioSaving.isChecked = true
                }
                BANK_ACCOUNT_CURRENT -> {
                    radioCurrent.isChecked = true
                }
            }
            selectedBankId = it.bankId!!
        }
    }

    private fun validateData(): Boolean {
        if (etBankName.text.toString().isNotEmpty()) {
            if (!bankAccountType.isNullOrEmpty()) {
                if (etAccountNumber.text.toString().isNotEmpty()) {
                    if (etIfscCode.text.toString().isNotEmpty()) {
                        return true
                    } else {
                        etIfscCode.error = "IFSC code required"
                    }
                } else {
                    etAccountNumber.error = "Account number required"
                }
            } else {
                showToast("please select bank type")
            }
        } else {
            etBankName.error = "choose bank"
        }
        return false
    }

    private fun getAllBankList() {

        val jsonObject = JsonObject()
        jsonObject.addProperty("secret_key", SharedPreferenceUtils.getString(KEY_TOKEN))
        jsonObject.addProperty("access_key", ACCESS_KEY)
        viewModel.getAllBankList(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe { }
            .doAfterTerminate {}
            .subscribe({
                if (it.status) {
                    val list = it.data?.get("banks")
                    viewModel.bankList.value = list
                } else {
                    showToast(it.message)
                }
            }, {
                Timber.e(it.localizedMessage)
                showToast(it.localizedMessage ?: "")
            }).autoDispose(compositeDisposable)
    }

    private fun callAddPaymentMethodApi() {
        var dialog: Dialog? = null
        val jsonObject = JsonObject()
        if (isEditMode) {
            jsonObject.addProperty("bank_detail_id", orderDetail?.bankDetailId)
        }
        jsonObject.addProperty("user_id", SharedPreferenceUtils.getInt(KEY_USERID))
        jsonObject.addProperty("bank_id", selectedBankId)
        jsonObject.addProperty("account_type", bankAccountType)
        jsonObject.addProperty("account_number", etAccountNumber.text.toString())
        jsonObject.addProperty("ifsc_number", etIfscCode.text.toString())
        jsonObject.addProperty("other_detail", etAdditionalInfo.text.toString())
        jsonObject.addProperty("is_primary", 1)
        jsonObject.addProperty("secret_key", SharedPreferenceUtils.getString(KEY_TOKEN))
        jsonObject.addProperty("access_key", ACCESS_KEY)

        val response = if (isEditMode) {
            viewModel.editPaymentDetail(jsonObject)
        } else {
            viewModel.addPaymentDetail(jsonObject)
        }

        response.observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe { showProgress() }
            .doAfterTerminate { hideProgress() }
            .subscribe({
                applicationContext.showToast(it.message)
                if (it.status) {
                    RxBus.instance?.publish("refreshPaymentList")
                    finish()
                }
            }, {
                Timber.e(it.localizedMessage)
                showToast(it.localizedMessage ?: "")
            }).autoDispose(compositeDisposable)
    }

    private fun openBankChooserDialog() {
        val dialog = Dialog(this)
        dialog.apply {
            setContentView(R.layout.layout_dialog_item_select)
            window?.addFlags(Window.FEATURE_NO_TITLE)
            window?.setBackgroundDrawableResource(android.R.color.transparent)
            window?.setLayout(
                (getDeviceWidth(context) * 0.90).toInt(),
                (getDeviceHeight(context) * 0.80).toInt()
            )
        }

        val imgCancel: ImageView = dialog.findViewById(R.id.img_cancel)
        val btn_next: Button = dialog.findViewById(R.id.btn_next)
        val tvTitle: TextView = dialog.findViewById(R.id.tvTitle)
        val et_search: EditText = dialog.findViewById(R.id.et_search)
        et_search.visibility = View.GONE
        tvTitle.text = "Select Bank"
        val recyclerview: RecyclerView = dialog.findViewById(R.id.recyclerView)
        recyclerview.layoutManager = LinearLayoutManager(this)
        adapter = BankListAdapter(this)
        recyclerview.adapter = adapter
        viewModel.bankList.value?.let {
            adapter?.bankList = it
            adapter?.notifyDataSetChanged()
        }

        imgCancel.setOnClickListener { dialog.dismiss() }
        btn_next.setOnClickListener { dialog.dismiss() }
        dialog.show()
        adapter?.apply {
            onItemClick = { id, name ->
                etBankName.error = null
                etBankName.setText(name)
                selectedBankId = id
                dialog.dismiss()

            }
        }
    }

    override fun onBackPressed() {
        super.onBackPressed()
        finishWithAnimation()
    }

}
