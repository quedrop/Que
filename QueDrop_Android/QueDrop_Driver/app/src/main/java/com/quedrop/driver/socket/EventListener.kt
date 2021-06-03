package com.quedrop.driver.socket

import org.json.JSONObject

interface EventListener {
    fun getNewEvent(event: String, argument: JSONObject) {}
    fun setEventListener(eventListener: EventListener){}

}