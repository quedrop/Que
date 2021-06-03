package com.quedrop.driver.viewModel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.quedrop.driver.service.ApiService
import com.quedrop.driver.service.model.FutureOrderDates
import com.quedrop.driver.service.model.MainOrderResponse
import com.quedrop.driver.service.model.Orders
import com.quedrop.driver.service.request.*
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers;


class MainViewModel(var apiService: ApiService) : BaseViewModel() {

    //1.0 Weekly Payment Request...
    val weeklyPaymentObserver: MutableLiveData<MainOrderResponse> = MutableLiveData()

    fun getWeeklyPaymentRequest(getWeeklyPaymentRequest: GetWeeklyPaymentRequest) {
        compositeDisposable.add(apiService.getDriverWeekleyPaymentDetail(getWeeklyPaymentRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .doOnSubscribe { isLoading.postValue(true) }
            .doOnDispose { isLoading.postValue(false) }
            .doOnError { isLoading.postValue(false) }
            .doOnSuccess { isLoading.postValue(false) }
            .subscribeOn(Schedulers.io())
            .subscribe({ it ->
                if (it.status) {
                    weeklyPaymentObserver.value = it
                } else {
                    isError.value = it.message
                }
            }, {
                isLoading.postValue(false)
            })
        )
    }


    //2.0 Manual Store Payment Request...
    val manualStorePaymentObserver: MutableLiveData<MainOrderResponse> = MutableLiveData()

    fun getManualStorePaymentRequest(getManualStorePaymentRequest: GetManualStorePaymentRequest) {
        compositeDisposable.add(apiService.getManualStorePaymentDetail(getManualStorePaymentRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .doOnSubscribe { isLoading.postValue(true) }
            .doOnDispose { isLoading.postValue(false) }
            .doOnError { isLoading.postValue(false) }
            .doOnSuccess { isLoading.postValue(false) }
            .subscribeOn(Schedulers.io())
            .subscribe({ it ->
                if (it.status) {
                    manualStorePaymentObserver.value = it
                } else {
                    isError.value = it.message
                }
            }, {
                isLoading.postValue(false)
            })
        )
    }


    //3.0 Earning data for home Request...

    val earningObserver: MutableLiveData<MainOrderResponse> = MutableLiveData()

    fun getEarningDataForHomeRequest(getManualStorePaymentRequest: GetManualStorePaymentRequest) {
        compositeDisposable.add(apiService.getEarningDataForHome(getManualStorePaymentRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .doOnSubscribe { isLoading.postValue(true) }
            .doOnDispose { isLoading.postValue(false) }
            .doOnError { isLoading.postValue(false) }
            .doOnSuccess { isLoading.postValue(false) }
            .subscribeOn(Schedulers.io())
            .subscribe({ it ->
                if (it.status) {
                    earningObserver.value = it
                } else {
                    isError.value = it.message
                }
            }, {
                isLoading.postValue(false)
            })
        )
    }


    //4.0 Current Order Request...
    val currentOrderList: MutableLiveData<MutableList<Orders>?> = MutableLiveData()

    fun getCurrentRequest(ordersRequest: OrdersRequest) {
        compositeDisposable.add(apiService.getCurrentAndPastOrder(ordersRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .doOnSubscribe { isLoading.postValue(true) }
            .doOnDispose { isLoading.postValue(false) }
            .doOnError { isLoading.postValue(false) }
            .doOnSuccess { isLoading.postValue(false) }
            .subscribeOn(Schedulers.io())
            .subscribe({ it ->
                if (it.status!!) {
                    currentOrderList.value = it.data?.currentOrder
                } else {
                    isError.value = it.message
                }
            }, {
                isLoading.postValue(false)
            })
        )
    }

    //5.0 Past Order Request...

    val pastOrderList: MutableLiveData<MutableList<Orders>?> = MutableLiveData()

    fun getPastOrderRequest(ordersRequest: OrdersRequest) {
        compositeDisposable.add(apiService.getCurrentAndPastOrder(ordersRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .doOnSubscribe { isLoading.postValue(true) }
            .doOnDispose { isLoading.postValue(false) }
            .doOnError { isLoading.postValue(false) }
            .doOnSuccess { isLoading.postValue(false) }
            .subscribeOn(Schedulers.io())
            .subscribe({ it ->
                if (it.status!!) {
                    pastOrderList.value = it.data?.pastOrder
                } else {
                    isError.value = it.message
                }
            }, {
                isLoading.postValue(false)
            })
        )
    }


    //6.0 Rate and Review Request
    val ratingResponse: MutableLiveData<String> = MutableLiveData()

    fun giveRatingRequest(giveRateRequest: GiveRateRequest) {
        compositeDisposable.add(apiService.giveRateAndReview(giveRateRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .doOnSubscribe { isLoading.postValue(true) }
            .doOnDispose { isLoading.postValue(false) }
            .doOnError { isLoading.postValue(false) }
            .doOnSuccess { isLoading.postValue(false) }
            .subscribeOn(Schedulers.io())
            .subscribe({ it ->
                if (it.status) {
                    ratingResponse.value = it.message
                } else {
                    isError.value = it.message
                }
            }, {
                isLoading.postValue(false)
            })
        )
    }


    //7.0 Rate and Review Request
    val referralCodeResponse: MutableLiveData<String> = MutableLiveData()

    fun checkForValidReferralCode(checkForValidReferralCodeRequest: CheckForValidReferralCodeRequest) {
        compositeDisposable.add(apiService.checkForValidReferralCode(
            checkForValidReferralCodeRequest
        )
            .observeOn(AndroidSchedulers.mainThread())
            .doOnSubscribe { isLoading.postValue(true) }
            .doOnDispose { isLoading.postValue(false) }
            .doOnError { isLoading.postValue(false) }
            .doOnSuccess { isLoading.postValue(false) }
            .subscribeOn(Schedulers.io())
            .subscribe({ it ->
                if (it.status) {
                    referralCodeResponse.value = it.message
                } else {
                    isError.value = it.message
                }
            }, {
                isLoading.postValue(false)
            })
        )
    }

    //8.0 Future Order request

    val futureOrderList: MutableLiveData<MutableList<Orders>?> = MutableLiveData()

    fun getFutureOrderRequest(futureOrderRequest: GetFutureOrderRequest) {
        compositeDisposable.add(apiService.getFutureOrders(futureOrderRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .doOnSubscribe { isLoading.postValue(true) }
            .doOnDispose { isLoading.postValue(false) }
            .doOnError { isLoading.postValue(false) }
            .doOnSuccess { isLoading.postValue(false) }
            .subscribeOn(Schedulers.io())
            .subscribe({ it ->
                if (it.status!!) {
                    futureOrderList.value = it.data?.futureOrders
                } else {
                    isError.value = it.message
                }
            }, {
                isLoading.postValue(false)
            })
        )
    }

    //9.0 Future Single Order request

    val futureSingleOrderList: MutableLiveData<Orders> = MutableLiveData()

    fun getFutureSingleOrderRequest(getFutureSingleOrderRequest: GetFutureSingleOrderRequest) {
        compositeDisposable.add(apiService.getFutureSingleOrderDetail(getFutureSingleOrderRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .doOnSubscribe { isLoading.postValue(true) }
            .doOnDispose { isLoading.postValue(false) }
            .doOnError { isLoading.postValue(false) }
            .doOnSuccess { isLoading.postValue(false) }
            .subscribeOn(Schedulers.io())
            .subscribe({ it ->
                if (it.status) {
                    futureSingleOrderList.value = it.data.futureOrders
                } else {
                    isError.value = it.message
                }
            }, {
                isLoading.postValue(false)
                Log.e("FUTURE", "==>" + it.localizedMessage)
            })
        )
    }

    //10.0
    val futureOrderDateListObserver: MutableLiveData<MutableList<FutureOrderDates>> =
        MutableLiveData()

    fun getFutureOrderDatesRequest(getFutureOrderDatesRequest: GetFutureOrderDatesRequest) {
        compositeDisposable.add(apiService.getFutureOrderDates(getFutureOrderDatesRequest)
            .observeOn(AndroidSchedulers.mainThread())
            .doOnSubscribe { isLoading.postValue(true) }
            .doOnDispose { isLoading.postValue(false) }
            .doOnError { isLoading.postValue(false) }
            .doOnSuccess { isLoading.postValue(false) }
            .subscribeOn(Schedulers.io())
            .subscribe({ it ->
                if (it.status) {
                    futureOrderDateListObserver.value = it.data.futureOrderDates
                } else {
                    isError.value = it.message
                }
            }, {
                isLoading.postValue(false)
                Log.e("FUTURE", "==>" + it.localizedMessage)
            })
        )
    }
}