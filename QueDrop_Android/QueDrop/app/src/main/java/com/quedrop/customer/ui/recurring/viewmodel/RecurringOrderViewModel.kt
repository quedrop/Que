package com.quedrop.customer.ui.recurring.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface

import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class RecurringOrderViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val addressList: MutableLiveData<List<Address>> = MutableLiveData()
    val user: MutableLiveData<User> = MutableLiveData()



    fun getCustomAddressApi(customerAddressRequest: AddCustomerAddress) {


        apiService.getCustomerAddress(customerAddressRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ addressResponse ->

                if (addressResponse.status) {
                    addressList.value = addressResponse.data.addresses
                }else{
                    errorMessage.value = addressResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

}