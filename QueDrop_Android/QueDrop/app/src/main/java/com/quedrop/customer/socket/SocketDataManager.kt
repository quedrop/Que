package com.quedrop.customer.socket

import com.quedrop.driver.socket.SocketEventListener
import com.quedrop.customer.socket.chat.ChatRepository
import timber.log.Timber

class SocketDataManager(private val chatRepository: ChatRepository) : SocketEventListener {

    override fun onConnect() {
        Timber.i("Socket onConnect")
    }

    override fun onConnectionError() {

    }

    override fun onReconnect() {

    }

    override fun onDisconnect() {
        Timber.i("Socket onDisconnect")
    }

    fun onAppDestroy() {
        chatRepository.disconnect()
    }

    fun getChatRepository(): ChatRepository = chatRepository
}