package com.quedrop.driver.socket.model

import com.google.gson.annotations.SerializedName

data class DriverStatusResponse(

    @field:SerializedName("data")
    val data: DriverStatusData? = null,

    @field:SerializedName("status")
    val status: Int? = null
) {
    fun isSuccess(): Boolean {
        return status == 1
    }
}

data class DriverStatusData(
    @field:SerializedName("user_id")
    val userId: Int? = null,

    @field:SerializedName("is_driver_verified")
    val isDriverVerified: Int? = null,

    @field:SerializedName("driver_status")
    val driverStatus: Int? = null
) {
    fun isDriverOnline(): Boolean {
        return driverStatus == 1
    }
}

data class DriverStatusChangesResponse(
    @field:SerializedName("status")
    val status: Int? = null,

    @field:SerializedName("message")
    val message: String? = null,

    @field:SerializedName("is_online")
    val isOnline: Int? = null
) {
    fun isSuccess(): Boolean {
        return status == 1
    }
    fun isDriverOnline(): Boolean {
        return isOnline == 1
    }
}

data class DriverStatusRequest(
    @field:SerializedName("user_id")
    val userId: Int = 0,

    @field:SerializedName("is_online")
    val isOnline: Int = 0
)