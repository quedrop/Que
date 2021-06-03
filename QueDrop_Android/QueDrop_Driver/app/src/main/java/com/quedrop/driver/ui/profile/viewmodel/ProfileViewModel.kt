package com.quedrop.driver.ui.profile.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.driver.viewModel.BaseViewModel
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.service.ApiService
import com.quedrop.driver.service.model.BankDetails
import com.quedrop.driver.service.model.DriverDetails
import com.quedrop.driver.service.model.RateAndReviews
import com.quedrop.driver.service.model.User
import com.quedrop.driver.service.request.*
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class ProfileViewModel(
    private val apiService: ApiService
) : BaseViewModel() {
    val logOutData: MutableLiveData<Boolean> = MutableLiveData()
    val changePasswordMessage: MutableLiveData<String> = MutableLiveData()
    val rateReviewList: MutableLiveData<List<RateAndReviews>> = MutableLiveData()
    val identityDetails: MutableLiveData<DriverDetails> = MutableLiveData()
    val bankDetails: MutableLiveData<List<BankDetails>> = MutableLiveData()
    val errorMessage: MutableLiveData<String> = MutableLiveData()
    val message: MutableLiveData<String> = MutableLiveData()

    val editProfileData: MutableLiveData<Boolean> = MutableLiveData()
    val editProfileMessage: MutableLiveData<String> = MutableLiveData()
    val userData: MutableLiveData<User> = MutableLiveData()

    fun logOutApiCall(logOutRequest: LogOutRequest) {

        try {
            apiService.logOut(logOutRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ forgotResponse ->
                    if (forgotResponse.status!!) {
                        logOutData.value = true
                    } else {
                        errorMessage.value = forgotResponse.message
                    }

                }, {
                    Log.e("error", it.toString())
                }).autoDispose(compositeDisposable)

        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }

    }

    fun getUserProfileDetail(rateReviewDriverRequest: RateReviewDriverRequest) {

        try {
            apiService.getUserProfileDetail(rateReviewDriverRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ userProfile ->
                    if (userProfile.status!!) {
                        logOutData.value = true
                        userData.value = userProfile.data?.user

                    } else {
                        errorMessage.value = userProfile.message
                    }

                }, {
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
                    if (changePasswordResponse.status!!) {
                        changePasswordMessage.value = changePasswordResponse.message
                    } else {
                        errorMessage.value = changePasswordResponse.message
                    }

                }, {
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
                    if (rateReviewResponse.status!!) {
                        rateReviewList.value = rateReviewResponse.data?.reviews
                    } else {
                        errorMessage.value = rateReviewResponse.message
                    }

                }, {
                    Log.e("error", it.toString())
                }).autoDispose(compositeDisposable)

        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }

    }


    fun getIdentityDetails(rateReviewDriverRequest: RateReviewDriverRequest) {

        try {
            apiService.getIndentityDetails(rateReviewDriverRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ rateReviewResponse ->
                    if (rateReviewResponse.status!!) {
                        identityDetails.value = rateReviewResponse.data?.driverDetail
                    } else {
                        errorMessage.value = rateReviewResponse.message
                    }

                }, {
                    Log.e("error", it.toString())
                }).autoDispose(compositeDisposable)

        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }

    }

    fun getBankDetails(rateReviewDriverRequest: RateReviewDriverRequest) {

        try {
            apiService.getBankDetails(rateReviewDriverRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ bankDetailsResponse ->
                    if (bankDetailsResponse.status!!) {
                        bankDetails.value = bankDetailsResponse.bankData?.bankDetails
                    } else {
                        errorMessage.value = bankDetailsResponse.message
                    }

                }, {
                    Log.e("error", it.toString())
                }).autoDispose(compositeDisposable)

        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }

    }

    fun deleteBankDetail(deleteBankDetailRequest: DeleteBankDetailRequest) {

        try {
            apiService.deleteBanksDetail(deleteBankDetailRequest)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe({ bankDetailsResponse ->
                    if (bankDetailsResponse.status!!) {
                        message.value = bankDetailsResponse.message
                    } else {
                        errorMessage.value = bankDetailsResponse.message
                    }

                }, {
                    Log.e("error", it.toString())
                }).autoDispose(compositeDisposable)

        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }

    }

    fun editProfileApi(
        editProfileRequest: EditProfileRequest
    ) {
        apiService.editProfile(
            editProfileRequest.userId,
            editProfileRequest.userName,
            editProfileRequest.secretKey,
            editProfileRequest.accessKey,
            editProfileRequest.userImage,
            editProfileRequest.firstName,
            editProfileRequest.lastName,
            editProfileRequest.loginAs,
            editProfileRequest.countryCode,
            editProfileRequest.phone_number,
            editProfileRequest.version
        )
            .observeOn(AndroidSchedulers.mainThread()).subscribeOn(Schedulers.io())
            .subscribe({ editProfileResponse ->

                if (editProfileResponse.status!!) {
                    editProfileData.value = true
                    userData.value = editProfileResponse.data?.user
                    editProfileMessage.value = editProfileResponse.message
                } else {
                    errorMessage.value = editProfileResponse.message
                }
            }, {
                Log.e("Error", it.toString())
            }).autoDispose(compositeDisposable)
    }


}