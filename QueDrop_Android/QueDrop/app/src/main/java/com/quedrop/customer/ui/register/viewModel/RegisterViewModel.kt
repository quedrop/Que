package com.quedrop.customer.ui.register.viewModel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.driver.socket.model.SocketRequest
import com.quedrop.customer.api.authentication.LoggedInUserCache
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.socket.chat.ChatRepository
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import timber.log.Timber
import java.lang.Exception
import java.lang.NumberFormatException

class RegisterViewModel(
    private val apiService: ApiInterface,
    private val loggedInUserCache: LoggedInUserCache? = null,
    private val chatRepository: ChatRepository? = null
) : BaseViewModel() {

    val tokenData: MutableLiveData<String> = MutableLiveData()
    val userData: MutableLiveData<User> = MutableLiveData()
    val otpSendData: MutableLiveData<Boolean> = MutableLiveData()
    val verifyData: MutableLiveData<Boolean> = MutableLiveData()
    val forgotData: MutableLiveData<Boolean> = MutableLiveData()
    val logOutData: MutableLiveData<Boolean> = MutableLiveData()

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
                    errorMessage.value = it.toString()
                    Log.e("Error", it.toString())
                }).autoDispose(compositeDisposable)
        } catch (e: Exception) {
        }
    }

    fun registerUser(registerRequest: Register) {
        try {
            apiService.registerUser(registerRequest.secret_key,
                registerRequest.access_key,
                registerRequest.user_image,
                registerRequest.firstname,
                registerRequest.lastname,
                registerRequest.password,
                registerRequest.login_as,
                registerRequest.referral_code,
                registerRequest.email,
                registerRequest.device_type,
                registerRequest.timezone,
                registerRequest.latitude,
                registerRequest.longitude,
                registerRequest.address)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ registerResponse ->
                    if (registerResponse.status) {
                        userData.value = registerResponse.data.user
                        loggedInUserCache?.setLoggedInUser(registerResponse.data.user)
                        loggedInUserCache?.getLoggedInUser()?.user_id?.let { userId ->
                            chatRepository?.joinSocket(SocketRequest(senderId = userId))?.subscribe({
                                Timber.i("joinSocket successfully called")
                            }, {
                                Timber.e(it)
                            })?.autoDispose()
                        }
                    } else {
                        errorMessage.value = registerResponse.message
                    }

                }, {
                    errorMessage.value = it.toString()
                    Log.e("Error", it.toString())
                }).autoDispose(compositeDisposable)
        } catch (e: Exception) {
        }

    }

    fun sendOTP(sendOTPRequest: SendOTPRequest) {
        try {
            apiService.sendOTP(sendOTPRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ OTPResponse ->
                    if (OTPResponse.status) {
                        otpSendData.value = true
                    } else {
                        errorMessage.value = OTPResponse.message
                    }

                }, {
                    errorMessage.value = it.toString()
                    Log.e("error", it.toString())
                }).autoDispose(compositeDisposable)

        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }
    }

    fun verifyOTP(verifyOTPRequest: VerifyOTPRequest) {

        try {
            apiService.verifyOTP(verifyOTPRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ OTPResponse ->
                    if (OTPResponse.status) {
                        verifyData.value = true
                        userData.value = OTPResponse.data.user
                    } else {
                        errorMessage.value = OTPResponse.message
                    }

                }, {
                    errorMessage.value = it.toString()
                    Log.e("error", it.toString())
                }).autoDispose(compositeDisposable)

        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }
    }

    fun forgotPasswordApi(forgotPasswordRequest: ForgotPasswordRequest) {

        try {
            apiService.forgotPassword(forgotPasswordRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ forgotResponse ->
                    if (forgotResponse.status!!) {
                        forgotData.value = true
                    } else {
                        errorMessage.value = forgotResponse.message
                    }

                }, {
                    errorMessage.value = it.toString()
                    Log.e("error", it.toString())
                }).autoDispose(compositeDisposable)

        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }

    }

    //7.0 Rate and Review Request

    val referralCodeResponse: MutableLiveData<String> = MutableLiveData()

    fun checkForValidReferralCode(checkForValidReferralCodeRequest: CheckForValidReferralCodeRequest) {
        compositeDisposable.add(apiService.checkForValidReferralCode(checkForValidReferralCodeRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .doOnSubscribe { isLoading.postValue(true) }
            .doOnDispose { isLoading.postValue(false) }
            .doOnError { isLoading.postValue(false) }
            .doOnSuccess { isLoading.postValue(false) }
            .subscribeOn(Schedulers.io())
            .subscribe { it ->
                if (it.status) {
                    referralCodeResponse.value = it.message
                } else {
                    errorMessage.value = it.toString()
                }
            })
    }


}