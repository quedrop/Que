package com.quedrop.customer.ui.supplier.product

import android.app.Dialog
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.Gravity
import android.view.View
import android.widget.TextView
import androidx.appcompat.widget.PopupMenu
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.GridLayoutManager
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.showToast
import com.quedrop.customer.base.extentions.startActivityWithAnimation
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.ui.supplier.product.viewmodel.SupplierProductViewModel
import com.quedrop.customer.utils.*
import com.google.gson.JsonObject
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_supplier_product.*
import kotlinx.android.synthetic.main.layout_deletedialog.*
import timber.log.Timber

class SupplierProductActivity : BaseActivity() {

    var categoryId: Int? = null
    private lateinit var viewModel: SupplierProductViewModel
    private var adapter: SupplierProductAdapter? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_supplier_product)
        categoryId = intent.getIntExtra("categoryId", 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(this, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(this, KeysUtils.KeySupplierAccessKey)!!

        init()
        callGetProductApi()
        viewModel.productList.observe(this, Observer {

            if (adapter == null) {
                adapter = SupplierProductAdapter(this,false).apply {
                    onActionMenuClick = { position, view ->
                        showPopupMenu(view, position)
                    }
                }
                recyclerview.adapter = adapter
            }

            adapter?.productList = it
            adapter?.notifyDataSetChanged()

        })
    }

    private fun init() {
        viewModel =
            SupplierProductViewModel(
                appService
            )
        recyclerview.layoutManager = GridLayoutManager(this, 2)

        imgSearch.setOnClickListener {
            if (rl_search.visibility == View.VISIBLE) {
                editSearch.setText("")
                rl_search.visibility = View.GONE
            } else {
                rl_search.visibility = View.VISIBLE
            }
        }

        editSearch.addTextChangedListener(object : TextWatcher {
            private var searchFor = ""
            override fun afterTextChanged(p0: Editable?) {}

            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}

            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
                val searchText = p0.toString().trim()
                if (searchText == searchFor)
                    return

                searchFor = searchText
                callSearchProductApi(searchFor)
            }
        })

        swipeRefreshLayout.setOnRefreshListener {
            callGetProductApi()
        }

        fabAddProduct.setOnClickListener {
            startActivityWithAnimation<AddProductActivity> {
                putExtra("categoryId", categoryId)
            }
        }

        RxBus.instance!!.listen().subscribe {
            if (it == "refreshProduct") { //autorefresh page after add
                callGetProductApi()
            }
        }.autoDispose(compositeDisposable)
    }

    private fun callGetProductApi() {
        var dialog: Dialog? = null
        val jsonObject = JsonObject()
        jsonObject.addProperty("store_category_id", categoryId)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.accessKey)
        viewModel.getSupplierProducts(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe { dialog = DialogCaller.showProgressDialog(this) }
            .doAfterTerminate {
                dialog?.dismiss()
                swipeRefreshLayout.isRefreshing = false
            }
            .subscribe({
                if (it != null && it.status) {
                    val products = it.data?.get("products")
                    viewModel.productList.value = products

                } else {
                    Timber.e(it.message)
                    //showToast(it.message)
                }
            }, {
                showToast(it.localizedMessage ?: "")
            }).autoDispose(compositeDisposable)
    }

    private fun callSearchProductApi(searchtext: String) {
        val jsonObject = JsonObject()
        jsonObject.addProperty("store_category_id", categoryId)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        jsonObject.addProperty("searchText", searchtext)
        jsonObject.addProperty("page_num", 1)
        viewModel.searchSupplierProducts(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe {}
            .doAfterTerminate {}
            .subscribe({
                if (it != null && it.status) {
                    val products = it.data?.get("products")
                    viewModel.productList.value = products

                } else {
                    Timber.e(it.message)
                   // showToast(it.message)
                }
            }, {
                showToast(it.localizedMessage ?: "")
            }).autoDispose(compositeDisposable)
    }

    private fun showPopupMenu(view: View, position: Int) {
        val popup = PopupMenu(this, view, Gravity.BOTTOM)
        popup.menuInflater.inflate(R.menu.supplier_category_menu, popup.menu)
        popup.setOnMenuItemClickListener {
            when (it.itemId) {
                R.id.action_edit -> {
                    startActivityWithAnimation<AddProductActivity> {
                        putExtra("isEditMode", true)
                        putExtra("product", adapter?.productList?.get(position))
                    }
                }
                R.id.action_delete -> {
                    dialogDelete(adapter?.productList?.get(position)?.product_id ?: "0")
                }
            }
            false
        }
        popup.show()
    }

    private fun dialogDelete(id: String) {

        val dialog = Dialog(this)
        dialog.setContentView(R.layout.layout_deletedialog)
        dialog.textTitleDelete.setText(getString(R.string.deleteProduct))
        val textOk = dialog.findViewById<TextView>(R.id.dialog_ok)
        val textCancel = dialog.findViewById<TextView>(R.id.dialog_cancel)

        textOk.setOnClickListener {
            dialog.dismiss()
            callDeleteProductApi(id)
        }

        textCancel.setOnClickListener {
            dialog.dismiss()
        }

        dialog.show()
    }

    private fun callDeleteProductApi(productId: String) {
        var dialog: Dialog? = null
        val jsonObject = JsonObject()
        jsonObject.addProperty("product_id", productId)
        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        viewModel.deleteSupplierProducts(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe { dialog = DialogCaller.showProgressDialog(this) }
            .doAfterTerminate { dialog?.dismiss() }
            .subscribe({ response ->
                showToast(response.message)
                if (response.status) {
                    val obj =
                        viewModel.productList.value?.first { it.store_category_id == productId }
                    viewModel.productList.value?.remove(obj)
                    viewModel.productList.postValue(viewModel.productList.value)
                }
            }, {
                showToast(it.localizedMessage ?: "")
            }).autoDispose(compositeDisposable)
    }
}
