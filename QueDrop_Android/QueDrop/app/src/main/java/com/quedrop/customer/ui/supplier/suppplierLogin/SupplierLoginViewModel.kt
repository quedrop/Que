package com.quedrop.customer.ui.supplier.suppplierLogin

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.LoginRequest
import com.quedrop.customer.model.TokenRequest
import com.quedrop.customer.model.User
import com.quedrop.customer.network.ApiInterface
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import java.lang.Exception
import java.lang.NumberFormatException

class SupplierLoginViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    val tokenData: MutableLiveData<String> = MutableLiveData()
    val userData: MutableLiveData<User> = MutableLiveData()

    fun getNewTokenRequestApi(tokenRequest: TokenRequest) {
        try {
            apiService.getNewToken(tokenRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ tokenResponse ->
                    if (tokenResponse.status!!) {
                        tokenData.value = tokenResponse.tempToken
                    }
                }, {
                    Log.e("Error", it.toString())
                }).autoDispose(compositeDisposable)
        } catch (e: Exception) {
        }
    }

    fun loginUser(loginRequest: LoginRequest) {
        try {
            apiService.loginUSer(loginRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ loginResponse ->
                    if (loginResponse.status!!) {
                        userData.value = loginResponse.data?.user
                    } else {
                        errorMessage.value = loginResponse.message
                    }
                }, {
                    Log.e("error", it.toString())
                }).autoDispose(compositeDisposable)

        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }
    }
}