package com.quedrop.customer.ui.addaddress.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface

import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class AddAddressViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val addressListEdit: MutableLiveData<List<Address>> = MutableLiveData()
    val addressListAdd: MutableLiveData<List<Address>> = MutableLiveData()

    fun getAddAddressApi(addAddressRequest: AddAddress) {
        apiService.addAddress(addAddressRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ addressResponse ->

                if (addressResponse.status) {
                    addressListEdit.value = addressResponse.data.addresses
                }else{
                    errorMessage.value = addressResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }


    fun getEditAddressApi(editAddressRequest: EditAddress) {
        apiService.editAddress(editAddressRequest)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ addressResponse ->

                if (addressResponse.status) {
                    addressListAdd.value = addressResponse.data.addresses
                }else{
                    errorMessage.value = addressResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

}