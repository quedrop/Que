package com.quedrop.driver.base.network

import androidx.annotation.Keep


object NoNetworkException : Exception()

@Keep
data class UnsuccessfulResponseException(val url: String, val code: Int) :
        Exception("Request $url failed with code $code")

@Keep
data class ResponseParseFailureException(val url: String) :
        Exception("Failed to parse result for $url")