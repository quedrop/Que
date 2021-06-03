package com.quedrop.customer.network

object ApiUtils {
    val BASE_URL = "http://34.204.81.189/quedrop/API/"

    val apiService: ApiInterface
        get() = AppService.setupRetrofit().create(ApiInterface::class.java)
}