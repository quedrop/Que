package com.quedrop.customer.utils

import io.reactivex.Observable
import io.reactivex.subjects.PublishSubject

class RxBus private constructor() {
    private val publisher: PublishSubject<String> = PublishSubject.create()
    private val publisherData = PublishSubject.create<Any>()


    fun publish(event: String) {
        publisher.onNext(event)
    }

    // Listen should return an Observable
    fun listen(): Observable<String> {
        return publisher
    }

    fun publish(event: Any) {
        publisherData.onNext(event)
    }

    // Listen should return an Observable and not the publisher
    // Using ofType we filter only events that match that class type
    fun <T> listen(eventType: Class<T>): Observable<T> = publisherData.ofType(eventType)

    companion object {
        private var mInstance: RxBus? = null
        val instance: RxBus?
            get() {
                if (mInstance == null) {
                    mInstance = RxBus()
                }
                return mInstance
            }
    }
}