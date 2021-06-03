package com.quedrop.driver.ui.orderDetailsFragment.viewModel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.driver.viewModel.BaseViewModel
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.service.ApiService
import com.quedrop.driver.service.model.Orders
import com.quedrop.driver.service.request.RemoveOrderReceiptRequest
import com.quedrop.driver.service.request.SingleOrderRequest
import com.quedrop.driver.service.request.UploadOrderReceipt
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class OrderDetailViewModel(private val apiService: ApiService) : BaseViewModel() {
    val errorMessage: MutableLiveData<String> = MutableLiveData()
    val receiptUploaded: MutableLiveData<Boolean> = MutableLiveData()

    val singleOrderDetailArrayList: MutableLiveData<Orders> = MutableLiveData()


    fun getSingleOrderDetail(singleOrderRequest: SingleOrderRequest) {
        apiService.getSingleOrderDetail(singleOrderRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ orderDetailResponse ->
                if (orderDetailResponse.status) {
                    singleOrderDetailArrayList.value = orderDetailResponse.data.singleOrders

                } else {
                    errorMessage.value = orderDetailResponse.message
                }
            }, {

                //Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun uploadOrderReceipt(uploadOrderReceipt: UploadOrderReceipt) {
        apiService.uploadOrderReceipt(
            uploadOrderReceipt.orderId,
            uploadOrderReceipt.orderStoreId,
            uploadOrderReceipt.secretKey,
            uploadOrderReceipt.accessKey,
            uploadOrderReceipt.receipt,
            uploadOrderReceipt.userId,
            uploadOrderReceipt.billAmount
        )
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ orderDetailResponse ->
                if (orderDetailResponse.status!!) {
                    receiptUploaded.value = orderDetailResponse.status

                } else {
                    errorMessage.value = orderDetailResponse.message
                }
            }, {

                //Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }


    //remove order receipt
    val removeReceiptObserver: MutableLiveData<String>? =  MutableLiveData()
    fun removeOrderReceipt(removeOrderReceiptRequest: RemoveOrderReceiptRequest) {
        apiService.removeOrderReceipt(removeOrderReceiptRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ orderDetailResponse ->
                if (orderDetailResponse.status) {
                    removeReceiptObserver?.value = orderDetailResponse.message
                } else {
                    errorMessage.value = orderDetailResponse.message
                }
            }, {
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }


}

