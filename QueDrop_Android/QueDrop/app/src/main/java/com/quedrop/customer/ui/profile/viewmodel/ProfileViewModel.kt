package com.quedrop.customer.ui.profile.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.*
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.network.GenieResponse
import com.google.gson.JsonObject
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import okhttp3.MultipartBody
import okhttp3.RequestBody
import java.lang.NumberFormatException

class ProfileViewModel(
    private val apiService: ApiInterface
) : BaseViewModel() {
    val logOutData: MutableLiveData<Boolean> = MutableLiveData()
    val editProfileData: MutableLiveData<Boolean> = MutableLiveData()
    val editProfileMessage :MutableLiveData<String> = MutableLiveData()
    val changePasswordMessage: MutableLiveData<String> = MutableLiveData()
    val rateReviewList: MutableLiveData<List<RateReviewResponse>> = MutableLiveData()
    val user: MutableLiveData<User> = MutableLiveData()
    val storeDetail: MutableLiveData<SupplierStoreDetail> = MutableLiveData()

    fun logOutApiCall(logOutRequest: LogOutRequest) {

        try {
            apiService.logOut(logOutRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ forgotResponse ->
                    if (forgotResponse.status) {
                        logOutData.value = true
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


    fun changePasswordApiCall(changePasswordRequest: ChangePasswordRequest) {

        try {
            apiService.changePassword(changePasswordRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ changePasswordResponse ->
                    if (changePasswordResponse.status) {
                        changePasswordMessage.value = changePasswordResponse.message
                    } else {
                        errorMessage.value = changePasswordResponse.message
                    }

                }, {
                    errorMessage.value = it.toString()
                    Log.e("error", it.toString())
                }).autoDispose(compositeDisposable)

        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }

    }

    fun ratingReviewApi(rateReviewDriverRequest: RateReviewDriverRequest) {

        try {
            apiService.getRatingReview(rateReviewDriverRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ rateReviewResponse ->
                    if (rateReviewResponse.status) {
                        rateReviewList.value = rateReviewResponse.data.reviews
                    } else {
                        errorMessage.value = rateReviewResponse.message
                    }

                }, {
                    errorMessage.value = it.toString()
                    Log.e("error", it.toString())
                }).autoDispose(compositeDisposable)

        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }

    }

    fun getUserProfileApi(getUserProfileDetailRequest: GetUserProfileDetailRequest) {

        try {
            apiService.getUserProfileDetail(getUserProfileDetailRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ userProfileResponse ->
                    if (userProfileResponse.status) {
                        user.value = userProfileResponse.data.user
                    } else {
                        errorMessage.value = userProfileResponse.message
                    }

                }, {
                    errorMessage.value = it.toString()
                    Log.e("error", it.toString())
                }).autoDispose(compositeDisposable)

        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }

    }

    fun editEmailProfileApi(
        userId: RequestBody,
        userName: RequestBody,
        secretKey: RequestBody,
        accessKey: RequestBody,
        userImage: MultipartBody.Part?,
        firstNameRequest: RequestBody,
        lastNameRequest: RequestBody,
        loginAsRequest: RequestBody,
        countryCodeRequest: RequestBody,
        phoneNumberRequest: RequestBody,
        emailRequest: RequestBody
    ) {
        apiService.editEmailProfile(
            userId,
            userName,
            secretKey,
            accessKey,
            userImage,
            firstNameRequest,
            lastNameRequest,
            loginAsRequest,
            countryCodeRequest,
            phoneNumberRequest,
            emailRequest
        )
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ editProfileResponse ->

                if (editProfileResponse.status) {
                    editProfileData.value = true
                    editProfileMessage.value = editProfileResponse.message
                } else {
                    errorMessage.value = editProfileResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun editProfileApi(
        userId: RequestBody,
        userName: RequestBody,
        secretKey: RequestBody,
        accessKey: RequestBody,
        userImage: MultipartBody.Part?,
        firstNameRequest: RequestBody,
        lastNameRequest: RequestBody,
        loginAsRequest: RequestBody,
        countryCodeRequest: RequestBody,
        phoneNumberRequest: RequestBody
    ) {
        apiService.editProfile(
            userId,
            userName,
            secretKey,
            accessKey,
            userImage,
            firstNameRequest,
            lastNameRequest,
            loginAsRequest,
            countryCodeRequest,
            phoneNumberRequest
        )
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ editProfileResponse ->

                if (editProfileResponse.status) {
                    editProfileData.value = true
                    editProfileMessage.value = editProfileResponse.message
                } else {
                    errorMessage.value = editProfileResponse.message
                }
            }, {
                errorMessage.value = it.toString()
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }

    fun getStoreDetails(jsonObject: JsonObject): Single<GenieResponse<SupplierStoreDetail>> {
        return apiService.getStoreDetailsSupplier(jsonObject)
    }
}