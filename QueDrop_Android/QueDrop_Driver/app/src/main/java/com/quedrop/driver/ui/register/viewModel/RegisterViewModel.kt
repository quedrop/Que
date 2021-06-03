package com.quedrop.driver.ui.register.viewModel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.driver.viewModel.BaseViewModel
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.service.ApiService
import com.quedrop.driver.service.model.GoogleMapDirection
import com.quedrop.driver.service.model.User
import com.quedrop.driver.service.request.*
import com.quedrop.driver.utils.ACCESS_KEY
import com.google.android.gms.maps.model.LatLng
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import retrofit2.http.Part

class RegisterViewModel(private val apiService: ApiService) : BaseViewModel() {

    val tokenData: MutableLiveData<String> = MutableLiveData()
    val errorMessage: MutableLiveData<String> = MutableLiveData()
    val userData: MutableLiveData<User> = MutableLiveData()
    val otpSendData: MutableLiveData<Boolean> = MutableLiveData()
    val verifyData: MutableLiveData<Boolean> = MutableLiveData()
    val identityData: MutableLiveData<Boolean> = MutableLiveData()
    val mapDirectionData: MutableLiveData<GoogleMapDirection> = MutableLiveData()


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

    /*  fun registerUser(registerRequest: RegisterRequest) {
          apiService.registerUser(registerRequest)
              .observeOn(AndroidSchedulers.mainThread())
              .subscribeOn(Schedulers.io())
              .subscribe({ registerResponse ->
                  if (registerResponse.status!!) {
                      userData.value = registerResponse.data!!.user
                  } else {
                      errorMessage.value = registerResponse.message
                  }

              }, {

              }).autoDispose(compositeDisposable)

      }
  */

    fun registerUser(registerRequest: RegisterRequest) {
        apiService.registerUser(
            registerRequest.secret_key,
            registerRequest.access_key,
            registerRequest.user_image,
            registerRequest.firstname,
            registerRequest.lastname,
            registerRequest.password,
            registerRequest.login_as,
            registerRequest.referralCode,
            registerRequest.email,
            registerRequest.device_type,
            registerRequest.timezone,
            registerRequest.latitude,
            registerRequest.longitude,
            registerRequest.address
        )
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ registerResponse ->
                if (registerResponse.status!!) {
                    userData.value = registerResponse.data!!.user
                } else {
                    errorMessage.value = registerResponse.message
                }
            }, {

            }).autoDispose(compositeDisposable)

    }

    fun sendOTP(sendOTPRequest: SendOTPRequest) {
        try {
            apiService.sendOTP(sendOTPRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ OTPResponse ->
                    if (OTPResponse.status!!) {
                        otpSendData.value = true
                    } else {
                        errorMessage.value = OTPResponse.message
                    }

                }, {
                    Log.e("error", it.toString())
                }).autoDispose(compositeDisposable)

        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }
    }

    fun verifyOTP(verifyOTPRequest: VerifyOTPRequest) {
        apiService.verifyOTP(verifyOTPRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ OTPResponse ->
                if (OTPResponse.status!!) {
                    verifyData.value = true
                } else {
                    errorMessage.value = OTPResponse.message
                }

            }, {

            }).autoDispose(compositeDisposable)

    }

    fun updateIdentity(identityRequest: IdentityRequest) {
        apiService.updateIdentity(
            identityRequest.secret_key,
            identityRequest.access_key,
            identityRequest.userId,
            identityRequest.vehicleType,
            identityRequest.licencePhoto,
            identityRequest.driverPhoto,
            identityRequest.registrationProof,
            identityRequest.numberPlate
        )
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ identityResponse ->
                if (identityResponse.status!!) {
                    identityData.value = true
                    Log.e("UpdateIdentity", "==>")
                } else {
                    errorMessage.value = identityResponse.message
                    Log.e("UpdateIdentity", "==>err:" + errorMessage)
                }

            }, {
                Log.e("UpdateIdentity", "==>" + it)

            }).autoDispose(compositeDisposable)
    }

    fun forgotPassword(forgotPasswordRequest: ForgotPasswordRequest) {
        apiService.forgotPassword(forgotPasswordRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ forgotResponse ->
                if (forgotResponse.status!!) {
                    errorMessage.value = forgotResponse.message
                } else {
                    errorMessage.value = forgotResponse.message
                }

            }, {

            }).autoDispose(compositeDisposable)

    }

    fun getMapRoute(
        origin: String,
        destination: String,
        mapKey: String,
        wayPointsList: ArrayList<LatLng>
    ) {
        val viaPoint = StringBuilder()
        val data = HashMap<String, String>()
        data["origin"] = origin
        data["destination"] = destination
        for (points in wayPointsList) {
            viaPoint.append(
                points.latitude.toString().plus(",").plus(points.longitude.toString()).plus(
                    "|"
                )
            )
        }
        data["waypoints"] = viaPoint.toString()
        data["mode"] = "walk"
        data["key"] = mapKey

        Log.e("MapCalling", data.toString())
        apiService.getMapRoute(data)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribeOn(Schedulers.io())
            .subscribe({ mapData ->
                mapDirectionData.value = mapData
                // val jsonResponse = JSONObject(jsonResponse)
                //    val routes = jsonResponse.getJSONArray("routes")


            }, {
                Log.e("MapError", it.toString())
            }).autoDispose(compositeDisposable)

    }
}