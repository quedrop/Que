package com.quedrop.customer.ui.selectaddress.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface

import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class SelectAddressViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val addressList: MutableLiveData<List<Address>> = MutableLiveData()
    val userGuest: MutableLiveData<GuestUser> = MutableLiveData()



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


    fun guestRegisterApi(guestRegister: AddGuestRegister) {
        apiService.guestRegister(guestRegister)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ userResponse ->

                if (userResponse.status) {
                    userGuest.value = userResponse.data.guest_user
                }else{
                    errorMessage.value = userResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }


    fun deleteAddressApi(deleteAddress: DeleteAddress) {
        apiService.deleteAddress(deleteAddress)
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ deleteAddressResponse ->

                if (deleteAddressResponse.status) {
                    message.value = deleteAddressResponse.message
                }else{
                    errorMessage.value = deleteAddressResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }


}