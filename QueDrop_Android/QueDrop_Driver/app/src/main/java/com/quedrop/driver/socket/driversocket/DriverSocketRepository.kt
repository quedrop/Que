package com.quedrop.driver.socket.driversocket

import com.quedrop.driver.socket.model.DriverStatusChangesResponse
import com.quedrop.driver.socket.model.DriverStatusRequest
import io.reactivex.Observable

class DriverSocketRepository(private val connectible: DriverConnectible) : DriverRepository {

    override fun getDriverStatus(driverStatusRequest: DriverStatusRequest): Observable<Boolean> {
        return connectible.getDriverStatus(driverStatusRequest)
            .map { it.isSuccess() && it.data?.isDriverOnline() == true }
    }

    override fun changeDriverStatus(driverStatusRequest: DriverStatusRequest): Observable<DriverStatusChangesResponse> {
        return connectible.changeDriverStatus(driverStatusRequest)
    }
}

interface DriverRepository {
    fun getDriverStatus(driverStatusRequest: DriverStatusRequest): Observable<Boolean>
    fun changeDriverStatus(driverStatusRequest: DriverStatusRequest): Observable<DriverStatusChangesResponse>
}