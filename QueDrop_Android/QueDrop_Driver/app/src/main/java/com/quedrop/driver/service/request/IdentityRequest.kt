package com.quedrop.driver.service.request

import okhttp3.MultipartBody
import okhttp3.RequestBody

data class IdentityRequest(

    val secret_key: RequestBody,
    val access_key: RequestBody,
    val userId: RequestBody,
    val vehicleType: RequestBody,
    val licencePhoto: MultipartBody.Part,
    val driverPhoto: MultipartBody.Part,
    val registrationProof: MultipartBody.Part,
    val numberPlate: MultipartBody.Part
)