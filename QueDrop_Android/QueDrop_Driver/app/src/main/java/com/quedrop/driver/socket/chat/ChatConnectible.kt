package com.quedrop.driver.socket.chat

import com.quedrop.driver.socket.Connectible
import com.quedrop.driver.socket.model.*
import io.reactivex.Completable
import io.reactivex.Observable

interface ChatConnectible : Connectible {
    fun joinSocket(socketRequest: SocketRequest): Completable
    fun fetchMessages(fetchMessageRequest: FetchMessageRequest): Observable<ChatMessageResponse>
    fun sendNewMessage(sendNewMessageRequest: SendMessageRequest): Observable<ChatMessageResponse>
    fun observeNewMessage(): Observable<ChatMessageResponse>
}