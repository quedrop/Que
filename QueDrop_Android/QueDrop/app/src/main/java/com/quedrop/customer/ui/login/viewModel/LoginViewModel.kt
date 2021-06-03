package com.quedrop.customer.ui.login.viewModel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.driver.socket.model.SocketRequest
import com.quedrop.customer.api.authentication.LoggedInUserCache
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.LoginRequest
import com.quedrop.customer.model.SocialRegisterRequest
import com.quedrop.customer.model.TokenRequest
import com.quedrop.customer.model.User
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.socket.chat.ChatRepository
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import timber.log.Timber
import java.lang.Exception
import java.lang.NumberFormatException

class LoginViewModel(
    private val apiService: ApiInterface,
    private val loggedInUserCache: LoggedInUserCache,
    private val chatRepository: ChatRepository
) : BaseViewModel() {

    val tokenData: MutableLiveData<String> = MutableLiveData()
    val userData: MutableLiveData<User> = MutableLiveData()
    val userAvailableStatus: MutableLiveData<Boolean> = MutableLiveData()

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

    fun loginUser(loginRequest: LoginRequest) {
        try {
            apiService.loginUSer(loginRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ loginResponse ->
                    if (loginResponse.status!!) {
                        userData.value = loginResponse.data?.user
                        loggedInUserCache.setLoggedInUser(loginResponse.data?.user)
                        loggedInUserCache.getLoggedInUser()?.user_id?.let { userId ->
                            chatRepository.joinSocket(SocketRequest(senderId = userId)).subscribe({
                                Timber.i("joinSocket successfully called")
                            }, {
                                Timber.e(it)
                            }).autoDispose()
                        }
                    } else {
                        errorMessage.value = loginResponse.message
                    }
                }, {
                    errorMessage.value = it.toString()
                    Log.e("error", it.toString())
                }).autoDispose(compositeDisposable)

        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }
    }

    fun registerSocialUser(socialRegisterRequest: SocialRegisterRequest) {
        apiService.socialRegister(socialRegisterRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ loginResponse ->
                if (loginResponse.status) {
                    if (loginResponse.data.isUserAvailable == 0) {
                        userAvailableStatus.value = false
                    } else {
                        userData.value = loginResponse.data.user
                        loggedInUserCache.setLoggedInUser(loginResponse.data.user)
                        loggedInUserCache.getLoggedInUser()?.user_id?.let { userId ->
                            chatRepository.joinSocket(SocketRequest(senderId = userId)).subscribe({
                                Timber.i("joinSocket successfully called")
                            }, {
                                Timber.e(it)
                            }).autoDispose()
                        }
                    }
                } else {
                    errorMessage.value = loginResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }


}