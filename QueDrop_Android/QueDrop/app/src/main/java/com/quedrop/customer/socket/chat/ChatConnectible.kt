package com.quedrop.customer.socket.chat

import com.quedrop.driver.socket.model.*
import com.quedrop.customer.socket.Connectible
import com.quedrop.customer.socket.model.ChatMessageResponse
import com.quedrop.customer.socket.model.FetchMessageRequest
import com.quedrop.customer.socket.model.SendMessageRequest
import io.reactivex.Completable
import io.reactivex.Observable

interface ChatConnectible : Connectible {
    fun joinSocket(socketRequest: SocketRequest): Completable
    fun fetchMessages(fetchMessageRequest: FetchMessageRequest): Observable<ChatMessageResponse>
    fun sendNewMessage(sendNewMessageRequest: SendMessageRequest): Observable<ChatMessageResponse>
    fun observeNewMessage(): Observable<ChatMessageResponse>
}