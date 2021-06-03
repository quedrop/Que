package com.quedrop.driver.ui.login.viewModel

import androidx.lifecycle.MutableLiveData
import com.quedrop.driver.api.authentication.LoggedInUserCache
import com.quedrop.driver.viewModel.BaseViewModel
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.service.ApiService
import com.quedrop.driver.service.model.User
import com.quedrop.driver.service.request.LoginRequest
import com.quedrop.driver.service.request.SocialRegisterRequest
import com.quedrop.driver.service.request.TokenRequest
import com.quedrop.driver.socket.chat.ChatRepository
import com.quedrop.driver.socket.model.SocketRequest
import com.quedrop.driver.utils.ACCESS_KEY
import com.quedrop.driver.utils.KEY_USERID
import com.quedrop.driver.utils.SharedPreferenceUtils
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class LoginViewModel(
    private val apiService: ApiService,
    private val loggedInUserCache: LoggedInUserCache,
    private val chatRepository: ChatRepository
) : BaseViewModel() {

    val tokenData: MutableLiveData<String> = MutableLiveData()
    val errorMessage: MutableLiveData<String> = MutableLiveData()
    val userData: MutableLiveData<User> = MutableLiveData()
    val userAvailableStatus: MutableLiveData<Boolean> = MutableLiveData()

    fun getNewToken() {
        apiService.getNewToken(TokenRequest(ACCESS_KEY))
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ tokenResponse ->
                if (tokenResponse.status!!) {
                    tokenData.value = tokenResponse.tempToken
                }
            }, {

            }).autoDispose(compositeDisposable)

    }

    fun loginUser(loginRequest: LoginRequest) {
        apiService.loginUSer(loginRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ loginResponse ->
                if (loginResponse.status!!) {
                    userData.value = loginResponse.data!!.user
                    SharedPreferenceUtils.setInt(
                        KEY_USERID,
                        loginResponse.data!!.user?.userId!!
                    )
                    loggedInUserCache.setLoggedInUser(loginResponse.data?.user)
                    loggedInUserCache.getLoggedInUser()?.userId?.let { userId ->
                        chatRepository.joinSocket(SocketRequest(senderId = userId))
                    }
                } else {
                    errorMessage.value = loginResponse.message
                }
            }, {

            }).autoDispose(compositeDisposable)

    }

    fun registerSocialUser(socialRegisterRequest: SocialRegisterRequest) {
        apiService.socialRegister(socialRegisterRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ loginResponse ->
                if (loginResponse.status!!) {
                    if (loginResponse.data!!.isUserAvailable == 0) {
                        userAvailableStatus.value = false
                    } else {
                        loggedInUserCache.setLoggedInUser(loginResponse.data?.user)
                        userData.value = loginResponse.data!!.user
                        loggedInUserCache.getLoggedInUser()?.userId?.let { userId ->
                            chatRepository.joinSocket(SocketRequest(senderId = userId))
                        }
                    }
                } else {
                    errorMessage.value = loginResponse.message
                }
            }, {

            }).autoDispose(compositeDisposable)
    }


}