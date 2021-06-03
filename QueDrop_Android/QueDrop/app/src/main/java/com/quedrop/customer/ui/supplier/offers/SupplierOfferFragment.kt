package com.quedrop.customer.ui.supplier.offers

import android.app.Dialog
import android.os.Bundle
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.appcompat.widget.PopupMenu
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.extentions.startActivityWithAnimation
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.ui.supplier.offers.adapters.SupplierOfferAdapter
import com.quedrop.customer.ui.supplier.offers.viewmodels.SupplierOfferViewModel
import com.quedrop.customer.utils.*
import com.google.gson.JsonObject
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.layout_deletedialog.*
import kotlinx.android.synthetic.main.supplier_offer_fragment.*
import timber.log.Timber

class SupplierOfferFragment : BaseFragment() {

    private var adapter: SupplierOfferAdapter? = null

    companion object {
        fun newInstance() = SupplierOfferFragment()
    }

    private lateinit var viewModel: SupplierOfferViewModel

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.supplier_offer_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        Utils.Supplier.supplierUserId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.KeyUserSupplierId, 0)
        Utils.Supplier.supplierStoreID =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keySupplierStoreId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.KeySupplierAccessKey)!!

        viewModel =
            SupplierOfferViewModel(
                appService
            )
        init()
        getSupplierOfferApi()

    }

    private fun init() {
        recyclerview.layoutManager = LinearLayoutManager(activity)
        swipeRefreshLayout.setOnRefreshListener {
            getSupplierOfferApi()
        }

        fab_add_offer.setOnClickListener {
            activity.startActivityWithAnimation<AddEditOfferActivity> { }
        }

        viewModel.offerList.observe(viewLifecycleOwner, Observer {
            adapter?.offerList = it
            adapter?.notifyDataSetChanged()
        })

        if (adapter == null) {
            adapter = SupplierOfferAdapter(
                activity
            ).apply {
                onActionMenuClick = { position, view ->
                    run {
                        showPopupMenu(view, position)
                    }
                }
            }
            recyclerview.adapter = adapter
        }

        RxBus.instance!!.listen().subscribe {
            if (it == "refreshOffer") { //autorefresh page after add
                getSupplierOfferApi()
            }
        }.autoDispose(compositeDisposable)
    }

    private fun showPopupMenu(view: View, position: Int) {
        val popup = PopupMenu(activity, view, Gravity.BOTTOM)
        popup.menuInflater.inflate(R.menu.supplier_category_menu, popup.menu)
        popup.setOnMenuItemClickListener {
            when (it.itemId) {
                R.id.action_edit -> {
                    activity.startActivityWithAnimation<AddEditOfferActivity> {
                        putExtra("offer", adapter?.offerList?.get(position))
                        putExtra("isEditMode", true)
                    }
                }
                R.id.action_delete -> {
                    dialogDelete(adapter?.offerList?.get(position)?.product_offer_id ?: 0)
                }
            }
            false
        }

        popup.show()
    }

    private fun dialogDelete(id: Int) {

        val dialog = Dialog(activity)
        dialog.setContentView(R.layout.layout_deletedialog)
        dialog.textTitleDelete.setText(getString(R.string.deleteOffer))
        val textOk = dialog.findViewById<TextView>(R.id.dialog_ok)
        val textCancel = dialog.findViewById<TextView>(R.id.dialog_cancel)

        textOk.setOnClickListener {
            dialog.dismiss()
            callDeleteOfferApi(id)
        }

        textCancel.setOnClickListener {
            dialog.dismiss()
        }

        dialog.show()

    }


    private fun getSupplierOfferApi() {
        var dialog: Dialog? = null
        val jsonObject = JsonObject()
        jsonObject.addProperty("user_id", Utils.Supplier.supplierUserId)
        jsonObject.addProperty("store_id", Utils.Supplier.supplierStoreID)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        viewModel.getSupplierOffer(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe { dialog = DialogCaller.showProgressDialog(activity) }
            .doAfterTerminate {
                dialog?.dismiss()
                swipeRefreshLayout.isRefreshing = false
            }
            .subscribe({
                if (it.status) {
                    textNoOffers.visibility = View.GONE
                    viewModel.offerList.value = it.data?.get("offers")
                } else {
                    textNoOffers.visibility = View.VISIBLE
                    textNoOffers.text = it.message
                }
            }, {
                Timber.e(it.localizedMessage)
                // activity.showToast(it.localizedMessage ?: "")
            }).autoDispose(compositeDisposable)
    }

    private fun callDeleteOfferApi(id: Int) {
        var dialog: Dialog? = null
        val jsonObject = JsonObject()
        jsonObject.addProperty("product_offer_id", id)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)

        viewModel.deleteSupplierOffer(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe { dialog = DialogCaller.showProgressDialog(activity) }
            .doAfterTerminate { dialog?.dismiss() }
            .subscribe({
                //  activity.showToast(it.message)
                if (it.status) {
                    val obj =
                        viewModel.offerList.value?.first { it.product_offer_id == id }
                    viewModel.offerList.value?.remove(obj)
                    viewModel.offerList.postValue(viewModel.offerList.value)
                }
            }, {
                Timber.e(it.localizedMessage)
                // activity.showToast(it.localizedMessage ?: "")
            }).autoDispose(compositeDisposable)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        adapter = null
    }
}