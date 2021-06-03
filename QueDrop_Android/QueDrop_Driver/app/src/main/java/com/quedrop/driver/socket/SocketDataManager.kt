package com.quedrop.driver.socket

import com.quedrop.driver.socket.chat.ChatRepository
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