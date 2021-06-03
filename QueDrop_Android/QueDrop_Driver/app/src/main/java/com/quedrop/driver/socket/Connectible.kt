package com.quedrop.driver.socket

import io.reactivex.Observable

interface Connectible {
    val isConnected: Boolean
    fun connect()
    fun connectionEmitter(): Observable<Unit>
    fun disconnect()
    fun disconnectEmitter(): Observable<Unit>
}