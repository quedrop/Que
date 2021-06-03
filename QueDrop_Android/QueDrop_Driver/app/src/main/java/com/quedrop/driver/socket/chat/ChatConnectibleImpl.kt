package com.quedrop.driver.socket.chat

import com.quedrop.driver.socket.SocketService
import com.quedrop.driver.socket.model.*
import io.reactivex.Observable
import io.socket.emitter.Emitter
import org.json.JSONObject

class ChatConnectibleImpl(private val appSocket: SocketService) :
    ChatConnectible {

    override val isConnected: Boolean
        get() = appSocket.isConnected

    private val connectionEmitter by lazy {
        Observable.create<Unit> { emitter ->
            appSocket.on(SocketService.EVENT_CONNECT, Emitter.Listener {
                emitter.onNext(Unit)
            })
        }.share()
    }

    private val disconnectEmitter by lazy {
        Observable.create<Unit> { emitter ->
            appSocket.on(SocketService.EVENT_DISCONNECT, Emitter.Listener {
                emitter.onNext(Unit)
            })
        }.share()
    }

    private val observeNewMessage by lazy {
        Observable.create<ChatMessageResponse> { emitter ->
            appSocket.on(SocketService.EVENT_GET_NEW_MESSAGE, Emitter.Listener {
                emitter.onNext(it.getResponse(ChatMessageResponse::class.java))
            })
        }.share()
    }

    private fun <T> Array<Any>.getResponse(clazz: Class<T>): T {
        return appSocket.getGson().fromJson(this[0].toString(), clazz)
    }

    private fun String.toJsonObject() = JSONObject(this)

    override fun connect() = appSocket.connect()

    override fun connectionEmitter(): Observable<Unit> = connectionEmitter

    override fun disconnect() = appSocket.disconnect()

    override fun disconnectEmitter(): Observable<Unit> = disconnectEmitter

    override fun observeNewMessage(): Observable<ChatMessageResponse> = observeNewMessage


    override fun joinSocket(socketRequest: SocketRequest) = appSocket.request(
        SocketService.EVENT_JOIN_SOCKET,
        appSocket.getGson().toJson(socketRequest).toJsonObject()
    )

    override fun fetchMessages(fetchMessageRequest: FetchMessageRequest): Observable<ChatMessageResponse> {
        return Observable.create<ChatMessageResponse> { emitter ->
            appSocket.requestWithAck(
                SocketService.EVENT_FETCH_MESSAGE,
                appSocket.getGson().toJson(fetchMessageRequest).toJsonObject(),
                emitter,
                ChatMessageResponse::class.java
            )
        }.share()
    }

    override fun sendNewMessage(sendNewMessageRequest: SendMessageRequest): Observable<ChatMessageResponse> {
        return Observable.create<ChatMessageResponse> { emitter ->
            appSocket.requestWithAck(
                SocketService.EVENT_SEND_NEW_MESSAGE,
                appSocket.getGson().toJson(sendNewMessageRequest).toJsonObject(),
                emitter,
                ChatMessageResponse::class.java
            )
        }.share()
    }
}