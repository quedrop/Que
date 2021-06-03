package com.quedrop.customer.network

data class ResponseHandler(
    var status: Boolean,
    var message: String,
    var data: ResponseWrapper
)

data class GenieResponse<T>(
    val data: Map<String, T>? = null,
    val status: Boolean,
    val message: String
)

data class GenieResponseWrapper<T>(
    val data: T? = null,
    var status: Boolean,
    var message: String
)