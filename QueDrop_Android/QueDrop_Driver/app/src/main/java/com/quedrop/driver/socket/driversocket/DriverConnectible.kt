package com.quedrop.driver.socket.driversocket

import com.quedrop.driver.socket.model.DriverStatusChangesResponse
import com.quedrop.driver.socket.model.DriverStatusRequest
import com.quedrop.driver.socket.model.DriverStatusResponse
import io.reactivex.Observable

interface DriverConnectible {
    fun getDriverStatus(driverStatusRequest: DriverStatusRequest): Observable<DriverStatusResponse>
    fun changeDriverStatus(driverStatusRequest: DriverStatusRequest): Observable<DriverStatusChangesResponse>
}