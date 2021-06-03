package com.quedrop.driver.socket

interface SocketEventListener {

    fun onConnect()

    fun onConnectionError()

    fun onReconnect()

    fun onDisconnect()
}