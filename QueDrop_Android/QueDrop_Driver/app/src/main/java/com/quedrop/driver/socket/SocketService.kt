package com.quedrop.driver.socket

import com.quedrop.driver.base.rxjava.onSafeNext
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import io.reactivex.Completable
import io.reactivex.ObservableEmitter
import io.socket.client.Ack
import io.socket.client.IO
import io.socket.client.Socket
import io.socket.emitter.Emitter

class SocketService {

    private lateinit var socket: Socket
    private var gson: Gson = GsonBuilder().create()

    init {
        startListening()
    }

    val isConnected: Boolean get() = socket.connected()

    private fun startListening() {
        socket = IO.socket(SOCKET_URL)
        connect()
    }

    fun stopListening() {
        disconnect()
    }

    fun connect() {
        if (!isConnected)
            socket.connect()
    }

    fun disconnect() {
        socket.disconnect()
    }

    fun getGson() = gson

    companion object {
//        const val SOCKET_URL = "http://clientapp.narola.online:8081"
        const val SOCKET_URL = "http://34.204.81.189:30080"
        const val EVENT_CONNECT = Socket.EVENT_CONNECT
        const val EVENT_DISCONNECT = Socket.EVENT_DISCONNECT
        const val EVENT_JOIN_SOCKET = "join_socket"
        const val EVENT_GET_DRIVER_WORKING_STATUS = "getDriverWorkingStatus"
        const val EVENT_CHANGE_DRIVER_WORKING_STATUS = "changeDriverWorkingStatus"
        const val EVENT_FETCH_MESSAGE = "fetch_messages"
        const val EVENT_SEND_NEW_MESSAGE = "send_new_message"
        const val EVENT_GET_NEW_MESSAGE = "get_new_message"
    }

    fun request(name: String, any: Any): Completable =
        if (isConnected) {
            Completable.fromCallable {
                socket.emit(name, any)
            }
        } else {
            Completable.error(SocketNotConnectedException())
        }

    fun on(name: String, listener: Emitter.Listener) {
        socket.on(name, listener)
    }

    fun <T> requestWithAck(name: String, any: Any, emitter: ObservableEmitter<T>, clazz: Class<T>) {
        if (isConnected)
            socket.emit(name, any, SocketAck(emitter, gson, clazz))
    }
}

class SocketNotConnectedException : Throwable()

class SocketAck<T>(
    private val emitter: ObservableEmitter<T>,
    private val gson: Gson,
    private val clazz: Class<T>
) : Ack {
    override fun call(vararg args: Any?) {
        emitter.onSafeNext(gson.fromJson(args[0].toString(), clazz))
    }
}