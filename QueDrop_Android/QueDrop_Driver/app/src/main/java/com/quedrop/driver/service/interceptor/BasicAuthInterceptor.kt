package com.quedrop.driver.service.interceptor

import okhttp3.Interceptor
import okhttp3.Response
import java.io.IOException

class BasicAuthInterceptor : Interceptor {

    @Throws(IOException::class)
    override fun intercept(chain: Interceptor.Chain): Response {

        val request = chain.request()
        val authenticatedRequest = request.newBuilder()
            .header("User-Agent", "Android").header("Content-Type","application/json") .method(request.method(), request.body()).build()
        return chain.proceed(authenticatedRequest)
    }
}