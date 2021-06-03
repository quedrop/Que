package com.quedrop.driver.service.request

import com.google.gson.annotations.SerializedName

class DeleteBankDetailRequest(

    @SerializedName("secret_key")
    var secret_key: String,

    @SerializedName("access_key")
    var access_key: String,

    @SerializedName("bank_detail_id")
    var bank_detail_id: Int,

    @SerializedName("user_id")
    var user_id: Int

)