package com.quedrop.driver.socket.chat

import com.quedrop.driver.socket.model.ChatMessageResponse
import com.quedrop.driver.socket.model.FetchMessageRequest
import com.quedrop.driver.socket.model.SendMessageRequest
import com.quedrop.driver.socket.model.SocketRequest
import io.reactivex.Completable
import io.reactivex.Observable


class ChatSocketRepository(private val connectible: ChatConnectible) : ChatRepository {

    override fun joinSocket(socketRequest: SocketRequest) =
        connectible.joinSocket(socketRequest)

    override fun sendNewMessage(sendNewMessageRequest: SendMessageRequest) =
        connectible.sendNewMessage(sendNewMessageRequest)

    override fun fetchMessages(fetchMessageRequest: FetchMessageRequest) =
        connectible.fetchMessages(fetchMessageRequest)

    override fun observeNewMessage(): Observable<ChatMessageResponse> =
        connectible.observeNewMessage()

    override fun disconnect() = connectible.disconnect()

    override fun connectionEmitter(): Observable<Unit> = connectible.connectionEmitter()

    override fun disconnectEmitter(): Observable<Unit> = connectible.disconnectEmitter()
}

interface ChatRepository {
    fun joinSocket(socketRequest: SocketRequest): Completable
    fun sendNewMessage(sendNewMessageRequest: SendMessageRequest): Observable<ChatMessageResponse>
    fun fetchMessages(fetchMessageRequest: FetchMessageRequest): Observable<ChatMessageResponse>
    fun observeNewMessage(): Observable<ChatMessageResponse>
    fun disconnect()
    fun connectionEmitter(): Observable<Unit>
    fun disconnectEmitter(): Observable<Unit>
}