package com.quedrop.driver.service.request

import okhttp3.MultipartBody
import okhttp3.RequestBody

data class EditProfileRequest(

    val userId: RequestBody,
    val userName: RequestBody,
    val secretKey: RequestBody,
    val accessKey: RequestBody,
    val userImage: MultipartBody.Part,
    val loginAs: RequestBody,
    val firstName: RequestBody,
    val lastName: RequestBody,
    val countryCode: RequestBody,
    val phone_number: RequestBody,
    val version: RequestBody

)