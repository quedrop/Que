package com.quedrop.driver.service.model

import com.google.gson.annotations.SerializedName


class IdentityResponse {
    @SerializedName("status")
    val status: Boolean? = null

    @SerializedName("message")
    val message: String? = null

    @SerializedName("data")
    val data: IdentityData? = null
}

class IdentityData {
    @SerializedName("driver_detail")
    val driverDetail: DriverDetails? = null
}

class DriverDetails {

    @SerializedName("identity_id")
    val identityId: Int? = null

    @SerializedName("user_id")
    val userId: Int? = null

    @SerializedName("vehicle_type")
    val vehicleType: String? = null

    @SerializedName("driver_photo")
    val driverPhoto: String? = null

    @SerializedName("licence_photo")
    val licencePhoto: String? = null

    @SerializedName("registration_proof")
    val registrationProof: String? = null

    @SerializedName("number_plate")
    val numberPlate: String? = null


}