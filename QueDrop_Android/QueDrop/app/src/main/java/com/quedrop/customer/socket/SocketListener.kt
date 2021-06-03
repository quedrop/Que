package com.quedrop.customer.socket

import org.json.JSONObject

interface SocketListener {
    fun isSocketConnected(connected: Boolean)
    fun onEvent(event: String, arg0: JSONObject)
}