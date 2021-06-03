package com.quedrop.customer.ui.supplier.payment

import android.app.Dialog
import android.content.res.Configuration
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.showToast
import com.quedrop.customer.base.extentions.startActivityWithAnimation
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.ui.supplier.payment.adapters.ItemControlHelper
import com.quedrop.customer.ui.supplier.payment.adapters.MangePaymentAdapter
import com.quedrop.customer.ui.supplier.payment.viewmodel.ManagePaymentViewModel
import com.quedrop.customer.utils.*
import com.google.gson.JsonObject
import com.quedrop.customer.base.rxjava.throttleClicks
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_toolbar.*
import kotlinx.android.synthetic.main.fragment_manage_payment.*
import timber.log.Timber

/**
 * A simple [Fragment] subclass.
 */
class ManagePaymentActivity : BaseActivity(), ItemControlHelper.ItemControlInterface {

    private var mangePaymentAdapter: MangePaymentAdapter? = null
    private lateinit var viewModel: ManagePaymentViewModel
    private var itemControlHelper: ItemControlHelper? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.fragment_manage_payment)

        Utils.Supplier.supplierUserId = SharedPrefsUtils.getIntegerPreference(this, KeysUtils.KeyUserSupplierId, 0)
        Utils.seceretKey = SharedPrefsUtils.getStringPreference(this, KeysUtils.keySecretKey)!!
        Utils.Supplier.supplierAccessKey = SharedPrefsUtils.getStringPreference(this, KeysUtils.KeySupplierAccessKey)!!

        viewModel = ManagePaymentViewModel(appService)

        initViews()
        getBankDetails()
    }


    private fun initViews() {

        ivBackManagePayment.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose(compositeDisposable)

        rvBankDetails.layoutManager = LinearLayoutManager(
            this,
            LinearLayoutManager.VERTICAL,
            false
        )

        mangePaymentAdapter =
            MangePaymentAdapter(
                this
            )

        rvBankDetails.adapter = mangePaymentAdapter


        itemControlHelper = ItemControlHelper(
            rvBankDetails!!,
            this,
            resources.configuration.orientation == Configuration.ORIENTATION_PORTRAIT
        )


        mangePaymentAdapter?.apply {
            onItemClick = { view, adapterPosition, name ->
                startActivityWithAnimation<AddEditPaymentActivity> {
                    putExtra("isEditMode", true)
                    putExtra("payment", viewModel.bankDetailList.value?.get(adapterPosition))
                }

            }
            onClickDeleteBtn = { view, adapterPosition, s ->
                itemControlHelper?.finishSwiping()
                onCtrlDeleteClick(adapterPosition)

            }
        }

        viewModel.bankDetailList.observe(this, Observer {
            mangePaymentAdapter?.updateData(it)
        })


        viewModel.message.observe(this, Observer {
            hideProgress()


        })


        addBankDetail.setOnClickListener {
            startActivityWithAnimation<AddEditPaymentActivity> { }
        }

        ivBackManagePayment.setOnClickListener {
            onBackPressed()
        }

        RxBus.instance?.listen()?.subscribe {
            if (it == "refreshPaymentList") {
                getBankDetails()
            }
        }?.autoDispose(compositeDisposable)
    }

    private fun onCtrlDeleteClick(position: Int) {
        alertDialog(position)
    }

    private fun alertDialog(position: Int) {

        val dialog = Dialog(this)
        dialog.setContentView(R.layout.layout_deletedialog)

        val textOk = dialog.findViewById<TextView>(R.id.dialog_ok)
        val textCancel = dialog.findViewById<TextView>(R.id.dialog_cancel)
        val textTitleDelete = dialog.findViewById<TextView>(R.id.textTitleDelete)

        textTitleDelete.text = "Are you sure you want to delete?"

        textOk.setOnClickListener {

            textOk.setTextColor(ContextCompat.getColor(this, R.color.colorBlue))
            textCancel.setTextColor(ContextCompat.getColor(this, R.color.colorGrey))
            deleteBankAccount(position)
            Log.e("Yes", ": ")
        }

        textCancel.setOnClickListener {
            textOk.setTextColor(ContextCompat.getColor(this, R.color.colorGrey))
            textCancel.setTextColor(ContextCompat.getColor(this, R.color.colorBlue))
            dialog.dismiss()
        }
        dialog.show()
    }


    private fun getBankDetails() {
        var dialog: Dialog? = null
        val jsonObject = JsonObject()
        jsonObject.addProperty("user_id", Utils.Supplier.supplierUserId)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        viewModel.getUserBankDetailList(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe { dialog = DialogCaller.showProgressDialog(this) }
            .doAfterTerminate { dialog?.dismiss() }
            .subscribe({
                if (it.status) {
                    viewModel.bankDetailList.value = it.data?.get("bank_details")
                } else {
                    showToast(it.message)
                }
            }, {
                Timber.e(it.localizedMessage)
                showToast(it.localizedMessage ?: "")
            }).autoDispose(compositeDisposable)

    }

    private fun deleteBankAccount(position: Int) {
        var dialog: Dialog? = null
        val jsonObject = JsonObject()
        jsonObject.addProperty("user_id", Utils.Supplier.supplierUserId)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        jsonObject.addProperty(
            "bank_detail_id",
            mangePaymentAdapter?.bankDetailArrayList?.get(position)?.bank_detail_id
        )
        viewModel.deleteBankDetail(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe { dialog = DialogCaller.showProgressDialog(this) }
            .doAfterTerminate { dialog?.dismiss() }
            .subscribe({
                if (it.status) {
                    viewModel.message.value = it.message
                    mangePaymentAdapter?.bankDetailArrayList?.removeAt(position)
                    mangePaymentAdapter?.notifyItemRemoved(position)
                } else {
                    // showToast(it.message)
                }
            }, {
                Timber.e(it.localizedMessage)
                //showToast(it.localizedMessage ?: "")
            }).autoDispose(compositeDisposable)

    }

    override fun getItemMovementFlags(position: Int): Int {
        val item = mangePaymentAdapter?.bankDetailArrayList?.get(position)
        var flags = 0
        if (item?.isSwipeFromEnd()!!) flags = flags or ItemControlHelper.SWIPE_FROM_END
        return flags
    }

    override fun getSwipeAndControlViews(
        swipeAndControlViews: Array<View?>,
        viewHolder: RecyclerView.ViewHolder,
        fromStart: Boolean
    ): Boolean {
        val item = mangePaymentAdapter?.bankDetailArrayList?.get(viewHolder.adapterPosition)
        swipeAndControlViews[0] = viewHolder.itemView.findViewById(R.id.card_item)
        swipeAndControlViews[1] = viewHolder.itemView.findViewById(R.id.end_control)
        return item?.isPull()!!
    }

    override fun onItemDragged(position: Int, toPosition: Int): Boolean {
        val saved = mangePaymentAdapter?.bankDetailArrayList?.get(toPosition)
        mangePaymentAdapter?.bankDetailArrayList?.set(
            toPosition,
            mangePaymentAdapter?.bankDetailArrayList?.get(toPosition)!!
        )
        mangePaymentAdapter?.bankDetailArrayList?.set(position, saved!!)
        mangePaymentAdapter?.notifyItemMoved(position, toPosition)
        return true
    }
}
