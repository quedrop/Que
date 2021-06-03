package com.quedrop.driver.ui.orderDetailsFragment.view

import io.reactivex.Observable
import io.reactivex.subjects.PublishSubject

class OrderDetailObserver {

    companion object {
        val itemReceiptClickResult: PublishSubject<OrderObserverModel> = PublishSubject.create()
        var itemReceiptClick: Observable<OrderObserverModel> = itemReceiptClickResult.hide()


        val itemReceiptRemoveClickResult: PublishSubject<OrderObserverModel> = PublishSubject.create()
        var itemRemoveReceiptClick: Observable<OrderObserverModel> = itemReceiptRemoveClickResult.hide()
    }

}