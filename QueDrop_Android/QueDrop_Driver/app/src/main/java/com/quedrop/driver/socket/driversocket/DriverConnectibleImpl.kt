package com.quedrop.driver.socket.driversocket

import com.quedrop.driver.socket.SocketService
import com.quedrop.driver.socket.model.*
import io.reactivex.Observable
import org.json.JSONObject

class DriverConnectibleImpl(private val appSocket: SocketService) : DriverConnectible {

    private fun <T> Array<Any>.getResponse(clazz: Class<T>): T {
        return appSocket.getGson().fromJson(this[0].toString(), clazz)
    }

    private fun String.toJsonObject() = JSONObject(this)

    override fun getDriverStatus(driverStatusRequest: DriverStatusRequest): Observable<DriverStatusResponse> {
        return Observable.create<DriverStatusResponse> { emitter ->
            appSocket.requestWithAck(
                SocketService.EVENT_GET_DRIVER_WORKING_STATUS,
                appSocket.getGson().toJson(driverStatusRequest).toJsonObject(),
                emitter,
                DriverStatusResponse::class.java
            )
        }.share()
    }

    override fun changeDriverStatus(driverStatusRequest: DriverStatusRequest): Observable<DriverStatusChangesResponse> {
        return Observable.create<DriverStatusChangesResponse> { emitter ->
            appSocket.requestWithAck(
                SocketService.EVENT_CHANGE_DRIVER_WORKING_STATUS,
                appSocket.getGson().toJson(driverStatusRequest).toJsonObject(),
                emitter,
                DriverStatusChangesResponse::class.java
            )
        }.share()
    }
}