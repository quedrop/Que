package com.quedrop.customer.ui.supplier.myorders

import android.Manifest
import android.content.Intent
import android.content.Intent.ACTION_CALL
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.view.View
import androidx.core.app.ActivityCompat
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.bumptech.glide.request.RequestOptions
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.getCalenderDate
import com.quedrop.customer.base.extentions.getDateInFormatOf
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.SupplierOrder
import com.quedrop.customer.ui.supplier.myorders.adapter.OrderDetailProductAdapter
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import com.google.gson.JsonObject
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_supplier_order_detail.*
import timber.log.Timber


class SupplierOrderDetailActivity : BaseActivity() {

    private var adapter: OrderDetailProductAdapter? = null
    private lateinit var orderDetail: SupplierOrder
    private val PERMISSION_ID: Int = 1

    lateinit var orderViewModel: SupplierOrderViewModel
    var orderId: Int = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_supplier_order_detail)

        orderId = intent.getIntExtra("order_id", 0)

        orderViewModel = SupplierOrderViewModel(appService)

        Utils.Supplier.supplierUserId =
            SharedPrefsUtils.getIntegerPreference(this, KeysUtils.KeyUserSupplierId, 0)
        Utils.Supplier.supplierStoreID =
            SharedPrefsUtils.getIntegerPreference(this, KeysUtils.keySupplierStoreId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(this, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(this, KeysUtils.KeySupplierAccessKey)!!


        init()
        getSingleSupplierOrderDetail(orderId)
        //displayData(it)
    }

    private fun init() {


        rvProduct.layoutManager = LinearLayoutManager(this)
        if (adapter == null) {
            adapter = OrderDetailProductAdapter(this)
            rvProduct.adapter = adapter
        }

        ivCall.setOnClickListener {
            OpenDialer()
        }

        ivBack.setOnClickListener {
            onBackPressed()
        }

        orderViewModel.singleOrderList.observe(this, Observer {

            displayData(it)
        })


    }

    private fun displayData(orderDetail: SupplierOrder) {

        adapter?.orderItemList = orderDetail.products
        adapter?.notifyDataSetChanged()


        val date = orderDetail.created_at
        val cal = date.getCalenderDate("yyyy-MM-dd HH:mm:ss")
        val formatedDate = cal.getDateInFormatOf("dd-MM-yyyy")
        val formatedTime = cal.getDateInFormatOf("hh:mm a")

        tvOrderId.text = "#${orderDetail.order_id}"
        tvOrderDate.text = formatedDate
        tvOrderTime.text = formatedTime
        val lastName:String= orderDetail.customer_detail.last_name
        val first: Char = lastName[0]
        tvDriverName.text = "${orderDetail.driver_detail.first_name} ${orderDetail.driver_detail.last_name}"
        tvCustomerName.text =orderDetail.customer_detail.first_name+" "+ first+"."

        tvPhone.text = orderDetail.customer_detail.phone_number
        Glide.with(this)
            .load(orderDetail.customer_detail.user_image)
            .override(300, 300)
            .centerCrop()
            .placeholder(R.drawable.customer_unpress)
            .apply(RequestOptions.circleCropTransform())
            .into(ivProfile)
    }

    private fun getSingleSupplierOrderDetail(orderId: Int) {
        val jsonObject = JsonObject()

        jsonObject.addProperty("secret_key", Utils.seceretKey)
        jsonObject.addProperty("access_key", Utils.Supplier.supplierAccessKey)
        jsonObject.addProperty("user_id", Utils.Supplier.supplierUserId)
        jsonObject.addProperty("order_id", orderId)
        jsonObject.addProperty("store_id", Utils.Supplier.supplierStoreID)


        orderViewModel.getSingleSupplierOrderDetail(jsonObject)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .doOnSubscribe { }
            .doAfterTerminate { }
            .subscribe({
                if (it.status) {
                    linearOrder.visibility=View.VISIBLE
                    textNoOrderDetail.visibility=View.GONE
                    orderViewModel.singleOrderList.value = it.data?.get("order_detail")
                } else {
                    linearOrder.visibility=View.GONE
                    textNoOrderDetail.visibility=View.VISIBLE
                    textNoOrderDetail.text=it.message
                }
            }, {
                Timber.e(it.localizedMessage)
                //  activity.showToast(it.localizedMessage ?: "")
            }).autoDispose(compositeDisposable)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == PERMISSION_ID) {
            if ((grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)) {

                OpenDialer()
            }
        }
    }

    private fun OpenDialer() {
        val intent =
            Intent(ACTION_CALL, Uri.parse("tel:" + orderDetail.customer_detail.phone_number))
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE)
            == PackageManager.PERMISSION_GRANTED
        ) {
            startActivity(intent)
        } else {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.CALL_PHONE),
                PERMISSION_ID
            )
        }
    }
}
