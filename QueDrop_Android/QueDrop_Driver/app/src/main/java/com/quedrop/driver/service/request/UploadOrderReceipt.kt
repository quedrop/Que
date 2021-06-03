package com.quedrop.driver.service.request

import okhttp3.MultipartBody
import okhttp3.RequestBody

data class UploadOrderReceipt(

    val orderId: RequestBody,
    val orderStoreId: RequestBody,
    val secretKey: RequestBody,
    val accessKey: RequestBody,
    val receipt: MultipartBody.Part,
    val userId: RequestBody,
    val billAmount: RequestBody

)
